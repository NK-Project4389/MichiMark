import 'package:drift/drift.dart';

import 'event_tables.dart';
import 'master_tables.dart';

/// event_members 中間テーブル
class EventMembers extends Table {
  TextColumn get eventId =>
      text().references(Events, #id, onDelete: KeyAction.cascade)();
  TextColumn get memberId => text().references(Members, #id)();

  @override
  Set<Column> get primaryKey => {eventId, memberId};
}

/// event_tags 中間テーブル
class EventTags extends Table {
  TextColumn get eventId =>
      text().references(Events, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {eventId, tagId};
}

/// mark_link_members 中間テーブル
class MarkLinkMembers extends Table {
  TextColumn get markLinkId =>
      text().references(MarkLinks, #id, onDelete: KeyAction.cascade)();
  TextColumn get memberId => text().references(Members, #id)();

  @override
  Set<Column> get primaryKey => {markLinkId, memberId};
}

/// mark_link_actions 中間テーブル
class MarkLinkActions extends Table {
  TextColumn get markLinkId =>
      text().references(MarkLinks, #id, onDelete: KeyAction.cascade)();
  TextColumn get actionId => text().references(Actions, #id)();

  @override
  Set<Column> get primaryKey => {markLinkId, actionId};
}

/// payment_split_members 中間テーブル
class PaymentSplitMembers extends Table {
  TextColumn get paymentId =>
      text().references(Payments, #id, onDelete: KeyAction.cascade)();
  TextColumn get memberId => text().references(Members, #id)();

  @override
  Set<Column> get primaryKey => {paymentId, memberId};
}
