import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/trans_setting_bloc.dart';
import '../bloc/trans_setting_event.dart';
import '../bloc/trans_setting_state.dart';

class TransSettingPage extends StatelessWidget {
  const TransSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransSettingBloc, TransSettingState>(
      listener: (context, state) async {
        if (state is TransSettingLoaded && state.delegate != null) {
          await _handleDelegate(context, state.delegate!);
          if (context.mounted) {
            context
                .read<TransSettingBloc>()
                .add(const TransSettingStarted());
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          TransSettingLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          TransSettingError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          TransSettingLoaded(:final items) => Scaffold(
              appBar: AppBar(
                title: const Text('交通手段'),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => context
                        .read<TransSettingBloc>()
                        .add(const TransSettingAddTapped()),
                  ),
                ],
              ),
              body: items.isEmpty
                  ? const Center(child: Text('交通手段がありません'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.transName),
                          subtitle: Text(
                            '燃費: ${item.displayKmPerGas}　メーター: ${item.displayMeterValue}'
                            '${item.isVisible ? '' : '　非表示'}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context
                              .read<TransSettingBloc>()
                              .add(TransSettingItemSelected(item.id)),
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
    TransSettingDelegate delegate,
  ) async {
    switch (delegate) {
      case TransSettingOpenDetailDelegate(:final transId):
        await context.push('/settings/trans/$transId');
      case TransSettingOpenNewDelegate():
        await context.push('/settings/trans/new');
    }
  }
}
