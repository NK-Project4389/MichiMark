import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/tag_setting_bloc.dart';
import '../bloc/tag_setting_event.dart';
import '../bloc/tag_setting_state.dart';

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
                    onPressed: () => context
                        .read<TagSettingBloc>()
                        .add(const TagSettingAddTapped()),
                  ),
                ],
              ),
              body: items.isEmpty
                  ? const Center(child: Text('タグがありません'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.tagName),
                          subtitle: item.isVisible ? null : const Text('非表示'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context
                              .read<TagSettingBloc>()
                              .add(TagSettingItemSelected(item.id)),
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
