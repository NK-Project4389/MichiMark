import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../features/selection/selection_args.dart';
import '../../../features/selection/selection_result.dart';
import '../../../widgets/numeric_input_row.dart';
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
          PaymentDetailLoaded(:final draft, :final isSaving, :final availableMembers) =>
            _PaymentDetailScaffold(draft: draft, isSaving: isSaving, availableMembers: availableMembers),
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
  final List<MemberDomain> availableMembers;

  const _PaymentDetailScaffold({required this.draft, required this.isSaving, required this.availableMembers});

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
      ),
      body: _PaymentDetailForm(draft: draft, availableMembers: availableMembers),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSaving
            ? null
            : () => context
                .read<PaymentDetailBloc>()
                .add(const PaymentDetailSaveTapped()),
        icon: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save_outlined),
        label: Text(isSaving ? '保存中' : '保存'),
      ),
    );
  }
}

// ── Form ─────────────────────────────────────────────────────────────────

class _PaymentDetailForm extends StatelessWidget {
  final PaymentDetailDraft draft;
  final List<MemberDomain> availableMembers;

  const _PaymentDetailForm({required this.draft, required this.availableMembers});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        NumericInputRow(
          label: '支払金額',
          unit: '円',
          value: draft.paymentAmount,
          onChanged: (v) => context
              .read<PaymentDetailBloc>()
              .add(PaymentDetailAmountChanged(v)),
        ),
        const Divider(height: 1),
        _SelectionRow(
          label: '支払者',
          value: draft.paymentMember?.memberName ?? '未選択',
          enabled: availableMembers.isNotEmpty,
          onEditPressed: () => context
              .read<PaymentDetailBloc>()
              .add(const PaymentDetailEditMemberPressed()),
        ),
        const Divider(height: 1),
        _SelectionRow(
          label: '割り勘',
          value: draft.splitMembers.isEmpty
              ? '未選択'
              : draft.splitMembers.map((m) => m.memberName).join('、'),
          enabled: availableMembers.isNotEmpty,
          onEditPressed: () => context
              .read<PaymentDetailBloc>()
              .add(const PaymentDetailEditSplitMembersPressed()),
        ),
        const Divider(height: 1),
        _MemoField(value: draft.paymentMemo),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Field widgets ─────────────────────────────────────────────────────────

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'メモ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
                hintText: '任意',
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              maxLines: null,
              onChanged: (v) => context
                  .read<PaymentDetailBloc>()
                  .add(PaymentDetailMemoChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEditPressed;
  final bool enabled;

  const _SelectionRow({
    required this.label,
    required this.value,
    required this.onEditPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final disabledColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: enabled ? onEditPressed : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: enabled ? null : disabledColor,
                      ),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: enabled ? null : disabledColor),
          ],
        ),
      ),
    );
  }
}
