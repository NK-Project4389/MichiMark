import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di.dart';
import '../../../repository/event_repository.dart';
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
  const EventDetailPage({super.key});

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
          EventDetailLoaded(:final projection, :final draft, :final isSaving) =>
            _EventDetailScaffold(
              projection: projection,
              draft: draft,
              isSaving: isSaving,
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
      case EventDetailAvailableTopicsDelegate():
        // BasicInfoBlocはEventDetailScaffoldのMultiBlocProvider内で生成されるため
        // このスコープからは直接アクセスできない。_EventDetailScaffoldInnerのBlocListenerで処理する。
        break;
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

  const _EventDetailScaffold({
    required this.projection,
    required this.draft,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    final eventId = projection.basicInfo.eventId;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => BasicInfoBloc(
            eventRepository: getIt<EventRepository>(),
          )..add(BasicInfoStarted(eventId)),
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
      ),
    );
  }
}

/// 子Blocが利用可能になったスコープ内でEventDetailBlocのDelegateを処理する。
class _EventDetailScaffoldInner extends StatelessWidget {
  final EventDetailProjection projection;
  final EventDetailDraft draft;
  final bool isSaving;

  const _EventDetailScaffoldInner({
    required this.projection,
    required this.draft,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    // BasicInfoBlocのDelegateを監視し、TopicChanged → EventDetailTopicChanged を送信する
    // EventDetailBlocのDelegateを監視し、子BlocへTopicConfig伝播を行う
    return MultiBlocListener(
      listeners: [
        BlocListener<BasicInfoBloc, BasicInfoState>(
          listenWhen: (prev, curr) =>
              curr is BasicInfoLoaded &&
              curr.delegate is BasicInfoTopicChangedDelegate,
          listener: (context, state) {
            if (state case BasicInfoLoaded(
              delegate: BasicInfoTopicChangedDelegate(:final topic),
            )) {
              context.read<EventDetailBloc>().add(EventDetailTopicChanged(topic));
            }
          },
        ),
        BlocListener<EventDetailBloc, EventDetailState>(
          listenWhen: (prev, curr) =>
              curr is EventDetailLoaded && curr.delegate != null,
          listener: (context, state) {
            if (state is! EventDetailLoaded) return;
            final delegate = state.delegate;
            if (delegate == null) return;

            switch (delegate) {
              case EventDetailAvailableTopicsDelegate(:final topics):
                context
                    .read<BasicInfoBloc>()
                    .add(BasicInfoAvailableTopicsReceived(topics));

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
                // MarkDetailBloc / LinkDetailBloc はルートレベルにあるため
                // このスコープからは参照不可。EventDetailで管理しているBlocのみ伝播する。
                // NOTE: MarkDetailBloc / LinkDetailBloc は別ルートで生成されるため、
                // topicConfig の伝播は現状のアーキテクチャでは未対応（別ルート起動時に初期値を使用）。

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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => context
                .read<EventDetailBloc>()
                .add(const EventDetailDismissPressed()),
          ),
          title: Text(projection.basicInfo.eventName.isEmpty
              ? 'イベント詳細'
              : projection.basicInfo.eventName),
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
              BlocBuilder<BasicInfoBloc, BasicInfoState>(
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
              ),
          ],
        ),
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
