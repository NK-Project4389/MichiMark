import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/master/member/member_domain.dart';
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
        automaticallyImplyLeading: false,
        title: const Text(
          '支払詳細',
          key: Key('paymentDetail_appBar_title'),
        ),
        centerTitle: true,
      ),
      body: _PaymentDetailForm(
        draft: draft,
        availableMembers: availableMembers,
        isSaving: isSaving,
      ),
    );
  }
}

// ── Form ─────────────────────────────────────────────────────────────────

class _PaymentDetailForm extends StatelessWidget {
  final PaymentDetailDraft draft;
  final List<MemberDomain> availableMembers;
  final bool isSaving;

  const _PaymentDetailForm({
    required this.draft,
    required this.availableMembers,
    required this.isSaving,
  });

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
        _PayMemberChipSection(
          availableMembers: availableMembers,
          selectedPayMember: draft.paymentMember,
        ),
        const Divider(height: 1),
        _SplitMemberChipSection(
          availableMembers: availableMembers,
          splitMembers: draft.splitMembers,
          paymentMember: draft.paymentMember,
        ),
        const Divider(height: 1),
        _MemoField(value: draft.paymentMemo),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                key: const Key('paymentDetail_button_cancel'),
                onPressed: () => context
                    .read<PaymentDetailBloc>()
                    .add(const PaymentDetailCancelTapped()),
                child: const Text('キャンセル'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                key: const Key('paymentDetail_button_save'),
                onPressed: isSaving
                    ? null
                    : () => context
                        .read<PaymentDetailBloc>()
                        .add(const PaymentDetailSaveTapped()),
                child: isSaving
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

// ── 支払者チップセクション（インライン選択・single） ───────────────────────

class _PayMemberChipSection extends StatelessWidget {
  final List<MemberDomain> availableMembers;
  final MemberDomain? selectedPayMember;

  const _PayMemberChipSection({
    required this.availableMembers,
    required this.selectedPayMember,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('支払者', style: labelStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: availableMembers.map((member) {
              final isSelected = selectedPayMember?.id == member.id;
              return FilterChip(
                key: Key('paymentDetail_chip_payMember_${member.id}'),
                label: Text(member.memberName),
                selected: isSelected,
                onSelected: (_) => context
                    .read<PaymentDetailBloc>()
                    .add(PaymentDetailPayMemberChipToggled(member)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── 割り勘メンバーチップセクション（インライン選択・multiple、支払者常にON固定） ─

class _SplitMemberChipSection extends StatelessWidget {
  final List<MemberDomain> availableMembers;
  final List<MemberDomain> splitMembers;
  final MemberDomain? paymentMember;

  const _SplitMemberChipSection({
    required this.availableMembers,
    required this.splitMembers,
    required this.paymentMember,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('割り勘', style: labelStyle),
              const Spacer(),
              TextButton(
                key: const Key('paymentDetail_button_selectAllSplitMembers'),
                onPressed: () => context
                    .read<PaymentDetailBloc>()
                    .add(const PaymentDetailSplitMembersAllSelected()),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('全選択'),
              ),
              TextButton(
                key: const Key('paymentDetail_button_clearAllSplitMembers'),
                onPressed: () => context
                    .read<PaymentDetailBloc>()
                    .add(const PaymentDetailSplitMembersAllCleared()),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('全解除'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: availableMembers.map((member) {
              final isPayMember = paymentMember?.id == member.id;
              final isSelected =
                  isPayMember || splitMembers.any((m) => m.id == member.id);
              return FilterChip(
                key: Key('paymentDetail_chip_splitMember_${member.id}'),
                label: Text(member.memberName),
                selected: isSelected,
                // 支払者は常にON固定（非活性）
                onSelected: isPayMember
                    ? null
                    : (_) => context
                        .read<PaymentDetailBloc>()
                        .add(PaymentDetailSplitMemberChipToggled(member)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
