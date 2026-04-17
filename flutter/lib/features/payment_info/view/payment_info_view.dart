import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/topic/topic_theme_color.dart';
import '../../../features/event_detail/projection/payment_info_projection.dart';
import '../../../features/payment_detail/payment_detail_args.dart';
import '../../../features/shared/projection/payment_item_projection.dart';
import '../bloc/payment_info_bloc.dart';
import '../bloc/payment_info_event.dart';
import '../bloc/payment_info_state.dart';


class PaymentInfoView extends StatefulWidget {
  final TopicThemeColor? topicThemeColor;

  const PaymentInfoView({super.key, this.topicThemeColor});

  @override
  State<PaymentInfoView> createState() => _PaymentInfoViewState();
}

class _PaymentInfoViewState extends State<PaymentInfoView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentInfoBloc, PaymentInfoState>(
      listener: (context, state) async {
        if (state is PaymentInfoLoaded && state.delegate != null) {
          await _handleDelegate(context, state.delegate!, state.eventId);
          if (!context.mounted) return;
          context
              .read<PaymentInfoBloc>()
              .add(const PaymentInfoDelegateConsumed());
        }
      },
      builder: (context, state) {
        return switch (state) {
          PaymentInfoLoading() =>
            const Center(child: CircularProgressIndicator()),
          PaymentInfoError(:final message) => Center(child: Text(message)),
          PaymentInfoLoaded(:final projection) =>
            _PaymentInfoList(
              projection: projection,
              topicThemeColor: widget.topicThemeColor,
            ),
        };
      },
    );
  }

  Future<void> _handleDelegate(
    BuildContext context,
    PaymentInfoDelegate delegate,
    String eventId,
  ) async {
    switch (delegate) {
      case PaymentInfoOpenNewPaymentDelegate():
        await context.push(
          '/event/payment',
          extra: PaymentDetailArgs(eventId: eventId),
        );
        if (!context.mounted) return;
        context.read<PaymentInfoBloc>().add(const PaymentInfoReloadRequested());

      case PaymentInfoOpenPaymentByIdDelegate(:final paymentId):
        await context.push(
          '/event/payment',
          extra: PaymentDetailArgs(eventId: eventId, paymentId: paymentId),
        );
        if (!context.mounted) return;
        context.read<PaymentInfoBloc>().add(const PaymentInfoReloadRequested());

      case PaymentInfoReloadedDelegate():
        // 再読込完了: EventDetailPageのBlocListenerでcachedEventを更新する
        break;
    }
  }
}

// ── List ──────────────────────────────────────────────────────────────────

class _PaymentInfoList extends StatelessWidget {
  final PaymentInfoProjection projection;
  final TopicThemeColor? topicThemeColor;

  const _PaymentInfoList({required this.projection, this.topicThemeColor});

  bool get _isEmpty =>
      projection.dateGroups.isEmpty && projection.directItems.isEmpty;

  @override
  Widget build(BuildContext context) {
    // 表示用フラットリストを構築（セクションヘッダー + アイテム）
    final List<Widget> rows = [];

    for (final dateGroup in projection.dateGroups) {
      rows.add(_SectionHeader(title: dateGroup.displayDate));
      for (final nameGroup in dateGroup.nameGroups) {
        rows.add(_SubSectionHeader(
          title: nameGroup.displayName,
          totalAmount: nameGroup.displayGroupTotal,
        ));
        for (final item in nameGroup.items) {
          rows.add(_PaymentListTile(item: item, showMemberSection: projection.showMemberSection));
          rows.add(const Divider(height: 1, indent: 56));
        }
        if (rows.isNotEmpty && rows.last is Divider) {
          rows.removeLast();
        }
      }
    }

    if (projection.directItems.isNotEmpty) {
      rows.add(const _SectionHeader(title: '直接登録'));
      for (final item in projection.directItems) {
        rows.add(_PaymentListTile(item: item));
        rows.add(const Divider(height: 1, indent: 56));
      }
      if (rows.isNotEmpty && rows.last is Divider) {
        rows.removeLast();
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _isEmpty
                ? const Center(child: Text('支払情報がありません'))
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: rows,
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '合計: ${projection.displayTotalAmount}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context
            .read<PaymentInfoBloc>()
            .add(const PaymentInfoPlusButtonTapped()),
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _SubSectionHeader extends StatelessWidget {
  final String title;
  final String totalAmount;
  const _SubSectionHeader({required this.title, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Text(
            totalAmount,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ── List tile ─────────────────────────────────────────────────────────────

class _PaymentListTile extends StatefulWidget {
  final PaymentItemProjection item;
  final bool showMemberSection;

  const _PaymentListTile({required this.item, this.showMemberSection = true});

  @override
  State<_PaymentListTile> createState() => _PaymentListTileState();
}

class _PaymentListTileState extends State<_PaymentListTile> {
  static const _payerChipColor = Color(0xFF2B7A9B);
  static const _splitChipColor = Color(0xFF2E9E6B);
  static const _deleteIconColor = Color(0xFFDC2626);
  static const _deleteBackgroundColor = Color(0xFFFEE2E2);

  Future<void> _onDeleteTapped() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        key: const Key('deleteConfirmDialog_dialog_confirm'),
        title: const Text('削除しますか？'),
        content: const Text('この操作は取り消せません。'),
        actions: [
          CupertinoDialogAction(
            key: const Key('deleteConfirmDialog_button_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('キャンセル'),
          ),
          CupertinoDialogAction(
            key: const Key('deleteConfirmDialog_button_delete'),
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    context
        .read<PaymentInfoBloc>()
        .add(PaymentInfoPaymentDeleteRequested(widget.item.id));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final textTheme = Theme.of(context).textTheme;
    final memo = item.memo;
    final hasMemo = memo != null && memo.isNotEmpty;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context
                  .read<PaymentInfoBloc>()
                  .add(PaymentInfoPaymentTapped(item.id)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 16),
                      child: Icon(Icons.payment),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 行1: 金額
                          Text(
                            item.displayAmount,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // 行2: メモ（存在する場合のみ・italic で表示）
                          if (hasMemo) ...[
                            const SizedBox(height: 2),
                            Text(
                              memo,
                              style: textTheme.bodyLarge?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          // 行3: 支払者チップ（F-6: visitWorkでは非表示）
                          if (widget.showMemberSection) ...[
                            Row(
                              children: [
                                Text('支払', style: textTheme.bodySmall),
                                const SizedBox(width: 6),
                                _MemberChip(
                                  name: item.payer.memberName,
                                  backgroundColor: _payerChipColor,
                                ),
                              ],
                            ),
                          ],
                          // 行4: 割り勘メンバー（存在する場合のみ、F-6: visitWorkでは非表示）
                          if (widget.showMemberSection && item.splitMembers.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child:
                                      Text('割り勘', style: textTheme.bodySmall),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: item.splitMembers
                                        .map(
                                          (m) => _MemberChip(
                                            name: m.memberName,
                                            backgroundColor: _splitChipColor,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 削除アイコンボタン（常時表示）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: GestureDetector(
              key: Key('paymentInfo_button_delete_${item.id}'),
              onTap: _onDeleteTapped,
              child: Container(
                width: 44,
                decoration: BoxDecoration(
                  color: _deleteBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete,
                  color: _deleteIconColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  final String name;
  final Color backgroundColor;

  const _MemberChip({required this.name, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        name,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}
