import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../repository/event_repository.dart';
import '../../basic_info/bloc/basic_info_bloc.dart';
import '../../basic_info/bloc/basic_info_event.dart';
import '../../basic_info/bloc/basic_info_state.dart';
import '../../basic_info/view/basic_info_view.dart';
import '../../michi_info/bloc/michi_info_bloc.dart';
import '../../michi_info/bloc/michi_info_event.dart';
import '../../michi_info/view/michi_info_view.dart';
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
          if (state.delegate != null) {
            _handleDelegate(context, state.delegate!);
          }
          if (state.saveErrorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.saveErrorMessage!)),
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

  void _handleDelegate(BuildContext context, EventDetailDelegate delegate) {
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
            eventRepository: context.read<EventRepository>(),
          )..add(BasicInfoStarted(eventId)),
        ),
        BlocProvider(
          create: (_) => MichiInfoBloc(
            eventRepository: context.read<EventRepository>(),
          )..add(MichiInfoStarted(eventId)),
        ),
        BlocProvider(
          create: (_) => PaymentInfoBloc()
            ..add(PaymentInfoStarted(
              eventId: projection.eventId,
              projection: projection.paymentInfo,
            )),
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
                                eventId: eventId,
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
            Expanded(child: _tabContent(draft)),
            const Divider(height: 1),
            _TabBar(selectedTab: draft.selectedTab),
          ],
        ),
      ),
    );
  }

  Widget _tabContent(EventDetailDraft draft) {
    return switch (draft.selectedTab) {
      EventDetailTab.basicInfo => const BasicInfoView(),
      EventDetailTab.michiInfo => const MichiInfoView(),
      EventDetailTab.paymentInfo => const PaymentInfoView(),
      EventDetailTab.overview => const _OverviewTabView(),
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

// ── Tab contents（Overview プレースホルダー）─────────────────────────────

class _OverviewTabView extends StatelessWidget {
  const _OverviewTabView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('振り返り（未実装）'));
  }
}

