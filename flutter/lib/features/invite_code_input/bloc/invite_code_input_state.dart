import 'package:equatable/equatable.dart';
import '../domain/invite_code_error_type.dart';
import '../domain/invite_code_member_item.dart';

sealed class InviteCodeInputState extends Equatable {
  const InviteCodeInputState();
}

/// 初期状態（コード入力中）
class InviteCodeInputInitial extends InviteCodeInputState {
  final String code;
  final String? formatError;

  const InviteCodeInputInitial({this.code = '', this.formatError});

  @override
  List<Object?> get props => [code, formatError];
}

/// コード検証中
class InviteCodeInputValidating extends InviteCodeInputState {
  const InviteCodeInputValidating();

  @override
  List<Object?> get props => [];
}

/// コード検証OK → member選択ステップ
class InviteCodeInputMemberSelection extends InviteCodeInputState {
  final String code;
  final String eventName;
  final List<InviteCodeMemberItem> members;
  final String? selectedMemberId;

  const InviteCodeInputMemberSelection({
    required this.code,
    required this.eventName,
    required this.members,
    this.selectedMemberId,
  });

  @override
  List<Object?> get props => [code, eventName, members, selectedMemberId];
}

/// 参加処理中
class InviteCodeInputJoining extends InviteCodeInputState {
  const InviteCodeInputJoining();

  @override
  List<Object?> get props => [];
}

/// 参加成功
class InviteCodeInputJoined extends InviteCodeInputState {
  final String eventId;
  final String eventName;

  const InviteCodeInputJoined({required this.eventId, required this.eventName});

  @override
  List<Object?> get props => [eventId, eventName];
}

/// エラー（APIエラー）
class InviteCodeInputError extends InviteCodeInputState {
  final InviteCodeErrorType errorType;

  const InviteCodeInputError({required this.errorType});

  @override
  List<Object?> get props => [errorType];
}
