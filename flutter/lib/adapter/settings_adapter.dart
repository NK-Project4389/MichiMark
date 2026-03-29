import 'package:intl/intl.dart';

import '../domain/master/action/action_domain.dart';
import '../domain/master/member/member_domain.dart';
import '../domain/master/tag/tag_domain.dart';
import '../domain/master/trans/trans_domain.dart';
import '../features/shared/projection/action_item_projection.dart';
import '../features/shared/projection/member_item_projection.dart';
import '../features/shared/projection/tag_item_projection.dart';
import '../features/shared/projection/trans_item_projection.dart';

/// マスタ設定 Domain → Projection 変換
class SettingsAdapter {
  SettingsAdapter._();

  static final _numberFormat = NumberFormat('#,###');

  static TransItemProjection toTransProjection(TransDomain d) =>
      TransItemProjection(
        id: d.id,
        transName: d.transName,
        displayKmPerGas: _formatKmPerGas(d.kmPerGas),
        displayMeterValue: d.meterValue != null
            ? '${_numberFormat.format(d.meterValue)} km'
            : '未設定',
        isVisible: d.isVisible,
      );

  static MemberItemProjection toMemberProjection(MemberDomain d) =>
      MemberItemProjection(
        id: d.id,
        memberName: d.memberName,
        mailAddress: d.mailAddress,
        isVisible: d.isVisible,
      );

  static TagItemProjection toTagProjection(TagDomain d) => TagItemProjection(
        id: d.id,
        tagName: d.tagName,
        isVisible: d.isVisible,
      );

  static ActionItemProjection toActionProjection(ActionDomain d) =>
      ActionItemProjection(
        id: d.id,
        actionName: d.actionName,
        isVisible: d.isVisible,
      );

  static String _formatKmPerGas(int? value) {
    if (value == null) return '未設定';
    return '${(value / 10.0).toStringAsFixed(1)} km/L';
  }
}
