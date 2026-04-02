import 'package:drift/drift.dart';

import 'master_tables.dart';

/// events テーブル
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get eventName => text()();
  TextColumn get transId =>
      text().nullable().references(Transports, #id)();
  IntColumn get kmPerGas => integer().nullable()();
  IntColumn get pricePerGas => integer().nullable()();
  TextColumn get payMemberId =>
      text().nullable().references(Members, #id)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// mark_links テーブル
class MarkLinks extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();
  IntColumn get markLinkSeq => integer()();
  TextColumn get markLinkType => text()();
  DateTimeColumn get markLinkDate => dateTime()();
  TextColumn get markLinkName => text().nullable()();
  IntColumn get meterValue => integer().nullable()();
  IntColumn get distanceValue => integer().nullable()();
  TextColumn get memo => text().nullable()();
  BoolColumn get isFuel => boolean().withDefault(const Constant(false))();
  IntColumn get pricePerGas => integer().nullable()();
  IntColumn get gasQuantity => integer().nullable()();
  IntColumn get gasPrice => integer().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// payments テーブル
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();
  IntColumn get paymentSeq => integer()();
  IntColumn get paymentAmount => integer()();
  TextColumn get paymentMemberId =>
      text().references(Members, #id)();
  TextColumn get paymentMemo => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
