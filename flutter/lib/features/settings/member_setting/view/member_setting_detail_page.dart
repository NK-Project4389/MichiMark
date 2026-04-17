import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/member_setting_detail_bloc.dart';
import '../bloc/member_setting_detail_event.dart';
import '../bloc/member_setting_detail_state.dart';
import '../draft/member_setting_detail_draft.dart';

class MemberSettingDetailPage extends StatelessWidget {
  const MemberSettingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemberSettingDetailBloc, MemberSettingDetailState>(
      listener: (context, state) {
        if (state is MemberSettingDetailLoaded && state.delegate != null) {
          switch (state.delegate!) {
            case MemberSettingDetailDidSaveDelegate():
              if (context.canPop()) { context.pop(true); } else { context.go('/'); }
            case MemberSettingDetailDismissDelegate():
              if (context.canPop()) { context.pop(); } else { context.go('/'); }
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          MemberSettingDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          MemberSettingDetailError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          MemberSettingDetailLoaded() => _MemberSettingDetailScaffold(
              state: state,
            ),
        };
      },
    );
  }
}

class _MemberSettingDetailScaffold extends StatelessWidget {
  final MemberSettingDetailLoaded state;

  const _MemberSettingDetailScaffold({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('memberSettingDetail_appBar_backButton'),
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context
              .read<MemberSettingDetailBloc>()
              .add(const MemberSettingDetailBackTapped()),
        ),
        title: Text(
          state.draft.memberName.isEmpty ? 'メンバー' : state.draft.memberName,
        ),
        centerTitle: true,
      ),
      body: _MemberSettingDetailForm(draft: state.draft, state: state),
    );
  }
}

class _MemberSettingDetailForm extends StatelessWidget {
  final MemberSettingDetailDraft draft;
  final MemberSettingDetailLoaded state;

  const _MemberSettingDetailForm({required this.draft, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _MemberNameField(value: draft.memberName),
        if (state.validationError != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              state.validationError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
        const Divider(height: 1),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text('表示'),
          value: draft.isVisible,
          onChanged: (v) => context
              .read<MemberSettingDetailBloc>()
              .add(MemberSettingDetailIsVisibleChanged(v)),
        ),
        if (state.saveErrorMessage != null) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              state.saveErrorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                key: const Key('memberSettingDetail_button_cancel'),
                onPressed: () => context
                    .read<MemberSettingDetailBloc>()
                    .add(const MemberSettingDetailBackTapped()),
                child: const Text('キャンセル'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                key: const Key('memberSettingDetail_button_save'),
                onPressed: state.isSaving
                    ? null
                    : () => context
                        .read<MemberSettingDetailBloc>()
                        .add(const MemberSettingDetailSaveTapped()),
                child: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('保存'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MemberNameField extends StatefulWidget {
  final String value;
  const _MemberNameField({required this.value});

  @override
  State<_MemberNameField> createState() => _MemberNameFieldState();
}

class _MemberNameFieldState extends State<_MemberNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'メンバー名',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: '必須',
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              autofocus: true,
              onChanged: (v) => context
                  .read<MemberSettingDetailBloc>()
                  .add(MemberSettingDetailNameChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}
