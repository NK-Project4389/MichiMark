import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/topic/topic_theme_color.dart';
import '../../../repository/event_repository.dart';
import '../../../repository/tag_repository.dart';
import '../../../repository/topic_repository.dart';
import '../../basic_info/bloc/basic_info_bloc.dart';
import '../../basic_info/bloc/basic_info_event.dart';
import '../../basic_info/bloc/basic_info_state.dart';
import '../../basic_info/view/basic_info_view.dart';
import '../../michi_info/bloc/michi_info_bloc.dart';
import '../../michi_info/bloc/michi_info_event.dart';
import '../../michi_info/view/michi_info_view.dart';
import '../../overview/bloc/overview_bloc.dart';
import '../../overview/bloc/overview_event.dart';
import '../../overview/view/event_detail_overview_page.dart';
import '../../payment_info/bloc/payment_info_bloc.dart';
import '../../payment_info/bloc/payment_info_event.dart';
import '../../payment_info/view/payment_info_view.dart';
import '../bloc/event_detail_bloc.dart';
import '../bloc/event_detail_event.dart';
import '../bloc/event_detail_state.dart';
import '../draft/event_detail_draft.dart';
import '../projection/event_detail_projection.dart';

class EventDetailPage extends StatelessWidget {
  final TopicType? initialTopicType;

  const EventDetailPage({super.key, this.initialTopicType});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventDetailBloc, EventDetailState>(
      listener: (context, state) {
        if (state is EventDetailLoaded) {
          final delegate = state.delegate;
          if (delegate != null) {
            _handleDelegate(context, delegate, state);
          }
          final errorMessage = state.saveErrorMessage;
          if (errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          EventDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          EventDetailError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          EventDetailLoaded(
            :final projection,
            :final draft,
            :final isSaving,
            :final topicThemeColor,
            :final topicDisplayName,
          ) =>
            _EventDetailScaffold(
              projection: projection,
              draft: draft,
              isSaving: isSaving,
              topicThemeColor: topicThemeColor,
              topicDisplayName: topicDisplayName,
              initialTopicType: initialTopicType,
            ),
        };
      },
    );
  }

  void _handleDelegate(
    BuildContext context,
    EventDetailDelegate delegate,
    EventDetailLoaded state,
  ) {
    switch (delegate) {
      case EventDetailDismissDelegate():
        context.pop();
      case EventDetailOpenMarkDelegate(:final markLinkId):
        context.go('/event/mark/$markLinkId');
      case EventDetailOpenLinkDelegate(:final markLinkId):
        context.go('/event/link/$markLinkId');
      case EventDetailOpenPaymentDelegate(:final paymentId):
        context.go('/event/payment/$paymentId');
      case EventDetailAddMarkLinkDelegate():
        context.go('/event/mark-link/add');
      case EventDetailSavedDelegate():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存しました')),
        );
      case EventDetailTopicConfigPropagateDelegate():
        // 子BlocへTopicConfigを伝播する。
        // 子BlocはEventDetailScaffoldのMultiBlocProvider内にある。
        // EventDetailScaffoldのBlocListenerで処理する。
        break;
    }
  }
}

class _EventDetailScaffold extends StatelessWidget {
  final EventDetailProjection projection;
  final EventDetailDraft draft;
  final bool isSaving;
  final TopicThemeColor? topicThemeColor;
  final String? topicDisplayName;
  final TopicType? initialTopicType;

  const _EventDetailScaffold({
    required this.projection,
    required this.draft,
    required this.isSaving,
    this.topicThemeColor,
    this.topicDisplayName,
    this.initialTopicType,
  });

  @override
  Widget build(BuildContext context) {
    final eventId = projection.basicInfo.eventId;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => BasicInfoBloc(
            eventRepository: getIt<EventRepository>(),
            topicRepository: getIt<TopicRepository>(),
            tagRepository: getIt<TagRepository>(),
          )..add(BasicInfoStarted(eventId, initialTopicType: initialTopicType)),
        ),
        BlocProvider(
          create: (_) => MichiInfoBloc(
            eventRepository: getIt<EventRepository>(),
          )..add(MichiInfoStarted(eventId)),
        ),
        BlocProvider(
          create: (_) => PaymentInfoBloc()
            ..add(PaymentInfoStarted(
              eventId: projection.eventId,
              projection: projection.paymentInfo,
            )),
        ),
        BlocProvider(
          create: (_) => EventDetailOverviewBloc(
            aggregationService: getIt(),
          ),
        ),
      ],
      child: _EventDetailScaffoldInner(
        projection: projection,
        draft: draft,
        isSaving: isSaving,
        topicThemeColor: topicThemeColor,
        topicDisplayName: topicDisplayName,
      ),
    );
  }
}

/// 子Blocが利用可能になったスコープ内でEventDetailBlocのDelegateを処理する。
class _EventDetailScaffoldInner extends StatelessWidget {
  final EventDetailProjection projection;
  final EventDetailDraft draft;
  final bool isSaving;
  final TopicThemeColor? topicThemeColor;
  final String? topicDisplayName;

  const _EventDetailScaffoldInner({
    required this.projection,
    required this.draft,
    required this.isSaving,
    this.topicThemeColor,
    this.topicDisplayName,
  });

  AppBar _buildAppBar(BuildContext context) {
    final themeColor = topicThemeColor;
    final displayName = topicDisplayName;
    final eventName = projection.basicInfo.eventName.isEmpty
        ? 'イベント詳細'
        : projection.basicInfo.eventName;

    final saveAction = BlocBuilder<BasicInfoBloc, BasicInfoState>(
      builder: (context, basicInfoState) {
        return IconButton(
          icon: const Icon(Icons.check),
          onPressed: basicInfoState is BasicInfoLoaded
              ? () => context.read<EventDetailBloc>().add(
                    EventDetailSaveRequested(
                      eventId: projection.basicInfo.eventId,
                      basicInfoDraft: basicInfoState.draft,
                    ),
                  )
              : null,
        );
      },
    );

    if (themeColor == null) {
      // Topic未設定: デフォルトのAppBar表示
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context
              .read<EventDetailBloc>()
              .add(const EventDetailDismissPressed()),
        ),
        title: Text(eventName),
        centerTitle: true,
        actions: [
          if (isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            saveAction,
        ],
      );
    }

    // Topic設定済み: グラデーション AppBar
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () => context
            .read<EventDetailBloc>()
            .add(const EventDetailDismissPressed()),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eventName,
            style: const TextStyle(color: Colors.white),
          ),
          if (displayName != null && displayName.isNotEmpty)
            Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
      centerTitle: true,
      foregroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themeColor.darkColor, themeColor.primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        if (isSaving)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          )
        else
          saveAction,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // EventDetailBlocのDelegateを監視し、子BlocへTopicConfig伝播を行う
    return MultiBlocListener(
      listeners: [
        BlocListener<EventDetailBloc, EventDetailState>(
          listenWhen: (prev, curr) =>
              curr is EventDetailLoaded && curr.delegate != null,
          listener: (context, state) {
            if (state is! EventDetailLoaded) return;
            final delegate = state.delegate;
            if (delegate == null) return;

            switch (delegate) {
              case EventDetailTopicConfigPropagateDelegate(:final topicConfig):
                context
                    .read<MichiInfoBloc>()
                    .add(MichiInfoTopicConfigUpdated(topicConfig));
                // OverviewBlocへもTopicConfig変更を伝播する
                final cachedEvent = state.cachedEvent;
                if (cachedEvent != null) {
                  context.read<EventDetailOverviewBloc>().add(
                        OverviewTopicConfigUpdated(
                          config: topicConfig,
                          event: cachedEvent,
                        ),
                      );
                }

              default:
                break;
            }
          },
        ),
        // Overviewタブ選択時にOverviewStartedを発火する
        BlocListener<EventDetailBloc, EventDetailState>(
          listenWhen: (prev, curr) {
            if (prev is! EventDetailLoaded || curr is! EventDetailLoaded) {
              return false;
            }
            return prev.draft.selectedTab != EventDetailTab.overview &&
                curr.draft.selectedTab == EventDetailTab.overview;
          },
          listener: (context, state) {
            if (state is! EventDetailLoaded) return;
            final cachedEvent = state.cachedEvent;
            if (cachedEvent == null) return;
            context.read<EventDetailOverviewBloc>().add(OverviewStarted(
                  event: cachedEvent,
                  topicConfig: state.topicConfig,
                ));
          },
        ),
      ],
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(child: _tabContent(context, draft, projection)),
            const Divider(height: 1),
            _TabBar(selectedTab: draft.selectedTab),
          ],
        ),
      ),
    );
  }

  Widget _tabContent(
    BuildContext context,
    EventDetailDraft draft,
    EventDetailProjection projection,
  ) {
    return switch (draft.selectedTab) {
      EventDetailTab.basicInfo => const BasicInfoView(),
      EventDetailTab.michiInfo => const MichiInfoView(),
      EventDetailTab.paymentInfo => const PaymentInfoView(),
      EventDetailTab.overview => const EventDetailOverviewPage(),
    };
  }
}

class _TabBar extends StatelessWidget {
  final EventDetailTab selectedTab;

  const _TabBar({required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Row(
        children: EventDetailTab.values.map((tab) {
          return Expanded(
            child: _TabButton(tab: tab, selectedTab: selectedTab),
          );
        }).toList(),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final EventDetailTab tab;
  final EventDetailTab selectedTab;

  const _TabButton({required this.tab, required this.selectedTab});

  String get _label => switch (tab) {
        EventDetailTab.basicInfo => '基本',
        EventDetailTab.michiInfo => 'ミチ',
        EventDetailTab.paymentInfo => '支払',
        EventDetailTab.overview => '振り返り',
      };

  @override
  Widget build(BuildContext context) {
    final isSelected = tab == selectedTab;
    return TextButton(
      onPressed: () => context
          .read<EventDetailBloc>()
          .add(EventDetailTabSelected(tab)),
      child: Text(
        _label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
      ),
    );
  }
}
