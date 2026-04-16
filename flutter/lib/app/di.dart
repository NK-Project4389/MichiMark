import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../adapter/aggregation_service.dart';
import '../features/invite_code_input/repository/invitation_repository.dart';
import '../features/invite_code_input/repository/impl/stub_invitation_repository.dart';
import '../repository/action_repository.dart';
import '../repository/auth_repository.dart';
import '../repository/event_repository.dart';
import '../repository/impl/fake/fake_auth_repository.dart';
import '../repository/impl/firebase/firebase_auth_repository.dart';
import '../repository/impl/firestore/firestore_action_repository.dart';
import '../repository/impl/firestore/firestore_event_repository.dart';
import '../repository/impl/firestore/firestore_member_repository.dart';
import '../repository/impl/firestore/firestore_migration_repository.dart';
import '../repository/impl/firestore/firestore_tag_repository.dart';
import '../repository/impl/firestore/firestore_topic_repository.dart';
import '../repository/impl/firestore/firestore_trans_repository.dart';
import '../repository/impl/in_memory/in_memory_action_repository.dart';
import '../repository/impl/in_memory/in_memory_event_repository.dart';
import '../repository/impl/in_memory/in_memory_member_repository.dart';
import '../repository/impl/in_memory/in_memory_tag_repository.dart';
import '../repository/impl/in_memory/in_memory_topic_repository.dart';
import '../repository/impl/in_memory/in_memory_trans_repository.dart';
import '../repository/impl/in_memory/seed_data.dart';
import '../repository/member_repository.dart';
import '../repository/migration_repository.dart';
import '../repository/tag_repository.dart';
import '../repository/topic_repository.dart';
import '../repository/trans_repository.dart';

final getIt = GetIt.instance;

/// FLAVOR環境変数（--dart-define=FLAVOR=dev/prod）
const _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

void setupDi() {
  final isTest = Platform.environment.containsKey('FLUTTER_TEST');

  // --- AuthRepository ---
  if (isTest) {
    getIt.registerLazySingleton<AuthRepository>(() => FakeAuthRepository());
  } else {
    getIt.registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(),
    );
  }

  // --- Repository実装の選択 ---
  // テスト環境 or FLAVOR=dev（schemaVersion未チェック）: InMemory実装
  // FLAVOR=prod: Firestore実装
  //
  // 移行フェーズ（schemaVersion確認）での動的切替は
  // setupDiFirestore() を呼び出して実現する。
  if (isTest || _flavor == 'dev') {
    _registerInMemoryRepositories();
  } else {
    _registerFirestoreRepositories();
  }

  getIt.registerSingleton<AggregationService>(
    AggregationService(actionRepository: getIt<ActionRepository>()),
  );

  // --- InvitationRepository（スタブ実装・API未実装のため） ---
  getIt.registerLazySingleton<InvitationRepository>(
    () => const StubInvitationRepository(),
  );
}

/// InMemory実装でRepository群を登録する（テスト・開発用）
void _registerInMemoryRepositories() {
  getIt.registerSingleton<EventRepository>(
    InMemoryEventRepository(initialItems: seedEvents),
  );
  getIt.registerSingleton<TransRepository>(
    InMemoryTransRepository(initialItems: seedTrans),
  );
  getIt.registerSingleton<MemberRepository>(
    InMemoryMemberRepository(initialItems: seedMembers),
  );
  getIt.registerSingleton<TagRepository>(
    InMemoryTagRepository(initialItems: seedTags),
  );
  getIt.registerSingleton<ActionRepository>(
    InMemoryActionRepository(initialItems: seedActions),
  );
  getIt.registerSingleton<TopicRepository>(
    InMemoryTopicRepository(initialItems: seedTopics),
  );
}

/// Firestore実装でRepository群を登録する（本番用）
void _registerFirestoreRepositories() {
  final authRepository = getIt<AuthRepository>();

  getIt.registerSingleton<MemberRepository>(
    FirestoreMemberRepository(authRepository: authRepository),
  );
  getIt.registerSingleton<TransRepository>(
    FirestoreTransRepository(authRepository: authRepository),
  );
  getIt.registerSingleton<TagRepository>(
    FirestoreTagRepository(authRepository: authRepository),
  );
  getIt.registerSingleton<ActionRepository>(
    FirestoreActionRepository(authRepository: authRepository),
  );
  getIt.registerSingleton<TopicRepository>(
    FirestoreTopicRepository(authRepository: authRepository),
  );
  getIt.registerSingleton<EventRepository>(
    FirestoreEventRepository(authRepository: authRepository),
  );
}

/// Firestore実装への動的切替（移行完了後に呼び出す）
///
/// InMemory/drift → Firestore への一括切替を行う。
/// 既存のRepository登録を解除してFirestore実装で再登録する。
Future<void> setupDiFirestore() async {
  // 既存のRepository登録を解除
  await getIt.unregister<EventRepository>();
  await getIt.unregister<TransRepository>();
  await getIt.unregister<MemberRepository>();
  await getIt.unregister<TagRepository>();
  await getIt.unregister<ActionRepository>();
  await getIt.unregister<TopicRepository>();
  await getIt.unregister<AggregationService>();

  // Firestore実装で再登録
  _registerFirestoreRepositories();

  getIt.registerSingleton<AggregationService>(
    AggregationService(actionRepository: getIt<ActionRepository>()),
  );
}

/// MigrationRepository を登録する
///
/// 移行元Repository群（InMemory/drift）が登録済みの状態で呼び出す。
void registerMigrationRepository({FirebaseFirestore? firestore}) {
  final authRepository = getIt<AuthRepository>();

  getIt.registerSingleton<MigrationRepository>(
    FirestoreMigrationRepository(
      authRepository: authRepository,
      sourceEventRepository: getIt<EventRepository>(),
      sourceMemberRepository: getIt<MemberRepository>(),
      sourceTransRepository: getIt<TransRepository>(),
      sourceTagRepository: getIt<TagRepository>(),
      sourceActionRepository: getIt<ActionRepository>(),
      sourceTopicRepository: getIt<TopicRepository>(),
      firestore: firestore,
    ),
  );
}
