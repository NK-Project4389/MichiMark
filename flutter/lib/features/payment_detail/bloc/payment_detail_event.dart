import 'package:equatable/equatable.dart';
import '../../../domain/master/member/member_domain.dart';

sealed class PaymentDetailEvent extends Equatable {
  const PaymentDetailEvent();
}

/// 画面が表示されたとき
class PaymentDetailStarted extends PaymentDetailEvent {
  final String eventId;

  /// 既存編集時は paymentId を指定。null = 新規作成
  final String? paymentId;

  const PaymentDetailStarted({required this.eventId, this.paymentId});

  @override
  List<Object?> get props => [eventId, paymentId];
}

/// 支払金額が変更されたとき
class PaymentDetailAmountChanged extends PaymentDetailEvent {
  final String value;
  const PaymentDetailAmountChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// 支払者チップがタップされたとき（インライン選択・single）
class PaymentDetailPayMemberChipToggled extends PaymentDetailEvent {
  final MemberDomain member;
  const PaymentDetailPayMemberChipToggled(this.member);

  @override
  List<Object?> get props => [member];
}

/// 割り勘メンバーチップがタップされたとき（インライン選択・multiple、支払者は常にON固定）
class PaymentDetailSplitMemberChipToggled extends PaymentDetailEvent {
  final MemberDomain member;
  const PaymentDetailSplitMemberChipToggled(this.member);

  @override
  List<Object?> get props => [member];
}

/// メモが変更されたとき
class PaymentDetailMemoChanged extends PaymentDetailEvent {
  final String value;
  const PaymentDetailMemoChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// 保存ボタンが押されたとき
class PaymentDetailSaveTapped extends PaymentDetailEvent {
  const PaymentDetailSaveTapped();

  @override
  List<Object?> get props => [];
}

/// 割り勘メンバーを全選択するとき
class PaymentDetailSplitMembersAllSelected extends PaymentDetailEvent {
  const PaymentDetailSplitMembersAllSelected();

  @override
  List<Object?> get props => [];
}

/// 割り勘メンバーを全解除するとき（支払者は除外しない）
class PaymentDetailSplitMembersAllCleared extends PaymentDetailEvent {
  const PaymentDetailSplitMembersAllCleared();

  @override
  List<Object?> get props => [];
}

/// キャンセルボタンが押されたとき
class PaymentDetailCancelTapped extends PaymentDetailEvent {
  const PaymentDetailCancelTapped();

  @override
  List<Object?> get props => [];
}

/// キャンセル確認ダイアログで「破棄する」が選択されたとき
class PaymentDetailCancelDiscardConfirmed extends PaymentDetailEvent {
  const PaymentDetailCancelDiscardConfirmed();

  @override
  List<Object?> get props => [];
}

/// キャンセル確認ダイアログが閉じられたとき（「編集を続ける」選択）
class PaymentDetailCancelDialogDismissed extends PaymentDetailEvent {
  const PaymentDetailCancelDialogDismissed();

  @override
  List<Object?> get props => [];
}
