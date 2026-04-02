// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_dao.dart';

// ignore_for_file: type=lint
mixin _$EventDaoMixin on DatabaseAccessor<AppDatabase> {
  $TransportsTable get transports => attachedDatabase.transports;
  $MembersTable get members => attachedDatabase.members;
  $EventsTable get events => attachedDatabase.events;
  $MarkLinksTable get markLinks => attachedDatabase.markLinks;
  $PaymentsTable get payments => attachedDatabase.payments;
  $EventMembersTable get eventMembers => attachedDatabase.eventMembers;
  $TagsTable get tags => attachedDatabase.tags;
  $EventTagsTable get eventTags => attachedDatabase.eventTags;
  $MarkLinkMembersTable get markLinkMembers => attachedDatabase.markLinkMembers;
  $ActionsTable get actions => attachedDatabase.actions;
  $MarkLinkActionsTable get markLinkActions => attachedDatabase.markLinkActions;
  $PaymentSplitMembersTable get paymentSplitMembers =>
      attachedDatabase.paymentSplitMembers;
  EventDaoManager get managers => EventDaoManager(this);
}

class EventDaoManager {
  final _$EventDaoMixin _db;
  EventDaoManager(this._db);
  $$TransportsTableTableManager get transports =>
      $$TransportsTableTableManager(_db.attachedDatabase, _db.transports);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db.attachedDatabase, _db.members);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db.attachedDatabase, _db.events);
  $$MarkLinksTableTableManager get markLinks =>
      $$MarkLinksTableTableManager(_db.attachedDatabase, _db.markLinks);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db.attachedDatabase, _db.payments);
  $$EventMembersTableTableManager get eventMembers =>
      $$EventMembersTableTableManager(_db.attachedDatabase, _db.eventMembers);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$EventTagsTableTableManager get eventTags =>
      $$EventTagsTableTableManager(_db.attachedDatabase, _db.eventTags);
  $$MarkLinkMembersTableTableManager get markLinkMembers =>
      $$MarkLinkMembersTableTableManager(
        _db.attachedDatabase,
        _db.markLinkMembers,
      );
  $$ActionsTableTableManager get actions =>
      $$ActionsTableTableManager(_db.attachedDatabase, _db.actions);
  $$MarkLinkActionsTableTableManager get markLinkActions =>
      $$MarkLinkActionsTableTableManager(
        _db.attachedDatabase,
        _db.markLinkActions,
      );
  $$PaymentSplitMembersTableTableManager get paymentSplitMembers =>
      $$PaymentSplitMembersTableTableManager(
        _db.attachedDatabase,
        _db.paymentSplitMembers,
      );
}
