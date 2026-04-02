import 'package:get_it/get_it.dart';

import '../repository/action_repository.dart';
import '../repository/event_repository.dart';
import '../repository/impl/in_memory/in_memory_action_repository.dart';
import '../repository/impl/in_memory/in_memory_event_repository.dart';
import '../repository/impl/in_memory/in_memory_member_repository.dart';
import '../repository/impl/in_memory/in_memory_tag_repository.dart';
import '../repository/impl/in_memory/in_memory_trans_repository.dart';
import '../repository/impl/in_memory/seed_data.dart';
import '../repository/member_repository.dart';
import '../repository/tag_repository.dart';
import '../repository/trans_repository.dart';

final getIt = GetIt.instance;

void setupDi() {
  // --- InMemory 実装（開発用） ---
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

  // --- drift 実装に切り替える場合 ---
  // final db = AppDatabase();
  // getIt.registerSingleton<EventRepository>(DriftEventRepository(db.eventDao));
  // getIt.registerSingleton<TransRepository>(DriftTransRepository(db.masterDao));
  // getIt.registerSingleton<MemberRepository>(DriftMemberRepository(db.masterDao));
  // getIt.registerSingleton<TagRepository>(DriftTagRepository(db.masterDao));
  // getIt.registerSingleton<ActionRepository>(DriftActionRepository(db.masterDao));
}
