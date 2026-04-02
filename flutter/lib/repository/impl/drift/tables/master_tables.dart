import 'package:drift/drift.dart';

/// actions テーブル
class Actions extends Table {
  TextColumn get id => text()();
  TextColumn get actionName => text()();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// members テーブル
class Members extends Table {
  TextColumn get id => text()();
  TextColumn get memberName => text()();
  TextColumn get mailAddress => text().nullable()();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// tags テーブル
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get tagName => text()();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// transports テーブル
class Transports extends Table {
  TextColumn get id => text()();
  TextColumn get transName => text()();
  IntColumn get kmPerGas => integer().nullable()();
  IntColumn get meterValue => integer().nullable()();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
