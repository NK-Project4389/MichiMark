import 'package:equatable/equatable.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/topic/topic_config.dart';

sealed class MarkDetailEvent extends Equatable {
  const MarkDetailEvent();
}

/// 画面が表示されたとき
class MarkDetailStarted extends MarkDetailEvent {
  final String eventId;
  final String markLinkId;
  final TopicConfig topicConfig;

  /// メーター入力の初期値（新規追加時のみ使用）
  final String initialMeterValueInput;

  /// メンバーの初期値（前の地点から引き継ぎ。新規追加時のみ使用）
  final List<MemberDomain> initialSelectedMembers;

  /// 日付の初期値（null の場合は Bloc 側で DateTime.now() を使用）
  final DateTime? initialMarkLinkDate;

  /// メンバー選択候補（イベントメンバー一覧）
  final List<MemberDomain> eventMembers;

  const MarkDetailStarted({
    required this.eventId,
    required this.markLinkId,
    TopicConfig? topicConfig,
    this.initialMeterValueInput = '',
    this.initialSelectedMembers = const [],
    this.initialMarkLinkDate,
    this.eventMembers = const [],
  }) : topicConfig = topicConfig ?? const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        );

  @override
  List<Object?> get props => [
        eventId,
        markLinkId,
        topicConfig,
        initialMeterValueInput,
        initialSelectedMembers,
        initialMarkLinkDate,
        eventMembers,
      ];
}

/// 戻るボタンが押されたとき
class MarkDetailDismissPressed extends MarkDetailEvent {
  const MarkDetailDismissPressed();

  @override
  List<Object?> get props => [];
}

/// 名称が変更されたとき
class MarkDetailNameChanged extends MarkDetailEvent {
  final String name;
  const MarkDetailNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

/// 日付が変更されたとき
class MarkDetailDateChanged extends MarkDetailEvent {
  final DateTime date;
  const MarkDetailDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

/// メンバーチップがタップされたとき（インライン選択）
class MarkDetailMemberChipToggled extends MarkDetailEvent {
  final MemberDomain member;
  const MarkDetailMemberChipToggled(this.member);

  @override
  List<Object?> get props => [member];
}

/// 累積メーター入力が変更されたとき
class MarkDetailMeterValueChanged extends MarkDetailEvent {
  final String input;
  const MarkDetailMeterValueChanged(this.input);

  @override
  List<Object?> get props => [input];
}

/// アクション編集ボタンが押されたとき
class MarkDetailEditActionsPressed extends MarkDetailEvent {
  const MarkDetailEditActionsPressed();

  @override
  List<Object?> get props => [];
}

/// 選択画面からアクションが返却されたとき
class MarkDetailActionsSelected extends MarkDetailEvent {
  final List<ActionDomain> actions;
  const MarkDetailActionsSelected(this.actions);

  @override
  List<Object?> get props => [actions];
}

/// メモが変更されたとき
class MarkDetailMemoChanged extends MarkDetailEvent {
  final String memo;
  const MarkDetailMemoChanged(this.memo);

  @override
  List<Object?> get props => [memo];
}

/// 給油フラグがトグルされたとき
class MarkDetailIsFuelToggled extends MarkDetailEvent {
  const MarkDetailIsFuelToggled();

  @override
  List<Object?> get props => [];
}

/// 保存ボタンが押されたとき
class MarkDetailSaveTapped extends MarkDetailEvent {
  const MarkDetailSaveTapped();

  @override
  List<Object?> get props => [];
}

/// EventDetailBlocからTopicConfigが更新されたとき
class MarkDetailTopicConfigUpdated extends MarkDetailEvent {
  final TopicConfig config;
  const MarkDetailTopicConfigUpdated(this.config);

  @override
  List<Object?> get props => [config];
}

/// ガソリン支払者チップがタップされたとき（インライン選択）
class MarkDetailGasPayerChipToggled extends MarkDetailEvent {
  final MemberDomain member;
  const MarkDetailGasPayerChipToggled(this.member);

  @override
  List<Object?> get props => [member];
}

/// メンバーを全選択するとき
class MarkDetailMembersAllSelected extends MarkDetailEvent {
  const MarkDetailMembersAllSelected();

  @override
  List<Object?> get props => [];
}

/// メンバーを全解除するとき
class MarkDetailMembersAllCleared extends MarkDetailEvent {
  const MarkDetailMembersAllCleared();

  @override
  List<Object?> get props => [];
}

/// FuelDetailBlocのDelegateを受けてFuel入力値を同期するとき
class MarkDetailFuelFieldsChanged extends MarkDetailEvent {
  final String pricePerGas;
  final String gasQuantity;
  final String gasPrice;

  const MarkDetailFuelFieldsChanged({
    required this.pricePerGas,
    required this.gasQuantity,
    required this.gasPrice,
  });

  @override
  List<Object?> get props => [pricePerGas, gasQuantity, gasPrice];
}
