import 'package:equatable/equatable.dart';

import '../domain/invite_link_share_result.dart';
import '../draft/invite_link_share_draft.dart';

sealed class InviteLinkShareState extends Equatable {
  const InviteLinkShareState();
}

/// Step 1: 設定選択中。
class InviteLinkShareSetting extends InviteLinkShareState {
  final InviteLinkShareDraft draft;

  const InviteLinkShareSetting({required this.draft});

  @override
  List<Object?> get props => [draft];
}

/// API呼び出し中（ローディング）。
class InviteLinkShareCreating extends InviteLinkShareState {
  final InviteLinkShareDraft draft;

  const InviteLinkShareCreating({required this.draft});

  @override
  List<Object?> get props => [draft];
}

/// Step 2: 生成完了・結果表示。
class InviteLinkShareCreated extends InviteLinkShareState {
  final InviteLinkShareResult result;

  const InviteLinkShareCreated({required this.result});

  @override
  List<Object?> get props => [result];
}

/// 生成失敗。
class InviteLinkShareError extends InviteLinkShareState {
  final String errorMessage;
  final InviteLinkShareDraft draft;

  const InviteLinkShareError({
    required this.errorMessage,
    required this.draft,
  });

  @override
  List<Object?> get props => [errorMessage, draft];
}
