// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_dao.dart';

// ignore_for_file: type=lint
mixin _$MasterDaoMixin on DatabaseAccessor<AppDatabase> {
  $ActionsTable get actions => attachedDatabase.actions;
  $MembersTable get members => attachedDatabase.members;
  $TagsTable get tags => attachedDatabase.tags;
  $TransportsTable get transports => attachedDatabase.transports;
  MasterDaoManager get managers => MasterDaoManager(this);
}

class MasterDaoManager {
  final _$MasterDaoMixin _db;
  MasterDaoManager(this._db);
  $$ActionsTableTableManager get actions =>
      $$ActionsTableTableManager(_db.attachedDatabase, _db.actions);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db.attachedDatabase, _db.members);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$TransportsTableTableManager get transports =>
      $$TransportsTableTableManager(_db.attachedDatabase, _db.transports);
}
