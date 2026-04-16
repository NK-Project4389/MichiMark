import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/invite_link_share_result.dart';

/// 招待リンク生成結果表示 UI。
class InviteLinkResultView extends StatelessWidget {
  final InviteLinkShareResult result;

  const InviteLinkResultView({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 招待URL セクション
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '招待リンク',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            result.inviteUrl,
            key: const Key('inviteLinkShare_text_inviteUrl'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            key: const Key('inviteLinkShare_button_copyUrl'),
            onPressed: () => _copyToClipboard(context, result.inviteUrl),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('リンクをコピー'),
          ),
        ),
        const SizedBox(height: 20),

        // 招待コード セクション
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '招待コード',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            result.code,
            key: const Key('inviteLinkShare_text_inviteCode'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            key: const Key('inviteLinkShare_button_copyCode'),
            onPressed: () => _copyToClipboard(context, result.code),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('コードをコピー'),
          ),
        ),
        const SizedBox(height: 24),

        // 共有ボタン
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            key: const Key('inviteLinkShare_button_share'),
            onPressed: () => _share(context),
            icon: const Icon(Icons.share),
            label: const Text('共有する'),
          ),
        ),
        const SizedBox(height: 8),

        // 閉じるボタン
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextButton(
            key: const Key('inviteLinkShare_button_close'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('コピーしました'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _share(BuildContext context) {
    final shareText =
        '${result.inviteUrl}\n招待コード: ${result.code}';
    Share.share(shareText);
  }
}
