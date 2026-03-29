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

/// 支払者選択ボタンが押されたとき
class PaymentDetailEditMemberPressed extends PaymentDetailEvent {
  const PaymentDetailEditMemberPressed();

  @override
  List<Object?> get props => [];
}

/// 選択画面から支払者が返却されたとき
class PaymentDetailMemberSelected extends PaymentDetailEvent {
  final MemberDomain member;
  const PaymentDetailMemberSelected(this.member);

  @override
  List<Object?> get props => [member];
}

/// 割り勘メンバー選択ボタンが押されたとき
class PaymentDetailEditSplitMembersPressed extends PaymentDetailEvent {
  const PaymentDetailEditSplitMembersPressed();

  @override
  List<Object?> get props => [];
}

/// 選択画面から割り勘メンバーが返却されたとき
class PaymentDetailSplitMembersSelected extends PaymentDetailEvent {
  final List<MemberDomain> members;
  const PaymentDetailSplitMembersSelected(this.members);

  @override
  List<Object?> get props => [members];
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

/// キャンセルボタンが押されたとき
class PaymentDetailCancelTapped extends PaymentDetailEvent {
  const PaymentDetailCancelTapped();

  @override
  List<Object?> get props => [];
}
