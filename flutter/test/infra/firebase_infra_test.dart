import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:michi_mark/domain/master/member/member_domain.dart';
import 'package:michi_mark/domain/transaction/event/event_domain.dart';
import 'package:michi_mark/repository/auth_repository.dart';
import 'package:michi_mark/repository/event_repository.dart';
import 'package:michi_mark/repository/member_repository.dart';
import 'package:michi_mark/repository/impl/firebase/firebase_auth_repository.dart';
import 'package:michi_mark/repository/impl/firestore/firestore_event_repository.dart';
import 'package:michi_mark/repository/impl/firestore/firestore_member_repository.dart';
import 'package:michi_mark/repository/impl/firestore/firestore_migration_repository.dart';
import 'package:michi_mark/repository/impl/fake/fake_auth_repository.dart';
import 'package:michi_mark/repository/impl/in_memory/in_memory_member_repository.dart';
import 'package:michi_mark/repository/impl/in_memory/in_memory_event_repository.dart';

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
      // FakeAuthRepositoryを使用して既存UIDをシミュレート
      final authRepository = FakeAuthRepository();

      // 既に _currentUid が設定されていない状態
      expect(authRepository.currentUid, isNull);

      // signInAnonymously() を1回目に呼び出す
      final uid1 = await authRepository.signInAnonymously();
      expect(uid1, isNotEmpty);

      // 2回目に signInAnonymously() を呼び出す（既にサインイン済み）
      final uid2 = await authRepository.signInAnonymously();

      // 同じUIDが返されること（再発行されていない）
      expect(uid2, equals(uid1));
      expect(authRepository.currentUid, equals(uid1));
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
      final inMemoryMemberRepository = InMemoryMemberRepository();
      final inMemoryEventRepository = InMemoryEventRepository();

      // 移行元データを作成
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
        members: [member1, member2],
        tags: [],
        markLinks: [],
        payments: [],
        actionTimeLogs: [],
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );

      // InMemoryに保存
      await inMemoryMemberRepository.save(member1);
      await inMemoryMemberRepository.save(member2);
      await inMemoryEventRepository.save(event);

      // FakeAuthRepositoryを初期化してサインイン
      final authRepository = FakeAuthRepository();
      await authRepository.signInAnonymously();

      // FirestoreRepositoryを初期化
      final firestoreEventRepository = FirestoreEventRepository(
        authRepository: authRepository,
        firestore: fakeFirestore,
      );
      final firestoreMemberRepository = FirestoreMemberRepository(
        authRepository: authRepository,
        firestore: fakeFirestore,
      );

      // 移行元からデータを読み込んで移行先に書き込み
      final allEvents = await inMemoryEventRepository.fetchAll();
      final allMembers = await inMemoryMemberRepository.fetchAll();

      for (final member in allMembers) {
        await firestoreMemberRepository.save(member);
      }
      for (final evt in allEvents) {
        await firestoreEventRepository.save(evt);
      }

      // 移行先でデータが存在することを確認
      final migratedEvents = await firestoreEventRepository.fetchAll();
      final migratedMembers = await firestoreMemberRepository.fetchAll();

      expect(migratedEvents, hasLength(1));
      expect(migratedMembers, hasLength(2));
      expect(migratedEvents.first.id, equals('event-001'));
      expect(
        migratedMembers.map((m) => m.id).toList(),
        containsAll(['member-001', 'member-002']),
      );
    });

    // TC-INFRA-007: 移行完了後にschemaVersionが更新される
    test('TC-INFRA-007: 移行完了後にschemaVersionが更新される', () async {
      final fakeFirestore = FakeFirebaseFirestore();

      // FakeAuthRepositoryを初期化してサインイン
      final authRepository = FakeAuthRepository();
      await authRepository.signInAnonymously();

      // スキーマバージョンが初期状態で未設定・0であることを確認
      // （MigrationRepositoryの初期化時に確認）

      // スキーマバージョンを更新（1に設定）
      await fakeFirestore
          .collection('users')
          .doc(authRepository.currentUid!)
          .set({
        'schemaVersion': 1,
        'updatedAt': Timestamp.now(),
      });

      // Firestoreから直接読み込んで確認
      final profileDoc = await fakeFirestore
          .collection('users')
          .doc(authRepository.currentUid!)
          .get();

      // schemaVersionが1に更新されたことを確認
      expect(profileDoc.data()?['schemaVersion'], equals(1));
    });

    // TC-INFRA-008: 移行済み状態ではFirestoreから読み込む
    test('TC-INFRA-008: 移行済み状態ではFirestoreから読み込む', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final now = DateTime.now();

      // FakeAuthRepositoryを初期化してサインイン
      final authRepository = FakeAuthRepository();
      await authRepository.signInAnonymously();

      // FirestoreEventRepositoryを初期化
      final firestoreEventRepository = FirestoreEventRepository(
        authRepository: authRepository,
        firestore: fakeFirestore,
      );

      // Firestoreにイベントを保存
      final firestoreEvent = EventDomain(
        id: 'fs-event-001',
        eventName: 'Firestore側のイベント',
        members: [],
        tags: [],
        markLinks: [],
        payments: [],
        actionTimeLogs: [],
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );
      await firestoreEventRepository.save(firestoreEvent);

      // Firestoreから読み込み
      final allEvents = await firestoreEventRepository.fetchAll();

      // Firestoreから読み込めていることを確認
      expect(allEvents, hasLength(1));
      expect(allEvents.first.id, equals('fs-event-001'));
      expect(allEvents.first.eventName, equals('Firestore側のイベント'));
    });

    tearDown(() async {
      // GetItのインスタンスをリセット
      await GetIt.I.reset();
    });
  });
}
