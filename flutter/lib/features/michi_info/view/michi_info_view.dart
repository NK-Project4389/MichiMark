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

/// _MarkActionButtons がある場合の追加高さ
const double _actionButtonsHeight = 48.0;

/// Mark カード右端の内側余白。スパン矢印列幅分を確保する
// ignore: unused_element
const double _markCardRightInset = 80.0;

/// Link 個別距離列の固定幅
const double _linkDistanceColumnWidth = 64.0;

/// Mark 間スパン矢印列の固定幅
const double _spanArrowColumnWidth = 72.0;

/// 距離表示エリア合計幅（_linkDistanceColumnWidth + _spanArrowColumnWidth）
// ignore: unused_element
const double _distanceAreaTotalWidth = 136.0;

// ────────────────────────────────────────────────────────
// SpanArrowData
// ────────────────────────────────────────────────────────

/// Mark 間スパン矢印の描画データ
class SpanArrowData {
  /// スパン開始 Mark のリスト内絶対 Y 座標（中心）
  final double startY;

  /// スパン終了 Mark のリスト内絶対 Y 座標（中心）
  final double endY;

  /// 表示する距離文字列（displayMeterDiff）
  final String distanceText;

  const SpanArrowData({
    required this.startY,
    required this.endY,
    required this.distanceText,
  });
}

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

class _MichiInfoList extends StatefulWidget {
  final MichiInfoListProjection projection;
  final TopicConfig topicConfig;
  final List<ActionItemProjection> markActionItems;

  const _MichiInfoList({
    required this.projection,
    required this.topicConfig,
    required this.markActionItems,
  });

  @override
  State<_MichiInfoList> createState() => _MichiInfoListState();
}

class _MichiInfoListState extends State<_MichiInfoList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {});
  }

  /// this Mark から次の Mark まで連続する Link の件数を数える
  int _buildSpanLinkCount(List<MarkLinkItemProjection> items, int index) {
    if (items[index].markLinkType != MarkOrLink.mark) return 0;
    var count = 0;
    for (var i = index + 1; i < items.length; i++) {
      if (items[i].markLinkType == MarkOrLink.link) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// この Link がスパン区間内かどうかを判定する
  bool _buildIsSpanLink(List<MarkLinkItemProjection> items, int index) {
    if (items[index].markLinkType != MarkOrLink.link) return false;
    // 直近の Mark を遡って探す
    for (var i = index - 1; i >= 0; i--) {
      if (items[i].markLinkType == MarkOrLink.mark) {
        // その Mark の spanLinkCount > 0 かつ次に Mark が存在するか確認
        final spanCount = _buildSpanLinkCount(items, i);
        return spanCount > 0;
      }
    }
    return false;
  }

  /// SpanArrowData のリストを事前計算する
  List<SpanArrowData> _buildSpanArrows(
    List<MarkLinkItemProjection> items,
    List<ActionItemProjection> markActionItems,
  ) {
    final spans = <SpanArrowData>[];
    final hasActions = markActionItems.isNotEmpty;

    // 各アイテムの累積 Y オフセットを計算
    final yOffsets = <double>[];
    var cumulative = 0.0;
    for (final item in items) {
      yOffsets.add(cumulative);
      final isMark = item.markLinkType == MarkOrLink.mark;
      final itemHeight = isMark && hasActions
          ? _cardHeight + _actionButtonsHeight
          : _cardHeight;
      cumulative += itemHeight;
    }

    // Mark を走査してスパン矢印データを生成
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.markLinkType != MarkOrLink.mark) continue;

      final spanCount = _buildSpanLinkCount(items, i);
      final distanceText = item.displayMeterDiff;
      if (distanceText == null) continue;

      // スパンなし（パターン1）: 次の Mark との間
      if (spanCount == 0) {
        // 次の Mark を探す
        for (var j = i + 1; j < items.length; j++) {
          if (items[j].markLinkType == MarkOrLink.mark) {
            final startY = yOffsets[i] + _cardHeight / 2;
            final endY = yOffsets[j] + _cardHeight / 2;
            spans.add(SpanArrowData(
              startY: startY,
              endY: endY,
              distanceText: distanceText,
            ));
            break;
          }
        }
      } else {
        // スパンあり（パターン3・4）: 次の Mark まで
        final endMarkIndex = i + spanCount + 1;
        if (endMarkIndex < items.length &&
            items[endMarkIndex].markLinkType == MarkOrLink.mark) {
          final startY = yOffsets[i] + _cardHeight / 2;
          final endY = yOffsets[endMarkIndex] + _cardHeight / 2;
          spans.add(SpanArrowData(
            startY: startY,
            endY: endY,
            distanceText: distanceText,
          ));
        }
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final projection = widget.projection;
    final markActionItems = widget.markActionItems;

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
    final colorScheme = Theme.of(context).colorScheme;
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final spans = _buildSpanArrows(items, markActionItems);

    return Scaffold(
      body: Stack(
        children: [
          // 背景レイヤー: Mark 間スパン矢印
          Positioned.fill(
            child: CustomPaint(
              painter: _MichiTimelineCanvas(
                spans: spans,
                scrollOffset: scrollOffset,
                arrowColor: colorScheme.onSurface,
                textColor: colorScheme.onSurface,
              ),
            ),
          ),
          // メインスクロールビュー
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 48, bottom: 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      final isFirst = index == 0;
                      final isLast = index == items.length - 1;

                      // 太線判定
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

                      final isSpanLink = _buildIsSpanLink(items, index);

                      return _TimelineItem(
                        item: item,
                        isFirst: isFirst,
                        isLast: isLast,
                        isLinkActive: isLinkActive,
                        isSpanLink: isSpanLink,
                        onTap: () => context.read<MichiInfoBloc>().add(
                              MichiInfoItemTapped(
                                markLinkId: item.id,
                                type: item.markLinkType,
                              ),
                            ),
                        markActionItems: markActionItems,
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          ),
          // 右上固定の凡例
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
            if (widget.topicConfig.allowLinkAdd)
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
// _MichiTimelineCanvas（新設・全体スパン矢印 CustomPainter）
// ────────────────────────────────────────────────────────

class _MichiTimelineCanvas extends CustomPainter {
  final List<SpanArrowData> spans;
  final double scrollOffset;
  final Color arrowColor;
  final Color textColor;

  /// スパン矢印列の中心 X（画面右端 - spanArrowColumnWidth の中央）
  static const double _arrowHeadSize = 6.0;
  static const double _arrowStrokeWidth = 1.5;

  const _MichiTimelineCanvas({
    required this.spans,
    required this.scrollOffset,
    required this.arrowColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (spans.isEmpty) return;

    // スパン矢印列の中心 X
    final arrowCenterX = size.width - _spanArrowColumnWidth / 2;

    final paint = Paint()
      ..color = arrowColor
      ..strokeWidth = _arrowStrokeWidth
      ..strokeCap = StrokeCap.round;

    const topPadding = 48.0; // SliverPadding top と一致させる

    for (final span in spans) {
      final drawStartY = span.startY - scrollOffset + topPadding;
      final drawEndY = span.endY - scrollOffset + topPadding;

      // 画面外なら描画スキップ
      if (drawEndY < 0 || drawStartY > size.height) continue;

      // 縦線
      canvas.drawLine(
        Offset(arrowCenterX, drawStartY),
        Offset(arrowCenterX, drawEndY),
        paint,
      );

      // 上向き矢印頭
      canvas.drawLine(
        Offset(arrowCenterX, drawStartY),
        Offset(arrowCenterX - _arrowHeadSize / 2, drawStartY + _arrowHeadSize),
        paint,
      );
      canvas.drawLine(
        Offset(arrowCenterX, drawStartY),
        Offset(arrowCenterX + _arrowHeadSize / 2, drawStartY + _arrowHeadSize),
        paint,
      );

      // 下向き矢印頭
      canvas.drawLine(
        Offset(arrowCenterX, drawEndY),
        Offset(arrowCenterX - _arrowHeadSize / 2, drawEndY - _arrowHeadSize),
        paint,
      );
      canvas.drawLine(
        Offset(arrowCenterX, drawEndY),
        Offset(arrowCenterX + _arrowHeadSize / 2, drawEndY - _arrowHeadSize),
        paint,
      );

      // 距離テキスト（矢印の中央）
      final midY = (drawStartY + drawEndY) / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: span.distanceText,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: _spanArrowColumnWidth - 4);

      textPainter.paint(
        canvas,
        Offset(
          arrowCenterX - textPainter.width / 2,
          midY - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_MichiTimelineCanvas old) =>
      spans != old.spans ||
      scrollOffset != old.scrollOffset ||
      arrowColor != old.arrowColor ||
      textColor != old.textColor;
}

// ────────────────────────────────────────────────────────
// _TimelineItem
// ────────────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  final MarkLinkItemProjection item;
  final bool isFirst;
  final bool isLast;
  final bool isLinkActive;
  final bool isSpanLink;
  final VoidCallback onTap;
  final List<ActionItemProjection> markActionItems;

  const _TimelineItem({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.isLinkActive,
    required this.isSpanLink,
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
              // タイムライン軸 + カード本体（幅: 画面幅 - 距離エリア幅）
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
                    // テキスト・タップ領域のオーバーレイ（Positioned.fill でカード全体をタップ可能に）
                    Positioned.fill(
                      child: _TimelineItemOverlay(
                        item: item,
                        onTap: onTap,
                        colorScheme: colorScheme,
                        isMark: isMark,
                      ),
                    ),
                  ],
                ),
              ),
              // Link 個別距離列（Link 行のみ表示）
              if (!isMark)
                SizedBox(
                  width: _linkDistanceColumnWidth,
                  child: _LinkDistanceCell(item: item),
                ),
              // スパン矢印列のスペース確保（_MichiTimelineCanvas が描画）
              SizedBox(width: _spanArrowColumnWidth),
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
// _MichiTimelinePainter v3.0（統合 CustomPainter）
// ────────────────────────────────────────────────────────

class _MichiTimelinePainter extends CustomPainter {
  static const double _normalWidth = 1.5;
  static const double _thickWidth = 6.0;
  static const double _dotRadius = 6.0;

  /// タイムライン軸の中心 X 座標（左端からの距離）
  static const double _axisX = 20.0;

  /// カード左端の X 座標（Mark・Link ともに統一）
  static const double _cardLeft = 40.0;

  /// カード右端の余白
  static const double _cardRight = 8.0;

  /// カード角丸
  static const double _cornerRadius = 8.0;

  /// 水平接続線の長さ（タイムライン軸からカード左端まで）
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
    // _cardHeight 範囲内に限定（size.height ではなく _cardHeight を使用）
    // ──────────────────────────────
    if (!isFirst) {
      final topLineEnd = isMark ? centerY - _dotRadius : 0.0;
      final topPaint = isLinkActive ? thickPaint : normalPaint;
      // 上端から dotTop または cardTop まで
      final topLineStart = 0.0;
      if (topLineEnd > topLineStart) {
        canvas.drawLine(
          Offset(_axisX, topLineStart),
          Offset(_axisX, topLineEnd),
          topPaint,
        );
      }
    }

    // ──────────────────────────────
    // タイムライン縦線（下半分）
    // _cardHeight 範囲内に限定
    // ──────────────────────────────
    if (!isLast) {
      final bottomLineStart = isMark ? centerY + _dotRadius : size.height;
      final bottomLineEnd = _cardHeight;
      final bottomPaint = isLinkActive ? thickPaint : normalPaint;
      if (bottomLineEnd > bottomLineStart) {
        canvas.drawLine(
          Offset(_axisX, bottomLineStart),
          Offset(_axisX, bottomLineEnd),
          bottomPaint,
        );
      }
    }

    // ──────────────────────────────
    // カード背景（Mark・Link ともに角丸矩形）
    // ──────────────────────────────
    final cardPaint = Paint()
      ..color = cardBgColor
      ..style = PaintingStyle.fill;

    // カード右端を幅設定に合わせる
    // Mark: size.width - _cardLeft - _cardRight（スパン矢印列は SizedBox で確保済み）
    // Link: size.width - _cardLeft - _cardRight（Link距離列も SizedBox で確保済み）
    final rect = Rect.fromLTWH(
      _cardLeft,
      0,
      size.width - _cardLeft - _cardRight,
      size.height,
    );
    final rrect =
        RRect.fromRectAndRadius(rect, const Radius.circular(_cornerRadius));
    canvas.drawRRect(rrect, cardPaint);

    // ──────────────────────────────
    // 水平接続線（タイムライン軸からカード左端まで）
    // Mark・Link ともに同じ描画パターン
    // ──────────────────────────────
    canvas.drawLine(
      Offset(_axisX, centerY),
      Offset(_axisX + _connectorLineLength, centerY),
      normalPaint,
    );

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
  final bool isMark;

  /// タイムライン軸 + 接続線幅分のオフセット
  static const double _cardLeft = 40.0;

  const _TimelineItemOverlay({
    required this.item,
    required this.onTap,
    required this.colorScheme,
    required this.isMark,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        item.markLinkName.isEmpty ? '（名称未設定）' : item.markLinkName;

    // Mark・Link ともに同じ leftPadding（三角ポインター廃止で統一）
    const leftPadding = _cardLeft + 8.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.only(
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
// _LinkDistanceCell（新設・Link 行の個別距離表示）
// ────────────────────────────────────────────────────────

class _LinkDistanceCell extends StatelessWidget {
  final MarkLinkItemProjection item;

  const _LinkDistanceCell({required this.item});

  @override
  Widget build(BuildContext context) {
    final displayText = item.displayDistanceValue;
    if (displayText == null) return const SizedBox.shrink();

    final outline = Theme.of(context).colorScheme.outline;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(16, 24),
            painter: _VerticalArrowPainter(color: outline),
          ),
          const SizedBox(height: 2),
          Text(
            displayText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: outline,
                  fontWeight: FontWeight.normal,
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
// _DistanceLegend（凡例文言更新）
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
            'Mark間合計',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: onSurface,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '区間距離（Link）',
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
