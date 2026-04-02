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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'michi_mark.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
