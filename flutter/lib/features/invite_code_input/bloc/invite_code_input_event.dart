import 'package:equatable/equatable.dart';

sealed class InviteCodeInputEvent extends Equatable {
  const InviteCodeInputEvent();
}

/// コード文字列が変化
class InviteCodeChanged extends InviteCodeInputEvent {
  final String code;
  const InviteCodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

/// 「次へ」ボタン → コード検証開始
class InviteCodeSubmitted extends InviteCodeInputEvent {
  const InviteCodeSubmitted();

  @override
  List<Object?> get props => [];
}

/// メンバー選択
class InviteCodeMemberSelected extends InviteCodeInputEvent {
  final String memberId;
  const InviteCodeMemberSelected(this.memberId);

  @override
  List<Object?> get props => [memberId];
}

/// 「参加する」ボタン → 参加確定
class InviteCodeJoinConfirmed extends InviteCodeInputEvent {
  const InviteCodeJoinConfirmed();

  @override
  List<Object?> get props => [];
}

/// コード入力ステップに戻る
class InviteCodeBackToInput extends InviteCodeInputEvent {
  const InviteCodeBackToInput();

  @override
  List<Object?> get props => [];
}
