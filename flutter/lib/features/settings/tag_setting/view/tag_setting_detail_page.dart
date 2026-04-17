import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/tag_setting_detail_bloc.dart';
import '../bloc/tag_setting_detail_event.dart';
import '../bloc/tag_setting_detail_state.dart';
import '../draft/tag_setting_detail_draft.dart';

class TagSettingDetailPage extends StatelessWidget {
  const TagSettingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TagSettingDetailBloc, TagSettingDetailState>(
      listener: (context, state) {
        if (state is TagSettingDetailLoaded && state.delegate != null) {
          switch (state.delegate!) {
            case TagSettingDetailDidSaveDelegate():
              if (context.canPop()) { context.pop(true); } else { context.go('/'); }
            case TagSettingDetailDismissDelegate():
              if (context.canPop()) { context.pop(); } else { context.go('/'); }
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          TagSettingDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          TagSettingDetailError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          TagSettingDetailLoaded() => _TagSettingDetailScaffold(
              state: state,
            ),
        };
      },
    );
  }
}

class _TagSettingDetailScaffold extends StatelessWidget {
  final TagSettingDetailLoaded state;

  const _TagSettingDetailScaffold({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('tagSettingDetail_appBar_backButton'),
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context
              .read<TagSettingDetailBloc>()
              .add(const TagSettingDetailBackTapped()),
        ),
        title: Text(state.draft.tagName.isEmpty ? 'タグ' : state.draft.tagName),
        centerTitle: true,
      ),
      body: _TagSettingDetailForm(draft: state.draft, state: state),
    );
  }
}

class _TagSettingDetailForm extends StatelessWidget {
  final TagSettingDetailDraft draft;
  final TagSettingDetailLoaded state;

  const _TagSettingDetailForm({required this.draft, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _TagNameField(value: draft.tagName),
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
              .read<TagSettingDetailBloc>()
              .add(TagSettingDetailIsVisibleChanged(v)),
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
                key: const Key('tagSettingDetail_button_cancel'),
                onPressed: () => context
                    .read<TagSettingDetailBloc>()
                    .add(const TagSettingDetailBackTapped()),
                child: const Text('キャンセル'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                key: const Key('tagSettingDetail_button_save'),
                onPressed: state.isSaving
                    ? null
                    : () => context
                        .read<TagSettingDetailBloc>()
                        .add(const TagSettingDetailSaveTapped()),
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

class _TagNameField extends StatefulWidget {
  final String value;
  const _TagNameField({required this.value});

  @override
  State<_TagNameField> createState() => _TagNameFieldState();
}

class _TagNameFieldState extends State<_TagNameField> {
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
              'タグ名',
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
                  .read<TagSettingDetailBloc>()
                  .add(TagSettingDetailNameChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}
