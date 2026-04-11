import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/tag_setting_bloc.dart';
import '../bloc/tag_setting_event.dart';
import '../bloc/tag_setting_state.dart';
import '../../../../features/shared/projection/tag_item_projection.dart';

class TagSettingPage extends StatelessWidget {
  const TagSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TagSettingBloc, TagSettingState>(
      listener: (context, state) async {
        if (state is TagSettingLoaded && state.delegate != null) {
          await _handleDelegate(context, state.delegate!);
          if (context.mounted) {
            context.read<TagSettingBloc>().add(const TagSettingStarted());
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          TagSettingLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          TagSettingError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          TagSettingLoaded(:final items) => Scaffold(
              appBar: AppBar(
                title: const Text('タグ'),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    color: const Color(0xFFF59E0B),
                    onPressed: () => context
                        .read<TagSettingBloc>()
                        .add(const TagSettingAddTapped()),
                  ),
                ],
              ),
              body: items.isEmpty
                  ? const Center(child: Text('タグがありません'))
                  : _buildList(context, items),
            ),
        };
      },
    );
  }

  Widget _buildList(BuildContext context, List<TagItemProjection> items) {
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

  Widget _buildTile(BuildContext context, TagItemProjection item) {
    return ListTile(
      title: Text(item.tagName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context
          .read<TagSettingBloc>()
          .add(TagSettingItemSelected(item.id)),
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
    TagSettingDelegate delegate,
  ) async {
    switch (delegate) {
      case TagSettingOpenDetailDelegate(:final tagId):
        await context.push('/settings/tag/$tagId');
      case TagSettingOpenNewDelegate():
        await context.push('/settings/tag/new');
    }
  }
}
