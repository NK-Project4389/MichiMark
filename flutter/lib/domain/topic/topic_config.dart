import 'package:equatable/equatable.dart';
import 'topic_domain.dart';
import 'topic_theme_color.dart';

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

  /// 地点（Mark）タップ時に提示するActionIDのリスト（REQ-002）
  final List<String> markActions;

  /// 区間（Link）タップ時に提示するActionIDのリスト（REQ-002）
  final List<String> linkActions;

  /// テーマカラー（REQ-007確定値）
  final TopicThemeColor themeColor;

  /// トピックの日本語表示名。EventDetailヘッダーラベルに使用（REQ-008）
  final String displayName;

  const TopicConfig({
    required this.showMeterValue,
    required this.showFuelDetail,
    required this.allowLinkAdd,
    required this.showLinkDistance,
    required this.showKmPerGas,
    required this.showPricePerGas,
    required this.showPayMember,
    required this.showPaymentInfoTab,
    this.markActions = const [],
    this.linkActions = const [],
    this.themeColor = TopicThemeColor.brandTeal,
    this.displayName = '',
  });

  /// TopicTypeからTopicConfigを生成するファクトリ（エイリアス）。
  static TopicConfig forType(TopicType type) => TopicConfig.fromTopicType(type);

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
          // SeedDataで定義される固定UUIDを参照（出発・到着）
          markActions: ['action-seed-depart', 'action-seed-arrive'],
          linkActions: [],
          themeColor: TopicThemeColor.emeraldGreen,
          displayName: '移動コスト可視化',
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
          markActions: [],
          linkActions: [],
          themeColor: TopicThemeColor.amberOrange,
          displayName: '旅費可視化',
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
        markActions,
        linkActions,
        themeColor,
        displayName,
      ];
}
