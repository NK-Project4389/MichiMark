import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/event_detail/projection/payment_info_projection.dart';
import '../../../features/payment_detail/payment_detail_args.dart';
import '../../../features/shared/projection/payment_item_projection.dart';
import '../bloc/payment_info_bloc.dart';
import '../bloc/payment_info_event.dart';
import '../bloc/payment_info_state.dart';

class PaymentInfoView extends StatelessWidget {
  const PaymentInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentInfoBloc, PaymentInfoState>(
      listener: (context, state) {
        if (state is PaymentInfoLoaded && state.delegate != null) {
          _handleDelegate(context, state.delegate!, state.eventId);
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

  void _handleDelegate(
    BuildContext context,
    PaymentInfoDelegate delegate,
    String eventId,
  ) {
    switch (delegate) {
      case PaymentInfoOpenNewPaymentDelegate():
        context.push(
          '/event/payment',
          extra: PaymentDetailArgs(eventId: eventId),
        );
      case PaymentInfoOpenPaymentByIdDelegate(:final paymentId):
        context.push(
          '/event/payment',
          extra: PaymentDetailArgs(eventId: eventId, paymentId: paymentId),
        );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context
            .read<PaymentInfoBloc>()
            .add(const PaymentInfoPlusButtonTapped()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── List tile ─────────────────────────────────────────────────────────────

class _PaymentListTile extends StatelessWidget {
  final PaymentItemProjection item;

  const _PaymentListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.payment),
      title: Text(item.displayAmount),
      subtitle: Text(_buildSubtitle(item)),
      onTap: () => context
          .read<PaymentInfoBloc>()
          .add(PaymentInfoPaymentTapped(item.id)),
    );
  }

  String _buildSubtitle(PaymentItemProjection item) {
    final parts = <String>[item.payer.memberName];
    if (item.splitMembers.isNotEmpty) {
      final names = item.splitMembers.map((m) => m.memberName).join('・');
      parts.add('割り勘: $names');
    }
    if (item.memo != null && item.memo!.isNotEmpty) {
      parts.add(item.memo!);
    }
    return parts.join('  ');
  }
}
