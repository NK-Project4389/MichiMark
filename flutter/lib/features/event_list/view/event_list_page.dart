import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/topic/topic_theme_color.dart';
import '../../event_detail/event_detail_args.dart';
import '../bloc/event_list_bloc.dart';
import '../bloc/event_list_event.dart';
import '../bloc/event_list_state.dart';
import '../projection/event_list_projection.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventListBloc, EventListState>(
      listener: (context, state) {
        if (state is! EventListLoaded) return;

        if (state.showTopicSelection) {
          _handleShowTopicSelection();
        }

        final delegate = state.delegate;
        if (delegate != null) {
          _handleDelegate(context, delegate);
          context.read<EventListBloc>().add(const EventListDelegateConsumed());
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

  void _handleShowTopicSelection() {
    showModalBottomSheet<TopicType>(
      context: context,
      builder: (sheetContext) => _TopicSelectionSheet(),
    ).then((selectedTopicType) {
      if (!mounted) return;
      if (selectedTopicType == null) return;
      final eventId = const Uuid().v4();
      context.read<EventListBloc>().add(
            EventListTopicSelectedForNewEvent(
              topicType: selectedTopicType,
              eventId: eventId,
            ),
          );
    });
  }

  void _handleDelegate(BuildContext context, EventListDelegate delegate) {
    switch (delegate) {
      case OpenEventDetailDelegate(:final eventId):
        context.push('/event/$eventId');
      case OpenAddEventWithTopicDelegate(:final topicType, :final eventId):
        context.push(
          '/event/$eventId',
          extra: EventDetailArgs(initialTopicType: topicType),
        );
      case OpenSettingsDelegate():
        context.go('/settings');
    }
  }
}

class _TopicSelectionSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'トピックを選択',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...TopicType.values.map((type) {
            final config = TopicConfig.forType(type);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: config.themeColor.primaryColor,
                radius: 16,
              ),
              title: Text(config.displayName),
              onTap: () => Navigator.of(context).pop(type),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
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
