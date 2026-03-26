import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/event_list/bloc/event_list_bloc.dart';
import '../features/event_list/bloc/event_list_event.dart';
import '../features/event_list/view/event_list_page.dart';
import '../repository/event_repository.dart';

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
    // TODO: event_detail, settings など Feature実装後に追加
  ],
);
