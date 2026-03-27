import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../features/selection/selection_args.dart';
import '../../../features/selection/selection_result.dart';
import '../bloc/mark_detail_bloc.dart';
import '../bloc/mark_detail_event.dart';
import '../bloc/mark_detail_state.dart';
import '../draft/mark_detail_draft.dart';

class MarkDetailPage extends StatefulWidget {
  const MarkDetailPage({super.key});

  @override
  State<MarkDetailPage> createState() => _MarkDetailPageState();
}

class _MarkDetailPageState extends State<MarkDetailPage> {
  static final _dateFormat = DateFormat('yyyy/MM/dd');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarkDetailBloc, MarkDetailState>(
      listener: (context, state) async {
        if (state is MarkDetailLoaded && state.delegate != null) {
          await _handleDelegate(state.delegate!, state.draft);
        }
      },
      builder: (context, state) {
        return switch (state) {
          MarkDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          MarkDetailError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          MarkDetailLoaded(:final draft) => _MarkDetailScaffold(
              draft: draft,
              dateFormat: _dateFormat,
            ),
        };
      },
    );
  }

  Future<void> _handleDelegate(
    MarkDetailDelegate delegate,
    MarkDetailDraft draft,
  ) async {
    switch (delegate) {
      case MarkDetailDismissDelegate():
        if (!mounted) return;
        context.pop();

      case MarkDetailOpenMembersSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.markMembers,
            selectedIds: draft.selectedMembers.map((m) => m.id).toSet(),
          ),
        );
        if (!mounted) return;
        if (result case MembersSelectionResult(:final selected)) {
          context.read<MarkDetailBloc>().add(MarkDetailMembersSelected(selected));
        }

      case MarkDetailOpenActionsSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.markActions,
            selectedIds: draft.selectedActions.map((a) => a.id).toSet(),
          ),
        );
        if (!mounted) return;
        if (result case ActionsSelectionResult(:final selected)) {
          context.read<MarkDetailBloc>().add(MarkDetailActionsSelected(selected));
        }
    }
  }
}

class _MarkDetailScaffold extends StatelessWidget {
  final MarkDetailDraft draft;
  final DateFormat dateFormat;

  const _MarkDetailScaffold({
    required this.draft,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context
              .read<MarkDetailBloc>()
              .add(const MarkDetailDismissPressed()),
        ),
        title: Text(
          draft.markLinkName.isEmpty ? 'マーク詳細' : draft.markLinkName,
        ),
        centerTitle: true,
      ),
      body: _MarkDetailForm(draft: draft, dateFormat: dateFormat),
    );
  }
}

class _MarkDetailForm extends StatelessWidget {
  final MarkDetailDraft draft;
  final DateFormat dateFormat;

  const _MarkDetailForm({required this.draft, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NameField(value: draft.markLinkName),
        const SizedBox(height: 16),
        _DateRow(date: draft.markLinkDate, dateFormat: dateFormat),
        const SizedBox(height: 16),
        _SelectionRow(
          label: 'メンバー',
          value: draft.selectedMembers.isEmpty
              ? '未選択'
              : draft.selectedMembers.map((m) => m.memberName).join('、'),
          onEditPressed: () => context
              .read<MarkDetailBloc>()
              .add(const MarkDetailEditMembersPressed()),
        ),
        const SizedBox(height: 16),
        _MeterValueField(value: draft.meterValueInput),
        const SizedBox(height: 16),
        _SelectionRow(
          label: 'アクション',
          value: draft.selectedActions.isEmpty
              ? '未選択'
              : draft.selectedActions.map((a) => a.actionName).join('、'),
          onEditPressed: () => context
              .read<MarkDetailBloc>()
              .add(const MarkDetailEditActionsPressed()),
        ),
        const SizedBox(height: 16),
        _MemoField(value: draft.memo),
        const SizedBox(height: 16),
        _FuelRow(isFuel: draft.isFuel),
      ],
    );
  }
}

// ── Field widgets ─────────────────────────────────────────────────────────

class _NameField extends StatefulWidget {
  final String value;
  const _NameField({required this.value});

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
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
        labelText: '名称（任意）',
        border: OutlineInputBorder(),
      ),
      onChanged: (v) =>
          context.read<MarkDetailBloc>().add(MarkDetailNameChanged(v)),
    );
  }
}

class _MeterValueField extends StatefulWidget {
  final String value;
  const _MeterValueField({required this.value});

  @override
  State<_MeterValueField> createState() => _MeterValueFieldState();
}

class _MeterValueFieldState extends State<_MeterValueField> {
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
        labelText: '累積メーター (km)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) =>
          context.read<MarkDetailBloc>().add(MarkDetailMeterValueChanged(v)),
    );
  }
}

class _MemoField extends StatefulWidget {
  final String value;
  const _MemoField({required this.value});

  @override
  State<_MemoField> createState() => _MemoFieldState();
}

class _MemoFieldState extends State<_MemoField> {
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
        labelText: 'メモ',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (v) =>
          context.read<MarkDetailBloc>().add(MarkDetailMemoChanged(v)),
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime date;
  final DateFormat dateFormat;

  const _DateRow({required this.date, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '日付',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Text(
            dateFormat.format(date),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _pickDate(context),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (!context.mounted) return;
    if (picked != null) {
      context.read<MarkDetailBloc>().add(MarkDetailDateChanged(picked));
    }
  }
}

class _SelectionRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEditPressed;

  const _SelectionRow({
    required this.label,
    required this.value,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onEditPressed,
        ),
      ],
    );
  }
}

class _FuelRow extends StatelessWidget {
  final bool isFuel;

  const _FuelRow({required this.isFuel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('給油'),
          value: isFuel,
          onChanged: (_) =>
              context.read<MarkDetailBloc>().add(const MarkDetailIsFuelToggled()),
        ),
        if (isFuel)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              '給油詳細（未実装）',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
      ],
    );
  }
}
