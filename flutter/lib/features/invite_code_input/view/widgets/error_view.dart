import 'package:flutter/material.dart';
import '../../domain/invite_code_error_type.dart';

class InviteCodeErrorView extends StatelessWidget {
  final InviteCodeErrorType errorType;

  const InviteCodeErrorView({super.key, required this.errorType});

  String get _message {
    switch (errorType) {
      case InviteCodeErrorType.expired:
        return 'この招待コードの有効期限が切れています';
      case InviteCodeErrorType.usedUp:
        return 'この招待コードは使用済みです';
      case InviteCodeErrorType.notFound:
        return '招待コードが見つかりません';
      case InviteCodeErrorType.alreadyJoined:
        return 'すでにこのイベントに参加しています';
      case InviteCodeErrorType.memberAlreadyLinked:
        return 'このメンバーはすでに別のアカウントに紐づいています';
      case InviteCodeErrorType.networkError:
        return '通信エラーが発生しました。もう一度お試しください';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        key: const Key('invite_code_error_message'),
        _message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 14,
        ),
      ),
    );
  }
}
