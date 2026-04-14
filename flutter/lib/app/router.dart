import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'di.dart';
import '../features/event_detail/bloc/event_detail_bloc.dart';
import '../features/event_detail/bloc/event_detail_event.dart';
import '../features/event_detail/event_detail_args.dart';
import '../features/event_detail/view/event_detail_page.dart';
import '../features/event_list/bloc/event_list_bloc.dart';
import '../features/event_list/bloc/event_list_event.dart';
import '../features/event_list/view/event_list_page.dart';
import '../features/selection/bloc/selection_bloc.dart';
import '../features/selection/bloc/selection_event.dart';
import '../features/selection/selection_args.dart';
import '../features/link_detail/bloc/link_detail_bloc.dart';
import '../features/link_detail/bloc/link_detail_event.dart';
import '../features/link_detail/link_detail_args.dart';
import '../features/link_detail/view/link_detail_page.dart';
import '../features/mark_detail/bloc/mark_detail_bloc.dart';
import '../features/mark_detail/bloc/mark_detail_event.dart';
import '../features/mark_detail/mark_detail_args.dart';
import '../features/mark_detail/view/mark_detail_page.dart';
import '../features/payment_detail/bloc/payment_detail_bloc.dart';
import '../features/payment_detail/bloc/payment_detail_event.dart';
import '../features/payment_detail/payment_detail_args.dart';
import '../features/payment_detail/view/payment_detail_page.dart';
import '../features/selection/view/selection_page.dart';
import '../features/settings/bloc/settings_bloc.dart';
import '../features/settings/view/settings_page.dart';
import '../features/settings/trans_setting/bloc/trans_setting_bloc.dart';
import '../features/settings/trans_setting/bloc/trans_setting_event.dart';
import '../features/settings/trans_setting/bloc/trans_setting_detail_bloc.dart';
import '../features/settings/trans_setting/bloc/trans_setting_detail_event.dart';
import '../features/settings/trans_setting/view/trans_setting_page.dart';
import '../features/settings/trans_setting/view/trans_setting_detail_page.dart';
import '../features/settings/member_setting/bloc/member_setting_bloc.dart';
import '../features/settings/member_setting/bloc/member_setting_event.dart';
import '../features/settings/member_setting/bloc/member_setting_detail_bloc.dart';
import '../features/settings/member_setting/bloc/member_setting_detail_event.dart';
import '../features/settings/member_setting/view/member_setting_page.dart';
import '../features/settings/member_setting/view/member_setting_detail_page.dart';
import '../features/settings/tag_setting/bloc/tag_setting_bloc.dart';
import '../features/settings/tag_setting/bloc/tag_setting_event.dart';
import '../features/settings/tag_setting/bloc/tag_setting_detail_bloc.dart';
import '../features/settings/tag_setting/bloc/tag_setting_detail_event.dart';
import '../features/settings/tag_setting/view/tag_setting_page.dart';
import '../features/settings/tag_setting/view/tag_setting_detail_page.dart';
import '../features/settings/action_setting/bloc/action_setting_bloc.dart';
import '../features/settings/action_setting/bloc/action_setting_event.dart';
import '../features/settings/action_setting/bloc/action_setting_detail_bloc.dart';
import '../features/settings/action_setting/bloc/action_setting_detail_event.dart';
import '../features/settings/action_setting/view/action_setting_page.dart';
import '../features/settings/action_setting/view/action_setting_detail_page.dart';
import '../adapter/aggregation_service.dart';
import '../features/aggregation/bloc/aggregation_bloc.dart';
import '../features/aggregation/bloc/aggregation_event.dart';
import '../features/aggregation/view/aggregation_page.dart';
import '../domain/master/member/member_domain.dart';
import '../repository/action_repository.dart';
import '../repository/event_repository.dart';
import '../repository/member_repository.dart';
import '../repository/tag_repository.dart';
import '../repository/topic_repository.dart';
import '../repository/trans_repository.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => EventListBloc(
          eventRepository: getIt<EventRepository>(),
        )..add(const EventListStarted()),
        child: const EventListPage(),
      ),
    ),
    // 固定パスを先に定義（/event/:id より前に置かないとマッチしない）
    GoRoute(
      path: '/event/mark/:markId',
      builder: (context, state) {
        final markId = state.pathParameters['markId'] ?? '';
        final args = state.extra;
        final eventId = args is MarkDetailArgs ? args.eventId : (args as String? ?? '');
        final topicConfig = args is MarkDetailArgs ? args.topicConfig : null;
        final initialMeterValueInput =
            args is MarkDetailArgs ? args.initialMeterValueInput : '';
        final List<MemberDomain> initialSelectedMembers =
            args is MarkDetailArgs ? args.initialSelectedMembers : const [];
        final initialMarkLinkDate =
            args is MarkDetailArgs ? args.initialMarkLinkDate : null;
        final List<MemberDomain> eventMembers =
            args is MarkDetailArgs ? args.eventMembers : const [];
        final insertAfterSeq =
            args is MarkDetailArgs ? args.insertAfterSeq : null;
        return BlocProvider(
          create: (_) => MarkDetailBloc(
            eventRepository: getIt<EventRepository>(),
            transRepository: getIt<TransRepository>(),
            insertAfterSeq: insertAfterSeq,
          )..add(MarkDetailStarted(
              eventId: eventId,
              markLinkId: markId,
              topicConfig: topicConfig,
              initialMeterValueInput: initialMeterValueInput,
              initialSelectedMembers: initialSelectedMembers,
              initialMarkLinkDate: initialMarkLinkDate,
              eventMembers: eventMembers,
            )),
          child: const MarkDetailPage(),
        );
      },
    ),
    GoRoute(
      path: '/event/link/:linkId',
      builder: (context, state) {
        final linkId = state.pathParameters['linkId'] ?? '';
        final args = state.extra;
        final eventId = args is LinkDetailArgs ? args.eventId : (args as String? ?? '');
        final topicConfig = args is LinkDetailArgs ? args.topicConfig : null;
        final eventMembers = args is LinkDetailArgs ? args.eventMembers : const <MemberDomain>[];
        final insertAfterSeq =
            args is LinkDetailArgs ? args.insertAfterSeq : null;
        return BlocProvider(
          create: (_) => LinkDetailBloc(
            eventRepository: getIt<EventRepository>(),
            insertAfterSeq: insertAfterSeq,
          )..add(LinkDetailStarted(
              eventId: eventId,
              markLinkId: linkId,
              topicConfig: topicConfig,
              eventMembers: eventMembers,
            )),
          child: const LinkDetailPage(),
        );
      },
    ),
    GoRoute(
      path: '/event/payment',
      builder: (context, state) {
        final args = state.extra as PaymentDetailArgs;
        return BlocProvider(
          create: (_) => PaymentDetailBloc(
            eventRepository: getIt<EventRepository>(),
            memberRepository: getIt<MemberRepository>(),
          )..add(PaymentDetailStarted(
              eventId: args.eventId,
              paymentId: args.paymentId,
            )),
          child: const PaymentDetailPage(),
        );
      },
    ),
    // パラメータ付きルートは固定パスの後に定義
    GoRoute(
      path: '/event/:id',
      builder: (context, state) {
        final eventId = state.pathParameters['id'] ?? '';
        final args = state.extra as EventDetailArgs?;
        return BlocProvider(
          create: (_) => EventDetailBloc(
            eventRepository: getIt<EventRepository>(),
            topicRepository: getIt<TopicRepository>(),
          )..add(EventDetailStarted(eventId, initialTopicType: args?.initialTopicType)),
          child: EventDetailPage(initialTopicType: args?.initialTopicType),
        );
      },
    ),
    GoRoute(
      path: '/selection',
      builder: (context, state) {
        final args = state.extra as SelectionArgs;
        return BlocProvider(
          create: (_) => SelectionBloc(
            type: args.type,
            selectedIds: args.selectedIds,
            fixedSelectedIds: args.fixedSelectedIds,
            candidateMembers: args.candidateMembers,
            transRepository: getIt<TransRepository>(),
            memberRepository: getIt<MemberRepository>(),
            tagRepository: getIt<TagRepository>(),
            actionRepository: getIt<ActionRepository>(),
            topicRepository: getIt<TopicRepository>(),
          )..add(const SelectionStarted()),
          child: const SelectionPage(),
        );
      },
    ),
    // Aggregation
    GoRoute(
      path: '/aggregation',
      builder: (context, state) => BlocProvider(
        create: (_) => AggregationBloc(
          eventRepository: getIt<EventRepository>(),
          aggregationService: getIt<AggregationService>(),
          tagRepository: getIt<TagRepository>(),
          memberRepository: getIt<MemberRepository>(),
          transRepository: getIt<TransRepository>(),
          topicRepository: getIt<TopicRepository>(),
        )..add(const AggregationStarted()),
        child: const AggregationPage(),
      ),
    ),
    // Settings
    GoRoute(
      path: '/settings',
      builder: (context, state) => BlocProvider(
        create: (_) => SettingsBloc(),
        child: const SettingsPage(),
      ),
    ),
    // Trans Setting
    GoRoute(
      path: '/settings/trans',
      builder: (context, state) => BlocProvider(
        create: (_) => TransSettingBloc(
          transRepository: getIt<TransRepository>(),
        )..add(const TransSettingStarted()),
        child: const TransSettingPage(),
      ),
    ),
    GoRoute(
      path: '/settings/trans/new',
      builder: (context, state) => BlocProvider(
        create: (_) => TransSettingDetailBloc(
          transRepository: getIt<TransRepository>(),
        )..add(const TransSettingDetailStarted()),
        child: const TransSettingDetailPage(),
      ),
    ),
    GoRoute(
      path: '/settings/trans/:transId',
      builder: (context, state) {
        final transId = state.pathParameters['transId'] ?? '';
        return BlocProvider(
          create: (_) => TransSettingDetailBloc(
            transRepository: getIt<TransRepository>(),
          )..add(TransSettingDetailStarted(transId: transId)),
          child: const TransSettingDetailPage(),
        );
      },
    ),
    // Member Setting
    GoRoute(
      path: '/settings/member',
      builder: (context, state) => BlocProvider(
        create: (_) => MemberSettingBloc(
          memberRepository: getIt<MemberRepository>(),
        )..add(const MemberSettingStarted()),
        child: const MemberSettingPage(),
      ),
    ),
    GoRoute(
      path: '/settings/member/new',
      builder: (context, state) => BlocProvider(
        create: (_) => MemberSettingDetailBloc(
          memberRepository: getIt<MemberRepository>(),
        )..add(const MemberSettingDetailStarted()),
        child: const MemberSettingDetailPage(),
      ),
    ),
    GoRoute(
      path: '/settings/member/:memberId',
      builder: (context, state) {
        final memberId = state.pathParameters['memberId'] ?? '';
        return BlocProvider(
          create: (_) => MemberSettingDetailBloc(
            memberRepository: getIt<MemberRepository>(),
          )..add(MemberSettingDetailStarted(memberId: memberId)),
          child: const MemberSettingDetailPage(),
        );
      },
    ),
    // Tag Setting
    GoRoute(
      path: '/settings/tag',
      builder: (context, state) => BlocProvider(
        create: (_) => TagSettingBloc(
          tagRepository: getIt<TagRepository>(),
        )..add(const TagSettingStarted()),
        child: const TagSettingPage(),
      ),
    ),
    GoRoute(
      path: '/settings/tag/new',
      builder: (context, state) => BlocProvider(
        create: (_) => TagSettingDetailBloc(
          tagRepository: getIt<TagRepository>(),
        )..add(const TagSettingDetailStarted()),
        child: const TagSettingDetailPage(),
      ),
    ),
    GoRoute(
      path: '/settings/tag/:tagId',
      builder: (context, state) {
        final tagId = state.pathParameters['tagId'] ?? '';
        return BlocProvider(
          create: (_) => TagSettingDetailBloc(
            tagRepository: getIt<TagRepository>(),
          )..add(TagSettingDetailStarted(tagId: tagId)),
          child: const TagSettingDetailPage(),
        );
      },
    ),
    // Action Setting
    GoRoute(
      path: '/settings/action',
      builder: (context, state) => BlocProvider(
        create: (_) => ActionSettingBloc(
          actionRepository: getIt<ActionRepository>(),
        )..add(const ActionSettingStarted()),
        child: const ActionSettingPage(),
      ),
    ),
    GoRoute(
      path: '/settings/action/new',
      builder: (context, state) => BlocProvider(
        create: (_) => ActionSettingDetailBloc(
          actionRepository: getIt<ActionRepository>(),
        )..add(const ActionSettingDetailStarted()),
        child: const ActionSettingDetailPage(),
      ),
    ),
    GoRoute(
      path: '/settings/action/:actionId',
      builder: (context, state) {
        final actionId = state.pathParameters['actionId'] ?? '';
        return BlocProvider(
          create: (_) => ActionSettingDetailBloc(
            actionRepository: getIt<ActionRepository>(),
          )..add(ActionSettingDetailStarted(actionId: actionId)),
          child: const ActionSettingDetailPage(),
        );
      },
    ),
  ],
);
