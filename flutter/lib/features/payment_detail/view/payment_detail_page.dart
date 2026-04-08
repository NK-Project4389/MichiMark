import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../features/selection/selection_args.dart';
import '../../../features/selection/selection_result.dart';
import '../bloc/payment_detail_bloc.dart';
import '../bloc/payment_detail_event.dart';
import '../bloc/payment_detail_state.dart';
import '../draft/payment_detail_draft.dart';

class PaymentDetailPage extends StatefulWidget {
  const PaymentDetailPage({super.key});

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentDetailBloc, PaymentDetailState>(
      listener: (context, state) async {
        if (state is PaymentDetailLoaded && state.delegate != null) {
          await _handleDelegate(context, state.delegate!, state.draft, state.availableMembers);
        }
      },
      builder: (context, state) {
        return switch (state) {
          PaymentDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          PaymentDetailError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          PaymentDetailLoaded(:final draft, :final isSaving) =>
            _PaymentDetailScaffold(draft: draft, isSaving: isSaving),
        };
      },
    );
  }

  Future<void> _handleDelegate(
    BuildContext context,
    PaymentDetailDelegate delegate,
    PaymentDetailDraft draft,
    List<MemberDomain> availableMembers,
  ) async {
    switch (delegate) {
      case PaymentDetailDismissDelegate():
        if (!context.mounted) return;
        context.pop();

      case PaymentDetailSavedDelegate():
        if (!context.mounted) return;
        context.pop(draft);

      case PaymentDetailSaveErrorDelegate(:final message):
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

      case PaymentDetailOpenMemberSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.payMember,
            selectedIds: draft.paymentMember != null
                ? {draft.paymentMember!.id}
                : const {},
            candidateMembers: availableMembers.isEmpty ? null : availableMembers,
          ),
        );
        if (!context.mounted) return;
        if (result case MembersSelectionResult(:final selected)) {
          if (selected.isNotEmpty) {
            context
                .read<PaymentDetailBloc>()
                .add(PaymentDetailMemberSelected(selected.first));
          }
        }

      case PaymentDetailOpenSplitMembersSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.splitMembers,
            selectedIds: draft.splitMembers.map((m) => m.id).toSet(),
            fixedSelectedIds: draft.paymentMember != null
                ? {draft.paymentMember!.id}
                : const {},
            candidateMembers: availableMembers.isEmpty ? null : availableMembers,
          ),
        );
        if (!context.mounted) return;
        if (result case MembersSelectionResult(:final selected)) {
          context
              .read<PaymentDetailBloc>()
              .add(PaymentDetailSplitMembersSelected(selected));
        }
    }
  }
}

// ── Scaffold ─────────────────────────────────────────────────────────────

class _PaymentDetailScaffold extends StatelessWidget {
  final PaymentDetailDraft draft;
  final bool isSaving;

  const _PaymentDetailScaffold({required this.draft, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context
              .read<PaymentDetailBloc>()
              .add(const PaymentDetailCancelTapped()),
        ),
        title: const Text('支払詳細'),
        centerTitle: true,
        actions: [
          if (isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: () => context
                  .read<PaymentDetailBloc>()
                  .add(const PaymentDetailSaveTapped()),
              child: const Text('保存'),
            ),
        ],
      ),
      body: _PaymentDetailForm(draft: draft),
    );
  }
}

// ── Form ─────────────────────────────────────────────────────────────────

class _PaymentDetailForm extends StatelessWidget {
  final PaymentDetailDraft draft;

  const _PaymentDetailForm({required this.draft});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AmountField(value: draft.paymentAmount),
        const SizedBox(height: 16),
        _SelectionRow(
          label: '支払者',
          value: draft.paymentMember?.memberName ?? '未選択',
          onEditPressed: () => context
              .read<PaymentDetailBloc>()
              .add(const PaymentDetailEditMemberPressed()),
        ),
        const SizedBox(height: 16),
        _SelectionRow(
          label: '割り勘',
          value: draft.splitMembers.isEmpty
              ? '未選択'
              : draft.splitMembers.map((m) => m.memberName).join('、'),
          onEditPressed: () => context
              .read<PaymentDetailBloc>()
              .add(const PaymentDetailEditSplitMembersPressed()),
        ),
        const SizedBox(height: 16),
        _MemoField(value: draft.paymentMemo),
      ],
    );
  }
}

// ── Field widgets ─────────────────────────────────────────────────────────

class _AmountField extends StatefulWidget {
  final String value;
  const _AmountField({required this.value});

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
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
        labelText: '支払金額（円）',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) => context
          .read<PaymentDetailBloc>()
          .add(PaymentDetailAmountChanged(v)),
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
      onChanged: (v) => context
          .read<PaymentDetailBloc>()
          .add(PaymentDetailMemoChanged(v)),
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
