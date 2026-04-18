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
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _insertSeedActions();
        },
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
          if (from < 4) {
            // MovingCostFuelMode: mark_links に gas_payer_id カラムを追加
            await customStatement(
              'ALTER TABLE mark_links ADD COLUMN gas_payer_id TEXT REFERENCES members(id)',
            );
          }
          if (from < 5) {
            // F-5: payments に mark_link_id カラムを追加（nullable）
            await customStatement(
              'ALTER TABLE payments ADD COLUMN mark_link_id TEXT',
            );
          }
          if (from < 6) {
            // F-10: actions に end_flag カラムを追加
            await customStatement(
              'ALTER TABLE actions ADD COLUMN end_flag INTEGER NOT NULL DEFAULT 0',
            );
            // F-10: action_time_logs に mark_link_id カラムを追加（nullable）
            await customStatement(
              'ALTER TABLE action_time_logs ADD COLUMN mark_link_id TEXT',
            );
            // F-10: 「出発」（visit_work_depart）の end_flag を 1 に設定
            await customStatement(
              "UPDATE actions SET end_flag = 1 WHERE id = 'visit_work_depart'",
            );
          }
        },
      );

  /// アクションマスタの固定シードデータを投入する（ユーザーが設定変更不可）
  Future<void> _insertSeedActions() async {
    final now = DateTime.now();
    final seedRows = [
      ActionsCompanion(
        id: const Value('action-seed-depart'),
        actionName: const Value('出発'),
        toState: const Value('moving'),
        isToggle: const Value(false),
        needsTransition: const Value(true),
        isDeleted: const Value(false),
        isVisible: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      ActionsCompanion(
        id: const Value('action-seed-arrive'),
        actionName: const Value('到着'),
        toState: const Value('working'),
        isToggle: const Value(false),
        needsTransition: const Value(true),
        isDeleted: const Value(false),
        isVisible: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      ActionsCompanion(
        id: const Value('action-001'),
        actionName: const Value('観光'),
        isToggle: const Value(false),
        needsTransition: const Value(false),
        isDeleted: const Value(false),
        isVisible: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      ActionsCompanion(
        id: const Value('action-002'),
        actionName: const Value('食事'),
        isToggle: const Value(false),
        needsTransition: const Value(false),
        isDeleted: const Value(false),
        isVisible: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      ActionsCompanion(
        id: const Value('action-003'),
        actionName: const Value('休憩'),
        isToggle: const Value(false),
        needsTransition: const Value(false),
        isDeleted: const Value(false),
        isVisible: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      ActionsCompanion(
        id: const Value('action-004'),
        actionName: const Value('買い物'),
        isToggle: const Value(false),
        needsTransition: const Value(false),
        isDeleted: const Value(false),
        isVisible: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      ActionsCompanion(
        id: const Value('action-005'),
        actionName: const Value('写真撮影'),
        isToggle: const Value(false),
        needsTransition: const Value(false),
        isDeleted: const Value(false),
        isVisible: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      // visitWork専用アクション（F-10）
      ActionsCompanion(
        id: const Value('visit_work_arrive'),
        actionName: const Value('到着'),
        toState: const Value('working'),
        isToggle: const Value(false),
        needsTransition: const Value(true),
        isDeleted: const Value(false),
        isVisible: const Value(true),
        endFlag: const Value(false),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      ActionsCompanion(
        id: const Value('visit_work_depart'),
        actionName: const Value('出発'),
        toState: const Value('moving'),
        isToggle: const Value(false),
        needsTransition: const Value(true),
        isDeleted: const Value(false),
        isVisible: const Value(true),
        endFlag: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      ActionsCompanion(
        id: const Value('visit_work_start'),
        actionName: const Value('作業開始'),
        isToggle: const Value(false),
        needsTransition: const Value(false),
        isDeleted: const Value(false),
        isVisible: const Value(true),
        endFlag: const Value(false),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      ActionsCompanion(
        id: const Value('visit_work_end'),
        actionName: const Value('作業終了'),
        isToggle: const Value(false),
        needsTransition: const Value(false),
        isDeleted: const Value(false),
        isVisible: const Value(true),
        endFlag: const Value(false),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    ];
    for (final row in seedRows) {
      await into(actions).insertOnConflictUpdate(row);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'michi_mark.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
