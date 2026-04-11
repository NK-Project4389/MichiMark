import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/action_setting_bloc.dart';
import '../bloc/action_setting_event.dart';
import '../bloc/action_setting_state.dart';
import '../../../../features/shared/projection/action_item_projection.dart';

class ActionSettingPage extends StatelessWidget {
  const ActionSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActionSettingBloc, ActionSettingState>(
      listener: (context, state) async {
        if (state is ActionSettingLoaded && state.delegate != null) {
          await _handleDelegate(context, state.delegate!);
          if (context.mounted) {
            context
                .read<ActionSettingBloc>()
                .add(const ActionSettingStarted());
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          ActionSettingLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ActionSettingError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          ActionSettingLoaded(:final items) => Scaffold(
              appBar: AppBar(
                title: const Text('行動'),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    color: const Color(0xFFF59E0B),
                    onPressed: () => context
                        .read<ActionSettingBloc>()
                        .add(const ActionSettingAddTapped()),
                  ),
                ],
              ),
              body: items.isEmpty
                  ? const Center(child: Text('行動がありません'))
                  : _buildList(context, items),
            ),
        };
      },
    );
  }

  Widget _buildList(BuildContext context, List<ActionItemProjection> items) {
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

  Widget _buildTile(BuildContext context, ActionItemProjection item) {
    return ListTile(
      title: Text(item.actionName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context
          .read<ActionSettingBloc>()
          .add(ActionSettingItemSelected(item.id)),
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
    ActionSettingDelegate delegate,
  ) async {
    switch (delegate) {
      case ActionSettingOpenDetailDelegate(:final actionId):
        await context.push('/settings/action/$actionId');
      case ActionSettingOpenNewDelegate():
        await context.push('/settings/action/new');
    }
  }
}
