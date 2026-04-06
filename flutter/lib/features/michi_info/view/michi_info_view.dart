import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../features/event_detail/projection/michi_info_list_projection.dart';
import '../../../features/link_detail/draft/link_detail_draft.dart';
import '../../../features/link_detail/link_detail_args.dart';
import '../../../features/mark_detail/draft/mark_detail_draft.dart';
import '../../../features/mark_detail/mark_detail_args.dart';
import '../../../features/shared/projection/mark_link_item_projection.dart';
import '../bloc/michi_info_bloc.dart';
import '../bloc/michi_info_event.dart';
import '../bloc/michi_info_state.dart';

class MichiInfoView extends StatefulWidget {
  const MichiInfoView({super.key});

  @override
  State<MichiInfoView> createState() => _MichiInfoViewState();
}

class _MichiInfoViewState extends State<MichiInfoView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MichiInfoBloc, MichiInfoState>(
      listener: (_, state) async {
        if (state is MichiInfoLoaded && state.delegate != null) {
          await _handleDelegate(state.delegate!);
        }
      },
      builder: (context, state) {
        return switch (state) {
          MichiInfoLoading() =>
            const Center(child: CircularProgressIndicator()),
          MichiInfoError(:final message) => Center(child: Text(message)),
          MichiInfoLoaded(:final projection, :final topicConfig) =>
            _MichiInfoList(
              projection: projection,
              topicConfig: topicConfig,
            ),
        };
      },
    );
  }

  Future<void> _handleDelegate(MichiInfoDelegate delegate) async {
    switch (delegate) {
      case MichiInfoOpenMarkDelegate(:final eventId, :final markLinkId, :final topicConfig):
        final result = await context.push<MarkDetailDraft>(
          '/event/mark/$markLinkId',
          extra: MarkDetailArgs(eventId: eventId, topicConfig: topicConfig),
        );
        if (!mounted) return;
        if (result != null) {
          context.read<MichiInfoBloc>().add(
                MichiInfoMarkDraftApplied(markLinkId: markLinkId, draft: result),
              );
        }

      case MichiInfoOpenLinkDelegate(:final eventId, :final markLinkId, :final topicConfig):
        final result = await context.push<LinkDetailDraft>(
          '/event/link/$markLinkId',
          extra: LinkDetailArgs(eventId: eventId, topicConfig: topicConfig),
        );
        if (!mounted) return;
        if (result != null) {
          context.read<MichiInfoBloc>().add(
                MichiInfoLinkDraftApplied(markLinkId: markLinkId, draft: result),
              );
        }

      case MichiInfoAddMarkDelegate(:final eventId, :final topicConfig):
        final markId = const Uuid().v4();
        final result = await context.push<MarkDetailDraft>(
          '/event/mark/$markId',
          extra: MarkDetailArgs(eventId: eventId, topicConfig: topicConfig),
        );
        if (!mounted) return;
        if (result != null) {
          context.read<MichiInfoBloc>().add(
                MichiInfoMarkDraftApplied(markLinkId: markId, draft: result),
              );
        }

      case MichiInfoAddLinkDelegate(:final eventId, :final topicConfig):
        final linkId = const Uuid().v4();
        final result = await context.push<LinkDetailDraft>(
          '/event/link/$linkId',
          extra: LinkDetailArgs(eventId: eventId, topicConfig: topicConfig),
        );
        if (!mounted) return;
        if (result != null) {
          context.read<MichiInfoBloc>().add(
                MichiInfoLinkDraftApplied(markLinkId: linkId, draft: result),
              );
        }
    }
  }
}

// ────────────────────────────────────────────────────────
// グループデータ
// ────────────────────────────────────────────────────────

class _GroupData {
  final MarkLinkItemProjection mark;
  final List<MarkLinkItemProjection> links;

  /// 次の Mark との累積メーター差分（次の Mark の displayMeterDiff）
  final String? meterDiff;

  const _GroupData({
    required this.mark,
    required this.links,
    required this.meterDiff,
  });
}

/// items をスキャンして各 Mark とその後続 Links をグループ化する
List<_GroupData> _buildGroups(List<MarkLinkItemProjection> items) {
  final groups = <_GroupData>[];

  int i = 0;
  while (i < items.length) {
    if (items[i].markLinkType != MarkOrLink.mark) {
      // Mark 以外で始まるケースは Skip（通常発生しないが安全策）
      i++;
      continue;
    }

    final mark = items[i];
    final links = <MarkLinkItemProjection>[];

    int j = i + 1;
    while (j < items.length && items[j].markLinkType == MarkOrLink.link) {
      links.add(items[j]);
      j++;
    }

    // 次の Mark の displayMeterDiff を meterDiff として使用
    final String? meterDiff;
    if (j < items.length && items[j].markLinkType == MarkOrLink.mark) {
      meterDiff = items[j].displayMeterDiff;
    } else {
      meterDiff = null;
    }

    groups.add(_GroupData(mark: mark, links: links, meterDiff: meterDiff));
    i = j;
  }

  return groups;
}

// ────────────────────────────────────────────────────────
// _MichiInfoList
// ────────────────────────────────────────────────────────

class _MichiInfoList extends StatelessWidget {
  final MichiInfoListProjection projection;
  final TopicConfig topicConfig;

  const _MichiInfoList({
    required this.projection,
    required this.topicConfig,
  });

  @override
  Widget build(BuildContext context) {
    if (projection.items.isEmpty) {
      return Scaffold(
        body: const Center(child: Text('地点/区間がありません')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddMenu(context),
          child: const Icon(Icons.add),
        ),
      );
    }

    final groups = _buildGroups(projection.items);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 48, bottom: 80),
            child: Column(
              children: [
                for (int i = 0; i < groups.length; i++)
                  _MarkGroup(
                    group: groups[i],
                    isFirst: i == 0,
                    isLast: i == groups.length - 1,
                  ),
              ],
            ),
          ),
          const Positioned(
            top: 8,
            right: 8,
            child: _DistanceLegend(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('地点を追加'),
              onTap: () {
                Navigator.of(context).pop();
                context
                    .read<MichiInfoBloc>()
                    .add(const MichiInfoAddMarkPressed());
              },
            ),
            if (topicConfig.allowLinkAdd)
              ListTile(
                leading: const Icon(Icons.route),
                title: const Text('区間を追加'),
                onTap: () {
                  Navigator.of(context).pop();
                  context
                      .read<MichiInfoBloc>()
                      .add(const MichiInfoAddLinkPressed());
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// _MarkGroup
// ────────────────────────────────────────────────────────

class _MarkGroup extends StatelessWidget {
  final _GroupData group;
  final bool isFirst;
  final bool isLast;

  const _MarkGroup({
    required this.group,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final hasLinks = group.links.isNotEmpty;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: _TimelineGroupConnector(
              isFirst: isFirst,
              isLast: isLast,
              hasLinks: hasLinks,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _MarkCard(
                      item: group.mark,
                      onTap: () => context.read<MichiInfoBloc>().add(
                            MichiInfoItemTapped(
                              markLinkId: group.mark.id,
                              type: group.mark.markLinkType,
                            ),
                          ),
                    ),
                  ),
                  for (final link in group.links)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _LinkCard(
                        item: link,
                        onTap: () => context.read<MichiInfoBloc>().add(
                              MichiInfoItemTapped(
                                markLinkId: link.id,
                                type: link.markLinkType,
                              ),
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: _GroupDistanceArrows(
              meterDiff: group.meterDiff,
              links: group.links,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// _TimelineGroupConnector (CustomPaint)
// ────────────────────────────────────────────────────────

class _TimelineGroupConnector extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool hasLinks;

  const _TimelineGroupConnector({
    required this.isFirst,
    required this.isLast,
    required this.hasLinks,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return CustomPaint(
      painter: _TimelineGroupConnectorPainter(
        isFirst: isFirst,
        isLast: isLast,
        hasLinks: hasLinks,
        color: color,
      ),
    );
  }
}

class _TimelineGroupConnectorPainter extends CustomPainter {
  static const double _normalWidth = 1.5;
  static const double _thickWidth = 6.0;
  static const double _dotRadius = 6.0;

  /// Mark カード1行の標準高さ（padding 6 + card ~44 + padding 6 = ~56）
  static const double _markRowHeight = 56.0;

  final bool isFirst;
  final bool isLast;
  final bool hasLinks;
  final Color color;

  const _TimelineGroupConnectorPainter({
    required this.isFirst,
    required this.isLast,
    required this.hasLinks,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Mark のドット中心 Y は Mark 行の中央（padding 6 + card高さの半分）
    // IntrinsicHeight を使っているので Mark 行の高さを推定する
    final dotY = _markRowHeight / 2;

    final normalPaint = Paint()
      ..color = color
      ..strokeWidth = _normalWidth
      ..strokeCap = StrokeCap.butt;

    final thickPaint = Paint()
      ..color = color
      ..strokeWidth = _thickWidth
      ..strokeCap = StrokeCap.butt;

    // 上半分の線（先頭グループは省略）
    if (!isFirst) {
      canvas.drawLine(
        Offset(cx, 0),
        Offset(cx, dotY - _dotRadius),
        normalPaint,
      );
    }

    // ドット
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, dotY), _dotRadius, dotPaint);

    // ドット下〜グループ下端の線
    if (!isLast) {
      final linePaint = hasLinks ? thickPaint : normalPaint;
      canvas.drawLine(
        Offset(cx, dotY + _dotRadius),
        Offset(cx, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TimelineGroupConnectorPainter old) =>
      isFirst != old.isFirst ||
      isLast != old.isLast ||
      hasLinks != old.hasLinks ||
      color != old.color;
}

// ────────────────────────────────────────────────────────
// _GroupDistanceArrows (距離矢印表示)
// ────────────────────────────────────────────────────────

class _GroupDistanceArrows extends StatelessWidget {
  final String? meterDiff;
  final List<MarkLinkItemProjection> links;

  const _GroupDistanceArrows({
    required this.meterDiff,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    final hasMeterDiff = meterDiff != null;
    final linkDistances = links
        .where((l) => l.displayDistanceValue != null)
        .toList();
    final hasLinkDist = linkDistances.isNotEmpty;

    if (!hasMeterDiff && !hasLinkDist) {
      return const SizedBox.shrink();
    }

    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outline = Theme.of(context).colorScheme.outline;

    // 重複ありの場合: 2列（meterDiff 左寄せ、link距離 右寄せ）
    if (hasMeterDiff && hasLinkDist) {
      return Row(
        children: [
          Expanded(
            child: _ArrowWithText(
              text: meterDiff!,
              color: onSurface,
              isBold: true,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final link in linkDistances)
                  Expanded(
                    child: _ArrowWithText(
                      text: link.displayDistanceValue!,
                      color: outline,
                      isBold: false,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    // meterDiff のみ
    if (hasMeterDiff) {
      return _ArrowWithText(
        text: meterDiff!,
        color: onSurface,
        isBold: true,
      );
    }

    // link距離のみ
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final link in linkDistances)
          Expanded(
            child: _ArrowWithText(
              text: link.displayDistanceValue!,
              color: outline,
              isBold: false,
            ),
          ),
      ],
    );
  }
}

/// 縦矢印（↕）とテキストを縦に並べたウィジェット
class _ArrowWithText extends StatelessWidget {
  final String text;
  final Color color;
  final bool isBold;

  const _ArrowWithText({
    required this.text,
    required this.color,
    required this.isBold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          size: const Size(16, 24),
          painter: _VerticalArrowPainter(color: color),
        ),
        const SizedBox(height: 2),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: color,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// 縦の両方向矢印を描画する CustomPainter
class _VerticalArrowPainter extends CustomPainter {
  final Color color;

  const _VerticalArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    const arrowSize = 5.0;

    // 縦線
    canvas.drawLine(
      Offset(cx, arrowSize),
      Offset(cx, size.height - arrowSize),
      paint,
    );

    // 上向き矢印
    canvas.drawLine(Offset(cx, 0), Offset(cx - arrowSize / 2, arrowSize), paint);
    canvas.drawLine(Offset(cx, 0), Offset(cx + arrowSize / 2, arrowSize), paint);

    // 下向き矢印
    canvas.drawLine(
      Offset(cx, size.height),
      Offset(cx - arrowSize / 2, size.height - arrowSize),
      paint,
    );
    canvas.drawLine(
      Offset(cx, size.height),
      Offset(cx + arrowSize / 2, size.height - arrowSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(_VerticalArrowPainter old) => color != old.color;
}

// ────────────────────────────────────────────────────────
// _MarkCard (CustomPaint バブルカード)
// ────────────────────────────────────────────────────────

class _MarkCard extends StatelessWidget {
  final MarkLinkItemProjection item;
  final VoidCallback onTap;

  const _MarkCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;
    final name = item.markLinkName.isEmpty ? '（名称未設定）' : item.markLinkName;

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _BubbleCardPainter(bgColor: bgColor),
        child: Padding(
          // 左側に三角ポインター分のスペースを確保
          padding: const EdgeInsets.only(left: 28, right: 8, top: 8, bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (item.displayMeterValue != null)
                      Text(
                        item.displayMeterValue!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                  ],
                ),
              ),
              if (item.isFuel)
                Icon(
                  Icons.local_gas_station,
                  size: 16,
                  color: primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubbleCardPainter extends CustomPainter {
  /// 三角ポインターの幅（先端からボディ左端まで）
  static const double _pointerWidth = 20.0;

  /// 三角ポインターの高さ（上下幅）
  static const double _pointerHeight = 14.0;
  static const double _cornerRadius = 8.0;

  final Color bgColor;

  const _BubbleCardPainter({required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(
      _pointerWidth,
      0,
      size.width - _pointerWidth,
      size.height,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_cornerRadius));

    final pointerY = size.height / 2;
    final path = Path()
      ..addRRect(rrect)
      ..moveTo(_pointerWidth, pointerY - _pointerHeight / 2)
      ..lineTo(0, pointerY)
      ..lineTo(_pointerWidth, pointerY + _pointerHeight / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubbleCardPainter old) => bgColor != old.bgColor;
}

// ────────────────────────────────────────────────────────
// _LinkCard
// ────────────────────────────────────────────────────────

class _LinkCard extends StatelessWidget {
  final MarkLinkItemProjection item;
  final VoidCallback onTap;

  const _LinkCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.surfaceContainerLow;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outline = Theme.of(context).colorScheme.outline;
    final primary = Theme.of(context).colorScheme.primary;
    final name = item.markLinkName.isEmpty ? '（名称未設定）' : item.markLinkName;

    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: onSurface,
                          ),
                    ),
                    if (item.displayDistanceValue != null)
                      Text(
                        item.displayDistanceValue!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: outline,
                            ),
                      ),
                  ],
                ),
              ),
              if (item.isFuel)
                Icon(
                  Icons.local_gas_station,
                  size: 16,
                  color: primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// _DistanceLegend
// ────────────────────────────────────────────────────────

class _DistanceLegend extends StatelessWidget {
  const _DistanceLegend();

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outline = Theme.of(context).colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'メーター差分',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: onSurface,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '区間距離',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: outline,
                ),
          ),
        ],
      ),
    );
  }
}
