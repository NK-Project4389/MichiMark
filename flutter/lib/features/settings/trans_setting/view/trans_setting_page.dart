import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/trans_setting_bloc.dart';
import '../bloc/trans_setting_event.dart';
import '../bloc/trans_setting_state.dart';
import '../../../../features/shared/projection/trans_item_projection.dart';

class TransSettingPage extends StatelessWidget {
  const TransSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransSettingBloc, TransSettingState>(
      listener: (context, state) async {
        if (state is TransSettingLoaded && state.delegate != null) {
          await _handleDelegate(context, state.delegate!);
          if (context.mounted) {
            context
                .read<TransSettingBloc>()
                .add(const TransSettingStarted());
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          TransSettingLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          TransSettingError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          TransSettingLoaded(:final items) => Scaffold(
              appBar: AppBar(
                title: const Text('交通手段'),
                centerTitle: true,
              ),
              body: items.isEmpty
                  ? const Center(child: Text('交通手段がありません'))
                  : _buildList(context, items),
              floatingActionButton: FloatingActionButton(
                key: const Key('transSetting_fab_add'),
                backgroundColor: const Color(0xFFF59E0B),
                onPressed: () => context
                    .read<TransSettingBloc>()
                    .add(const TransSettingAddTapped()),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
        };
      },
    );
  }

  Widget _buildList(BuildContext context, List<TransItemProjection> items) {
    final visibleItems = items.where((e) => e.isVisible).toList();
    final hiddenItems = items.where((e) => !e.isVisible).toList();
    return ListView(
      children: [
        for (int i = 0; i < visibleItems.length; i++) ...[
          _buildTile(context, visibleItems[i]),
          if (i < visibleItems.length - 1 || hiddenItems.isNotEmpty)
            const Divider(height: 1),
        ],
        if (hiddenItems.isNotEmpty) ...[
          _buildSectionHeader(context),
          for (int i = 0; i < hiddenItems.length; i++) ...[
            _buildTile(context, hiddenItems[i]),
            if (i < hiddenItems.length - 1) const Divider(height: 1),
          ],
        ],
      ],
    );
  }

  Widget _buildTile(BuildContext context, TransItemProjection item) {
    return ListTile(
      title: Text(item.transName),
      subtitle: Text('燃費: ${item.displayKmPerGas}　メーター: ${item.displayMeterValue}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context
          .read<TransSettingBloc>()
          .add(TransSettingItemSelected(item.id)),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        '非表示',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _handleDelegate(
    BuildContext context,
    TransSettingDelegate delegate,
  ) async {
    switch (delegate) {
      case TransSettingOpenDetailDelegate(:final transId):
        await context.push('/settings/trans/$transId');
      case TransSettingOpenNewDelegate():
        await context.push('/settings/trans/new');
    }
  }
}
