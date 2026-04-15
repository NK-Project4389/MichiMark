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
              context.pop(true);
            case TagSettingDetailDismissDelegate():
              context.pop();
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
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context
              .read<TagSettingDetailBloc>()
              .add(const TagSettingDetailBackTapped()),
        ),
        title: Text(state.draft.tagName.isEmpty ? 'タグ' : state.draft.tagName),
        centerTitle: true,
        actions: [
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: () => context
                  .read<TagSettingDetailBloc>()
                  .add(const TagSettingDetailSaveTapped()),
              child: const Text('保存'),
            ),
        ],
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
