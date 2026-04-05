import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        switch (state.delegate) {
          case SettingsNavigateToEventsDelegate():
            context.go('/events');
          case null:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('設定'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context
                .read<SettingsBloc>()
                .add(const SettingsNavigateToEventsRequested()),
          ),
        ),
        body: ListView(
          children: [
            _SettingsRow(
              icon: Icons.directions_car,
              title: '交通手段',
              onTap: () => context.push('/settings/trans'),
            ),
            const Divider(height: 1),
            _SettingsRow(
              icon: Icons.person,
              title: 'メンバー',
              onTap: () => context.push('/settings/member'),
            ),
            const Divider(height: 1),
            _SettingsRow(
              icon: Icons.tag,
              title: 'タグ',
              onTap: () => context.push('/settings/tag'),
            ),
            const Divider(height: 1),
            // REQ-003: 行動（ActionSetting）の導線は一時非表示
            // コード・Router・BLocは削除しない
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
