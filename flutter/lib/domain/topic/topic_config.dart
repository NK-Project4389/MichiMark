import 'package:equatable/equatable.dart';
import 'topic_domain.dart';
import 'topic_theme_color.dart';

/// MichiInfoの追加FABメニューに表示できる項目の種別
enum AddMenuItemType { mark, link }

/// TopicConfigはTopicTypeを入力として表示制御フラグのセットを返す値オブジェクト。
/// BlocやWidgetから参照される読み取り専用の設定値。
///
/// Widget内でTopicTypeをswitch/if比較することは禁止。TopicConfigのフラグのみ参照する。
class TopicConfig extends Equatable {
  /// MarkDetailの累積メーターを表示するか
  final bool showMeterValue;

  /// MarkDetail/LinkDetailの給油スイッチ+FuelDetailを表示するか
  final bool showFuelDetail;

  /// MichiInfoの追加FABメニューに表示する項目。
  /// - [mark, link]: ボトムシートで両方選択可能
  /// - [mark]: ボトムシートなしで直接MarkDetailへ遷移
  /// - [link]: ボトムシートなしで直接LinkDetailへ遷移
  /// - []: FABを非表示
  final List<AddMenuItemType> addMenuItems;

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

  /// アクションタイム記録ボタン（⚡）・地点アクションボタン・状態バッジを表示するか
  final bool showActionTimeButton;

  /// テーマカラー（REQ-007確定値）
  final TopicThemeColor themeColor;

  /// トピックの日本語表示名。EventDetailヘッダーラベルに使用（REQ-008）
  final String displayName;

  /// MarkDetail/LinkDetailの名称フィールドを表示するか（REQ-moving_cost_name_hidden）
  final bool showNameField;

  /// Markカードに日付を表示するか（F-4 MichiInfoカードトピック別表示切り替え）
  final bool showMarkDate;

  /// Markカードに参加メンバー名を表示するか（F-4 MichiInfoカードトピック別表示切り替え）
  final bool showMarkMembers;

  /// BasicInfo/MarkDetail/PaymentDetailのメンバーセクションを表示するか（F-6 visitWork以外はtrue）
  final bool showMemberSection;

  /// Linkカードに日付を表示するか（F-4 MichiInfoカードトピック別表示切り替え）
  final bool showLinkDate;

  const TopicConfig({
    required this.showMeterValue,
    required this.showFuelDetail,
    required this.addMenuItems,
    required this.showLinkDistance,
    required this.showKmPerGas,
    required this.showPricePerGas,
    required this.showPayMember,
    required this.showPaymentInfoTab,
    this.markActions = const [],
    this.linkActions = const [],
    this.showActionTimeButton = false,
    this.themeColor = TopicThemeColor.brandTeal,
    this.displayName = '',
    this.showNameField = true,
    this.showMarkDate = false,
    this.showMarkMembers = false,
    this.showLinkDate = false,
    this.showMemberSection = true,
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
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: false,
          showPricePerGas: false,
          showPayMember: false,
          showPaymentInfoTab: true,
          markActions: [],
          linkActions: [],
          showActionTimeButton: false,
          themeColor: TopicThemeColor.emeraldGreen,
          displayName: '移動コスト（給油から計算）',
          showNameField: false,
          showMarkDate: true,
          showMarkMembers: false,
          showLinkDate: true,
        ),
      TopicType.movingCostEstimated => const TopicConfig(
          showMeterValue: true,
          showFuelDetail: false,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
          markActions: [],
          linkActions: [],
          showActionTimeButton: false,
          themeColor: TopicThemeColor.emeraldGreen,
          displayName: '移動コスト（燃費で推定）',
          showNameField: false,
          showMarkDate: true,
          showMarkMembers: false,
          showLinkDate: true,
        ),
      TopicType.travelExpense => const TopicConfig(
          showMeterValue: false,
          showFuelDetail: false,
          addMenuItems: [AddMenuItemType.mark],
          showLinkDistance: false,
          showKmPerGas: false,
          showPricePerGas: false,
          showPayMember: false,
          showPaymentInfoTab: true,
          markActions: [],
          linkActions: [],
          showActionTimeButton: false,
          themeColor: TopicThemeColor.amberOrange,
          displayName: '旅費可視化',
          showNameField: true,
          showMarkDate: true,
          showMarkMembers: true,
          showLinkDate: false,
        ),
      TopicType.visitWork => const TopicConfig(
          showMeterValue: true,
          showFuelDetail: false,
          addMenuItems: [AddMenuItemType.mark],
          showLinkDistance: false,
          showKmPerGas: false,
          showPricePerGas: false,
          showPayMember: false,
          showPaymentInfoTab: true,
          markActions: [
            'visit_work_arrive',
            'visit_work_start',
            'visit_work_end',
            'visit_work_depart',
          ],
          linkActions: [],
          showActionTimeButton: true,
          themeColor: TopicThemeColor.skyBlue,
          displayName: '訪問作業',
          showNameField: true,
          showMarkDate: true,
          showMarkMembers: false,
          showLinkDate: false,
          showMemberSection: false,
        ),
    };
  }

  @override
  List<Object?> get props => [
        showMeterValue,
        showFuelDetail,
        addMenuItems,
        showLinkDistance,
        showKmPerGas,
        showPricePerGas,
        showPayMember,
        showPaymentInfoTab,
        markActions,
        linkActions,
        showActionTimeButton,
        themeColor,
        displayName,
        showNameField,
        showMarkDate,
        showMarkMembers,
        showLinkDate,
        showMemberSection,
      ];
}
