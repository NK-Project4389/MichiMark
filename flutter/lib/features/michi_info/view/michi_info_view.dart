import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../features/event_detail/projection/michi_info_list_projection.dart';
import '../../../features/link_detail/draft/link_detail_draft.dart';
import '../../../features/mark_detail/draft/mark_detail_draft.dart';
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
          MichiInfoLoaded(:final projection) =>
            _MichiInfoList(projection: projection),
        };
      },
    );
  }

  Future<void> _handleDelegate(MichiInfoDelegate delegate) async {
    switch (delegate) {
      case MichiInfoOpenMarkDelegate(:final eventId, :final markLinkId):
        final result = await context.push<MarkDetailDraft>(
          '/event/mark/$markLinkId',
          extra: eventId,
        );
        if (!mounted) return;
        if (result != null) {
          context.read<MichiInfoBloc>().add(
                MichiInfoMarkDraftApplied(markLinkId: markLinkId, draft: result),
              );
        }

      case MichiInfoOpenLinkDelegate(:final eventId, :final markLinkId):
        final result = await context.push<LinkDetailDraft>(
          '/event/link/$markLinkId',
          extra: eventId,
        );
        if (!mounted) return;
        if (result != null) {
          context.read<MichiInfoBloc>().add(
                MichiInfoLinkDraftApplied(markLinkId: markLinkId, draft: result),
              );
        }

      case MichiInfoAddMarkDelegate(:final eventId):
        final markId = const Uuid().v4();
        final result = await context.push<MarkDetailDraft>(
          '/event/mark/$markId',
          extra: eventId,
        );
        if (!mounted) return;
        if (result != null) {
          context.read<MichiInfoBloc>().add(
                MichiInfoMarkDraftApplied(markLinkId: markId, draft: result),
              );
        }

      case MichiInfoAddLinkDelegate(:final eventId):
        final linkId = const Uuid().v4();
        final result = await context.push<LinkDetailDraft>(
          '/event/link/$linkId',
          extra: eventId,
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
// 太線区間フラグ計算ヘルパー
// ────────────────────────────────────────────────────────

/// items リストを走査して各インデックスの太線フラグを計算する
List<({bool isUpperThick, bool isLowerThick})> _calcThickFlags(
  List<MarkLinkItemProjection> items,
) {
  final flags = List.generate(
    items.length,
    (_) => (isUpperThick: false, isLowerThick: false),
  );

  for (int i = 0; i < items.length; i++) {
    if (items[i].markLinkType != MarkOrLink.mark) continue;

    // この Mark の直後に Link が1つ以上続き、その後に Mark が存在するか確認
    int j = i + 1;
    bool hasLink = false;
    while (j < items.length && items[j].markLinkType == MarkOrLink.link) {
      hasLink = true;
      j++;
    }
    final nextMarkIndex = (j < items.length && items[j].markLinkType == MarkOrLink.mark) ? j : -1;

    if (!hasLink || nextMarkIndex < 0) continue;

    // 当該 Mark の下半分を太線に
    flags[i] = (isUpperThick: flags[i].isUpperThick, isLowerThick: true);

    // 中間の Link を全太線に
    for (int k = i + 1; k < nextMarkIndex; k++) {
      flags[k] = (isUpperThick: true, isLowerThick: true);
    }

    // 次の Mark の上半分を太線に
    flags[nextMarkIndex] = (
      isUpperThick: true,
      isLowerThick: flags[nextMarkIndex].isLowerThick,
    );
  }

  return flags;
}

// ────────────────────────────────────────────────────────
// _MichiInfoList
// ────────────────────────────────────────────────────────

class _MichiInfoList extends StatelessWidget {
  final MichiInfoListProjection projection;

  const _MichiInfoList({required this.projection});

  @override
  Widget build(BuildContext context) {
    if (projection.items.isEmpty) {
      return Scaffold(
        body: const Center(child: Text('マーク/リンクがありません')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddMenu(context),
          child: const Icon(Icons.add),
        ),
      );
    }

    final items = projection.items;
    final flags = _calcThickFlags(items);

    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _TimelineItem(
                item: items[index],
                isUpperThick: flags[index].isUpperThick,
                isLowerThick: flags[index].isLowerThick,
                isFirst: index == 0,
                isLast: index == items.length - 1,
              );
            },
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
              title: const Text('マークを追加'),
              onTap: () {
                Navigator.of(context).pop();
                context
                    .read<MichiInfoBloc>()
                    .add(const MichiInfoAddMarkPressed());
              },
            ),
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('リンクを追加'),
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
// _TimelineItem
// ────────────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  final MarkLinkItemProjection item;
  final bool isUpperThick;
  final bool isLowerThick;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.item,
    required this.isUpperThick,
    required this.isLowerThick,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isMark = item.markLinkType == MarkOrLink.mark;
    void onTap() => context.read<MichiInfoBloc>().add(
          MichiInfoItemTapped(
            markLinkId: item.id,
            type: item.markLinkType,
          ),
        );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: _TimelineConnector(
              showDot: isMark,
              isUpperThick: isUpperThick,
              isLowerThick: isLowerThick,
              isFirst: isFirst,
              isLast: isLast,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: isMark
                  ? _MarkCard(item: item, onTap: onTap)
                  : _LinkCard(item: item, onTap: onTap),
            ),
          ),
          SizedBox(
            width: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: _DistanceColumn(
                displayMeterDiff: item.displayMeterDiff,
                displayDistanceValue: item.displayDistanceValue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// _TimelineConnector (CustomPaint)
// ────────────────────────────────────────────────────────

class _TimelineConnector extends StatelessWidget {
  final bool showDot;
  final bool isUpperThick;
  final bool isLowerThick;
  final bool isFirst;
  final bool isLast;

  const _TimelineConnector({
    required this.showDot,
    required this.isUpperThick,
    required this.isLowerThick,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return CustomPaint(
      painter: _TimelineConnectorPainter(
        showDot: showDot,
        isUpperThick: isUpperThick,
        isLowerThick: isLowerThick,
        isFirst: isFirst,
        isLast: isLast,
        color: color,
      ),
    );
  }
}

class _TimelineConnectorPainter extends CustomPainter {
  static const double _normalWidth = 2.0;
  static const double _thickWidth = 4.0;
  static const double _dotRadius = 6.0;

  final bool showDot;
  final bool isUpperThick;
  final bool isLowerThick;
  final bool isFirst;
  final bool isLast;
  final Color color;

  const _TimelineConnectorPainter({
    required this.showDot,
    required this.isUpperThick,
    required this.isLowerThick,
    required this.isFirst,
    required this.isLast,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final upperPaint = Paint()
      ..color = color
      ..strokeWidth = isUpperThick ? _thickWidth : _normalWidth
      ..strokeCap = StrokeCap.butt;

    final lowerPaint = Paint()
      ..color = color
      ..strokeWidth = isLowerThick ? _thickWidth : _normalWidth
      ..strokeCap = StrokeCap.butt;

    // 上半分の線（先頭行は描画しない）
    if (!isFirst) {
      canvas.drawLine(
        Offset(cx, 0),
        Offset(cx, cy - _dotRadius),
        upperPaint,
      );
    }

    // 下半分の線（末尾行は描画しない）
    if (!isLast) {
      canvas.drawLine(
        Offset(cx, cy + _dotRadius),
        Offset(cx, size.height),
        lowerPaint,
      );
    }

    // ドット（Mark の場合）
    if (showDot) {
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), _dotRadius, dotPaint);
    } else {
      // Link の場合は細い線のみ（ドットなし）。上下をつなぐ中央部分
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = isUpperThick ? _thickWidth : _normalWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawLine(
        Offset(cx, cy - _dotRadius),
        Offset(cx, cy + _dotRadius),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TimelineConnectorPainter old) =>
      showDot != old.showDot ||
      isUpperThick != old.isUpperThick ||
      isLowerThick != old.isLowerThick ||
      isFirst != old.isFirst ||
      isLast != old.isLast ||
      color != old.color;
}

// ────────────────────────────────────────────────────────
// _MarkCard (CustomPaint)
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
          padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
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
  static const double _pointerWidth = 8.0;
  static const double _pointerHeight = 10.0;
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
// _DistanceColumn
// ────────────────────────────────────────────────────────

class _DistanceColumn extends StatelessWidget {
  final String? displayMeterDiff;
  final String? displayDistanceValue;

  const _DistanceColumn({
    required this.displayMeterDiff,
    required this.displayDistanceValue,
  });

  @override
  Widget build(BuildContext context) {
    if (displayMeterDiff == null && displayDistanceValue == null) {
      return const SizedBox.shrink();
    }

    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outline = Theme.of(context).colorScheme.outline;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (displayMeterDiff != null)
          Text(
            displayMeterDiff!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
            textAlign: TextAlign.right,
          ),
        if (displayDistanceValue != null) ...[
          const Icon(Icons.unfold_more, size: 14),
          Text(
            displayDistanceValue!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: outline,
                ),
            textAlign: TextAlign.right,
          ),
        ],
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: onSurface,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'メーター差分',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: outline,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '区間距離',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: outline,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
