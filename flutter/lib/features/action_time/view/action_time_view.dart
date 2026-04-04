import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/action_time_bloc.dart';
import '../bloc/action_time_event.dart';
import '../bloc/action_time_state.dart';
import '../projection/action_time_projection.dart';

/// ActionTime記録UI
class ActionTimeView extends StatelessWidget {
  const ActionTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActionTimeBloc, ActionTimeState>(
      listener: (context, state) {
        final delegate = state.delegate;
        if (delegate is ActionTimeNavigateBackDelegate) {
          Navigator.of(context).pop();
        }
        final error = state.errorMessage;
        if (error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error)));
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return _ActionTimeContent(state: state);
      },
    );
  }
}

class _ActionTimeContent extends StatelessWidget {
  final ActionTimeState state;

  const _ActionTimeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final projection = state.projection;
    final availableActions = state.draft.availableActions;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 現在状態表示
        _CurrentStateCard(label: projection.currentStateLabel),
        const SizedBox(height: 16),

        // 発火可能なActionボタン一覧
        if (availableActions.isNotEmpty) ...[
          Text(
            '記録する',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableActions.map((action) {
              return ElevatedButton(
                onPressed: () => context
                    .read<ActionTimeBloc>()
                    .add(ActionTimeLogRecorded(action.id)),
                child: Text(action.actionName),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // 休憩トグルボタン
        _BreakToggleButton(isBreakActive: projection.isBreakActive),
        const SizedBox(height: 16),

        // タイムラインログ
        Text(
          'ログ',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (projection.logItems.isEmpty)
          const Text('記録がありません')
        else
          ...projection.logItems.map(
            (item) => _LogItem(item: item),
          ),
      ],
    );
  }
}

class _CurrentStateCard extends StatelessWidget {
  final String label;

  const _CurrentStateCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              '現在の状態',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakToggleButton extends StatelessWidget {
  final bool isBreakActive;

  const _BreakToggleButton({required this.isBreakActive});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () =>
          context.read<ActionTimeBloc>().add(const ActionTimeBreakToggled()),
      icon: Icon(isBreakActive ? Icons.play_arrow : Icons.pause),
      label: Text(isBreakActive ? '休憩終了' : '休憩開始'),
    );
  }
}

class _LogItem extends StatelessWidget {
  final ActionTimeLogProjection item;

  const _LogItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Text(
        item.timestampLabel,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      title: Text(item.actionName),
      subtitle: Text(
        item.transitionLabel,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        onPressed: () =>
            context.read<ActionTimeBloc>().add(ActionTimeLogDeleted(item.id)),
      ),
    );
  }
}
