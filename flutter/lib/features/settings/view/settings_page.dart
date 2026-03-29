import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
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
          _SettingsRow(
            icon: Icons.directions_walk,
            title: '行動',
            onTap: () => context.push('/settings/action'),
          ),
          const Divider(height: 1),
        ],
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
