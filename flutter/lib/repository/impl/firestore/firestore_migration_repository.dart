import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth_repository.dart';
import '../../migration_repository.dart';
import '../../action_repository.dart';
import '../../event_repository.dart';
import '../../member_repository.dart';
import '../../tag_repository.dart';
import '../../topic_repository.dart';
import '../../trans_repository.dart';
import 'firestore_action_repository.dart';
import 'firestore_event_repository.dart';
import 'firestore_member_repository.dart';
import 'firestore_tag_repository.dart';
import 'firestore_topic_repository.dart';
import 'firestore_trans_repository.dart';

/// MigrationRepository の Firestore 実装
///
/// drift実装のRepository群からデータを読み込み、
/// Firestore実装のRepository群へ書き込む。
/// profile.schemaVersion で移行状態を管理する。
class FirestoreMigrationRepository implements MigrationRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  /// 移行元（drift / InMemory）のRepository群
  final EventRepository _sourceEventRepository;
  final MemberRepository _sourceMemberRepository;
  final TransRepository _sourceTransRepository;
  final TagRepository _sourceTagRepository;
  final ActionRepository _sourceActionRepository;
  final TopicRepository _sourceTopicRepository;

  FirestoreMigrationRepository({
    required AuthRepository authRepository,
    required EventRepository sourceEventRepository,
    required MemberRepository sourceMemberRepository,
    required TransRepository sourceTransRepository,
    required TagRepository sourceTagRepository,
    required ActionRepository sourceActionRepository,
    required TopicRepository sourceTopicRepository,
    FirebaseFirestore? firestore,
  })  : _authRepository = authRepository,
        _sourceEventRepository = sourceEventRepository,
        _sourceMemberRepository = sourceMemberRepository,
        _sourceTransRepository = sourceTransRepository,
        _sourceTagRepository = sourceTagRepository,
        _sourceActionRepository = sourceActionRepository,
        _sourceTopicRepository = sourceTopicRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  String get _uid {
    final uid = _authRepository.currentUid;
    if (uid == null) {
      throw StateError('FirestoreMigrationRepository: currentUid is null');
    }
    return uid;
  }

  DocumentReference<Map<String, Object?>> get _profileDoc =>
      _firestore.doc('users/$_uid/profile/main');

  @override
  Future<bool> isMigrationNeeded() async {
    final version = await getMigrationVersion();
    return version < 1;
  }

  @override
  Future<int> getMigrationVersion() async {
    final doc = await _profileDoc.get();
    if (!doc.exists) return 0;
    final data = doc.data();
    if (data == null) return 0;
    return data['schemaVersion'] as int? ?? 0;
  }

  @override
  Future<void> migrate() async {
    final uid = _uid;

    // Firestore実装を作成（書き込み先）
    final firestoreMemberRepo = FirestoreMemberRepository(
      authRepository: _authRepository,
      firestore: _firestore,
    );
    final firestoreTransRepo = FirestoreTransRepository(
      authRepository: _authRepository,
      firestore: _firestore,
    );
    final firestoreTagRepo = FirestoreTagRepository(
      authRepository: _authRepository,
      firestore: _firestore,
    );
    final firestoreActionRepo = FirestoreActionRepository(
      authRepository: _authRepository,
      firestore: _firestore,
    );
    final firestoreTopicRepo = FirestoreTopicRepository(
      authRepository: _authRepository,
      firestore: _firestore,
    );
    final firestoreEventRepo = FirestoreEventRepository(
      authRepository: _authRepository,
      firestore: _firestore,
    );

    // マスターデータの移行
    final members = await _sourceMemberRepository.fetchAll();
    for (final member in members) {
      await firestoreMemberRepo.save(member);
    }

    final transList = await _sourceTransRepository.fetchAll();
    for (final trans in transList) {
      await firestoreTransRepo.save(trans);
    }

    final tags = await _sourceTagRepository.fetchAll();
    for (final tag in tags) {
      await firestoreTagRepo.save(tag);
    }

    final actions = await _sourceActionRepository.fetchAll();
    for (final action in actions) {
      await firestoreActionRepo.save(action);
    }

    final topics = await _sourceTopicRepository.fetchAll();
    for (final topic in topics) {
      await firestoreTopicRepo.save(topic);
    }

    // イベントの移行
    final events = await _sourceEventRepository.fetchAll();
    for (final event in events) {
      await firestoreEventRepo.save(event);
    }

    // schemaVersion を更新
    await _profileDoc.set({
      'uid': uid,
      'schemaVersion': 1,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
