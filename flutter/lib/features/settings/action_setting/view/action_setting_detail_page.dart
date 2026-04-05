import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/action_time/action_state.dart';
import '../bloc/action_setting_detail_bloc.dart';
import '../bloc/action_setting_detail_event.dart';
import '../bloc/action_setting_detail_state.dart';
import '../draft/action_setting_detail_draft.dart';

class ActionSettingDetailPage extends StatelessWidget {
  const ActionSettingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActionSettingDetailBloc, ActionSettingDetailState>(
      listener: (context, state) {
        if (state is ActionSettingDetailLoaded && state.delegate != null) {
          switch (state.delegate!) {
            case ActionSettingDetailDidSaveDelegate():
              context.pop(true);
            case ActionSettingDetailDismissDelegate():
              context.pop();
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          ActionSettingDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ActionSettingDetailError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          ActionSettingDetailLoaded() => _ActionSettingDetailScaffold(
              state: state,
            ),
        };
      },
    );
  }
}

class _ActionSettingDetailScaffold extends StatelessWidget {
  final ActionSettingDetailLoaded state;

  const _ActionSettingDetailScaffold({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context
              .read<ActionSettingDetailBloc>()
              .add(const ActionSettingDetailBackTapped()),
        ),
        title: Text(
          state.draft.actionName.isEmpty ? '行動' : state.draft.actionName,
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
                  .read<ActionSettingDetailBloc>()
                  .add(const ActionSettingDetailSaveTapped()),
              child: const Text('保存'),
            ),
        ],
      ),
      body: _ActionSettingDetailForm(draft: state.draft, state: state),
    );
  }
}

class _ActionSettingDetailForm extends StatelessWidget {
  final ActionSettingDetailDraft draft;
  final ActionSettingDetailLoaded state;

  const _ActionSettingDetailForm({required this.draft, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ActionNameField(value: draft.actionName),
        if (state.validationError != null) ...[
          const SizedBox(height: 4),
          Text(
            state.validationError!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('表示'),
          value: draft.isVisible,
          onChanged: (v) => context
              .read<ActionSettingDetailBloc>()
              .add(ActionSettingDetailIsVisibleChanged(v)),
        ),
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          '状態遷移設定',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _ActionStateDropdown(
          label: '遷移後の状態',
          hint: '状態変化なし（未設定）',
          value: draft.toState,
          onChanged: (v) => context
              .read<ActionSettingDetailBloc>()
              .add(ActionSettingDetailToStateChanged(v)),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('トグル型Action'),
          subtitle: const Text('休憩開始/終了のようなペアのAction'),
          value: draft.isToggle,
          onChanged: (v) => context
              .read<ActionSettingDetailBloc>()
              .add(ActionSettingDetailIsToggleChanged(v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('状態遷移あり'),
          subtitle: const Text('オフにするとログ記録のみで状態遷移しない'),
          value: draft.needsTransition,
          onChanged: (v) => context
              .read<ActionSettingDetailBloc>()
              .add(ActionSettingDetailNeedsTransitionChanged(v)),
        ),
        if (state.saveErrorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            state.saveErrorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// ActionState を選択するドロップダウン
class _ActionStateDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final ActionState? value;
  final ValueChanged<ActionState?> onChanged;

  const _ActionStateDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ActionState?>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      hint: Text(hint),
      value: value,
      items: [
        DropdownMenuItem<ActionState?>(
          value: null,
          child: Text(hint),
        ),
        ...ActionState.values.map(
          (s) => DropdownMenuItem<ActionState?>(
            value: s,
            child: Text(s.label),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _ActionNameField extends StatefulWidget {
  final String value;
  const _ActionNameField({required this.value});

  @override
  State<_ActionNameField> createState() => _ActionNameFieldState();
}

class _ActionNameFieldState extends State<_ActionNameField> {
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
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: '行動名',
        border: OutlineInputBorder(),
      ),
      autofocus: true,
      onChanged: (v) => context
          .read<ActionSettingDetailBloc>()
          .add(ActionSettingDetailNameChanged(v)),
    );
  }
}
