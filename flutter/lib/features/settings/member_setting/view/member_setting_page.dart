import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/member_setting_bloc.dart';
import '../bloc/member_setting_event.dart';
import '../bloc/member_setting_state.dart';
import '../../../../features/shared/projection/member_item_projection.dart';

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
                    color: const Color(0xFFF59E0B),
                    onPressed: () => context
                        .read<MemberSettingBloc>()
                        .add(const MemberSettingAddTapped()),
                  ),
                ],
              ),
              body: items.isEmpty
                  ? const Center(child: Text('メンバーがいません'))
                  : _buildList(context, items),
            ),
        };
      },
    );
  }

  Widget _buildList(BuildContext context, List<MemberItemProjection> items) {
    final visibleItems = items.where((e) => e.isVisible).toList();
    final hiddenItems = items.where((e) => !e.isVisible).toList();
    return ListView(
      children: [
        for (int i = 0; i < visibleItems.length; i++) ...[
          _buildTile(context, visibleItems[i]),
          if (i < visibleItems.length - 1 || hiddenItems.isNotEmpty)
            const Divider(height: 1),
        ],
        if (hiddenItems.isNotEmpty) ...[
          _buildSectionHeader(context),
          for (int i = 0; i < hiddenItems.length; i++) ...[
            _buildTile(context, hiddenItems[i]),
            if (i < hiddenItems.length - 1) const Divider(height: 1),
          ],
        ],
      ],
    );
  }

  Widget _buildTile(BuildContext context, MemberItemProjection item) {
    return ListTile(
      title: Text(item.memberName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context
          .read<MemberSettingBloc>()
          .add(MemberSettingItemSelected(item.id)),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        '非表示',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
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
