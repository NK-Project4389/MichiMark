import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
        if (state is EventDetailLoaded && state.delegate != null) {
          _handleDelegate(context, state.delegate!);
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
          EventDetailLoaded(:final projection, :final draft) =>
            _EventDetailScaffold(projection: projection, draft: draft),
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
    }
  }
}

class _EventDetailScaffold extends StatelessWidget {
  final EventDetailProjection projection;
  final EventDetailDraft draft;

  const _EventDetailScaffold({
    required this.projection,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: Column(
        children: [
          Expanded(child: _tabContent(context, projection, draft)),
          const Divider(height: 1),
          _TabBar(selectedTab: draft.selectedTab),
        ],
      ),
    );
  }

  Widget _tabContent(
    BuildContext context,
    EventDetailProjection projection,
    EventDetailDraft draft,
  ) {
    return switch (draft.selectedTab) {
      EventDetailTab.basicInfo => _BasicInfoTabView(projection: projection),
      EventDetailTab.michiInfo => _MichiInfoTabView(projection: projection),
      EventDetailTab.paymentInfo => _PaymentInfoTabView(projection: projection),
      EventDetailTab.overview => _OverviewTabView(),
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

// ── Tab contents（各Featureで置き換え予定のプレースホルダー）──────────────

class _BasicInfoTabView extends StatelessWidget {
  final EventDetailProjection projection;

  const _BasicInfoTabView({required this.projection});

  @override
  Widget build(BuildContext context) {
    final info = projection.basicInfo;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoRow(label: 'イベント名', value: info.eventName),
        _InfoRow(label: '交通手段', value: info.trans?.transName ?? '未設定'),
        _InfoRow(label: '燃費', value: info.displayKmPerGas),
        _InfoRow(label: 'ガソリン単価', value: info.displayPricePerGas),
        _InfoRow(
          label: 'メンバー',
          value: info.members.map((m) => m.memberName).join('、'),
        ),
        _InfoRow(
          label: 'タグ',
          value: info.tags.map((t) => t.tagName).join('、'),
        ),
      ],
    );
  }
}

class _MichiInfoTabView extends StatelessWidget {
  final EventDetailProjection projection;

  const _MichiInfoTabView({required this.projection});

  @override
  Widget build(BuildContext context) {
    final items = projection.michiInfo.items;
    if (items.isEmpty) {
      return const Center(child: Text('マーク/リンクがありません'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(item.markLinkType.name == 'mark'
              ? Icons.place
              : Icons.route),
          title: Text(item.markLinkName),
          subtitle: Text(item.displayDate),
          onTap: () {
            final event = item.markLinkType.name == 'mark'
                ? EventDetailOpenMarkRequested(item.id)
                : EventDetailOpenLinkRequested(item.id);
            context.read<EventDetailBloc>().add(event);
          },
        );
      },
    );
  }
}

class _PaymentInfoTabView extends StatelessWidget {
  final EventDetailProjection projection;

  const _PaymentInfoTabView({required this.projection});

  @override
  Widget build(BuildContext context) {
    final info = projection.paymentInfo;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: info.items.length,
            itemBuilder: (context, index) {
              final item = info.items[index];
              return ListTile(
                title: Text(item.displayAmount),
                subtitle: Text(item.payer.memberName),
                onTap: () => context
                    .read<EventDetailBloc>()
                    .add(EventDetailOpenPaymentRequested(item.id)),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '合計: ${info.displayTotalAmount}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _OverviewTabView extends StatelessWidget {
  const _OverviewTabView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('振り返り（未実装）'));
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '未設定' : value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
