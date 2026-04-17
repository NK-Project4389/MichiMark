import 'package:intl/intl.dart';
import '../domain/topic/topic_domain.dart';
import '../domain/transaction/event/event_domain.dart';
import '../domain/transaction/mark_link/mark_or_link.dart';
import '../domain/master/member/member_domain.dart';
import '../domain/master/trans/trans_domain.dart';
import '../domain/master/tag/tag_domain.dart';
import '../domain/master/action/action_domain.dart';
import '../domain/transaction/mark_link/mark_link_domain.dart';
import '../domain/transaction/payment/payment_domain.dart';
import '../features/event_detail/projection/event_detail_projection.dart';
import '../features/event_detail/projection/basic_info_projection.dart';
import '../features/event_detail/projection/michi_info_list_projection.dart';
import '../features/event_detail/projection/payment_info_projection.dart';
import '../features/shared/projection/member_item_projection.dart';
import '../features/shared/projection/trans_item_projection.dart';
import '../features/shared/projection/tag_item_projection.dart';
import '../features/shared/projection/action_item_projection.dart';
import '../features/shared/projection/mark_link_item_projection.dart';
import '../features/shared/projection/payment_item_projection.dart';

/// EventDomain → EventDetailProjection の変換
class EventDetailAdapter {
  EventDetailAdapter._();

  static final _dateFormat = DateFormat('yyyy/MM/dd');
  static final _numberFormat = NumberFormat('#,###');

  static EventDetailProjection toProjection(EventDomain event) {
    return EventDetailProjection(
      eventId: event.id,
      basicInfo: _toBasicInfo(event),
      michiInfo: _toMichiInfo(event),
      paymentInfo: _toPaymentInfo(event),
    );
  }

  // ── BasicInfo ──────────────────────────────────────────────

  static BasicInfoProjection _toBasicInfo(EventDomain event) {
    return BasicInfoProjection(
      eventId: event.id,
      eventName: event.eventName,
      trans: event.trans != null ? _toTransItem(event.trans!) : null,
      tags: event.tags
          .where((t) => !t.isDeleted && t.isVisible)
          .map(_toTagItem)
          .toList(),
      members: event.members
          .where((m) => !m.isDeleted && m.isVisible)
          .map(_toMemberItem)
          .toList(),
      kmPerGas: event.kmPerGas,
      displayKmPerGas: _formatKmPerGas(event.kmPerGas),
      pricePerGas: event.pricePerGas,
      displayPricePerGas: _formatPricePerGas(event.pricePerGas),
      payMember: event.payMember != null ? _toMemberItem(event.payMember!) : null,
    );
  }

  // ── MichiInfo ─────────────────────────────────────────────

  static MichiInfoListProjection _toMichiInfo(EventDomain event) {
    final sorted = event.markLinks
        .where((ml) => !ml.isDeleted)
        .toList()
      ..sort((a, b) => a.markLinkSeq.compareTo(b.markLinkSeq));

    final projections = sorted.map(_toMarkLinkItem).toList();
    return MichiInfoListProjection(
      items: _applyMeterDiff(projections),
    );
  }

  /// ソート済み MarkLinkItemProjection リストを走査して
  /// 連続する Mark 間の displayMeterDiff を計算して返す
  static List<MarkLinkItemProjection> _applyMeterDiff(
    List<MarkLinkItemProjection> items,
  ) {
    int? prevMeterValue;
    return items.map((item) {
      if (item.markLinkType != MarkOrLink.mark) return item;

      // displayMeterValue から数値を逆算する
      // （Adapter では meterValue を直接持っていないため文字列を解析する）
      final rawMeter = item.displayMeterValue;
      if (rawMeter == null) {
        prevMeterValue = null;
        return item;
      }
      final parsed = int.tryParse(rawMeter.replaceAll(',', '').replaceAll(' km', ''));
      if (parsed == null) {
        prevMeterValue = null;
        return item;
      }

      final prev = prevMeterValue;
      prevMeterValue = parsed;

      if (prev == null) return item;

      final diff = parsed - prev;
      final sign = diff >= 0 ? '+' : '-';
      final absStr = _numberFormat.format(diff.abs());
      final diffStr = '$sign$absStr km';

      return MarkLinkItemProjection(
        id: item.id,
        markLinkSeq: item.markLinkSeq,
        markLinkType: item.markLinkType,
        displayDate: item.displayDate,
        markLinkName: item.markLinkName,
        members: item.members,
        displayMeterValue: item.displayMeterValue,
        displayMeterDiff: diffStr,
        displayDistanceValue: item.displayDistanceValue,
        actions: item.actions,
        isFuel: item.isFuel,
        pricePerGas: item.pricePerGas,
        gasQuantity: item.gasQuantity,
        gasPrice: item.gasPrice,
        memo: item.memo,
      );
    }).toList();
  }

  // ── PaymentInfo ───────────────────────────────────────────

  static PaymentInfoProjection _toPaymentInfo(EventDomain event) {
    final valid = event.payments
        .where((p) => !p.isDeleted)
        .toList()
      ..sort((a, b) => a.paymentSeq.compareTo(b.paymentSeq));

    final total = valid.fold(0, (sum, p) => sum + p.paymentAmount);

    // markLinkID != null: 日付→名称でグループ化
    final linked = valid.where((p) => p.markLinkID != null).toList();
    final direct = valid.where((p) => p.markLinkID == null).toList();

    // 日付グループ（markLinkDate の日付で groupBy）
    final dateMap = <String, List<PaymentDomain>>{};
    for (final p in linked) {
      final ml = event.markLinks
          .where((ml) => ml.id == p.markLinkID && !ml.isDeleted)
          .firstOrNull;
      final dateKey = ml != null
          ? _dateFormat.format(ml.markLinkDate)
          : _dateFormat.format(DateTime(1970));
      dateMap.putIfAbsent(dateKey, () => []).add(p);
    }

    final dateGroups = dateMap.entries.map((dateEntry) {
      final nameMap = <String, List<PaymentDomain>>{};
      for (final p in dateEntry.value) {
        final mlId = p.markLinkID!;
        nameMap.putIfAbsent(mlId, () => []).add(p);
      }
      final nameGroups = nameMap.entries.map((nameEntry) {
        final mlId = nameEntry.key;
        final ml = event.markLinks
            .where((ml) => ml.id == mlId && !ml.isDeleted)
            .firstOrNull;
        final displayName = (ml?.markLinkName?.isNotEmpty == true)
            ? ml!.markLinkName!
            : '名称なし';
        final groupTotal =
            nameEntry.value.fold(0, (sum, p) => sum + p.paymentAmount);
        return PaymentNameGroupProjection(
          markLinkId: mlId,
          displayName: displayName,
          items: nameEntry.value.map(_toPaymentItem).toList(),
          displayGroupTotal: '${_numberFormat.format(groupTotal)} 円',
        );
      }).toList();
      return PaymentDateGroupProjection(
        displayDate: dateEntry.key,
        nameGroups: nameGroups,
      );
    }).toList()
      ..sort((a, b) => a.displayDate.compareTo(b.displayDate));

    return PaymentInfoProjection(
      dateGroups: dateGroups,
      directItems: direct.map(_toPaymentItem).toList(),
      displayTotalAmount: '${_numberFormat.format(total)} 円',
      showMemberSection: event.topic?.topicType != TopicType.visitWork,
    );
  }

  // ── Item converters ───────────────────────────────────────

  static MemberItemProjection _toMemberItem(MemberDomain d) =>
      MemberItemProjection(
        id: d.id,
        memberName: d.memberName,
        mailAddress: d.mailAddress,
        isVisible: d.isVisible,
      );

  static TransItemProjection _toTransItem(TransDomain d) => TransItemProjection(
        id: d.id,
        transName: d.transName,
        displayKmPerGas: _formatKmPerGas(d.kmPerGas),
        displayMeterValue: d.meterValue != null
            ? '${_numberFormat.format(d.meterValue)} km'
            : '未設定',
        isVisible: d.isVisible,
      );

  static TagItemProjection _toTagItem(TagDomain d) => TagItemProjection(
        id: d.id,
        tagName: d.tagName,
        isVisible: d.isVisible,
      );

  static ActionItemProjection _toActionItem(ActionDomain d) =>
      ActionItemProjection(
        id: d.id,
        actionName: d.actionName,
        isVisible: d.isVisible,
      );

  static MarkLinkItemProjection _toMarkLinkItem(MarkLinkDomain d) {
    final gasQuantity =
        d.gasQuantity != null ? d.gasQuantity! / 10.0 : null;

    return MarkLinkItemProjection(
      id: d.id,
      markLinkSeq: d.markLinkSeq,
      markLinkType: d.markLinkType,
      displayDate: _dateFormat.format(d.markLinkDate),
      markLinkName: d.markLinkName ?? '',
      members: d.members
          .where((m) => !m.isDeleted)
          .map(_toMemberItem)
          .toList(),
      displayMeterValue: d.meterValue != null
          ? '${_numberFormat.format(d.meterValue)} km'
          : null,
      displayDistanceValue: d.distanceValue != null
          ? '${_numberFormat.format(d.distanceValue)} km'
          : null,
      actions: d.actions
          .where((a) => !a.isDeleted)
          .map(_toActionItem)
          .toList(),
      isFuel: d.isFuel,
      pricePerGas: d.pricePerGas,
      gasQuantity: gasQuantity,
      gasPrice: d.gasPrice,
      memo: d.memo,
    );
  }

  static PaymentItemProjection _toPaymentItem(PaymentDomain d) =>
      PaymentItemProjection(
        id: d.id,
        displayAmount: '${_numberFormat.format(d.paymentAmount)} 円',
        payer: _toMemberItem(d.paymentMember),
        splitMembers: d.splitMembers.map(_toMemberItem).toList(),
        memo: d.paymentMemo,
      );

  // ── Formatters ────────────────────────────────────────────

  static String _formatKmPerGas(int? value) {
    if (value == null) return '未設定';
    return '${(value / 10.0).toStringAsFixed(1)} km/L';
  }

  static String _formatPricePerGas(int? value) {
    if (value == null) return '未設定';
    return '$value 円/L';
  }
}
