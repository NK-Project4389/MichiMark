import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/topic/topic_theme_color.dart';
import '../bloc/event_list_bloc.dart';
import '../bloc/event_list_event.dart';
import '../bloc/event_list_state.dart';
import '../projection/event_list_projection.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventListBloc, EventListState>(
      listener: (context, state) {
        if (state is EventListLoaded && state.delegate != null) {
          _handleDelegate(context, state.delegate!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('イベント'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context
                    .read<EventListBloc>()
                    .add(const EventListSettingsButtonPressed()),
              ),
            ],
          ),
          body: switch (state) {
            EventListLoading() => const Center(child: CircularProgressIndicator()),
            EventListError(:final message) => Center(child: Text(message)),
            EventListLoaded(:final projection) => _EventListBody(
                projection: projection,
              ),
          },
          floatingActionButton: FloatingActionButton(
            onPressed: () => context
                .read<EventListBloc>()
                .add(const EventListAddButtonPressed()),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _handleDelegate(BuildContext context, EventListDelegate delegate) {
    switch (delegate) {
      case OpenEventDetailDelegate(:final eventId):
        context.push('/event/$eventId');
      case OpenAddEventDelegate():
        context.push('/event/${const Uuid().v4()}');
      case OpenSettingsDelegate():
        context.go('/settings');
    }
  }
}

class _EventListBody extends StatelessWidget {
  final EventListProjection projection;

  const _EventListBody({required this.projection});

  @override
  Widget build(BuildContext context) {
    if (projection.isEmpty) {
      return const Center(child: Text('イベントがありません'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: projection.events.length,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = projection.events[index];
        return _EventListItem(item: item);
      },
    );
  }
}

class _EventListItem extends StatelessWidget {
  final EventSummaryItemProjection item;

  const _EventListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final borderColor = item.themeColor?.primaryColor
        ?? TopicThemeColor.defaultBorderColor;

    return GestureDetector(
      onTap: () => context
          .read<EventListBloc>()
          .add(EventListItemTapped(item.id)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 左ボーダー（幅4dp・Topicカラー）
                Container(
                  width: 4,
                  color: borderColor,
                ),
                // メインコンテンツ
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.eventName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (item.displayFromDate.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.displayToDate.isNotEmpty
                                      ? '${item.displayFromDate} 〜 ${item.displayToDate}'
                                      : item.displayFromDate,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
