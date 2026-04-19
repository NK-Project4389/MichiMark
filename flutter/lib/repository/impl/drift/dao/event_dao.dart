import 'package:drift/drift.dart';

import '../../../../domain/action_time/action_time_log.dart'
    as domain_log;
import '../../../../domain/master/action/action_domain.dart';
import '../../../../domain/master/member/member_domain.dart';
import '../../../../domain/master/tag/tag_domain.dart';
import '../../../../domain/master/trans/trans_domain.dart';
import '../../../../domain/transaction/event/event_domain.dart';
import '../../../../domain/transaction/mark_link/mark_link_domain.dart';
import '../../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../../domain/transaction/payment/payment_domain.dart';
import '../database.dart';
import '../tables/event_tables.dart';
import '../tables/junction_tables.dart';
import '../tables/master_tables.dart';

part 'event_dao.g.dart';

@DriftAccessor(tables: [
  Events,
  MarkLinks,
  Payments,
  ActionTimeLogs,
  EventMembers,
  EventTags,
  MarkLinkMembers,
  MarkLinkActions,
  PaymentSplitMembers,
  Members,
  Tags,
  Actions,
  Transports,
])
class EventDao extends DatabaseAccessor<AppDatabase> with _$EventDaoMixin {
  EventDao(super.db);

  // ---------------------------------------------------------------------------
  // fetchAll
  // ---------------------------------------------------------------------------

  Future<List<EventDomain>> fetchAll() async {
    final eventRows = await (select(events)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();

    final result = <EventDomain>[];
    for (final row in eventRows) {
      result.add(await _buildEventDomain(row));
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // fetch(id)
  // ---------------------------------------------------------------------------

  Future<EventDomain?> fetchById(String id) async {
    final row = await (select(events)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
    if (row == null) return null;
    return _buildEventDomain(row);
  }

  // ---------------------------------------------------------------------------
  // save (トランザクション)
  // ---------------------------------------------------------------------------

  Future<void> saveEvent(EventDomain domain) async {
    await transaction(() async {
      // 1. events テーブルへの upsert
      await into(events).insertOnConflictUpdate(_toEventCompanion(domain));

      // 2. event_members: 全削除 → 再挿入
      await (delete(eventMembers)
            ..where((t) => t.eventId.equals(domain.id)))
          .go();
      for (final member in domain.members) {
        await into(eventMembers).insert(EventMembersCompanion(
          eventId: Value(domain.id),
          memberId: Value(member.id),
        ));
      }

      // 3. event_tags: 全削除 → 再挿入
      await (delete(eventTags)..where((t) => t.eventId.equals(domain.id)))
          .go();
      for (final tag in domain.tags) {
        await into(eventTags).insert(EventTagsCompanion(
          eventId: Value(domain.id),
          tagId: Value(tag.id),
        ));
      }

      // 4. mark_links の処理
      // DB上の既存 markLink ID を取得
      final existingMlIds = (await (select(markLinks)
                ..where((t) => t.eventId.equals(domain.id)))
              .get())
          .map((r) => r.id)
          .toSet();
      final domainMlIds = domain.markLinks.map((ml) => ml.id).toSet();

      // Domain に含まれない MarkLink を論理削除
      final orphanMlIds = existingMlIds.difference(domainMlIds);
      for (final orphanId in orphanMlIds) {
        await (update(markLinks)..where((t) => t.id.equals(orphanId)))
            .write(const MarkLinksCompanion(isDeleted: Value(true)));
      }

      // 各 MarkLink を upsert
      for (final ml in domain.markLinks) {
        await into(markLinks)
            .insertOnConflictUpdate(_toMarkLinkCompanion(ml, domain.id));

        // mark_link_members: 全削除 → 再挿入
        await (delete(markLinkMembers)
              ..where((t) => t.markLinkId.equals(ml.id)))
            .go();
        for (final member in ml.members) {
          await into(markLinkMembers).insert(MarkLinkMembersCompanion(
            markLinkId: Value(ml.id),
            memberId: Value(member.id),
          ));
        }

        // mark_link_actions: 全削除 → 再挿入
        await (delete(markLinkActions)
              ..where((t) => t.markLinkId.equals(ml.id)))
            .go();
        for (final action in ml.actions) {
          await into(markLinkActions).insert(MarkLinkActionsCompanion(
            markLinkId: Value(ml.id),
            actionId: Value(action.id),
          ));
        }
      }

      // 5. payments の処理
      final existingPayIds = (await (select(payments)
                ..where((t) => t.eventId.equals(domain.id)))
              .get())
          .map((r) => r.id)
          .toSet();
      final domainPayIds = domain.payments.map((p) => p.id).toSet();

      // Domain に含まれない Payment を論理削除
      final orphanPayIds = existingPayIds.difference(domainPayIds);
      for (final orphanId in orphanPayIds) {
        await (update(payments)..where((t) => t.id.equals(orphanId)))
            .write(const PaymentsCompanion(isDeleted: Value(true)));
      }

      // 各 Payment を upsert
      for (final pay in domain.payments) {
        await into(payments)
            .insertOnConflictUpdate(_toPaymentCompanion(pay, domain.id));

        // payment_split_members: 全削除 → 再挿入
        await (delete(paymentSplitMembers)
              ..where((t) => t.paymentId.equals(pay.id)))
            .go();
        for (final member in pay.splitMembers) {
          await into(paymentSplitMembers).insert(PaymentSplitMembersCompanion(
            paymentId: Value(pay.id),
            memberId: Value(member.id),
          ));
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // delete (論理削除)
  // ---------------------------------------------------------------------------

  Future<void> deleteEvent(String id) async {
    final now = DateTime.now();
    await transaction(() async {
      // 1. 子テーブル: mark_links 論理削除
      await (update(markLinks)..where((t) => t.eventId.equals(id))).write(
        MarkLinksCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
      );
      // 2. 子テーブル: payments 論理削除
      await (update(payments)..where((t) => t.eventId.equals(id))).write(
        PaymentsCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
      );
      // 3. 子テーブル: action_time_logs 論理削除
      await (update(actionTimeLogs)..where((t) => t.eventId.equals(id))).write(
        ActionTimeLogsCompanion(
            isDeleted: const Value(true), updatedAt: Value(now)),
      );
      // 4. 中間テーブル: event_members 物理削除
      await (delete(eventMembers)..where((t) => t.eventId.equals(id))).go();
      // 5. 中間テーブル: event_tags 物理削除
      await (delete(eventTags)..where((t) => t.eventId.equals(id))).go();
      // 6. events 本体 論理削除
      await (update(events)..where((t) => t.id.equals(id))).write(
        EventsCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
      );
    });
  }

  Future<void> deleteMarkLink(String markLinkId) async {
    final now = DateTime.now();
    await transaction(() async {
      // 1. markLinkID に紐づく payments を論理削除（カスケード削除）
      await (update(payments)..where((t) => t.markLinkId.equals(markLinkId)))
          .write(PaymentsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ));
      // 2. mark_links 本体を論理削除
      await (update(markLinks)..where((t) => t.id.equals(markLinkId))).write(
        MarkLinksCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
      );
    });
  }

  Future<void> deletePayment(String paymentId) async {
    final now = DateTime.now();
    await transaction(() async {
      // 1. payment_split_members 物理削除
      await (delete(paymentSplitMembers)
            ..where((t) => t.paymentId.equals(paymentId)))
          .go();
      // 2. payments 論理削除
      await (update(payments)..where((t) => t.id.equals(paymentId)))
          .write(PaymentsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(now),
          ));
    });
  }

  // ---------------------------------------------------------------------------
  // ActionTimeLog CRUD (F-10)
  // ---------------------------------------------------------------------------

  Future<void> saveActionTimeLog(domain_log.ActionTimeLog log) async {
    await into(actionTimeLogs).insertOnConflictUpdate(
      ActionTimeLogsCompanion(
        id: Value(log.id),
        eventId: Value(log.eventId),
        actionId: Value(log.actionId),
        timestamp: Value(log.timestamp),
        adjustedAt: Value(log.adjustedAt),
        isDeleted: Value(log.isDeleted),
        createdAt: Value(log.createdAt),
        updatedAt: Value(log.updatedAt),
        markLinkId: Value(log.markLinkId),
      ),
    );
  }

  Future<void> updateActionTimeLogAdjustedAt(
      String logId, DateTime? adjustedAt) async {
    final now = DateTime.now();
    await (update(actionTimeLogs)..where((t) => t.id.equals(logId))).write(
      ActionTimeLogsCompanion(
        adjustedAt: Value(adjustedAt),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteActionTimeLog(String logId) async {
    final now = DateTime.now();
    await (update(actionTimeLogs)..where((t) => t.id.equals(logId))).write(
      ActionTimeLogsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  Future<List<domain_log.ActionTimeLog>> fetchActionTimeLogs(
      String eventId) async {
    final rows = await (select(actionTimeLogs)
          ..where(
              (t) => t.eventId.equals(eventId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
    return rows.map(_toActionTimeLogDomain).toList();
  }

  domain_log.ActionTimeLog _toActionTimeLogDomain(ActionTimeLog row) =>
      domain_log.ActionTimeLog(
        id: row.id,
        eventId: row.eventId,
        actionId: row.actionId,
        timestamp: row.timestamp,
        adjustedAt: row.adjustedAt,
        isDeleted: row.isDeleted,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        markLinkId: row.markLinkId,
      );

  // ---------------------------------------------------------------------------
  // Event Domain 組み立て
  // ---------------------------------------------------------------------------

  Future<EventDomain> _buildEventDomain(Event row) async {
    // Trans
    TransDomain? transDomain;
    final transId = row.transId;
    if (transId != null) {
      final transRow = await (select(transports)
            ..where((t) => t.id.equals(transId)))
          .getSingleOrNull();
      if (transRow != null) transDomain = _toTransDomain(transRow);
    }

    // PayMember
    MemberDomain? payMemberDomain;
    final payMemberId = row.payMemberId;
    if (payMemberId != null) {
      final payRow = await (select(members)
            ..where((t) => t.id.equals(payMemberId)))
          .getSingleOrNull();
      if (payRow != null) payMemberDomain = _toMemberDomain(payRow);
    }

    // Members (event_members 中間テーブル経由)
    final memberJoins = await (select(eventMembers)
          ..where((t) => t.eventId.equals(row.id)))
        .get();
    final eventMemberList = <MemberDomain>[];
    for (final j in memberJoins) {
      final m = await (select(members)
            ..where((t) => t.id.equals(j.memberId)))
          .getSingleOrNull();
      if (m != null) eventMemberList.add(_toMemberDomain(m));
    }

    // Tags (event_tags 中間テーブル経由)
    final tagJoins = await (select(eventTags)
          ..where((t) => t.eventId.equals(row.id)))
        .get();
    final eventTagList = <TagDomain>[];
    for (final j in tagJoins) {
      final t = await (select(tags)..where((tbl) => tbl.id.equals(j.tagId)))
          .getSingleOrNull();
      if (t != null) eventTagList.add(_toTagDomain(t));
    }

    // MarkLinks
    final mlRows = await (select(markLinks)
          ..where(
              (t) => t.eventId.equals(row.id) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.markLinkSeq)]))
        .get();
    final markLinkList = <MarkLinkDomain>[];
    for (final ml in mlRows) {
      markLinkList.add(await _buildMarkLinkDomain(ml));
    }

    // Payments
    final payRows = await (select(payments)
          ..where(
              (t) => t.eventId.equals(row.id) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.paymentSeq)]))
        .get();
    final paymentList = <PaymentDomain>[];
    for (final pay in payRows) {
      paymentList.add(await _buildPaymentDomain(pay));
    }

    return EventDomain(
      id: row.id,
      eventName: row.eventName,
      trans: transDomain,
      members: eventMemberList,
      tags: eventTagList,
      kmPerGas: row.kmPerGas,
      pricePerGas: row.pricePerGas,
      payMember: payMemberDomain,
      markLinks: markLinkList,
      payments: paymentList,
      isDeleted: row.isDeleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<MarkLinkDomain> _buildMarkLinkDomain(MarkLink row) async {
    // Members
    final memberJoins = await (select(markLinkMembers)
          ..where((t) => t.markLinkId.equals(row.id)))
        .get();
    final mlMembers = <MemberDomain>[];
    for (final j in memberJoins) {
      final m = await (select(members)
            ..where((t) => t.id.equals(j.memberId)))
          .getSingleOrNull();
      if (m != null) mlMembers.add(_toMemberDomain(m));
    }

    // Actions
    final actionJoins = await (select(markLinkActions)
          ..where((t) => t.markLinkId.equals(row.id)))
        .get();
    final mlActions = <ActionDomain>[];
    for (final j in actionJoins) {
      final a = await (select(actions)
            ..where((t) => t.id.equals(j.actionId)))
          .getSingleOrNull();
      if (a != null) mlActions.add(_toActionDomain(a));
    }

    // GasPayer
    MemberDomain? gasPayerDomain;
    final gasPayerId = row.gasPayerId;
    if (gasPayerId != null) {
      final gasPayerRow = await (select(members)
            ..where((t) => t.id.equals(gasPayerId)))
          .getSingleOrNull();
      if (gasPayerRow != null) gasPayerDomain = _toMemberDomain(gasPayerRow);
    }

    return MarkLinkDomain(
      id: row.id,
      markLinkSeq: row.markLinkSeq,
      markLinkType:
          row.markLinkType == 'link' ? MarkOrLink.link : MarkOrLink.mark,
      markLinkDate: row.markLinkDate,
      markLinkName: row.markLinkName,
      members: mlMembers,
      meterValue: row.meterValue,
      distanceValue: row.distanceValue,
      actions: mlActions,
      memo: row.memo,
      isFuel: row.isFuel,
      pricePerGas: row.pricePerGas,
      gasQuantity: row.gasQuantity,
      gasPrice: row.gasPrice,
      isDeleted: row.isDeleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      gasPayer: gasPayerDomain,
    );
  }

  Future<PaymentDomain> _buildPaymentDomain(Payment row) async {
    // PaymentMember（paymentMemberId は NOT NULL のため必ず存在する想定）
    final payMemberRow = await (select(members)
          ..where((t) => t.id.equals(row.paymentMemberId)))
        .getSingleOrNull();

    // SplitMembers
    final splitJoins = await (select(paymentSplitMembers)
          ..where((t) => t.paymentId.equals(row.id)))
        .get();
    final splitList = <MemberDomain>[];
    for (final j in splitJoins) {
      final m = await (select(members)
            ..where((t) => t.id.equals(j.memberId)))
          .getSingleOrNull();
      if (m != null) splitList.add(_toMemberDomain(m));
    }

    // paymentMember が見つからない場合はフォールバック
    final paymentMember = payMemberRow != null
        ? _toMemberDomain(payMemberRow)
        : MemberDomain(
            id: row.paymentMemberId,
            memberName: '',
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          );

    return PaymentDomain(
      id: row.id,
      paymentSeq: row.paymentSeq,
      paymentAmount: row.paymentAmount,
      paymentMember: paymentMember,
      splitMembers: splitList,
      paymentMemo: row.paymentMemo,
      isDeleted: row.isDeleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      markLinkID: row.markLinkId,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → Companion 変換
  // ---------------------------------------------------------------------------

  EventsCompanion _toEventCompanion(EventDomain d) => EventsCompanion(
        id: Value(d.id),
        eventName: Value(d.eventName),
        transId: Value(d.trans?.id),
        kmPerGas: Value(d.kmPerGas),
        pricePerGas: Value(d.pricePerGas),
        payMemberId: Value(d.payMember?.id),
        isDeleted: Value(d.isDeleted),
        createdAt: Value(d.createdAt),
        updatedAt: Value(d.updatedAt),
      );

  MarkLinksCompanion _toMarkLinkCompanion(MarkLinkDomain d, String eventId) =>
      MarkLinksCompanion(
        id: Value(d.id),
        eventId: Value(eventId),
        markLinkSeq: Value(d.markLinkSeq),
        markLinkType: Value(d.markLinkType.name),
        markLinkDate: Value(d.markLinkDate),
        markLinkName: Value(d.markLinkName),
        meterValue: Value(d.meterValue),
        distanceValue: Value(d.distanceValue),
        memo: Value(d.memo),
        isFuel: Value(d.isFuel),
        pricePerGas: Value(d.pricePerGas),
        gasQuantity: Value(d.gasQuantity),
        gasPrice: Value(d.gasPrice),
        gasPayerId: Value(d.gasPayer?.id),
        isDeleted: Value(d.isDeleted),
        createdAt: Value(d.createdAt),
        updatedAt: Value(d.updatedAt),
      );

  PaymentsCompanion _toPaymentCompanion(PaymentDomain d, String eventId) =>
      PaymentsCompanion(
        id: Value(d.id),
        eventId: Value(eventId),
        paymentSeq: Value(d.paymentSeq),
        paymentAmount: Value(d.paymentAmount),
        paymentMemberId: Value(d.paymentMember.id),
        paymentMemo: Value(d.paymentMemo),
        isDeleted: Value(d.isDeleted),
        createdAt: Value(d.createdAt),
        updatedAt: Value(d.updatedAt),
        markLinkId: Value(d.markLinkID),
      );

  // ---------------------------------------------------------------------------
  // Row → Domain 変換（マスター）
  // ---------------------------------------------------------------------------

  MemberDomain _toMemberDomain(Member row) => MemberDomain(
        id: row.id,
        memberName: row.memberName,
        mailAddress: row.mailAddress,
        isVisible: row.isVisible,
        isDeleted: row.isDeleted,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  TagDomain _toTagDomain(Tag row) => TagDomain(
        id: row.id,
        tagName: row.tagName,
        isVisible: row.isVisible,
        isDeleted: row.isDeleted,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  ActionDomain _toActionDomain(Action row) => ActionDomain(
        id: row.id,
        actionName: row.actionName,
        isVisible: row.isVisible,
        isDeleted: row.isDeleted,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        endFlag: row.endFlag,
      );

  TransDomain _toTransDomain(Transport row) => TransDomain(
        id: row.id,
        transName: row.transName,
        kmPerGas: row.kmPerGas,
        meterValue: row.meterValue,
        isVisible: row.isVisible,
        isDeleted: row.isDeleted,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
