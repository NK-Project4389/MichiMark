import 'package:equatable/equatable.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/master/member/member_domain.dart';

sealed class MarkDetailEvent extends Equatable {
  const MarkDetailEvent();
}

/// 画面が表示されたとき
class MarkDetailStarted extends MarkDetailEvent {
  final String eventId;
  final String markLinkId;
  const MarkDetailStarted({required this.eventId, required this.markLinkId});

  @override
  List<Object?> get props => [eventId, markLinkId];
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

/// メンバー編集ボタンが押されたとき
class MarkDetailEditMembersPressed extends MarkDetailEvent {
  const MarkDetailEditMembersPressed();

  @override
  List<Object?> get props => [];
}

/// 選択画面からメンバーが返却されたとき
class MarkDetailMembersSelected extends MarkDetailEvent {
  final List<MemberDomain> members;
  const MarkDetailMembersSelected(this.members);

  @override
  List<Object?> get props => [members];
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
