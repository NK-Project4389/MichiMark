import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/action_repository.dart';
import '../repository/event_repository.dart';
import '../repository/impl/in_memory/in_memory_action_repository.dart';
import '../repository/impl/in_memory/in_memory_event_repository.dart';
import '../repository/impl/in_memory/in_memory_member_repository.dart';
import '../repository/impl/in_memory/in_memory_tag_repository.dart';
import '../repository/impl/in_memory/in_memory_trans_repository.dart';
import '../repository/member_repository.dart';
import '../repository/tag_repository.dart';
import '../repository/trans_repository.dart';
import 'router.dart';

class MichiMarkApp extends StatelessWidget {
  const MichiMarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<EventRepository>(
          create: (_) => InMemoryEventRepository(),
        ),
        RepositoryProvider<TransRepository>(
          create: (_) => InMemoryTransRepository(),
        ),
        RepositoryProvider<MemberRepository>(
          create: (_) => InMemoryMemberRepository(),
        ),
        RepositoryProvider<TagRepository>(
          create: (_) => InMemoryTagRepository(),
        ),
        RepositoryProvider<ActionRepository>(
          create: (_) => InMemoryActionRepository(),
        ),
      ],
      child: MaterialApp.router(
        title: 'MichiMark',
        routerConfig: router,
      ),
    );
  }
}
