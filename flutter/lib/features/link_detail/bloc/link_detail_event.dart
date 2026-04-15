import 'package:equatable/equatable.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/transaction/payment/payment_domain.dart';

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

/// メンバーチップがタップされたとき（インライン選択）
class LinkDetailMemberChipToggled extends LinkDetailEvent {
  final MemberDomain member;
  const LinkDetailMemberChipToggled(this.member);

  @override
  List<Object?> get props => [member];
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

/// ガソリン支払者チップがタップされたとき（インライン選択）
class LinkDetailGasPayerChipToggled extends LinkDetailEvent {
  final MemberDomain member;
  const LinkDetailGasPayerChipToggled(this.member);

  @override
  List<Object?> get props => [member];
}

/// メンバーを全選択するとき
class LinkDetailMembersAllSelected extends LinkDetailEvent {
  const LinkDetailMembersAllSelected();

  @override
  List<Object?> get props => [];
}

/// メンバーを全解除するとき
class LinkDetailMembersAllCleared extends LinkDetailEvent {
  const LinkDetailMembersAllCleared();

  @override
  List<Object?> get props => [];
}

/// キャンセル確認ダイアログで「破棄する」が選択されたとき
class LinkDetailCancelDiscardConfirmed extends LinkDetailEvent {
  const LinkDetailCancelDiscardConfirmed();

  @override
  List<Object?> get props => [];
}

/// キャンセル確認ダイアログが閉じられたとき（「編集を続ける」選択）
class LinkDetailCancelDialogDismissed extends LinkDetailEvent {
  const LinkDetailCancelDialogDismissed();

  @override
  List<Object?> get props => [];
}

/// PaymentDetailから戻った後に支払セクションをリロードするとき
class LinkDetailPaymentsReloadRequested extends LinkDetailEvent {
  const LinkDetailPaymentsReloadRequested();

  @override
  List<Object?> get props => [];
}

/// 支払セクション「＋」ボタンが押されたとき
class LinkDetailPaymentPlusTapped extends LinkDetailEvent {
  const LinkDetailPaymentPlusTapped();

  @override
  List<Object?> get props => [];
}

/// 支払セクションの既存カードがタップされたとき
class LinkDetailPaymentTapped extends LinkDetailEvent {
  final String paymentId;
  const LinkDetailPaymentTapped(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

/// EventDomainの payments が更新されたとき（再表示用）
class LinkDetailPaymentsUpdated extends LinkDetailEvent {
  final List<PaymentDomain> allPayments;
  const LinkDetailPaymentsUpdated(this.allPayments);

  @override
  List<Object?> get props => [allPayments];
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
