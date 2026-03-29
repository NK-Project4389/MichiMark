import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/event_detail/bloc/event_detail_bloc.dart';
import '../features/event_detail/bloc/event_detail_event.dart';
import '../features/event_detail/view/event_detail_page.dart';
import '../features/event_list/bloc/event_list_bloc.dart';
import '../features/event_list/bloc/event_list_event.dart';
import '../features/event_list/view/event_list_page.dart';
import '../features/selection/bloc/selection_bloc.dart';
import '../features/selection/bloc/selection_event.dart';
import '../features/selection/selection_args.dart';
import '../features/link_detail/bloc/link_detail_bloc.dart';
import '../features/link_detail/bloc/link_detail_event.dart';
import '../features/link_detail/view/link_detail_page.dart';
import '../features/mark_detail/bloc/mark_detail_bloc.dart';
import '../features/mark_detail/bloc/mark_detail_event.dart';
import '../features/mark_detail/view/mark_detail_page.dart';
import '../features/payment_detail/bloc/payment_detail_bloc.dart';
import '../features/payment_detail/bloc/payment_detail_event.dart';
import '../features/payment_detail/payment_detail_args.dart';
import '../features/payment_detail/view/payment_detail_page.dart';
import '../features/selection/view/selection_page.dart';
import '../repository/action_repository.dart';
import '../repository/event_repository.dart';
import '../repository/member_repository.dart';
import '../repository/tag_repository.dart';
import '../repository/trans_repository.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => EventListBloc(
          eventRepository: context.read<EventRepository>(),
        )..add(const EventListStarted()),
        child: const EventListPage(),
      ),
    ),
    GoRoute(
      path: '/event/:id',
      builder: (context, state) {
        final eventId = state.pathParameters['id'] ?? '';
        return BlocProvider(
          create: (_) => EventDetailBloc(
            eventRepository: context.read<EventRepository>(),
          )..add(EventDetailStarted(eventId)),
          child: const EventDetailPage(),
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
            transRepository: context.read<TransRepository>(),
            memberRepository: context.read<MemberRepository>(),
            tagRepository: context.read<TagRepository>(),
            actionRepository: context.read<ActionRepository>(),
          )..add(const SelectionStarted()),
          child: const SelectionPage(),
        );
      },
    ),
    GoRoute(
      path: '/event/mark/new',
      builder: (context, state) {
        final eventId = state.extra as String;
        return BlocProvider(
          create: (_) => MarkDetailBloc(
            eventRepository: context.read<EventRepository>(),
          )..add(MarkDetailStarted(eventId: eventId)),
          child: const MarkDetailPage(),
        );
      },
    ),
    GoRoute(
      path: '/event/mark/:markId',
      builder: (context, state) {
        final markId = state.pathParameters['markId']!;
        final eventId = state.extra as String;
        return BlocProvider(
          create: (_) => MarkDetailBloc(
            eventRepository: context.read<EventRepository>(),
          )..add(MarkDetailStarted(eventId: eventId, markLinkId: markId)),
          child: const MarkDetailPage(),
        );
      },
    ),
    GoRoute(
      path: '/event/link/new',
      builder: (context, state) {
        final eventId = state.extra as String;
        return BlocProvider(
          create: (_) => LinkDetailBloc(
            eventRepository: context.read<EventRepository>(),
          )..add(LinkDetailStarted(eventId: eventId)),
          child: const LinkDetailPage(),
        );
      },
    ),
    GoRoute(
      path: '/event/link/:linkId',
      builder: (context, state) {
        final linkId = state.pathParameters['linkId']!;
        final eventId = state.extra as String;
        return BlocProvider(
          create: (_) => LinkDetailBloc(
            eventRepository: context.read<EventRepository>(),
          )..add(LinkDetailStarted(eventId: eventId, markLinkId: linkId)),
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
            eventRepository: context.read<EventRepository>(),
          )..add(PaymentDetailStarted(
              eventId: args.eventId,
              paymentId: args.paymentId,
            )),
          child: const PaymentDetailPage(),
        );
      },
    ),
    // TODO: payment_info, settings など実装後に追加
  ],
);
