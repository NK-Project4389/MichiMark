import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/topic/topic_theme_color.dart';
import '../../../repository/action_repository.dart';
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
            :final topicThemeColor,
            :final topicDisplayName,
          ) =>
            _EventDetailScaffold(
              projection: projection,
              draft: draft,
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
  final TopicThemeColor? topicThemeColor;
  final String? topicDisplayName;
  final TopicType? initialTopicType;

  const _EventDetailScaffold({
    required this.projection,
    required this.draft,
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
            actionRepository: getIt<ActionRepository>(),
          )..add(MichiInfoStarted(eventId)),
        ),
        BlocProvider(
          create: (_) => PaymentInfoBloc(
            eventRepository: getIt<EventRepository>(),
          )..add(PaymentInfoStarted(
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
  final TopicThemeColor? topicThemeColor;
  final String? topicDisplayName;

  const _EventDetailScaffoldInner({
    required this.projection,
    required this.draft,
    this.topicThemeColor,
    this.topicDisplayName,
  });

  AppBar _buildAppBar(BuildContext context) {
    final themeColor = topicThemeColor;
    final displayName = topicDisplayName;
    final eventName = projection.basicInfo.eventName.isEmpty
        ? 'イベント詳細'
        : projection.basicInfo.eventName;

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
        // BasicInfoSavedDelegate受信後にcachedEventを更新する
        BlocListener<BasicInfoBloc, BasicInfoState>(
          listenWhen: (prev, curr) =>
              curr is BasicInfoLoaded && curr.delegate is BasicInfoSavedDelegate,
          listener: (context, state) {
            context
                .read<EventDetailBloc>()
                .add(const EventDetailCachedEventUpdateRequested());
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
      EventDetailTab.overview => _OverviewTabContent(
          eventId: projection.basicInfo.eventId,
        ),
      EventDetailTab.michiInfo => const MichiInfoView(),
      EventDetailTab.paymentInfo => const PaymentInfoView(),
    };
  }
}

/// 概要タブのコンテンツ（BasicInfoView + EventDetailOverviewPage の縦並び）
class _OverviewTabContent extends StatelessWidget {
  final String eventId;

  const _OverviewTabContent({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BasicInfoView(),
          Divider(height: 1),
          EventDetailOverviewPage(),
        ],
      ),
    );
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
        EventDetailTab.overview => '概要',
        EventDetailTab.michiInfo => 'ミチ',
        EventDetailTab.paymentInfo => '支払',
      };

  @override
  Widget build(BuildContext context) {
    final isSelected = tab == selectedTab;
    return TextButton(
      onPressed: () => _onTabPressed(context),
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

  void _onTabPressed(BuildContext context) {
    // 編集中チェック
    final basicInfoState = context.read<BasicInfoBloc>().state;
    if (basicInfoState is BasicInfoLoaded && basicInfoState.draft.isEditing) {
      _showUnsavedChangesDialog(context);
      return;
    }
    context.read<EventDetailBloc>().add(EventDetailTabSelected(tab));
  }

  void _showUnsavedChangesDialog(BuildContext context) {
    final targetTab = tab;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('未保存の変更があります'),
          content: const Text('編集内容を保存しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<BasicInfoBloc>()
                    .add(const BasicInfoEditCancelled());
                context
                    .read<EventDetailBloc>()
                    .add(EventDetailTabSelected(targetTab));
              },
              child: const Text('破棄して移動'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // 保存後にタブ切り替えを行うため、BasicInfoSavedDelegateを
                // BasicInfoBlocListenerで受け取ってタブ切り替えを実行する
                // ここでは保存のみ発火し、タブ切り替えはEventDetailBlocListenerで行う
                context
                    .read<BasicInfoBloc>()
                    .add(const BasicInfoSavePressed());
                // 保存完了後にタブ切り替え（BlocListenerで処理）
                // EventDetailBlocにタブ遷移先を伝えるため、直接切り替えを予約する
                // BasicInfoSavedDelegateがemitされた後にlistenerが動くため
                // ここではタブ切り替えをBlocListenerに委譲
                // 実装上、保存成功後は自動でisEditing=falseになるため
                // 次のフレームでタブ切り替えを行う
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context
                      .read<EventDetailBloc>()
                      .add(EventDetailTabSelected(targetTab));
                });
              },
              child: const Text('保存して移動'),
            ),
          ],
        );
      },
    );
  }
}
