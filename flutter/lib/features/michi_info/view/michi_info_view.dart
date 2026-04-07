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
import '../../../features/shared/projection/action_item_projection.dart';
import '../../../features/shared/projection/mark_link_item_projection.dart';
import '../bloc/michi_info_bloc.dart';
import '../bloc/michi_info_event.dart';
import '../bloc/michi_info_state.dart';

// ────────────────────────────────────────────────────────
// 定数
// ────────────────────────────────────────────────────────

/// 1カードの固定高さ。全描画座標の基準値
const double _cardHeight = 72.0;

// ────────────────────────────────────────────────────────
// MichiInfoView
// ────────────────────────────────────────────────────────

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
          MichiInfoLoaded(:final projection, :final topicConfig, :final markActionItems) =>
            _MichiInfoList(
              projection: projection,
              topicConfig: topicConfig,
              markActionItems: markActionItems,
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
// _MichiInfoList
// ────────────────────────────────────────────────────────

class _MichiInfoList extends StatelessWidget {
  final MichiInfoListProjection projection;
  final TopicConfig topicConfig;
  final List<ActionItemProjection> markActionItems;

  const _MichiInfoList({
    required this.projection,
    required this.topicConfig,
    required this.markActionItems,
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

    final items = projection.items;

    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(top: 48, bottom: 80),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isFirst = index == 0;
              final isLast = index == items.length - 1;

              // 太線判定:
              // - Link 行: isLinkActive = true
              // - Mark 行: 前後いずれかが Link なら isLinkActive = true
              final bool isLinkActive;
              if (item.markLinkType == MarkOrLink.link) {
                isLinkActive = true;
              } else {
                final prevIsLink = !isFirst &&
                    items[index - 1].markLinkType == MarkOrLink.link;
                final nextIsLink = !isLast &&
                    items[index + 1].markLinkType == MarkOrLink.link;
                isLinkActive = prevIsLink || nextIsLink;
              }

              return _TimelineItem(
                item: item,
                isFirst: isFirst,
                isLast: isLast,
                isLinkActive: isLinkActive,
                onTap: () => context.read<MichiInfoBloc>().add(
                      MichiInfoItemTapped(
                        markLinkId: item.id,
                        type: item.markLinkType,
                      ),
                    ),
                markActionItems: markActionItems,
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
// _TimelineItem
// ────────────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  final MarkLinkItemProjection item;
  final bool isFirst;
  final bool isLast;
  final bool isLinkActive;
  final VoidCallback onTap;
  final List<ActionItemProjection> markActionItems;

  const _TimelineItem({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.isLinkActive,
    required this.onTap,
    required this.markActionItems,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMark = item.markLinkType == MarkOrLink.mark;

    final cardBgColor = isMark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainerLow;
    final lineColor = colorScheme.onSurface;

    final hasActionButtons = isMark && markActionItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _cardHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // タイムライン軸 + カード本体
              Expanded(
                child: Stack(
                  children: [
                    // 全ビジュアル要素を1つの CustomPainter で描画
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MichiTimelinePainter(
                          markLinkType: item.markLinkType,
                          isFirst: isFirst,
                          isLast: isLast,
                          isLinkActive: isLinkActive,
                          cardBgColor: cardBgColor,
                          lineColor: lineColor,
                        ),
                      ),
                    ),
                    // テキスト・タップ領域のオーバーレイ
                    _TimelineItemOverlay(
                      item: item,
                      onTap: onTap,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
              // 距離表示列
              SizedBox(
                width: 72,
                child: _DistanceColumn(item: item),
              ),
            ],
          ),
        ),
        // 地点アクションボタン
        if (hasActionButtons)
          _MarkActionButtons(
            markLinkId: item.id,
            actions: markActionItems,
          ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────
// _MichiTimelinePainter (統合 CustomPainter)
// ────────────────────────────────────────────────────────

class _MichiTimelinePainter extends CustomPainter {
  static const double _normalWidth = 1.5;
  static const double _thickWidth = 6.0;
  static const double _dotRadius = 6.0;

  /// タイムライン軸の中心 X 座標（左端からの距離）
  static const double _axisX = 20.0;

  /// カード左端の X 座標（タイムライン軸 + 余白）
  static const double _cardLeft = 40.0;

  /// カード右端の余白
  static const double _cardRight = 8.0;

  /// カード角丸
  static const double _cornerRadius = 8.0;

  /// 三角ポインターの幅（先端からボディ左端まで）
  static const double _pointerWidth = 20.0;

  /// 三角ポインターの高さ（上下幅）
  static const double _pointerHeight = 14.0;

  /// Link カードの水平接続線の長さ（タイムライン軸からカード左端まで）
  static const double _connectorLineLength = 20.0;

  final MarkOrLink markLinkType;
  final bool isFirst;
  final bool isLast;
  final bool isLinkActive;
  final Color cardBgColor;
  final Color lineColor;

  const _MichiTimelinePainter({
    required this.markLinkType,
    required this.isFirst,
    required this.isLast,
    required this.isLinkActive,
    required this.cardBgColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final isMark = markLinkType == MarkOrLink.mark;

    final normalPaint = Paint()
      ..color = lineColor
      ..strokeWidth = _normalWidth
      ..strokeCap = StrokeCap.butt;

    final thickPaint = Paint()
      ..color = lineColor
      ..strokeWidth = _thickWidth
      ..strokeCap = StrokeCap.butt;

    // ──────────────────────────────
    // タイムライン縦線（上半分）
    // ──────────────────────────────
    if (!isFirst) {
      final topLineEnd = isMark ? centerY - _dotRadius : centerY;
      final topPaint = isLinkActive ? thickPaint : normalPaint;
      canvas.drawLine(
        Offset(_axisX, 0),
        Offset(_axisX, topLineEnd),
        topPaint,
      );
    }

    // ──────────────────────────────
    // タイムライン縦線（下半分）
    // ──────────────────────────────
    if (!isLast) {
      final bottomLineStart = isMark ? centerY + _dotRadius : centerY;
      final bottomPaint = isLinkActive ? thickPaint : normalPaint;
      canvas.drawLine(
        Offset(_axisX, bottomLineStart),
        Offset(_axisX, size.height),
        bottomPaint,
      );
    }

    // ──────────────────────────────
    // カード背景
    // ──────────────────────────────
    final cardPaint = Paint()
      ..color = cardBgColor
      ..style = PaintingStyle.fill;

    if (isMark) {
      // バブルカード（三角ポインター付き）
      final cardBodyLeft = _cardLeft + _pointerWidth;
      final rect = Rect.fromLTWH(
        cardBodyLeft,
        0,
        size.width - cardBodyLeft - _cardRight,
        size.height,
      );
      final rrect =
          RRect.fromRectAndRadius(rect, const Radius.circular(_cornerRadius));

      final pointerTipX = _cardLeft;
      final path = Path()
        ..addRRect(rrect)
        ..moveTo(cardBodyLeft, centerY - _pointerHeight / 2)
        ..lineTo(pointerTipX, centerY)
        ..lineTo(cardBodyLeft, centerY + _pointerHeight / 2)
        ..close();

      canvas.drawPath(path, cardPaint);
    } else {
      // Link カード（角丸矩形）
      final rect = Rect.fromLTWH(
        _cardLeft,
        0,
        size.width - _cardLeft - _cardRight,
        size.height,
      );
      final rrect =
          RRect.fromRectAndRadius(rect, const Radius.circular(_cornerRadius));
      canvas.drawRRect(rrect, cardPaint);

      // 水平接続線（タイムライン軸からカード左端まで）
      canvas.drawLine(
        Offset(_axisX, centerY),
        Offset(_axisX + _connectorLineLength, centerY),
        normalPaint,
      );
    }

    // ──────────────────────────────
    // ドット（Mark のみ）
    // ──────────────────────────────
    if (isMark) {
      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(_axisX, centerY), _dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_MichiTimelinePainter old) =>
      markLinkType != old.markLinkType ||
      isFirst != old.isFirst ||
      isLast != old.isLast ||
      isLinkActive != old.isLinkActive ||
      cardBgColor != old.cardBgColor ||
      lineColor != old.lineColor;
}

// ────────────────────────────────────────────────────────
// _TimelineItemOverlay
// ────────────────────────────────────────────────────────

class _TimelineItemOverlay extends StatelessWidget {
  final MarkLinkItemProjection item;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  /// タイムライン軸 + ポインター幅分のオフセット
  static const double _axisX = 20.0;
  static const double _cardLeft = 40.0;
  static const double _pointerWidth = 20.0;

  const _TimelineItemOverlay({
    required this.item,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isMark = item.markLinkType == MarkOrLink.mark;
    final name =
        item.markLinkName.isEmpty ? '（名称未設定）' : item.markLinkName;

    // Mark はポインター分の左余白を加算
    final leftPadding =
        isMark ? _axisX + _pointerWidth * 2 : _cardLeft + 8.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.only(
          left: leftPadding,
          right: 12,
          top: 8,
          bottom: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: isMark
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isMark && item.displayMeterValue != null)
                    Text(
                      item.displayMeterValue!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                  if (!isMark && item.displayDistanceValue != null)
                    Text(
                      item.displayDistanceValue!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                ],
              ),
            ),
            if (item.isFuel)
              Icon(
                Icons.local_gas_station,
                size: 16,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// _DistanceColumn (距離表示列)
// ────────────────────────────────────────────────────────

class _DistanceColumn extends StatelessWidget {
  final MarkLinkItemProjection item;

  const _DistanceColumn({required this.item});

  @override
  Widget build(BuildContext context) {
    final isMark = item.markLinkType == MarkOrLink.mark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outline = Theme.of(context).colorScheme.outline;

    // Mark: displayMeterDiff を表示
    // Link: displayDistanceValue を表示
    final String? displayText;
    final Color textColor;
    final bool isBold;

    if (isMark) {
      displayText = item.displayMeterDiff;
      textColor = onSurface;
      isBold = true;
    } else {
      displayText = item.displayDistanceValue;
      textColor = outline;
      isBold = false;
    }

    if (displayText == null) return const SizedBox.shrink();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(16, 24),
            painter: _VerticalArrowPainter(color: textColor),
          ),
          const SizedBox(height: 2),
          Text(
            displayText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: textColor,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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

    canvas.drawLine(
      Offset(cx, arrowSize),
      Offset(cx, size.height - arrowSize),
      paint,
    );

    canvas.drawLine(Offset(cx, 0), Offset(cx - arrowSize / 2, arrowSize), paint);
    canvas.drawLine(Offset(cx, 0), Offset(cx + arrowSize / 2, arrowSize), paint);

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
// _MarkActionButtons (地点アクションボタン群)
// ────────────────────────────────────────────────────────

class _MarkActionButtons extends StatelessWidget {
  final String markLinkId;
  final List<ActionItemProjection> actions;

  const _MarkActionButtons({
    required this.markLinkId,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 6, bottom: 6),
      child: Wrap(
        spacing: 8,
        children: actions
            .map((action) => FilledButton.tonal(
                  onPressed: () => context.read<MichiInfoBloc>().add(
                        MichiInfoMarkActionPressed(
                          markLinkId: markLinkId,
                          actionId: action.id,
                        ),
                      ),
                  child: Text(action.actionName),
                ))
            .toList(),
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

