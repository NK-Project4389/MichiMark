import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/action_setting_bloc.dart';
import '../bloc/action_setting_event.dart';
import '../bloc/action_setting_state.dart';

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
                    onPressed: () => context
                        .read<ActionSettingBloc>()
                        .add(const ActionSettingAddTapped()),
                  ),
                ],
              ),
              body: items.isEmpty
                  ? const Center(child: Text('行動がありません'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.actionName),
                          subtitle: item.isVisible ? null : const Text('非表示'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context
                              .read<ActionSettingBloc>()
                              .add(ActionSettingItemSelected(item.id)),
                        );
                      },
                    ),
            ),
        };
      },
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
