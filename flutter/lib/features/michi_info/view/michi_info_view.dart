import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../features/action_time/bloc/action_time_bloc.dart';
import '../../../features/action_time/bloc/action_time_event.dart';
import '../../../features/action_time/bloc/action_time_state.dart';
import '../../../features/action_time/view/action_time_view.dart';
import '../../../features/event_detail/projection/michi_info_list_projection.dart';
import '../../../features/link_detail/link_detail_args.dart';
import '../../../features/mark_detail/mark_detail_args.dart';
import '../../../features/shared/projection/action_item_projection.dart';
import '../../../features/shared/projection/mark_link_item_projection.dart';
import '../../../features/shared/projection/member_item_projection.dart';
import '../../../repository/action_repository.dart';
import '../../../repository/event_repository.dart';
import '../bloc/michi_info_bloc.dart';
import '../bloc/michi_info_event.dart';
import '../bloc/michi_info_state.dart';

// ────────────────────────────────────────────────────────
// 定数（レイアウト）
// ────────────────────────────────────────────────────────

/// Mark カードの固定高さ
const double _cardHeight = 72.0;

/// Link カードのコンパクト高さ（C-2 デザイン）
const double _linkCardHeight = 34.0;

/// _MarkActionButtons がある場合の追加高さ
const double _actionButtonsHeight = 48.0;

/// スパン矢印列の固定幅（メーター差分・区間距離テキストも含む）
const double _spanArrowColumnWidth = 72.0;

/// タイムラインアイテム間の通常隙間
const double _itemGap = 8.0;

/// Mark-Mark 直接隣接時のギャップ（スパン矢印表示スペース確保）
const double _markMarkGap = 50.0;

/// 日付区切りウィジェットの高さ
const double _dateSeparatorHeight = 48.0;

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
// UI-14 道路帯定数
// ────────────────────────────────────────────────────────

/// 軸中心からの片側幅（px）（帯幅18px = 2 * _roadBandHalfWidth）
const double _roadBandHalfWidth = 9.0;

/// 帯上下端の丸みRadius（px）
const double _roadBandRadius = 4.0;

/// 道路帯のグレー色
const Color _roadBandColor = Color(0xFF888888);

/// 白破線センターラインの色
const Color _centerLineColor = Color(0xFFFFFFFF);

/// センターライン幅（px）
const double _centerLineWidth = 1.5;

/// 破線の実線部分の長さ（px）
const double _dashOn = 6.0;

/// 破線の空白部分の長さ（px）
const double _dashOff = 4.0;

// ────────────────────────────────────────────────────────
// TimelineListItem（表示用アイテム識別）
// ────────────────────────────────────────────────────────

/// SliverList構築時に使用する sealed class
sealed class TimelineListItem {}

/// 既存のMarkまたはLinkカード
class CardItem extends TimelineListItem {
  final MarkLinkItemProjection projection;
  CardItem(this.projection);
}

/// 日付区切り行（`yyyy/MM/dd`形式）
class DateSeparatorItem extends TimelineListItem {
  final String dateLabel;
  DateSeparatorItem(this.dateLabel);
}

// ────────────────────────────────────────────────────────
// データクラス
// ────────────────────────────────────────────────────────

/// Mark 間スパン矢印の描画データ
/// startY = 上側 Mark の底辺 Y、endY = 下側 Mark の上辺 Y
class SpanArrowData {
  final double startY;
  final double endY;

  /// メーター差分テキスト（Teal）
  final String meterDiffText;

  /// 区間距離テキスト群（Emerald）。スパン内 Link ごとに 1 件
  final List<String> linkDistanceTexts;

  const SpanArrowData({
    required this.startY,
    required this.endY,
    required this.meterDiffText,
    this.linkDistanceTexts = const [],
  });
}

/// Link カードの Emerald グラデーション縦線セグメントデータ
class LinkSegmentData {
  final double startY;
  final double endY;

  const LinkSegmentData({required this.startY, required this.endY});
}

/// タイムライン描画データ一式
class _TimelineData {
  final List<SpanArrowData> spans;
  final List<LinkSegmentData> linkSegments;
  final List<double> gapAfterItem;

  /// 縦線の開始 Y（始点アイテムのドット中心・リスト相対）
  final double verticalLineStartRelY;

  /// 縦線の終了 Y（終点アイテムのドット中心・リスト相対）
  final double verticalLineEndRelY;

  /// スパンに含まれない Link の単独距離テキスト（centerRelY, text）
  final List<(double, String)> standaloneLinkDistances;

  /// スパンに含まれない Link のスパン列縦線（startY, endY）
  final List<(double, double)> standaloneLinkLines;

  const _TimelineData({
    required this.spans,
    required this.linkSegments,
    required this.gapAfterItem,
    required this.verticalLineStartRelY,
    required this.verticalLineEndRelY,
    required this.standaloneLinkDistances,
    required this.standaloneLinkLines,
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
      listenWhen: (prev, curr) {
        // delegate 変化 → 従来のトリガー
        if (curr is MichiInfoLoaded && curr.delegate != null) return true;
        // pendingInsertAfterSeq が null → non-null に変化 → BottomSheet トリガー
        if (prev is MichiInfoLoaded && curr is MichiInfoLoaded) {
          return prev.pendingInsertAfterSeq == null &&
              curr.pendingInsertAfterSeq != null;
        }
        return false;
      },
      listener: (context, state) async {
        if (state is! MichiInfoLoaded) return;

        // BottomSheet トリガー（pendingInsertAfterSeq が non-null になったとき）
        if (state.delegate == null && state.pendingInsertAfterSeq != null) {
          final items = state.topicConfig.addMenuItems;
          if (items.length == 1) {
            // 選択肢が 1 件のみ → ボトムシートをスキップして直接 dispatch
            final item = items[0];
            if (!mounted) return;
            if (item == AddMenuItemType.mark) {
              context
                  .read<MichiInfoBloc>()
                  .add(const MichiInfoInsertMarkPressed());
            } else {
              context
                  .read<MichiInfoBloc>()
                  .add(const MichiInfoInsertLinkPressed());
            }
          } else if (items.length == 2) {
            // 選択肢が 2 件 → 従来通りボトムシートを表示
            await _showInsertBottomSheet(state.topicConfig);
          }
          // items.length == 0 は安全ガード（到達しない想定）
          return;
        }

        // 従来の delegate 処理
        if (state.delegate != null) {
          await _handleDelegate(state.delegate!);
          if (mounted) {
            this
                .context
                .read<MichiInfoBloc>()
                .add(const MichiInfoDelegateConsumed());
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          MichiInfoLoading() =>
            const Center(child: CircularProgressIndicator()),
          MichiInfoError(:final message) => Center(child: Text(message)),
          MichiInfoLoaded(
            :final projection,
            :final topicConfig,
            :final markActionItems,
            :final markActionStateLabels,
            :final eventId,
            :final isInsertMode,
          ) =>
            _MichiInfoList(
              projection: projection,
              topicConfig: topicConfig,
              markActionItems: markActionItems,
              markActionStateLabels: markActionStateLabels,
              eventId: eventId,
              isInsertMode: isInsertMode,
            ),
        };
      },
    );
  }

  Future<void> _showInsertBottomSheet(TopicConfig topicConfig) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (topicConfig.addMenuItems.contains(AddMenuItemType.mark))
              ListTile(
                key: const Key('michiInfo_button_addMark'),
                leading: const Icon(Icons.place),
                title: const Text('地点を追加'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (mounted) {
                    context
                        .read<MichiInfoBloc>()
                        .add(const MichiInfoInsertMarkPressed());
                  }
                },
              ),
            if (topicConfig.addMenuItems.contains(AddMenuItemType.link))
              ListTile(
                key: const Key('michiInfo_button_addLink'),
                leading: const Icon(Icons.route),
                title: const Text('区間を追加'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (mounted) {
                    context
                        .read<MichiInfoBloc>()
                        .add(const MichiInfoInsertLinkPressed());
                  }
                },
              ),
          ],
        ),
      ),
    );
    // BottomSheet が閉じた（キャンセル）場合に pendingInsertAfterSeq をリセット
    if (mounted) {
      context
          .read<MichiInfoBloc>()
          .add(const MichiInfoInsertPointCancelled());
    }
  }

  Future<void> _handleDelegate(MichiInfoDelegate delegate) async {
    switch (delegate) {
      case MichiInfoOpenMarkDelegate(:final eventId, :final markLinkId, :final topicConfig, :final eventMembers):
        await context.push<void>(
          '/event/mark/$markLinkId',
          extra: MarkDetailArgs(
            eventId: eventId,
            topicConfig: topicConfig,
            eventMembers: eventMembers,
          ),
        );
        if (mounted) {
          context.read<MichiInfoBloc>().add(const MichiInfoReloadRequested());
        }

      case MichiInfoOpenLinkDelegate(:final eventId, :final markLinkId, :final topicConfig, :final eventMembers):
        await context.push<void>(
          '/event/link/$markLinkId',
          extra: LinkDetailArgs(
            eventId: eventId,
            topicConfig: topicConfig,
            eventMembers: eventMembers,
          ),
        );
        if (mounted) {
          context.read<MichiInfoBloc>().add(const MichiInfoReloadRequested());
        }

      case MichiInfoAddMarkDelegate(
          :final eventId,
          :final topicConfig,
          :final initialMeterValueInput,
          :final initialSelectedMembers,
          :final initialMarkLinkDate,
          :final eventMembers,
          :final insertAfterSeq,
        ):
        final markId = const Uuid().v4();
        await context.push<void>(
          '/event/mark/$markId',
          extra: MarkDetailArgs(
            eventId: eventId,
            topicConfig: topicConfig,
            initialMeterValueInput: initialMeterValueInput,
            initialSelectedMembers: initialSelectedMembers,
            initialMarkLinkDate: initialMarkLinkDate,
            eventMembers: eventMembers,
            insertAfterSeq: insertAfterSeq,
          ),
        );
        if (mounted) {
          context.read<MichiInfoBloc>().add(const MichiInfoReloadRequested());
        }

      case MichiInfoAddLinkDelegate(
          :final eventId,
          :final topicConfig,
          :final eventMembers,
          :final insertAfterSeq,
        ):
        final linkId = const Uuid().v4();
        await context.push<void>(
          '/event/link/$linkId',
          extra: LinkDetailArgs(
            eventId: eventId,
            topicConfig: topicConfig,
            eventMembers: eventMembers,
            insertAfterSeq: insertAfterSeq,
          ),
        );
        if (mounted) {
          context.read<MichiInfoBloc>().add(const MichiInfoReloadRequested());
        }

      case MichiInfoOpenActionTimeDelegate(
          :final markLinkId,
          :final eventId,
          :final topicConfig,
        ):
        await _showActionTimeBottomSheet(
          markLinkId: markLinkId,
          eventId: eventId,
          topicConfig: topicConfig,
        );

      case MichiInfoReloadedDelegate():
        // 再読込完了: EventDetailPageのBlocListenerでcachedEventを更新する
        break;
    }
  }

  Future<void> _showActionTimeBottomSheet({
    required String markLinkId,
    required String eventId,
    required TopicConfig topicConfig,
  }) async {
    ActionTimeState? lastState;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (sheetContext) {
        return BlocProvider<ActionTimeBloc>(
          create: (_) => ActionTimeBloc(
            eventRepository: GetIt.instance<EventRepository>(),
            actionRepository: GetIt.instance<ActionRepository>(),
          )..add(ActionTimeStarted(
              eventId,
              topicConfig: topicConfig,
              markOrLink: MarkOrLink.mark,
              markLinkId: markLinkId,
            )),
          child: BlocListener<ActionTimeBloc, ActionTimeState>(
            listener: (listenerContext, state) {
              lastState = state;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    // ヘッダー
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'ActionTime',
                            style: Theme.of(sheetContext).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          IconButton(
                            key: const Key('actionTime_sheet_close'),
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(sheetContext).pop(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // コンテンツ
                    const Expanded(
                      child: ActionTimeView(),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    // ボトムシートが閉じた後に状態ラベルを更新する
    if (!mounted) return;
    final stateLabel = lastState?.projection.currentStateLabel ?? '滞留中';
    context.read<MichiInfoBloc>().add(
          MichiInfoActionStateLabelUpdated(
            markLinkId: markLinkId,
            currentStateLabel: stateLabel,
          ),
        );

    // アクション記録後に cachedEvent を更新するため DB からリロードする。
    // MichiInfoReloadedDelegate → EventDetailPage の listener →
    // EventDetailCachedEventUpdateRequested の既存パスを経由して
    // OverviewBloc が最新の actionTimeLogs を使って集計できるようにする。
    if (!mounted) return;
    context.read<MichiInfoBloc>().add(const MichiInfoReloadRequested());
  }
}

// ────────────────────────────────────────────────────────
// _MichiInfoList
// ────────────────────────────────────────────────────────

class _MichiInfoList extends StatefulWidget {
  final MichiInfoListProjection projection;
  final TopicConfig topicConfig;
  final List<ActionItemProjection> markActionItems;
  final Map<String, String> markActionStateLabels;
  final String eventId;
  final bool isInsertMode;

  const _MichiInfoList({
    required this.projection,
    required this.topicConfig,
    required this.markActionItems,
    required this.markActionStateLabels,
    required this.eventId,
    this.isInsertMode = false,
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

  /// MarkLinkItemProjection リストから DateSeparatorItem を差し込んだ表示用リストを生成する。
  /// isInsertMode == true のときは区切りを挿入しない。
  List<TimelineListItem> _buildTimelineListItems(
    List<MarkLinkItemProjection> items,
    bool isInsertMode,
  ) {
    if (isInsertMode) {
      return items.map<TimelineListItem>((item) => CardItem(item)).toList();
    }

    final result = <TimelineListItem>[];
    for (var i = 0; i < items.length; i++) {
      if (i == 0) {
        // 先頭アイテムの直前に必ず区切りを挿入
        result.add(DateSeparatorItem(items[0].dateKey));
      } else {
        // 直前カードと dateKey が異なる場合のみ挿入
        if (items[i].dateKey != items[i - 1].dateKey) {
          result.add(DateSeparatorItem(items[i].dateKey));
        }
      }
      result.add(CardItem(items[i]));
    }
    return result;
  }

  /// この Mark から次の Mark まで連続する Link の件数を数える
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

  /// タイムライン描画データを一括計算する
  ///
  /// - Y座標はリスト先頭からの相対値（topPadding・scrollOffset は含まない）
  /// - Mark-Mark 直接隣接時は _markMarkGap を使用
  /// - startY = 上側 Mark 底辺、endY = 下側 Mark 上辺
  /// - DateSeparatorItem の高さ（_dateSeparatorHeight）をY座標計算に加算する
  _TimelineData _buildTimelineData(
    List<TimelineListItem> timelineItems,
    List<ActionItemProjection> markActionItems,
  ) {
    // CardItem のみ抽出（スパン計算・MarkLink処理用）
    final items = timelineItems
        .whereType<CardItem>()
        .map((c) => c.projection)
        .toList();

    if (items.isEmpty) {
      return const _TimelineData(
        spans: [],
        linkSegments: [],
        gapAfterItem: [],
        verticalLineStartRelY: 0,
        verticalLineEndRelY: 0,
        standaloneLinkDistances: [],
        standaloneLinkLines: [],
      );
    }

    // visitWork（showActionTimeButton == true）では _actionButtonsHeight を加算しない
    final hasActions = markActionItems.isNotEmpty && !widget.topicConfig.showActionTimeButton;

    // TimelineListItem リスト全体を走査して各 CardItem の Y オフセットを計算
    // DateSeparatorItem は _dateSeparatorHeight 分を累積に加算する
    final cardYOffsets = <double>[];
    final cardHeightList = <double>[];
    final gapAfterItem = <double>[];
    var cumulative = 0.0;

    // CardItem のインデックスを追跡しながら TimelineListItem を走査
    var cardIndex = 0;
    for (var k = 0; k < timelineItems.length; k++) {
      final tlItem = timelineItems[k];
      switch (tlItem) {
        case DateSeparatorItem():
          cumulative += _dateSeparatorHeight;
        case CardItem(:final projection):
          cardYOffsets.add(cumulative);
          final isMark = projection.markLinkType == MarkOrLink.mark;
          final cardH = isMark
              ? (hasActions ? _cardHeight + _actionButtonsHeight : _cardHeight)
              : _linkCardHeight;
          cardHeightList.add(cardH);

          // Mark-Mark 直接隣接 → 大きめギャップ
          final nextCardIsMark = cardIndex + 1 < items.length &&
              items[cardIndex + 1].markLinkType == MarkOrLink.mark;
          final gap = (isMark && nextCardIsMark) ? _markMarkGap : _itemGap;
          gapAfterItem.add(gap);
          cumulative += cardH + gap;
          cardIndex++;
      }
    }

    // 縦線は始点・終点アイテムのドット中心 Y を始終端とする
    // ドット中心 = カード部分の中心（アクションボタン高は含まない）
    double dotCenterRelY(int k) {
      final isMark = items[k].markLinkType == MarkOrLink.mark;
      return cardYOffsets[k] + (isMark ? _cardHeight : _linkCardHeight) / 2;
    }

    final verticalLineStartRelY = dotCenterRelY(0);
    final verticalLineEndRelY = dotCenterRelY(items.length - 1);

    final spans = <SpanArrowData>[];
    final linkSegments = <LinkSegmentData>[];
    // スパンに含まれる Link のインデックス（単独表示の重複除外に使用）
    final coveredLinkIndices = <int>{};

    for (var i = 0; i < items.length; i++) {
      if (items[i].markLinkType != MarkOrLink.mark) continue;

      final spanCount = _buildSpanLinkCount(items, i);

      if (spanCount == 0) {
        // パターン1: Mark-Mark 直接隣接
        final j = i + 1;
        if (j < items.length && items[j].markLinkType == MarkOrLink.mark) {
          final meterDiffText = items[j].displayMeterDiff;
          if (meterDiffText != null) {
            spans.add(SpanArrowData(
              startY: cardYOffsets[i] + cardHeightList[i],
              endY: cardYOffsets[j],
              meterDiffText: meterDiffText,
            ));
          }
        }
      } else {
        // パターン2: Mark-Link*-Mark
        final endMarkIndex = i + spanCount + 1;
        if (endMarkIndex < items.length &&
            items[endMarkIndex].markLinkType == MarkOrLink.mark) {
          final meterDiffText = items[endMarkIndex].displayMeterDiff;
          if (meterDiffText != null) {
            // Link セグメントと区間距離テキストを収集
            final linkDistTexts = <String>[];
            for (var k = i + 1; k < endMarkIndex; k++) {
              if (items[k].markLinkType == MarkOrLink.link) {
                coveredLinkIndices.add(k);
                linkSegments.add(LinkSegmentData(
                  startY: cardYOffsets[k],
                  endY: cardYOffsets[k] + _linkCardHeight,
                ));
                final dist = items[k].displayDistanceValue;
                if (dist != null) linkDistTexts.add(dist);
              }
            }
            spans.add(SpanArrowData(
              startY: cardYOffsets[i] + cardHeightList[i],
              endY: cardYOffsets[endMarkIndex],
              meterDiffText: meterDiffText,
              linkDistanceTexts: linkDistTexts,
            ));
          }
        }
      }
    }

    // スパンに含まれない Link（先頭・末尾・孤立）の Emerald 線・スパン列線・距離テキストを収集
    final standaloneLinkDistances = <(double, String)>[];
    final standaloneLinkLines = <(double, double)>[];
    for (var k = 0; k < items.length; k++) {
      if (items[k].markLinkType != MarkOrLink.link) continue;
      if (coveredLinkIndices.contains(k)) continue;
      // Emerald グラデーション縦線（スパン内 Link と同じ描画）
      linkSegments.add(LinkSegmentData(
        startY: cardYOffsets[k],
        endY: cardYOffsets[k] + _linkCardHeight,
      ));
      // スパン列縦線（矢印なし・区間の存在を示す）
      standaloneLinkLines.add((cardYOffsets[k], cardYOffsets[k] + _linkCardHeight));
      final dist = items[k].displayDistanceValue;
      if (dist != null) {
        standaloneLinkDistances.add((cardYOffsets[k] + _linkCardHeight / 2, dist));
      }
    }

    return _TimelineData(
      spans: spans,
      linkSegments: linkSegments,
      gapAfterItem: gapAfterItem,
      verticalLineStartRelY: verticalLineStartRelY,
      verticalLineEndRelY: verticalLineEndRelY,
      standaloneLinkDistances: standaloneLinkDistances,
      standaloneLinkLines: standaloneLinkLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    final projection = widget.projection;
    final markActionItems = widget.markActionItems;

    if (projection.items.isEmpty) {
      return Scaffold(
        body: const Center(child: Text('地点/区間がありません')),
        floatingActionButton: widget.topicConfig.addMenuItems.isEmpty
            ? null
            : FloatingActionButton(
                key: const Key('michiInfo_fab_add'),
                onPressed: () => context
                    .read<MichiInfoBloc>()
                    .add(const MichiInfoInsertModeFabPressed()),
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                child: Icon(
                  widget.isInsertMode ? Icons.close : Icons.add,
                ),
              ),
      );
    }

    final items = projection.items;
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final timelineListItems = _buildTimelineListItems(items, widget.isInsertMode);
    final timelineData = _buildTimelineData(timelineListItems, markActionItems);

    return Scaffold(
      body: Stack(
        children: [
          // 背景レイヤー: 縦線全体 + スパン矢印 + 距離テキスト
          // InsertMode 中はインジケーター挿入でY座標がずれるため非表示
          // top: 48 でタブ/凡例領域へのはみ出しを防ぎ、ClipRect でさらに安全にクリップ
          if (!widget.isInsertMode)
            Positioned.fill(
              top: 48,
              child: ClipRect(
                child: CustomPaint(
                  key: const Key('michiInfo_canvas_timeline'),
                  painter: _MichiTimelineCanvas(
                    spans: timelineData.spans,
                    linkSegments: timelineData.linkSegments,
                    standaloneLinkDistances: timelineData.standaloneLinkDistances,
                    standaloneLinkLines: timelineData.standaloneLinkLines,
                    verticalLineStartRelY: timelineData.verticalLineStartRelY,
                    verticalLineEndRelY: timelineData.verticalLineEndRelY,
                    scrollOffset: scrollOffset,
                  ),
                ),
              ),
            ),
          // メインスクロールビュー
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 48, bottom: 80),
                sliver: widget.isInsertMode
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // index 0 は先頭インジケーター（insertAfterSeq: -1）
                            // index 1 → items[0]
                            // index 2 → インジケーター（insertAfterSeq = items[0].markLinkSeq）
                            // ...
                            if (index == 0) {
                              return const _InsertIndicator(insertAfterSeq: -1);
                            }
                            final isIndicator = index.isEven;
                            if (isIndicator) {
                              final itemIndex = index ~/ 2 - 1;
                              return _InsertIndicator(
                                insertAfterSeq: items[itemIndex].markLinkSeq,
                              );
                            } else {
                              final itemIndex = index ~/ 2;
                              final item = items[itemIndex];
                              // InsertMode では Mark-Mark 間にインジケーターが挿入されるため
                              // スパン矢印表示用の大きめギャップ(_markMarkGap)は不要。
                              // Linkがない区間でも常に _itemGap を使用する。
                              final rawGap = timelineData.gapAfterItem[itemIndex];
                              final insertModeGap = rawGap > _itemGap ? _itemGap : rawGap;
                              return _TimelineItem(
                                item: item,
                                gapAfter: insertModeGap,
                                onTap: () => context.read<MichiInfoBloc>().add(
                                      MichiInfoItemTapped(
                                        markLinkId: item.id,
                                        type: item.markLinkType,
                                      ),
                                    ),
                                markActionItems: markActionItems,
                                markActionStateLabels:
                                    widget.markActionStateLabels,
                                topicConfig: widget.topicConfig,
                                eventId: widget.eventId,
                                isInsertMode: true,
                              );
                            }
                          },
                          // childCount = items.length * 2 + 1
                          // index 0: 先頭インジケーター（insertAfterSeq: -1）、index 1: items[0]、index 2: インジケーター、...
                          childCount: items.length * 2 + 1,
                        ),
                      )
                    : _buildNormalSliverList(
                        context: context,
                        timelineListItems: timelineListItems,
                        timelineData: timelineData,
                        markActionItems: markActionItems,
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
      floatingActionButton: widget.topicConfig.addMenuItems.isEmpty
          ? null
          : FloatingActionButton(
              key: const Key('michiInfo_fab_add'),
              onPressed: () => context
                  .read<MichiInfoBloc>()
                  .add(const MichiInfoInsertModeFabPressed()),
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              child: Icon(
                widget.isInsertMode ? Icons.close : Icons.add,
              ),
            ),
    );
  }

  /// 通常モード（isInsertMode == false）の SliverList を構築する。
  /// DateSeparatorItem と CardItem を混在したリストを描画する。
  Widget _buildNormalSliverList({
    required BuildContext context,
    required List<TimelineListItem> timelineListItems,
    required _TimelineData timelineData,
    required List<ActionItemProjection> markActionItems,
  }) {
    // DateSeparatorItem のインデックス（出現順）を採番するためにカウンターを事前計算
    // SliverChildBuilderDelegate は index ごとに呼ばれるため、
    // 各 index が DateSeparatorItem かどうかと、その出現番号を知る必要がある。
    // 事前に DateSeparatorItem の出現番号リストを作成しておく。
    var separatorCount = 0;
    final separatorIndexAt = <int, int>{};
    var cardCount = 0;
    final cardIndexAt = <int, int>{};
    for (var i = 0; i < timelineListItems.length; i++) {
      switch (timelineListItems[i]) {
        case DateSeparatorItem():
          separatorIndexAt[i] = separatorCount;
          separatorCount++;
        case CardItem():
          cardIndexAt[i] = cardCount;
          cardCount++;
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tlItem = timelineListItems[index];
          switch (tlItem) {
            case DateSeparatorItem(:final dateLabel):
              final separatorIndex = separatorIndexAt[index]!;
              return DateSeparatorWidget(
                key: Key('michiInfo_dateSeparator_$separatorIndex'),
                dateLabel: dateLabel,
              );
            case CardItem(:final projection):
              final cardItemIndex = cardIndexAt[index]!;
              return _TimelineItem(
                item: projection,
                gapAfter: timelineData.gapAfterItem[cardItemIndex],
                onTap: () => context.read<MichiInfoBloc>().add(
                      MichiInfoItemTapped(
                        markLinkId: projection.id,
                        type: projection.markLinkType,
                      ),
                    ),
                markActionItems: markActionItems,
                markActionStateLabels: widget.markActionStateLabels,
                topicConfig: widget.topicConfig,
                eventId: widget.eventId,
              );
          }
        },
        childCount: timelineListItems.length,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// _MichiTimelineCanvas（全体縦線 + スパン矢印 CustomPainter）
// ────────────────────────────────────────────────────────

class _MichiTimelineCanvas extends CustomPainter {
  final List<SpanArrowData> spans;
  final List<LinkSegmentData> linkSegments;
  final List<(double, String)> standaloneLinkDistances;
  final List<(double, double)> standaloneLinkLines;
  final double verticalLineStartRelY;
  final double verticalLineEndRelY;
  final double scrollOffset;

  static const double _axisX = 20.0;
  static const double _thickLineWidth = 6.0;
  static const double _arrowHeadSize = 6.0;
  static const double _arrowStrokeWidth = 1.5;
  // canvas は Positioned.fill(top: 48) で配置されるため、
  // リスト相対 Y と canvas Y のオフセットは 0（scrollOffset のみ考慮）
  static const double _topPadding = 0.0;

  const _MichiTimelineCanvas({
    required this.spans,
    required this.linkSegments,
    required this.standaloneLinkDistances,
    required this.standaloneLinkLines,
    required this.verticalLineStartRelY,
    required this.verticalLineEndRelY,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── 1. 道路帯（グレー角丸帯 + 白破線センターライン）UI-14 ──────
    if (verticalLineEndRelY > verticalLineStartRelY) {
      final roadStartY = _topPadding + verticalLineStartRelY - scrollOffset;
      final roadEndY = _topPadding + verticalLineEndRelY - scrollOffset;

      // 1-a. グレー道路帯（drawRRect）
      final roadRect = Rect.fromLTRB(
        _axisX - _roadBandHalfWidth,
        roadStartY,
        _axisX + _roadBandHalfWidth,
        roadEndY,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(roadRect, const Radius.circular(_roadBandRadius)),
        Paint()..color = _roadBandColor,
      );

      // 1-b. 白破線センターライン（drawLine ループ）
      final dashPaint = Paint()
        ..color = _centerLineColor
        ..strokeWidth = _centerLineWidth
        ..strokeCap = StrokeCap.butt;

      var y = roadStartY;
      while (y < roadEndY) {
        final segEnd = (y + _dashOn).clamp(y, roadEndY);
        canvas.drawLine(Offset(_axisX, y), Offset(_axisX, segEnd), dashPaint);
        y += _dashOn + _dashOff;
      }
    }

    // ── 2. Emerald グラデーション縦線（Link カード区間）─────────
    for (final seg in linkSegments) {
      final segStartY = _topPadding + seg.startY - scrollOffset;
      final segEndY = _topPadding + seg.endY - scrollOffset;
      if (segEndY < 0 || segStartY > size.height) continue;

      final lineRect = Rect.fromLTWH(
        _axisX - _thickLineWidth / 2,
        segStartY,
        _thickLineWidth,
        segEndY - segStartY,
      );
      canvas.drawRect(
        lineRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [_linkPrimaryColor, _linkDarkColor],
          ).createShader(lineRect),
      );
    }

    // ── 3. スパン矢印（Mark 底辺 → Mark 上辺）+ メーター差分テキスト ─
    final arrowX = size.width - _spanArrowColumnWidth + 8.0;
    final textX = arrowX + _arrowHeadSize + 4.0;
    final textMaxWidth = size.width - textX - 2.0;

    final arrowPaint = Paint()
      ..color = _markPrimaryColor
      ..strokeWidth = _arrowStrokeWidth
      ..strokeCap = StrokeCap.round;

    for (final span in spans) {
      final drawStartY = span.startY - scrollOffset + _topPadding;
      final drawEndY = span.endY - scrollOffset + _topPadding;
      if (drawEndY < 0 || drawStartY > size.height) continue;

      // 縦線
      canvas.drawLine(
        Offset(arrowX, drawStartY),
        Offset(arrowX, drawEndY),
        arrowPaint,
      );

      // 上向き矢印頭（スパン開始 = start Mark 底辺）
      canvas.drawLine(
        Offset(arrowX, drawStartY),
        Offset(arrowX - _arrowHeadSize / 2, drawStartY + _arrowHeadSize),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(arrowX, drawStartY),
        Offset(arrowX + _arrowHeadSize / 2, drawStartY + _arrowHeadSize),
        arrowPaint,
      );

      // 下向き矢印頭（スパン終了 = end Mark 上辺）
      canvas.drawLine(
        Offset(arrowX, drawEndY),
        Offset(arrowX - _arrowHeadSize / 2, drawEndY - _arrowHeadSize),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(arrowX, drawEndY),
        Offset(arrowX + _arrowHeadSize / 2, drawEndY - _arrowHeadSize),
        arrowPaint,
      );

      // メーター差分 + 区間距離を 1 つのテキストブロックにまとめてスパン縦中央に配置
      final children = <InlineSpan>[
        TextSpan(
          text: span.meterDiffText,
          style: const TextStyle(
            fontSize: 11,
            color: _markPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        for (final dist in span.linkDistanceTexts) ...[
          const TextSpan(text: '\n'),
          TextSpan(
            text: dist,
            style: const TextStyle(
              fontSize: 11,
              color: _linkPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ];
      final combinedPainter = TextPainter(
        text: TextSpan(children: children),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: textMaxWidth);
      final midY = (drawStartY + drawEndY) / 2;
      combinedPainter.paint(
        canvas,
        Offset(textX, midY - combinedPainter.height / 2),
      );
    }

    // ── 4. スパン外 Link の単独区間距離テキスト ─────────────────
    for (final (centerRelY, text) in standaloneLinkDistances) {
      final drawCenterY = _topPadding + centerRelY - scrollOffset;
      if (drawCenterY < -20 || drawCenterY > size.height + 20) continue;

      final standalonePainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 11,
            color: _linkPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: textMaxWidth);
      standalonePainter.paint(
        canvas,
        Offset(textX, drawCenterY - standalonePainter.height / 2),
      );
    }

    // ── 5. スパン外 Link のスパン列縦線（矢印あり）─────────────
    final standaloneLinkPaint = Paint()
      ..color = _linkPrimaryColor
      ..strokeWidth = _arrowStrokeWidth
      ..strokeCap = StrokeCap.round;
    for (final (startRelY, endRelY) in standaloneLinkLines) {
      final drawStartY = _topPadding + startRelY - scrollOffset;
      final drawEndY = _topPadding + endRelY - scrollOffset;
      if (drawEndY < 0 || drawStartY > size.height) continue;
      // 縦線
      canvas.drawLine(
        Offset(arrowX, drawStartY),
        Offset(arrowX, drawEndY),
        standaloneLinkPaint,
      );
      // 上向き矢印頭
      canvas.drawLine(
        Offset(arrowX, drawStartY),
        Offset(arrowX - _arrowHeadSize / 2, drawStartY + _arrowHeadSize),
        standaloneLinkPaint,
      );
      canvas.drawLine(
        Offset(arrowX, drawStartY),
        Offset(arrowX + _arrowHeadSize / 2, drawStartY + _arrowHeadSize),
        standaloneLinkPaint,
      );
      // 下向き矢印頭
      canvas.drawLine(
        Offset(arrowX, drawEndY),
        Offset(arrowX - _arrowHeadSize / 2, drawEndY - _arrowHeadSize),
        standaloneLinkPaint,
      );
      canvas.drawLine(
        Offset(arrowX, drawEndY),
        Offset(arrowX + _arrowHeadSize / 2, drawEndY - _arrowHeadSize),
        standaloneLinkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MichiTimelineCanvas old) =>
      spans != old.spans ||
      linkSegments != old.linkSegments ||
      standaloneLinkDistances != old.standaloneLinkDistances ||
      standaloneLinkLines != old.standaloneLinkLines ||
      verticalLineStartRelY != old.verticalLineStartRelY ||
      verticalLineEndRelY != old.verticalLineEndRelY ||
      scrollOffset != old.scrollOffset;
}

// ────────────────────────────────────────────────────────
// _TimelineItem
// ────────────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  final MarkLinkItemProjection item;
  final double gapAfter;
  final VoidCallback onTap;
  final List<ActionItemProjection> markActionItems;
  final Map<String, String> markActionStateLabels;
  final TopicConfig topicConfig;
  final String eventId;
  final bool isInsertMode;

  const _TimelineItem({
    required this.item,
    required this.gapAfter,
    required this.onTap,
    required this.markActionItems,
    required this.markActionStateLabels,
    required this.topicConfig,
    required this.eventId,
    this.isInsertMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMark = item.markLinkType == MarkOrLink.mark;
    // visitWork（showActionTimeButton == true）は中央カラムにアクションボタンを埋め込むため
    // _MarkActionButtons（カード下部のボタン群）は表示しない
    final hasActionButtons = isMark && markActionItems.isNotEmpty && !topicConfig.showActionTimeButton;
    final rowHeight = isMark ? _cardHeight : _linkCardHeight;

    final itemKey = isMark
        ? Key('michiInfo_item_mark_${item.id}')
        : Key('michiInfo_item_link_${item.id}');

    return Column(
      key: itemKey,
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
                          isFuel: item.isFuel,
                          isDone: item.isDone,
                        ),
                      ),
                    ),
                    // テキスト・タップ領域オーバーレイ
                    Positioned.fill(
                      child: _TimelineItemOverlay(
                        item: item,
                        onTap: onTap,
                        isMark: isMark,
                        currentStateLabel: markActionStateLabels[item.id],
                        topicConfig: topicConfig,
                        eventId: eventId,
                        isInsertMode: isInsertMode,
                      ),
                    ),
                  ],
                ),
              ),
              // Link 行のみスパン列スペース確保（Mark は右端まで拡張のためスペース不要）
              if (!isMark) const SizedBox(width: _spanArrowColumnWidth),
            ],
          ),
        ),
        // 地点アクションボタン
        if (hasActionButtons)
          _MarkActionButtons(
            markLinkId: item.id,
            actions: markActionItems,
          ),
        // カード間の隙間（Mark-Mark 直接隣接時は大きめ）
        SizedBox(height: gapAfter),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────
// _MichiTimelinePainter v4.1（縦線描画なし・カード+ドットのみ）
// ────────────────────────────────────────────────────────

class _MichiTimelinePainter extends CustomPainter {
  /// タイムライン軸の中心 X 座標
  static const double _axisX = 20.0;

  /// カード左端 X 座標
  static const double _cardLeft = 40.0;

  /// Mark カード右端余白（右端まで拡張）
  static const double _markCardRight = 0.0;

  /// Link カード右端余白
  static const double _linkCardRight = 8.0;

  /// 水平接続線の長さ（axisX からカード左端まで）
  static const double _connectorLength = 20.0;

  // Mark ドット
  static const double _markDotRadius = 10.0;
  static const double _markDotRingWidth = 3.0;

  // Link ドット
  static const double _linkDotSize = 14.0;
  static const double _linkDotCorner = 4.0;

  // カード角丸
  static const double _markCornerRadius = 16.0;
  static const double _linkCornerRadius = 8.0;

  // 完了ドット色（Gray 400）
  static const Color _doneDotColor = Color(0xFF9CA3AF);
  // 完了接続線色（Gray 300）
  static const Color _doneConnectorColor = Color(0xFFD1D5DB);

  final MarkOrLink markLinkType;
  final bool isFuel;
  final bool isDone;

  const _MichiTimelinePainter({
    required this.markLinkType,
    this.isFuel = false,
    this.isDone = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final isMark = markLinkType == MarkOrLink.mark;

    // 縦線は _MichiTimelineCanvas が全体を通して描画するため、ここでは描画しない

    // ── 1. カード背景 ──────────────────────────────────────
    final cardCornerRadius = isMark ? _markCornerRadius : _linkCornerRadius;
    final cardRight = isMark ? _markCardRight : _linkCardRight;
    final cardRect = Rect.fromLTWH(
      _cardLeft,
      0,
      size.width - _cardLeft - cardRight,
      size.height,
    );
    final rrect = RRect.fromRectAndRadius(
      cardRect,
      Radius.circular(cardCornerRadius),
    );

    // 完了ビジュアル色定数（F-10）
    const doneCardBg = Color(0xFFF9FAFB); // Gray 50
    const doneCardBorder = Color(0xFFD1D5DB); // Gray 300
    const doneTopLineColor = Color(0xFF9CA3AF); // Gray 400

    // Mark カード: ドロップシャドウ
    if (isMark) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          cardRect.translate(0, 2),
          Radius.circular(cardCornerRadius),
        ),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
      );
    }

    // カード塗り
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = isMark
            ? (isDone ? doneCardBg : Colors.white)
            : _linkTintLightColor
        ..style = PaintingStyle.fill,
    );

    // カードボーダー
    if (isMark) {
      // 上辺 3dp カラーライン（isDone: Gray / 通常: Teal）
      final topLineColor = isDone ? doneTopLineColor : _markPrimaryColor;
      final topPath = Path()
        ..moveTo(cardRect.left, cardRect.top + cardCornerRadius)
        ..arcToPoint(
          Offset(cardRect.left + cardCornerRadius, cardRect.top),
          radius: Radius.circular(cardCornerRadius),
        )
        ..lineTo(cardRect.right - cardCornerRadius, cardRect.top)
        ..arcToPoint(
          Offset(cardRect.right, cardRect.top + cardCornerRadius),
          radius: Radius.circular(cardCornerRadius),
        );
      canvas.drawPath(
        topPath,
        Paint()
          ..color = topLineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round,
      );
      // isDone: 全辺グレーボーダー追加
      if (isDone) {
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = doneCardBorder
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }
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

    // ── 2. 水平接続線（axisX → cardLeft）────────────────────
    final connectorColor = isDone
        ? _doneConnectorColor
        : (isMark ? _markPrimaryColor : _linkPrimaryColor.withValues(alpha: 0.55));
    canvas.drawLine(
      Offset(_axisX, centerY),
      Offset(_axisX + _connectorLength, centerY),
      Paint()
        ..color = connectorColor
        ..strokeWidth = isMark ? 2.0 : 1.5
        ..strokeCap = StrokeCap.round,
    );

    // ── 3. ドット ─────────────────────────────────────────
    if (isMark) {
      if (isFuel) {
        // 給油あり: 縦長ドット（拡大）+ アイコン内包
        final dotWidth = _markDotRadius * 2;
        final dotHeight = _markDotRadius * 2 + _actionButtonsHeight;
        final fuelDotRect = Rect.fromCenter(
          center: Offset(_axisX, centerY),
          width: dotWidth,
          height: dotHeight,
        );
        // 白リング（背景との分離）
        final ringRect = Rect.fromCenter(
          center: Offset(_axisX, centerY),
          width: dotWidth + _markDotRingWidth * 2,
          height: dotHeight + _markDotRingWidth * 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            ringRect,
            Radius.circular(dotWidth / 2),
          ),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        // Teal 角丸縦長ドット
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            fuelDotRect,
            Radius.circular(dotWidth / 2),
          ),
          Paint()
            ..color = _markPrimaryColor
            ..style = PaintingStyle.fill,
        );
        // 給油アイコン（TextPainter で描画）
        final iconPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(Icons.local_gas_station.codePoint),
            style: TextStyle(
              fontSize: 14,
              fontFamily: Icons.local_gas_station.fontFamily,
              package: Icons.local_gas_station.fontPackage,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        iconPainter.paint(
          canvas,
          Offset(
            _axisX - iconPainter.width / 2,
            centerY - iconPainter.height / 2,
          ),
        );
      } else if (isDone) {
        // 完了: 白リング + Gray 円ドット + 白チェックマーク
        canvas.drawCircle(
          Offset(_axisX, centerY),
          _markDotRadius + _markDotRingWidth,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(_axisX, centerY),
          _markDotRadius,
          Paint()
            ..color = _doneDotColor
            ..style = PaintingStyle.fill,
        );
        // 白色チェックマーク（✓）
        final checkPainter = TextPainter(
          text: const TextSpan(
            text: '✓',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        checkPainter.paint(
          canvas,
          Offset(
            _axisX - checkPainter.width / 2,
            centerY - checkPainter.height / 2,
          ),
        );
      } else {
        // 給油なし（従来通り）: 白リング + Teal 円ドット
        canvas.drawCircle(
          Offset(_axisX, centerY),
          _markDotRadius + _markDotRingWidth,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(_axisX, centerY),
          _markDotRadius,
          Paint()
            ..color = _markPrimaryColor
            ..style = PaintingStyle.fill,
        );
      }
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

  @override
  bool shouldRepaint(_MichiTimelinePainter old) =>
      markLinkType != old.markLinkType ||
      isFuel != old.isFuel ||
      isDone != old.isDone;
}

// ────────────────────────────────────────────────────────
// _TimelineItemOverlay
// ────────────────────────────────────────────────────────

// Violet カラー（ActionTime ボタン・バッジ用）
const Color _violetColor = Color(0xFF7C3AED);
const Color _violetBadgeBg = Color(0x197C3AED);

class _TimelineItemOverlay extends StatefulWidget {
  final MarkLinkItemProjection item;
  final VoidCallback onTap;
  final bool isMark;

  /// markActionStateLabels[item.id]。null の場合はデフォルト「滞留中」を表示する。
  final String? currentStateLabel;

  final TopicConfig topicConfig;
  final String eventId;
  final bool isInsertMode;

  static const double _cardLeft = 40.0;

  const _TimelineItemOverlay({
    required this.item,
    required this.onTap,
    required this.isMark,
    required this.currentStateLabel,
    required this.topicConfig,
    required this.eventId,
    this.isInsertMode = false,
  });

  @override
  State<_TimelineItemOverlay> createState() => _TimelineItemOverlayState();
}

class _TimelineItemOverlayState extends State<_TimelineItemOverlay> {
  /// メンバーリストを表示用文字列に変換する。
  /// 0名: null（非表示）、1名: 「田中」、2名: 「田中・鈴木」、
  /// 3名以上: 「田中・鈴木 +N人」（先頭2名＋残数）
  String? _buildMembersText(List<MemberItemProjection> members) {
    if (members.isEmpty) return null;
    if (members.length == 1) return members[0].memberName;
    if (members.length == 2) {
      return '${members[0].memberName}・${members[1].memberName}';
    }
    final rest = members.length - 2;
    return '${members[0].memberName}・${members[1].memberName} +$rest人';
  }

  Future<void> _onDeleteTapped() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        key: const Key('deleteConfirmDialog_dialog_confirm'),
        title: const Text('削除しますか？'),
        content: const Text('この操作は取り消せません。'),
        actions: [
          CupertinoDialogAction(
            key: const Key('deleteConfirmDialog_button_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('キャンセル'),
          ),
          CupertinoDialogAction(
            key: const Key('deleteConfirmDialog_button_delete'),
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    context
        .read<MichiInfoBloc>()
        .add(MichiInfoCardDeleteRequested(widget.item.id));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isMark = widget.isMark;
    final topicConfig = widget.topicConfig;
    final eventId = widget.eventId;
    final isInsertMode = widget.isInsertMode;
    final currentStateLabel = widget.currentStateLabel;
    final name =
        item.markLinkName.isEmpty ? '（名称未設定）' : item.markLinkName;
    final leftPadding = _TimelineItemOverlay._cardLeft + 8.0;
    final verticalPadding = isMark ? 8.0 : 4.0;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.only(
          left: leftPadding,
          right: 12,
          top: verticalPadding,
          bottom: verticalPadding,
        ),
        child: isMark && topicConfig.showActionTimeButton
            ? _buildVisitWorkCardRow(
                context: context,
                item: item,
                name: name,
                topicConfig: topicConfig,
                currentStateLabel: currentStateLabel,
                eventId: eventId,
                isInsertMode: isInsertMode,
              )
            : Row(
                children: [
                  Expanded(
                    child: isMark
                        ? _buildMarkCardContent(
                            context: context,
                            item: item,
                            name: name,
                            topicConfig: topicConfig,
                            currentStateLabel: currentStateLabel,
                          )
                        : _buildLinkCardContent(
                            context: context,
                            item: item,
                            name: name,
                            topicConfig: topicConfig,
                          ),
                  ),
                  // 完了バッジ（F-10: isDone=true かつ Markのみ表示）
                  if (isMark && item.isDone)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        key: Key('michiInfo_badge_done_${item.id}'),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6), // Gray 100
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB), // Gray 300
                            width: 1.0,
                          ),
                        ),
                        child: const Text(
                          '✓ 完了',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280), // Gray 500
                          ),
                        ),
                      ),
                    ),
                  // 削除アイコン（挿入モード中は非表示）
                  if (!isInsertMode)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: GestureDetector(
                        onTap: _onDeleteTapped,
                        child: Container(
                          key: Key('michiInfo_button_delete_${item.id}'),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  /// visitWork トピック用の3カラム Row を構築する。
  ///
  /// 左カラム（54dp）: 日付テキスト + 状態バッジ
  /// 中央カラム（Expanded）: 地点名テキスト + アクションボタン
  /// 右カラム（28dp）: 削除ボタン（Opacity 0.6）
  Widget _buildVisitWorkCardRow({
    required BuildContext context,
    required MarkLinkItemProjection item,
    required String name,
    required TopicConfig topicConfig,
    required String? currentStateLabel,
    required String eventId,
    required bool isInsertMode,
  }) {
    // F-10 完了ビジュアル色
    final isDone = item.isDone;
    const doneNameColor = Color(0xFF9CA3AF); // Gray 400
    const doneSecondaryColor = Color(0xFFADB5BD);
    final nameColor = isDone ? doneNameColor : const Color(0xFF1A1A2E);
    final dateColor = isDone ? doneSecondaryColor : const Color(0xFF6B7280);
    final nameDecoration = isDone ? TextDecoration.lineThrough : TextDecoration.none;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左カラム（54dp固定）: 日付 + 状態バッジ
        SizedBox(
          width: 54,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (topicConfig.showMarkDate)
                Text(
                  key: Key('michiInfo_text_markDate_${item.id}'),
                  item.displayDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: dateColor,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              _ActionStateBadge(
                label: currentStateLabel ?? '滞留中',
                markId: item.id,
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        // 中央カラム（Expanded）: 地点名 + アクションボタン
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: nameColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      decoration: nameDecoration,
                      decorationColor: doneNameColor,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              _VisitWorkActionButton(
                markLinkId: item.id,
                onPressed: () => context.read<MichiInfoBloc>().add(
                      MichiInfoActionButtonPressed(
                        markLinkId: item.id,
                        eventId: eventId,
                        topicConfig: topicConfig,
                        markOrLink: MarkOrLink.mark,
                      ),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        // 右カラム（28dp固定）: 削除ボタン（挿入モード中は非表示）
        if (!isInsertMode)
          SizedBox(
            width: 28,
            child: Opacity(
              opacity: 0.6,
              child: GestureDetector(
                onTap: _onDeleteTapped,
                child: Container(
                  key: Key('michiInfo_button_delete_${item.id}'),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6), // Gray 100
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete,
                    size: 14,
                    color: Color(0xFF9CA3AF), // Gray 400
                  ),
                ),
              ),
            ),
          ),
        if (isInsertMode) const SizedBox(width: 28),
      ],
    );
  }

    /// Mark（地点）カードのコンテンツColumnを構築する。
  ///
  /// レイアウト（Specセクション5）:
  /// - showNameField=false（movingCost系）: 日付（最上段）→ 累積メーター・メンバー行
  /// - showNameField=true（travelExpense）: 名称（最上段）→ 日付行 → 累積メーター・メンバー行
  Widget _buildMarkCardContent({
    required BuildContext context,
    required MarkLinkItemProjection item,
    required String name,
    required TopicConfig topicConfig,
    required String? currentStateLabel,
  }) {
    final membersText = topicConfig.showMarkMembers
        ? _buildMembersText(item.members)
        : null;

    // F-10 完了ビジュアル色
    final isDone = item.isDone;
    const doneNameColor = Color(0xFF9CA3AF); // Gray 400
    const doneSecondaryColor = Color(0xFFADB5BD); // Gray 400 lighter
    final nameColor = isDone ? doneNameColor : const Color(0xFF1A1A2E);
    final dateColor = isDone ? doneSecondaryColor : const Color(0xFF6B7280);
    final membersColor = isDone ? doneSecondaryColor : const Color(0xFF6B7280);
    final meterColor = isDone ? doneSecondaryColor : _markPrimaryColor;
    final nameDecoration = isDone ? TextDecoration.lineThrough : TextDecoration.none;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // showNameField=false の場合: 日付を最上段に表示
        if (!topicConfig.showNameField && topicConfig.showMarkDate)
          Flexible(
            child: Text(
              key: Key('michiInfo_text_markDate_${item.id}'),
              item.displayDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: dateColor,
                    fontWeight: FontWeight.w500,
                    decoration: nameDecoration,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // showNameField=true の場合: 名称を最上段に表示
        if (topicConfig.showNameField)
          Flexible(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: nameColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    decoration: nameDecoration,
                    decorationColor: doneNameColor,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // showNameField=true かつ showMarkDate=true の場合: 日付を名称の下に表示
        if (topicConfig.showNameField && topicConfig.showMarkDate)
          Flexible(
            child: Text(
              key: Key('michiInfo_text_markDate_${item.id}'),
              item.displayDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: dateColor,
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // 累積メーター・メンバー行
        if (item.displayMeterValue != null || membersText != null)
          Row(
            children: [
              if (item.displayMeterValue != null)
                Text(
                  item.displayMeterValue!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: meterColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              if (item.displayMeterValue != null && membersText != null)
                const SizedBox(width: 6),
              if (membersText != null)
                Flexible(
                  child: Text(
                    key: Key('michiInfo_text_markMembers_${item.id}'),
                    membersText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: membersColor,
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        // 状態バッジは visitWork（showActionTimeButton == true）の場合は
        // _buildVisitWorkCardRow の左カラムに配置されるため、ここでは表示しない。
        // visitWork 以外のトピックで showActionTimeButton == true になることは
        // 現状ないため、このブロック全体が非表示になることはない。
      ],
    );
  }

  /// Link（区間）カードのコンテンツColumnを構築する。
  ///
  /// レイアウト（Specセクション5）:
  /// - 日付テキスト（showLinkDate=true の場合）
  /// - 名称テキスト（showNameField=true の場合）
  /// - 区間距離テキスト（showLinkDistance=true かつ displayDistanceValue!=null の場合）
  Widget _buildLinkCardContent({
    required BuildContext context,
    required MarkLinkItemProjection item,
    required String name,
    required TopicConfig topicConfig,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 日付テキスト（showLinkDate=true の場合）
        if (topicConfig.showLinkDate)
          Flexible(
            child: Text(
              key: Key('michiInfo_text_linkDate_${item.id}'),
              item.displayDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // 名称テキスト（showNameField=true の場合）
        if (topicConfig.showNameField)
          Flexible(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // 区間距離テキスト（showLinkDistance=true かつ displayDistanceValue!=null の場合）
        if (topicConfig.showLinkDistance &&
            item.displayDistanceValue != null)
          Flexible(
            child: Text(
              key: Key('michiInfo_text_linkDistance_${item.id}'),
              item.displayDistanceValue!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: _linkPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────
// _VisitWorkActionButton（⚡ + テキスト アクションボタン）
// ────────────────────────────────────────────────────────

class _VisitWorkActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String markLinkId;

  const _VisitWorkActionButton({
    required this.onPressed,
    required this.markLinkId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        key: Key('michiInfo_button_actionTime_$markLinkId'),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _violetColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bolt,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              'アクション',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// _ActionStateBadge（状態バッジ）
// ────────────────────────────────────────────────────────

class _ActionStateBadge extends StatelessWidget {
  final String label;
  final String markId;

  const _ActionStateBadge({required this.label, required this.markId});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('michiInfo_badge_actionState_$markId'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _violetBadgeBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: _violetColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
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
            .map((action) => ElevatedButton(
                  onPressed: () => context.read<MichiInfoBloc>().add(
                        MichiInfoMarkActionPressed(
                          markLinkId: markLinkId,
                          actionId: action.id,
                        ),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A6A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
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
            'メーター差分',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: _markPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '区間距離',
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

// ────────────────────────────────────────────────────────
// _InsertIndicator（挿入モード時にカード間に表示するインジケーター）
// ────────────────────────────────────────────────────────

class _InsertIndicator extends StatelessWidget {
  final int insertAfterSeq;
  const _InsertIndicator({required this.insertAfterSeq});

  @override
  Widget build(BuildContext context) {
    final key = insertAfterSeq == -1
        ? const Key('michiInfo_button_insertIndicator_head')
        : Key('insert_indicator_$insertAfterSeq');
    return GestureDetector(
      key: key,
      onTap: () => context
          .read<MichiInfoBloc>()
          .add(MichiInfoInsertPointSelected(insertAfterSeq)),
      child: SizedBox(
        height: 36,
        child: Row(
          children: [
            Expanded(
              child: Divider(
                color: const Color(0x66F59E0B),
                thickness: 1.5,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x40F59E0B),
                    blurRadius: 8,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_circle,
                color: Color(0xFFF59E0B),
                size: 28,
              ),
            ),
            Expanded(
              child: Divider(
                color: const Color(0x66F59E0B),
                thickness: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// DateSeparatorWidget（日付区切りウィジェット）
// ────────────────────────────────────────────────────────

class DateSeparatorWidget extends StatelessWidget {
  /// 表示する日付テキスト（`yyyy/MM/dd`形式）
  final String dateLabel;

  const DateSeparatorWidget({
    super.key,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _dateSeparatorHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // 左横線
            const Expanded(
              child: Divider(
                color: Color(0xFFCBD5E1),
                thickness: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            // 日付バッジ
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFCBD5E1),
                  width: 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            // 右横線
            const Expanded(
              child: Divider(
                color: Color(0xFFCBD5E1),
                thickness: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
