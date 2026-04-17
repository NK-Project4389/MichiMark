import 'package:intl/intl.dart';
import '../domain/transaction/mark_link/mark_or_link.dart';
import '../features/link_detail/draft/link_detail_draft.dart';
import '../features/mark_detail/draft/mark_detail_draft.dart';
import '../features/shared/projection/action_item_projection.dart';
import '../features/shared/projection/mark_link_item_projection.dart';
import '../features/shared/projection/member_item_projection.dart';

/// MarkDetailDraft / LinkDetailDraft → MarkLinkItemProjection 変換
class MarkLinkDraftAdapter {
  MarkLinkDraftAdapter._();

  static final _dateFormat = DateFormat('yyyy/MM/dd');
  static final _numberFormat = NumberFormat('#,###');

  static MarkLinkItemProjection fromMarkDraft({
    required String markLinkId,
    required int markLinkSeq,
    required MarkDetailDraft draft,
  }) {
    final meterValue = int.tryParse(draft.meterValueInput);
    final pricePerGas = int.tryParse(draft.pricePerGasInput);
    final gasQuantity = double.tryParse(draft.gasQuantityInput);
    final gasPrice = int.tryParse(draft.gasPriceInput);

    return MarkLinkItemProjection(
      id: markLinkId,
      markLinkSeq: markLinkSeq,
      markLinkType: MarkOrLink.mark,
      displayDate: _dateFormat.format(draft.markLinkDate),
      dateKey: _dateFormat.format(draft.markLinkDate),
      markLinkName: draft.markLinkName,
      members: draft.selectedMembers
          .map((m) => MemberItemProjection(
                id: m.id,
                memberName: m.memberName,
                mailAddress: m.mailAddress,
                isVisible: m.isVisible,
              ))
          .toList(),
      displayMeterValue: meterValue != null
          ? '${_numberFormat.format(meterValue)} km'
          : null,
      actions: draft.selectedActions
          .map((a) => ActionItemProjection(
                id: a.id,
                actionName: a.actionName,
                isVisible: a.isVisible,
              ))
          .toList(),
      isFuel: draft.isFuel,
      pricePerGas: pricePerGas,
      gasQuantity: gasQuantity,
      gasPrice: gasPrice,
      memo: draft.memo.isEmpty ? null : draft.memo,
    );
  }

  static MarkLinkItemProjection fromLinkDraft({
    required String markLinkId,
    required int markLinkSeq,
    required LinkDetailDraft draft,
  }) {
    final distanceValue = int.tryParse(draft.distanceValueInput);
    final pricePerGas = int.tryParse(draft.pricePerGasInput);
    final gasQuantity = double.tryParse(draft.gasQuantityInput);
    final gasPrice = int.tryParse(draft.gasPriceInput);

    return MarkLinkItemProjection(
      id: markLinkId,
      markLinkSeq: markLinkSeq,
      markLinkType: MarkOrLink.link,
      displayDate: _dateFormat.format(draft.markLinkDate),
      dateKey: _dateFormat.format(draft.markLinkDate),
      markLinkName: draft.markLinkName,
      members: draft.selectedMembers
          .map((m) => MemberItemProjection(
                id: m.id,
                memberName: m.memberName,
                mailAddress: m.mailAddress,
                isVisible: m.isVisible,
              ))
          .toList(),
      displayDistanceValue: distanceValue != null
          ? '${_numberFormat.format(distanceValue)} km'
          : null,
      actions: draft.selectedActions
          .map((a) => ActionItemProjection(
                id: a.id,
                actionName: a.actionName,
                isVisible: a.isVisible,
              ))
          .toList(),
      isFuel: draft.isFuel,
      pricePerGas: pricePerGas,
      gasQuantity: gasQuantity,
      gasPrice: gasPrice,
      memo: draft.memo.isEmpty ? null : draft.memo,
    );
  }
}
