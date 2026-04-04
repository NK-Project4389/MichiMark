import 'package:equatable/equatable.dart';
import 'topic_domain.dart';

/// TopicConfigはTopicTypeを入力として表示制御フラグのセットを返す値オブジェクト。
/// BlocやWidgetから参照される読み取り専用の設定値。
///
/// Widget内でTopicTypeをswitch/if比較することは禁止。TopicConfigのフラグのみ参照する。
class TopicConfig extends Equatable {
  /// MarkDetailの累積メーターを表示するか
  final bool showMeterValue;

  /// MarkDetail/LinkDetailの給油スイッチ+FuelDetailを表示するか
  final bool showFuelDetail;

  /// LinkDetailの新規追加を許可するか
  final bool allowLinkAdd;

  /// LinkDetailの走行距離を表示するか
  final bool showLinkDistance;

  /// BasicInfoの燃費フィールドを表示するか
  final bool showKmPerGas;

  /// BasicInfoのガソリン単価フィールドを表示するか
  final bool showPricePerGas;

  /// BasicInfoのガソリン支払者フィールドを表示するか
  final bool showPayMember;

  /// EventDetailのPaymentInfoタブを表示するか
  final bool showPaymentInfoTab;

  const TopicConfig({
    required this.showMeterValue,
    required this.showFuelDetail,
    required this.allowLinkAdd,
    required this.showLinkDistance,
    required this.showKmPerGas,
    required this.showPricePerGas,
    required this.showPayMember,
    required this.showPaymentInfoTab,
  });

  /// TopicTypeからTopicConfigを生成するファクトリ。
  /// Topic未設定（null）の場合は movingCost 相当の設定にフォールバックする。
  factory TopicConfig.fromTopicType(TopicType? type) {
    final resolved = type ?? TopicType.movingCost;
    return switch (resolved) {
      TopicType.movingCost => const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          allowLinkAdd: true,
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
      TopicType.travelExpense => const TopicConfig(
          showMeterValue: false,
          showFuelDetail: false,
          allowLinkAdd: false,
          showLinkDistance: false,
          showKmPerGas: false,
          showPricePerGas: false,
          showPayMember: false,
          showPaymentInfoTab: true,
        ),
    };
  }

  @override
  List<Object?> get props => [
        showMeterValue,
        showFuelDetail,
        allowLinkAdd,
        showLinkDistance,
        showKmPerGas,
        showPricePerGas,
        showPayMember,
        showPaymentInfoTab,
      ];
}
