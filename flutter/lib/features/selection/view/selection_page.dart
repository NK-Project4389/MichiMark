import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/selection_bloc.dart';
import '../bloc/selection_event.dart';
import '../bloc/selection_state.dart';
import '../projection/selection_projection.dart';
import '../selection_args.dart';
import '../draft/selection_draft.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SelectionBloc, SelectionState>(
      listener: (context, state) {
        if (state is SelectionLoaded && state.delegate != null) {
          switch (state.delegate!) {
            case SelectionConfirmedDelegate(:final result):
              context.pop(result);
            case SelectionDismissedDelegate():
              context.pop(null);
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          SelectionLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          SelectionError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          SelectionLoaded(:final projection, :final draft) =>
            _SelectionScaffold(projection: projection, draft: draft),
        };
      },
    );
  }
}

class _SelectionScaffold extends StatelessWidget {
  final SelectionProjection projection;
  final SelectionDraft draft;

  const _SelectionScaffold({
    required this.projection,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.read<SelectionBloc>().add(const SelectionDismissed()),
        ),
        title: Text(projection.title),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () =>
                context.read<SelectionBloc>().add(const SelectionConfirmed()),
            child: const Text('確定'),
          ),
        ],
      ),
      body: projection.items.isEmpty
          ? const Center(child: Text('選択肢がありません'))
          : ListView.builder(
              itemCount: projection.items.length,
              itemBuilder: (context, index) {
                final item = projection.items[index];
                return _SelectionItem(
                  item: item,
                  mode: projection.mode,
                );
              },
            ),
    );
  }
}

class _SelectionItem extends StatelessWidget {
  final SelectionItemProjection item;
  final SelectionMode mode;

  const _SelectionItem({required this.item, required this.mode});

  @override
  Widget build(BuildContext context) {
    final leadingIcon = switch (mode) {
      SelectionMode.single => item.isSelected
          ? Icons.radio_button_checked
          : Icons.radio_button_unchecked,
      SelectionMode.multiple =>
        item.isSelected ? Icons.check_box : Icons.check_box_outline_blank,
    };
    final disabledColor = Theme.of(context).disabledColor;
    return ListTile(
      leading: Icon(
        leadingIcon,
        color: item.isFixed
            ? disabledColor
            : item.isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        item.label,
        style: item.isFixed
            ? TextStyle(color: disabledColor)
            : null,
      ),
      subtitle: item.subLabel != null
          ? Text(
              item.subLabel!,
              style: item.isFixed
                  ? TextStyle(color: disabledColor)
                  : null,
            )
          : null,
      onTap: item.isFixed
          ? null
          : () =>
              context.read<SelectionBloc>().add(SelectionItemToggled(item.id)),
    );
  }
}
