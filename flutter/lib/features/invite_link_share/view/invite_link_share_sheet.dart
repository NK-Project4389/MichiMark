import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/invite_link_share_bloc.dart';
import '../bloc/invite_link_share_event.dart';
import '../bloc/invite_link_share_state.dart';
import '../domain/invite_link_share_result.dart';
import '../draft/invite_link_share_draft.dart';
import 'widgets/expires_selector.dart';
import 'widgets/max_uses_selector.dart';
import 'widgets/result_view.dart';
import 'widgets/role_selector.dart';

/// 招待リンク生成・共有BottomSheet。
class InviteLinkShareSheet extends StatelessWidget {
  const InviteLinkShareSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('inviteLinkShare_sheet_root'),
      child: BlocBuilder<InviteLinkShareBloc, InviteLinkShareState>(
        builder: (context, state) {
          return switch (state) {
            InviteLinkShareSetting(:final draft) =>
              _SettingView(draft: draft, enabled: true),
            InviteLinkShareCreating(:final draft) =>
              _SettingView(draft: draft, enabled: false, isLoading: true),
            InviteLinkShareCreated(:final result) =>
              _CreatedView(result: result),
            InviteLinkShareError(:final errorMessage, :final draft) =>
              _SettingView(
                draft: draft,
                enabled: true,
                errorMessage: errorMessage,
              ),
          };
        },
      ),
    );
  }
}

/// Step 1: 設定画面。
class _SettingView extends StatelessWidget {
  final InviteLinkShareDraft draft;
  final bool enabled;
  final bool isLoading;
  final String? errorMessage;

  const _SettingView({
    required this.draft,
    required this.enabled,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ハンドルバー
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // タイトル
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'メンバーを招待',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(),

          // エラーメッセージ
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                errorMessage!,
                key: const Key('inviteLinkShare_text_error'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),

          // 権限選択
          RoleSelector(
            selectedRole: draft.role,
            onChanged: (role) => context
                .read<InviteLinkShareBloc>()
                .add(InviteLinkRoleChanged(role)),
            enabled: enabled,
          ),
          const SizedBox(height: 12),

          // 有効期限選択
          ExpiresSelector(
            selectedHours: draft.expiresHours,
            onChanged: (hours) => context
                .read<InviteLinkShareBloc>()
                .add(InviteLinkExpiresHoursChanged(hours)),
            enabled: enabled,
          ),
          const SizedBox(height: 12),

          // 使用回数選択
          MaxUsesSelector(
            selectedMaxUses: draft.maxUses,
            onChanged: (maxUses) => context
                .read<InviteLinkShareBloc>()
                .add(InviteLinkMaxUsesChanged(maxUses)),
            enabled: enabled,
          ),
          const SizedBox(height: 24),

          // 作成ボタン or ローディング
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        key: Key('inviteLinkShare_loading'),
                      ),
                    ),
                  )
                : ElevatedButton(
                    key: const Key('inviteLinkShare_button_create'),
                    onPressed: () => context
                        .read<InviteLinkShareBloc>()
                        .add(const InviteLinkCreatePressed()),
                    child: const Text('招待リンクを作成'),
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Step 2: 結果表示画面。
class _CreatedView extends StatelessWidget {
  final InviteLinkShareResult result;

  const _CreatedView({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ハンドルバー
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // タイトル
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '招待リンクを作成しました',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),

          // 結果表示
          InviteLinkResultView(result: result),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
