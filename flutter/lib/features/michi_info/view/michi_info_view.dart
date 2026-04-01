import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../features/event_detail/projection/michi_info_list_projection.dart';
import '../../../features/shared/projection/mark_link_item_projection.dart';
import '../bloc/michi_info_bloc.dart';
import '../bloc/michi_info_event.dart';
import '../bloc/michi_info_state.dart';

class MichiInfoView extends StatelessWidget {
  const MichiInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MichiInfoBloc, MichiInfoState>(
      listener: (context, state) {
        if (state is MichiInfoLoaded && state.delegate != null) {
          _handleDelegate(context, state.delegate!);
        }
      },
      builder: (context, state) {
        return switch (state) {
          MichiInfoLoading() =>
            const Center(child: CircularProgressIndicator()),
          MichiInfoError(:final message) => Center(child: Text(message)),
          MichiInfoLoaded(:final projection) =>
            _MichiInfoList(projection: projection),
        };
      },
    );
  }

  void _handleDelegate(BuildContext context, MichiInfoDelegate delegate) {
    switch (delegate) {
      case MichiInfoOpenMarkDelegate(:final eventId, :final markLinkId):
        context.go('/event/mark/$markLinkId', extra: eventId);
      case MichiInfoOpenLinkDelegate(:final eventId, :final markLinkId):
        context.go('/event/link/$markLinkId', extra: eventId);
      case MichiInfoAddMarkDelegate(:final eventId):
        final markId = const Uuid().v4();
        context.go('/event/mark/$markId', extra: eventId);
      case MichiInfoAddLinkDelegate(:final eventId):
        final linkId = const Uuid().v4();
        context.go('/event/link/$linkId', extra: eventId);
    }
  }
}

class _MichiInfoList extends StatelessWidget {
  final MichiInfoListProjection projection;

  const _MichiInfoList({required this.projection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: projection.items.isEmpty
          ? const Center(child: Text('マーク/リンクがありません'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: projection.items.length,
              separatorBuilder: (context, _) =>
                  const Divider(height: 1, indent: 56),
              itemBuilder: (context, index) {
                return _MarkLinkListTile(item: projection.items[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('マークを追加'),
              onTap: () {
                Navigator.of(context).pop();
                context
                    .read<MichiInfoBloc>()
                    .add(const MichiInfoAddMarkPressed());
              },
            ),
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('リンクを追加'),
              onTap: () {
                Navigator.of(context).pop();
                context
                    .read<MichiInfoBloc>()
                    .add(const MichiInfoAddLinkPressed());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkLinkListTile extends StatelessWidget {
  final MarkLinkItemProjection item;

  const _MarkLinkListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isMark = item.markLinkType == MarkOrLink.mark;
    return ListTile(
      leading: Icon(isMark ? Icons.place : Icons.route),
      title: Text(
        item.markLinkName.isEmpty ? '（名称未設定）' : item.markLinkName,
      ),
      subtitle: Text(_buildSubtitle(item)),
      trailing: item.isFuel
          ? Icon(
              Icons.local_gas_station,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () => context.read<MichiInfoBloc>().add(
            MichiInfoItemTapped(
              markLinkId: item.id,
              type: item.markLinkType,
            ),
          ),
    );
  }

  String _buildSubtitle(MarkLinkItemProjection item) {
    final parts = <String>[item.displayDate];
    if (item.displayMeterValue != null) {
      parts.add(item.displayMeterValue!);
    }
    if (item.displayDistanceValue != null) {
      parts.add(item.displayDistanceValue!);
    }
    return parts.join('  ');
  }
}
