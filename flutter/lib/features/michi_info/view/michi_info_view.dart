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
// 定数（レイアウト）
// ────────────────────────────────────────────────────────

/// Mark カードの固定高さ。スパン矢印 Y 座標の基準値
const double _cardHeight = 72.0;

/// Link カードのコンパクト高さ（C-2 デザイン）
const double _linkCardHeight = 34.0;

/// _MarkActionButtons がある場合の追加高さ
const double _actionButtonsHeight = 48.0;

/// Link 個別距離列の固定幅
const double _linkDistanceColumnWidth = 64.0;

/// Mark 間スパン矢印列の固定幅
const double _spanArrowColumnWidth = 72.0;

/// 距離表示エリア合計幅
// ignore: unused_element
const double _distanceAreaTotalWidth = 136.0;

// ────────────────────────────────────────────────────────
// C-2 カラーパレット
// ────────────────────────────────────────────────────────

/// Mark プライマリカラー（Teal）
const Color _markPrimaryColor = Color(0xFF2B7A9B);

/// Link プライマリカラー（Emerald）
const Color _linkPrimaryColor = Color(0xFF2E9E6B);

/// Link グラデーション終点（Emerald Dark）
const Color _linkDarkColor = Color(0xFF1A7A52);

/// Link カード背景色
const Color _linkTintLightColor = Color(0xFFEDFAF4);

/// Link カードボーダー色
const Color _linkBorderColor = Color(0xFFC3EBD8);

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
    for (var i = index - 1; i >= 0; i--) {
      if (items[i].markLinkType == MarkOrLink.mark) {
        final spanCount = _buildSpanLinkCount(items, i);
        return spanCount > 0;
      }
    }
    return false;
  }

  /// SpanArrowData のリストを事前計算する（Link カード高さを考慮）
  List<SpanArrowData> _buildSpanArrows(
    List<MarkLinkItemProjection> items,
    List<ActionItemProjection> markActionItems,
  ) {
    final spans = <SpanArrowData>[];
    final hasActions = markActionItems.isNotEmpty;

    // 各アイテムの累積 Y オフセットを計算（Link は _linkCardHeight を使用）
    final yOffsets = <double>[];
    var cumulative = 0.0;
    for (final item in items) {
      yOffsets.add(cumulative);
      final isMark = item.markLinkType == MarkOrLink.mark;
      final itemHeight = isMark
          ? (hasActions ? _cardHeight + _actionButtonsHeight : _cardHeight)
          : _linkCardHeight;
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
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final spans = _buildSpanArrows(items, markActionItems);

    return Scaffold(
      body: Stack(
        children: [
          // 背景レイヤー: Mark 間スパン矢印（Teal）
          Positioned.fill(
            child: CustomPaint(
              painter: _MichiTimelineCanvas(
                spans: spans,
                scrollOffset: scrollOffset,
                arrowColor: _markPrimaryColor,
                textColor: _markPrimaryColor,
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

                      // 太線判定（Link ゾーン判定）
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
// _MichiTimelineCanvas（全体スパン矢印 CustomPainter）
// ────────────────────────────────────────────────────────

class _MichiTimelineCanvas extends CustomPainter {
  final List<SpanArrowData> spans;
  final double scrollOffset;
  final Color arrowColor;
  final Color textColor;

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

    final arrowCenterX = size.width - _spanArrowColumnWidth / 2;

    final paint = Paint()
      ..color = arrowColor
      ..strokeWidth = _arrowStrokeWidth
      ..strokeCap = StrokeCap.round;

    const topPadding = 48.0;

    for (final span in spans) {
      final drawStartY = span.startY - scrollOffset + topPadding;
      final drawEndY = span.endY - scrollOffset + topPadding;

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
    final isMark = item.markLinkType == MarkOrLink.mark;
    final hasActionButtons = isMark && markActionItems.isNotEmpty;
    // Mark: _cardHeight / Link: _linkCardHeight (C-2 コンパクト化)
    final rowHeight = isMark ? _cardHeight : _linkCardHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: rowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // タイムライン軸 + カード本体
              Expanded(
                child: Stack(
                  children: [
                    // C-2 ビジュアル要素（CustomPainter）
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MichiTimelinePainter(
                          markLinkType: item.markLinkType,
                          isFirst: isFirst,
                          isLast: isLast,
                          isLinkActive: isLinkActive,
                        ),
                      ),
                    ),
                    // テキスト・タップ領域オーバーレイ
                    Positioned.fill(
                      child: _TimelineItemOverlay(
                        item: item,
                        onTap: onTap,
                        isMark: isMark,
                      ),
                    ),
                  ],
                ),
              ),
              // Link 個別距離列（Link 行のみ）
              if (!isMark)
                SizedBox(
                  width: _linkDistanceColumnWidth,
                  child: _LinkDistanceCell(item: item),
                ),
              // スパン矢印列スペース確保（_MichiTimelineCanvas が描画）
              const SizedBox(width: _spanArrowColumnWidth),
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
// _MichiTimelinePainter v4.0（C-2 カラーデザイン）
// ────────────────────────────────────────────────────────

class _MichiTimelinePainter extends CustomPainter {
  /// タイムライン軸の中心 X 座標
  static const double _axisX = 20.0;

  /// カード左端 X 座標
  static const double _cardLeft = 40.0;

  /// カード右端余白
  static const double _cardRight = 8.0;

  /// 水平接続線の長さ（axisX からカード左端まで）
  static const double _connectorLength = 20.0;

  // Mark ドット
  static const double _markDotRadius = 10.0;
  static const double _markDotRingWidth = 3.0;

  // Link ドット
  static const double _linkDotSize = 14.0;
  static const double _linkDotCorner = 4.0;

  // 縦線の太さ
  static const double _thinLineWidth = 1.5;
  static const double _thickLineWidth = 6.0;

  // カード角丸
  static const double _markCornerRadius = 16.0;
  static const double _linkCornerRadius = 8.0;

  final MarkOrLink markLinkType;
  final bool isFirst;
  final bool isLast;
  final bool isLinkActive;

  const _MichiTimelinePainter({
    required this.markLinkType,
    required this.isFirst,
    required this.isLast,
    required this.isLinkActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final isMark = markLinkType == MarkOrLink.mark;

    // ── 1. タイムライン縦線 ─────────────────────────────────
    if (isMark) {
      // Mark カード: ドットの上下に縦線を描画（ドット部分はスキップ）
      final dotClearance = _markDotRadius + _markDotRingWidth;

      if (!isFirst) {
        final topEnd = centerY - dotClearance;
        if (topEnd > 0) {
          canvas.drawLine(
            Offset(_axisX, 0),
            Offset(_axisX, topEnd),
            _makeLinePaint(isLinkActive),
          );
        }
      }
      if (!isLast) {
        final bottomStart = centerY + dotClearance;
        if (size.height > bottomStart) {
          canvas.drawLine(
            Offset(_axisX, bottomStart),
            Offset(_axisX, size.height),
            _makeLinePaint(isLinkActive),
          );
        }
      }
    } else {
      // Link カード: Emerald グラデーション縦線をカード全体に描画
      final lineRect = Rect.fromLTWH(
        _axisX - _thickLineWidth / 2,
        0,
        _thickLineWidth,
        size.height,
      );
      final gradientPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_linkPrimaryColor, _linkDarkColor],
        ).createShader(lineRect);
      canvas.drawRect(lineRect, gradientPaint);
    }

    // ── 2. カード背景 ──────────────────────────────────────
    final cardCornerRadius =
        isMark ? _markCornerRadius : _linkCornerRadius;
    final cardRect = Rect.fromLTWH(
      _cardLeft,
      0,
      size.width - _cardLeft - _cardRight,
      size.height,
    );
    final rrect = RRect.fromRectAndRadius(
      cardRect,
      Radius.circular(cardCornerRadius),
    );

    // Mark カード: ドロップシャドウ
    if (isMark) {
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          cardRect.translate(0, 2),
          Radius.circular(cardCornerRadius),
        ),
        shadowPaint,
      );
    }

    // カード塗り
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = isMark ? Colors.white : _linkTintLightColor
        ..style = PaintingStyle.fill,
    );

    // カードボーダー
    if (isMark) {
      // 上辺 3dp Teal ボーダー
      final topBorderPaint = Paint()
        ..color = _markPrimaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      final topPath = Path()
        ..moveTo(cardRect.left, cardRect.top + cardCornerRadius)
        ..arcToPoint(
          Offset(cardRect.left + cardCornerRadius, cardRect.top),
          radius: Radius.circular(cardCornerRadius),
          clockwise: false,
        )
        ..lineTo(cardRect.right - cardCornerRadius, cardRect.top)
        ..arcToPoint(
          Offset(cardRect.right, cardRect.top + cardCornerRadius),
          radius: Radius.circular(cardCornerRadius),
        );
      canvas.drawPath(topPath, topBorderPaint);
    } else {
      // 全辺 1.5px Emerald ボーダー
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = _linkBorderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // ── 3. 水平接続線（axisX → cardLeft）─────────────────
    canvas.drawLine(
      Offset(_axisX, centerY),
      Offset(_axisX + _connectorLength, centerY),
      Paint()
        ..color = isMark
            ? _markPrimaryColor
            : _linkPrimaryColor.withValues(alpha: 0.55)
        ..strokeWidth = isMark ? 2.0 : 1.5
        ..strokeCap = StrokeCap.round,
    );

    // ── 4. ドット ───────────────────────────────────────
    if (isMark) {
      // 白リング（背景との分離）
      canvas.drawCircle(
        Offset(_axisX, centerY),
        _markDotRadius + _markDotRingWidth,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      // Teal 円ドット
      canvas.drawCircle(
        Offset(_axisX, centerY),
        _markDotRadius,
        Paint()
          ..color = _markPrimaryColor
          ..style = PaintingStyle.fill,
      );
    } else {
      // Emerald 角丸矩形ドット
      final dotRect = Rect.fromCenter(
        center: Offset(_axisX, centerY),
        width: _linkDotSize,
        height: _linkDotSize,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          dotRect,
          const Radius.circular(_linkDotCorner),
        ),
        Paint()
          ..color = _linkPrimaryColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  /// 縦線用 Paint を生成（isLinkActive で Emerald 太線 / Teal 細線）
  Paint _makeLinePaint(bool linkActive) => Paint()
    ..color = linkActive
        ? _linkPrimaryColor.withValues(alpha: 0.8)
        : _markPrimaryColor.withValues(alpha: 0.4)
    ..strokeWidth = linkActive ? _thickLineWidth : _thinLineWidth
    ..strokeCap = StrokeCap.butt;

  @override
  bool shouldRepaint(_MichiTimelinePainter old) =>
      markLinkType != old.markLinkType ||
      isFirst != old.isFirst ||
      isLast != old.isLast ||
      isLinkActive != old.isLinkActive;
}

// ────────────────────────────────────────────────────────
// _TimelineItemOverlay
// ────────────────────────────────────────────────────────

class _TimelineItemOverlay extends StatelessWidget {
  final MarkLinkItemProjection item;
  final VoidCallback onTap;
  final bool isMark;

  static const double _cardLeft = 40.0;

  const _TimelineItemOverlay({
    required this.item,
    required this.onTap,
    required this.isMark,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        item.markLinkName.isEmpty ? '（名称未設定）' : item.markLinkName;
    const leftPadding = _cardLeft + 8.0;

    // Link カード（34dp）は padding を縮小して収まるようにする
    final verticalPadding = isMark ? 8.0 : 4.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.only(
          left: leftPadding,
          right: 12,
          top: verticalPadding,
          bottom: verticalPadding,
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
                          color: const Color(0xFF1A1A2E),
                          fontWeight: isMark
                              ? FontWeight.w700
                              : FontWeight.w600,
                          fontSize: isMark ? 13 : 11,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isMark && item.displayMeterValue != null)
                    Text(
                      item.displayMeterValue!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: _markPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  // Link の距離は _LinkDistanceCell に表示するため overlay では非表示
                ],
              ),
            ),
            if (item.isFuel)
              Icon(
                Icons.local_gas_station,
                size: 16,
                color: _markPrimaryColor,
              ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// _LinkDistanceCell（Link 行の個別距離表示・Emerald カラー）
// ────────────────────────────────────────────────────────

class _LinkDistanceCell extends StatelessWidget {
  final MarkLinkItemProjection item;

  const _LinkDistanceCell({required this.item});

  @override
  Widget build(BuildContext context) {
    final displayText = item.displayDistanceValue;
    if (displayText == null) return const SizedBox.shrink();

    // _linkCardHeight = 34dp 内に収める:
    // 矢印(14dp) + 間隔(0dp) + テキスト(≈14dp) = 28dp ≤ 34dp
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(14, 14),
            painter: const _VerticalArrowPainter(color: _linkPrimaryColor),
          ),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 12,
              color: _linkPrimaryColor,
              fontWeight: FontWeight.w800,
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
// _DistanceLegend（凡例）
// ────────────────────────────────────────────────────────

class _DistanceLegend extends StatelessWidget {
  const _DistanceLegend();

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
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
                  color: _markPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '区間距離（Link）',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: _linkPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
