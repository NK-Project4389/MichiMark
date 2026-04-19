import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:michi_mark/domain/master/member/member_domain.dart';
import 'package:michi_mark/domain/transaction/event/event_domain.dart';
import 'package:michi_mark/repository/impl/firebase/firebase_auth_repository.dart';
import 'package:michi_mark/repository/impl/firestore/firestore_event_repository.dart';
import 'package:michi_mark/repository/impl/firestore/firestore_member_repository.dart';
import 'package:michi_mark/repository/impl/firestore/firestore_migration_repository.dart';
import 'package:michi_mark/repository/impl/fake/fake_auth_repository.dart';
import 'package:michi_mark/repository/impl/in_memory/in_memory_member_repository.dart';
import 'package:michi_mark/repository/impl/in_memory/in_memory_event_repository.dart';
import 'package:michi_mark/repository/impl/in_memory/in_memory_trans_repository.dart';
import 'package:michi_mark/repository/impl/in_memory/in_memory_tag_repository.dart';
import 'package:michi_mark/repository/impl/in_memory/in_memory_action_repository.dart';
import 'package:michi_mark/repository/impl/in_memory/in_memory_topic_repository.dart';

void main() {
  group('Firebase基盤 Unit Test', () {
    // TC-INFRA-001: Anonymous AuthでUIDが発行される
    test('TC-INFRA-001: Anonymous AuthでUIDが発行される', () async {
      final mockAuth = MockFirebaseAuth();
      final authRepository = FirebaseAuthRepository(auth: mockAuth);

      // 未サインイン状態を確認
      expect(authRepository.currentUid, isNull);

      // signInAnonymously() を呼び出す
      final uid = await authRepository.signInAnonymously();

      // 発行されたUIDが空でないことを確認
      expect(uid, isNotEmpty);
      expect(authRepository.currentUid, equals(uid));
    });

    // TC-INFRA-002: 既存UIDがある場合は再発行しない
    test('TC-INFRA-002: 既存UIDがある場合は再発行しない', () async {
      // MockFirebaseAuthに既存ユーザーをセットして初期化
      final mockUser = MockUser(uid: 'existing-uid', isAnonymous: true);
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      final authRepository = FirebaseAuthRepository(auth: mockAuth);

      // 既にサインイン済みであることを確認
      expect(authRepository.currentUid, equals('existing-uid'));

      // signInAnonymously() を呼び出す
      final uid = await authRepository.signInAnonymously();

      // 既存のUIDが返されること（再発行されていない）
      expect(uid, equals('existing-uid'));
      expect(authRepository.currentUid, equals('existing-uid'));
    });

    // TC-INFRA-003: Apple Sign InでAnonymousアカウントにリンクできる
    test(
      'TC-INFRA-003: Apple Sign InでAnonymousアカウントにリンクできる',
      () {},
      skip: 'SignInWithApple はネイティブ呼び出しのためUnit Testでは実施不可',
    );

    // TC-INFRA-004: Firestoreにメンバーを保存・取得できる
    test('TC-INFRA-004: Firestoreにメンバーを保存・取得できる', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final now = DateTime.now();

      // テスト用メンバーを作成
      final memberDomain = MemberDomain(
        id: 'member-001',
        memberName: 'テストメンバー1',
        mailAddress: 'test1@example.com',
        isVisible: true,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );

      // FakeAuthRepositoryを初期化してサインイン
      final authRepository = FakeAuthRepository();
      await authRepository.signInAnonymously();

      // FirestoreMemberRepositoryを初期化
      final memberRepository = FirestoreMemberRepository(
        authRepository: authRepository,
        firestore: fakeFirestore,
      );

      // メンバーを保存
      await memberRepository.save(memberDomain);

      // メンバーを取得
      final allMembers = await memberRepository.fetchAll();

      // 保存したメンバーが取得できることを確認
      expect(allMembers, hasLength(1));
      expect(allMembers.first.id, equals('member-001'));
      expect(allMembers.first.memberName, equals('テストメンバー1'));
      expect(allMembers.first.mailAddress, equals('test1@example.com'));
      expect(allMembers.first.isVisible, isTrue);
      expect(allMembers.first.isDeleted, isFalse);
    });

    // TC-INFRA-005: Firestoreにイベントを保存・取得できる
    test('TC-INFRA-005: Firestoreにイベントを保存・取得できる', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final now = DateTime.now();

      // テスト用イベントを作成
      final eventDomain = EventDomain(
        id: 'event-001',
        eventName: 'テストイベント',
        members: [],
        tags: [],
        markLinks: [],
        payments: [],
        actionTimeLogs: [],
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );

      // FakeAuthRepositoryを初期化してサインイン
      final authRepository = FakeAuthRepository();
      await authRepository.signInAnonymously();

      // FirestoreEventRepositoryを初期化
      final eventRepository = FirestoreEventRepository(
        authRepository: authRepository,
        firestore: fakeFirestore,
      );

      // イベントを保存
      await eventRepository.save(eventDomain);

      // イベントを取得
      final allEvents = await eventRepository.fetchAll();

      // 保存したイベントが取得できることを確認
      expect(allEvents, hasLength(1));
      expect(allEvents.first.id, equals('event-001'));
      expect(allEvents.first.eventName, equals('テストイベント'));
      expect(allEvents.first.markLinks, isEmpty);
      expect(allEvents.first.payments, isEmpty);
      expect(allEvents.first.actionTimeLogs, isEmpty);
    });

    // TC-INFRA-006: driftからFirestoreへのデータ移行が完了する
    test('TC-INFRA-006: driftからFirestoreへのデータ移行が完了する', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final now = DateTime.now();

      // InMemoryリポジトリ（移行元）を初期化
      final sourceMemberRepository = InMemoryMemberRepository();
      final sourceEventRepository = InMemoryEventRepository();
      final sourceTransRepository = InMemoryTransRepository();
      final sourceTagRepository = InMemoryTagRepository();
      final sourceActionRepository = InMemoryActionRepository();
      final sourceTopicRepository = InMemoryTopicRepository();

      // 移行元データを準備
      final member1 = MemberDomain(
        id: 'member-001',
        memberName: 'メンバー1',
        isVisible: true,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );
      final member2 = MemberDomain(
        id: 'member-002',
        memberName: 'メンバー2',
        isVisible: true,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );
      final event = EventDomain(
        id: 'event-001',
        eventName: 'テストイベント',
        members: [],
        tags: [],
        markLinks: [],
        payments: [],
        actionTimeLogs: [],
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );
      await sourceMemberRepository.save(member1);
      await sourceMemberRepository.save(member2);
      await sourceEventRepository.save(event);

      // FakeAuthRepositoryでサインイン
      final authRepository = FakeAuthRepository();
      await authRepository.signInAnonymously();

      // FirestoreMigrationRepositoryを構築してmigrate()を呼ぶ
      final migrationRepository = FirestoreMigrationRepository(
        authRepository: authRepository,
        sourceEventRepository: sourceEventRepository,
        sourceMemberRepository: sourceMemberRepository,
        sourceTransRepository: sourceTransRepository,
        sourceTagRepository: sourceTagRepository,
        sourceActionRepository: sourceActionRepository,
        sourceTopicRepository: sourceTopicRepository,
        firestore: fakeFirestore,
      );

      // 移行前はisMigrationNeededがtrue
      expect(await migrationRepository.isMigrationNeeded(), isTrue);

      await migrationRepository.migrate();

      // Firestore側でデータが移行されていることを確認
      final firestoreMemberRepo = FirestoreMemberRepository(
        authRepository: authRepository,
        firestore: fakeFirestore,
      );
      final firestoreEventRepo = FirestoreEventRepository(
        authRepository: authRepository,
        firestore: fakeFirestore,
      );
      final migratedMembers = await firestoreMemberRepo.fetchAll();
      final migratedEvents = await firestoreEventRepo.fetchAll();

      expect(migratedMembers, hasLength(2));
      expect(migratedEvents, hasLength(1));
      expect(migratedEvents.first.id, equals('event-001'));
    });

    // TC-INFRA-007: 移行完了後にschemaVersionが更新される
    test('TC-INFRA-007: 移行完了後にschemaVersionが更新される', () async {
      final fakeFirestore = FakeFirebaseFirestore();

      final sourceMemberRepository = InMemoryMemberRepository();
      final sourceEventRepository = InMemoryEventRepository();
      final sourceTransRepository = InMemoryTransRepository();
      final sourceTagRepository = InMemoryTagRepository();
      final sourceActionRepository = InMemoryActionRepository();
      final sourceTopicRepository = InMemoryTopicRepository();

      final authRepository = FakeAuthRepository();
      await authRepository.signInAnonymously();

      final migrationRepository = FirestoreMigrationRepository(
        authRepository: authRepository,
        sourceEventRepository: sourceEventRepository,
        sourceMemberRepository: sourceMemberRepository,
        sourceTransRepository: sourceTransRepository,
        sourceTagRepository: sourceTagRepository,
        sourceActionRepository: sourceActionRepository,
        sourceTopicRepository: sourceTopicRepository,
        firestore: fakeFirestore,
      );

      // 移行前はschemaVersion=0（移行未実施）
      expect(await migrationRepository.getMigrationVersion(), equals(0));
      expect(await migrationRepository.isMigrationNeeded(), isTrue);

      // 移行を実行
      await migrationRepository.migrate();

      // 移行後はschemaVersion=1
      expect(await migrationRepository.getMigrationVersion(), equals(1));
      expect(await migrationRepository.isMigrationNeeded(), isFalse);
    });

    // TC-INFRA-008: 移行済み状態ではFirestoreから読み込む
    test('TC-INFRA-008: 移行済み状態ではFirestoreから読み込む', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final now = DateTime.now();

      final authRepository = FakeAuthRepository();
      await authRepository.signInAnonymously();

      // InMemory（移行元・drift相当）にはデータなし
      final sourceEventRepository = InMemoryEventRepository();
      // → fetchAll() は空リストを返す

      // Firestoreにデータを保存（migrate()完了後の状態を想定）
      final firestoreEventRepo = FirestoreEventRepository(
        authRepository: authRepository,
        firestore: fakeFirestore,
      );
      final firestoreEvent = EventDomain(
        id: 'fs-event-001',
        eventName: 'Firestore移行済みイベント',
        members: [],
        tags: [],
        markLinks: [],
        payments: [],
        actionTimeLogs: [],
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );
      await firestoreEventRepo.save(firestoreEvent);

      // Firestoreリポジトリから読み込む（移行後の動作）
      final fsEvents = await firestoreEventRepo.fetchAll();

      // InMemoryには存在しないがFirestoreから取得できる
      final inMemoryEvents = await sourceEventRepository.fetchAll();
      expect(inMemoryEvents, isEmpty);
      expect(fsEvents, hasLength(1));
      expect(fsEvents.first.id, equals('fs-event-001'));
    });

    tearDown(() async {
      // GetItのインスタンスをリセット
      await GetIt.I.reset();
    });
  });
}
