import 'package:equatable/equatable.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/topic/topic_config.dart';

sealed class LinkDetailEvent extends Equatable {
  const LinkDetailEvent();
}

/// 画面が表示されたとき
class LinkDetailStarted extends LinkDetailEvent {
  final String eventId;
  final String markLinkId;
  final TopicConfig topicConfig;

  /// メンバー選択候補（基本情報のメンバーのみを表示するために使用）
  final List<MemberDomain> eventMembers;

  const LinkDetailStarted({
    required this.eventId,
    required this.markLinkId,
    TopicConfig? topicConfig,
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
  List<Object?> get props => [eventId, markLinkId, topicConfig, eventMembers];
}

/// 戻るボタンが押されたとき
class LinkDetailDismissPressed extends LinkDetailEvent {
  const LinkDetailDismissPressed();

  @override
  List<Object?> get props => [];
}

/// 名称が変更されたとき
class LinkDetailNameChanged extends LinkDetailEvent {
  final String name;
  const LinkDetailNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

/// 走行距離入力が変更されたとき
class LinkDetailDistanceChanged extends LinkDetailEvent {
  final String input;
  const LinkDetailDistanceChanged(this.input);

  @override
  List<Object?> get props => [input];
}

/// メンバー編集ボタンが押されたとき
class LinkDetailEditMembersPressed extends LinkDetailEvent {
  const LinkDetailEditMembersPressed();

  @override
  List<Object?> get props => [];
}

/// 選択画面からメンバーが返却されたとき
class LinkDetailMembersSelected extends LinkDetailEvent {
  final List<MemberDomain> members;
  const LinkDetailMembersSelected(this.members);

  @override
  List<Object?> get props => [members];
}

/// アクション編集ボタンが押されたとき
class LinkDetailEditActionsPressed extends LinkDetailEvent {
  const LinkDetailEditActionsPressed();

  @override
  List<Object?> get props => [];
}

/// 選択画面からアクションが返却されたとき
class LinkDetailActionsSelected extends LinkDetailEvent {
  final List<ActionDomain> actions;
  const LinkDetailActionsSelected(this.actions);

  @override
  List<Object?> get props => [actions];
}

/// メモが変更されたとき
class LinkDetailMemoChanged extends LinkDetailEvent {
  final String memo;
  const LinkDetailMemoChanged(this.memo);

  @override
  List<Object?> get props => [memo];
}

/// 給油フラグがトグルされたとき
class LinkDetailIsFuelToggled extends LinkDetailEvent {
  const LinkDetailIsFuelToggled();

  @override
  List<Object?> get props => [];
}

/// 保存ボタンが押されたとき
class LinkDetailSaveTapped extends LinkDetailEvent {
  const LinkDetailSaveTapped();

  @override
  List<Object?> get props => [];
}

/// EventDetailBlocからTopicConfigが更新されたとき
class LinkDetailTopicConfigUpdated extends LinkDetailEvent {
  final TopicConfig config;
  const LinkDetailTopicConfigUpdated(this.config);

  @override
  List<Object?> get props => [config];
}

/// FuelDetailBlocのDelegateを受けてFuel入力値を同期するとき
class LinkDetailFuelFieldsChanged extends LinkDetailEvent {
  final String pricePerGas;
  final String gasQuantity;
  final String gasPrice;

  const LinkDetailFuelFieldsChanged({
    required this.pricePerGas,
    required this.gasQuantity,
    required this.gasPrice,
  });

  @override
  List<Object?> get props => [pricePerGas, gasQuantity, gasPrice];
}
