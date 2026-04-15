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
              context.pop(true);
            case MemberSettingDetailDismissDelegate():
              context.pop();
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
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context
              .read<MemberSettingDetailBloc>()
              .add(const MemberSettingDetailBackTapped()),
        ),
        title: Text(
          state.draft.memberName.isEmpty ? 'メンバー' : state.draft.memberName,
        ),
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
                  .read<MemberSettingDetailBloc>()
                  .add(const MemberSettingDetailSaveTapped()),
              child: const Text('保存'),
            ),
        ],
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
