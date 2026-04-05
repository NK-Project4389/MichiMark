import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'dao/event_dao.dart';
import 'dao/master_dao.dart';
import 'tables/event_tables.dart';
import 'tables/junction_tables.dart';
import 'tables/master_tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    // Master
    Actions,
    Members,
    Tags,
    Transports,
    // Transaction
    Events,
    MarkLinks,
    Payments,
    ActionTimeLogs,
    // Junction
    EventMembers,
    EventTags,
    MarkLinkMembers,
    MarkLinkActions,
    PaymentSplitMembers,
  ],
  daos: [MasterDao, EventDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // actions テーブルに ActionState 関連カラムを追加
            await customStatement(
              'ALTER TABLE actions ADD COLUMN from_state TEXT',
            );
            await customStatement(
              'ALTER TABLE actions ADD COLUMN to_state TEXT',
            );
            await customStatement(
              'ALTER TABLE actions ADD COLUMN is_toggle INTEGER NOT NULL DEFAULT 0',
            );
            await customStatement(
              'ALTER TABLE actions ADD COLUMN toggle_pair_id TEXT',
            );
            // action_time_logs テーブルを新規作成
            await customStatement('''
              CREATE TABLE IF NOT EXISTS action_time_logs (
                id TEXT NOT NULL PRIMARY KEY,
                event_id TEXT NOT NULL REFERENCES events(id),
                action_id TEXT NOT NULL REFERENCES actions(id),
                timestamp INTEGER NOT NULL,
                is_deleted INTEGER NOT NULL DEFAULT 0,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
              )
            ''');
          }
          if (from < 3) {
            // REQ-005: actions テーブルに needs_transition カラムを追加
            await customStatement(
              'ALTER TABLE actions ADD COLUMN needs_transition INTEGER NOT NULL DEFAULT 1',
            );
            // REQ-007枠: topics テーブルに color カラムを追加（NULLABLE）
            // topics テーブルが存在する場合のみ実行
            await customStatement(
              'ALTER TABLE topics ADD COLUMN color TEXT',
            );
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'michi_mark.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
