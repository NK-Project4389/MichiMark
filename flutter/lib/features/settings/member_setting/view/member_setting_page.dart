import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/member_setting_bloc.dart';
import '../bloc/member_setting_event.dart';
import '../bloc/member_setting_state.dart';

class MemberSettingPage extends StatelessWidget {
  const MemberSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemberSettingBloc, MemberSettingState>(
      listener: (context, state) async {
        if (state is MemberSettingLoaded && state.delegate != null) {
          await _handleDelegate(context, state.delegate!);
          if (context.mounted) {
            context.read<MemberSettingBloc>().add(const MemberSettingStarted());
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          MemberSettingLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          MemberSettingError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          MemberSettingLoaded(:final items) => Scaffold(
              appBar: AppBar(
                title: const Text('メンバー'),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => context
                        .read<MemberSettingBloc>()
                        .add(const MemberSettingAddTapped()),
                  ),
                ],
              ),
              body: items.isEmpty
                  ? const Center(child: Text('メンバーがいません'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.memberName),
                          subtitle: item.isVisible ? null : const Text('非表示'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context
                              .read<MemberSettingBloc>()
                              .add(MemberSettingItemSelected(item.id)),
                        );
                      },
                    ),
            ),
        };
      },
    );
  }

  Future<void> _handleDelegate(
    BuildContext context,
    MemberSettingDelegate delegate,
  ) async {
    switch (delegate) {
      case MemberSettingOpenDetailDelegate(:final memberId):
        await context.push('/settings/member/$memberId');
      case MemberSettingOpenNewDelegate():
        await context.push('/settings/member/new');
    }
  }
}
