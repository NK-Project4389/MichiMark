import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/event_detail/projection/payment_info_projection.dart';
import '../../../features/payment_detail/payment_detail_args.dart';
import '../../../features/shared/projection/payment_item_projection.dart';
import '../bloc/payment_info_bloc.dart';
import '../bloc/payment_info_event.dart';
import '../bloc/payment_info_state.dart';

class PaymentInfoView extends StatefulWidget {
  const PaymentInfoView({super.key});

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
            _PaymentInfoList(projection: projection),
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

  const _PaymentInfoList({required this.projection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: projection.items.isEmpty
                ? const Center(child: Text('支払情報がありません'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: projection.items.length,
                    separatorBuilder: (context, _) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (context, index) {
                      return _PaymentListTile(
                        item: projection.items[index],
                      );
                    },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context
            .read<PaymentInfoBloc>()
            .add(const PaymentInfoPlusButtonTapped()),
        icon: const Icon(Icons.add),
        label: const Text('追加'),
      ),
    );
  }
}

// ── List tile ─────────────────────────────────────────────────────────────

class _PaymentListTile extends StatelessWidget {
  final PaymentItemProjection item;

  static const _payerChipColor = Color(0xFF2B7A9B);
  static const _splitChipColor = Color(0xFF2E9E6B);

  const _PaymentListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final memo = item.memo;
    final hasMemo = memo != null && memo.isNotEmpty;

    return InkWell(
      onTap: () => context
          .read<PaymentInfoBloc>()
          .add(PaymentInfoPaymentTapped(item.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  // 行2: メモ（存在する場合のみ・金額と同スタイル）
                  if (hasMemo) ...[
                    const SizedBox(height: 2),
                    Text(
                      memo,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  // 行3: 支払者チップ
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
                  // 行4: 割り勘メンバー（存在する場合のみ）
                  if (item.splitMembers.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text('割り勘', style: textTheme.bodySmall),
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
