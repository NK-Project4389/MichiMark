import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/selection/selection_args.dart';
import '../../../features/selection/selection_result.dart';
import '../bloc/link_detail_bloc.dart';
import '../bloc/link_detail_event.dart';
import '../bloc/link_detail_state.dart';
import '../draft/link_detail_draft.dart';

class LinkDetailPage extends StatefulWidget {
  const LinkDetailPage({super.key});

  @override
  State<LinkDetailPage> createState() => _LinkDetailPageState();
}

class _LinkDetailPageState extends State<LinkDetailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LinkDetailBloc, LinkDetailState>(
      listener: (context, state) async {
        if (state is LinkDetailLoaded && state.delegate != null) {
          await _handleDelegate(state.delegate!, state.draft);
        }
      },
      builder: (context, state) {
        return switch (state) {
          LinkDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          LinkDetailError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          LinkDetailLoaded(:final draft) => _LinkDetailScaffold(draft: draft),
        };
      },
    );
  }

  Future<void> _handleDelegate(
    LinkDetailDelegate delegate,
    LinkDetailDraft draft,
  ) async {
    switch (delegate) {
      case LinkDetailDismissDelegate():
        if (!mounted) return;
        context.pop();

      case LinkDetailOpenMembersSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.linkMembers,
            selectedIds: draft.selectedMembers.map((m) => m.id).toSet(),
          ),
        );
        if (!mounted) return;
        if (result case MembersSelectionResult(:final selected)) {
          context
              .read<LinkDetailBloc>()
              .add(LinkDetailMembersSelected(selected));
        }

      case LinkDetailOpenActionsSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.linkActions,
            selectedIds: draft.selectedActions.map((a) => a.id).toSet(),
          ),
        );
        if (!mounted) return;
        if (result case ActionsSelectionResult(:final selected)) {
          context
              .read<LinkDetailBloc>()
              .add(LinkDetailActionsSelected(selected));
        }
    }
  }
}

class _LinkDetailScaffold extends StatelessWidget {
  final LinkDetailDraft draft;

  const _LinkDetailScaffold({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context
              .read<LinkDetailBloc>()
              .add(const LinkDetailDismissPressed()),
        ),
        title: Text(
          draft.markLinkName.isEmpty ? 'リンク詳細' : draft.markLinkName,
        ),
        centerTitle: true,
      ),
      body: _LinkDetailForm(draft: draft),
    );
  }
}

class _LinkDetailForm extends StatelessWidget {
  final LinkDetailDraft draft;

  const _LinkDetailForm({required this.draft});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NameField(value: draft.markLinkName),
        const SizedBox(height: 16),
        _DistanceField(value: draft.distanceValueInput),
        const SizedBox(height: 16),
        _SelectionRow(
          label: 'メンバー',
          value: draft.selectedMembers.isEmpty
              ? '未選択'
              : draft.selectedMembers.map((m) => m.memberName).join('、'),
          onEditPressed: () => context
              .read<LinkDetailBloc>()
              .add(const LinkDetailEditMembersPressed()),
        ),
        const SizedBox(height: 16),
        _SelectionRow(
          label: 'アクション',
          value: draft.selectedActions.isEmpty
              ? '未選択'
              : draft.selectedActions.map((a) => a.actionName).join('、'),
          onEditPressed: () => context
              .read<LinkDetailBloc>()
              .add(const LinkDetailEditActionsPressed()),
        ),
        const SizedBox(height: 16),
        _MemoField(value: draft.memo),
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
          context.read<LinkDetailBloc>().add(LinkDetailNameChanged(v)),
    );
  }
}

class _DistanceField extends StatefulWidget {
  final String value;
  const _DistanceField({required this.value});

  @override
  State<_DistanceField> createState() => _DistanceFieldState();
}

class _DistanceFieldState extends State<_DistanceField> {
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
        labelText: '走行距離 (km)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) =>
          context.read<LinkDetailBloc>().add(LinkDetailDistanceChanged(v)),
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
          context.read<LinkDetailBloc>().add(LinkDetailMemoChanged(v)),
    );
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
