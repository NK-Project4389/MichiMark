import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../adapter/event_detail_adapter.dart';
import '../../../adapter/mark_link_draft_adapter.dart';
import '../../../domain/action_time/action_time_log.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../features/event_detail/projection/michi_info_list_projection.dart';
import '../../../features/link_detail/draft/link_detail_draft.dart';
import '../../../features/mark_detail/draft/mark_detail_draft.dart';
import '../../../features/shared/projection/action_item_projection.dart';
import '../../../features/shared/projection/mark_link_item_projection.dart';
import '../../../repository/action_repository.dart';
import '../../../repository/event_repository.dart';
import '../draft/michi_info_draft.dart';
import 'michi_info_event.dart';
import 'michi_info_state.dart';

class MichiInfoBloc extends Bloc<MichiInfoEvent, MichiInfoState> {
  MichiInfoBloc({
    required EventRepository eventRepository,
    required ActionRepository actionRepository,
  })  : _eventRepository = eventRepository,
        _actionRepository = actionRepository,
        super(const MichiInfoLoading()) {
    on<MichiInfoStarted>(_onStarted);
    on<MichiInfoItemTapped>(_onItemTapped);
    on<MichiInfoAddMarkPressed>(_onAddMarkPressed);
    on<MichiInfoAddLinkPressed>(_onAddLinkPressed);
    on<MichiInfoMarkSaved>(_onMarkSaved);
    on<MichiInfoLinkSaved>(_onLinkSaved);
    on<MichiInfoTopicConfigUpdated>(_onTopicConfigUpdated);
    on<MichiInfoMarkActionPressed>(_onMarkActionPressed);
    on<MichiInfoDelegateConsumed>(_onDelegateConsumed);
  }

  final EventRepository _eventRepository;
  final ActionRepository _actionRepository;
  String _eventId = '';

  /// アクションマスタのキャッシュ（startedで一度取得して保持）
  List<ActionDomain> _cachedActions = [];

  Future<void> _onStarted(
    MichiInfoStarted event,
    Emitter<MichiInfoState> emit,
  ) async {
    _eventId = event.eventId;
    emit(const MichiInfoLoading());
    try {
      final domain = await _eventRepository.fetch(event.eventId);
      _cachedActions = await _actionRepository.fetchAll();
      final projection = EventDetailAdapter.toProjection(domain).michiInfo;
      emit(MichiInfoLoaded(
        projection: projection,
        draft: const MichiInfoDraft(),
      ));
    } on Exception catch (e) {
      emit(MichiInfoError(message: e.toString()));
    }
  }

  Future<void> _onItemTapped(
    MichiInfoItemTapped event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state is MichiInfoLoaded) {
      final current = state as MichiInfoLoaded;
      final delegate = switch (event.type) {
        MarkOrLink.mark => MichiInfoOpenMarkDelegate(
            eventId: _eventId,
            markLinkId: event.markLinkId,
            topicConfig: current.topicConfig,
          ),
        MarkOrLink.link => MichiInfoOpenLinkDelegate(
            eventId: _eventId,
            markLinkId: event.markLinkId,
            topicConfig: current.topicConfig,
          ),
      };
      emit(current.copyWith(delegate: delegate));
    }
  }

  Future<void> _onAddMarkPressed(
    MichiInfoAddMarkPressed event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state is! MichiInfoLoaded) return;
    final current = state as MichiInfoLoaded;

    try {
      final domain = await _eventRepository.fetch(_eventId);

      // markLinkSeq 昇順・論理削除除外でフィルタリング
      final activeMarkLinks = (List.of(domain.markLinks)
            ..sort((a, b) => a.markLinkSeq.compareTo(b.markLinkSeq)))
          .where((ml) => !ml.isDeleted)
          .toList();

      // 最後の Mark を前の地点として特定
      final markOnlyList = activeMarkLinks
          .where((ml) => ml.markLinkType == MarkOrLink.mark)
          .toList();
      final previousMark =
          markOnlyList.isNotEmpty ? markOnlyList.last : null;

      // REQ-MAD-001: メーター初期値
      final String initialMeterValueInput;
      if (previousMark != null) {
        final mv = previousMark.meterValue;
        initialMeterValueInput = mv != null ? mv.toString() : '';
      } else {
        final transMv = domain.trans?.meterValue;
        initialMeterValueInput = transMv != null ? transMv.toString() : '';
      }

      // REQ-MAD-002: メンバー初期値
      final List<MemberDomain> initialSelectedMembers =
          previousMark?.members ?? const [];

      // REQ-MAD-003: 日付初期値
      final DateTime? initialMarkLinkDate = previousMark?.markLinkDate;

      // REQ-MAD-004: イベントメンバー一覧
      final List<MemberDomain> eventMembers = domain.members;

      emit(current.copyWith(
        delegate: MichiInfoAddMarkDelegate(
          _eventId,
          current.topicConfig,
          initialMeterValueInput: initialMeterValueInput,
          initialSelectedMembers: initialSelectedMembers,
          initialMarkLinkDate: initialMarkLinkDate,
          eventMembers: eventMembers,
        ),
      ));
    } on Exception catch (e) {
      emit(MichiInfoError(message: e.toString()));
    }
  }

  Future<void> _onAddLinkPressed(
    MichiInfoAddLinkPressed event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state is MichiInfoLoaded) {
      final current = state as MichiInfoLoaded;
      emit(current.copyWith(
        delegate: MichiInfoAddLinkDelegate(_eventId, current.topicConfig),
      ));
    }
  }

  Future<void> _onMarkSaved(
    MichiInfoMarkSaved event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state case MichiInfoLoaded current) {
      final updated = _applyMarkDraft(
        current.projection,
        event.markLinkId,
        event.draft,
      );
      emit(current.copyWith(projection: updated));
    }
  }

  Future<void> _onLinkSaved(
    MichiInfoLinkSaved event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state case MichiInfoLoaded current) {
      final updated = _applyLinkDraft(
        current.projection,
        event.markLinkId,
        event.draft,
      );
      emit(current.copyWith(projection: updated));
    }
  }

  MichiInfoListProjection _applyMarkDraft(
    MichiInfoListProjection base,
    String markLinkId,
    MarkDetailDraft draft,
  ) {
    final items = List<MarkLinkItemProjection>.from(base.items);
    final existingIndex = items.indexWhere((item) => item.id == markLinkId);
    final seq = existingIndex >= 0
        ? items[existingIndex].markLinkSeq
        : (items.isEmpty ? 0 : items.map((i) => i.markLinkSeq).reduce((a, b) => a > b ? a : b) + 1);
    final newItem = MarkLinkDraftAdapter.fromMarkDraft(
      markLinkId: markLinkId,
      markLinkSeq: seq,
      draft: draft,
    );
    if (existingIndex >= 0) {
      items[existingIndex] = newItem;
    } else {
      items.add(newItem);
    }
    items.sort((a, b) => a.markLinkSeq.compareTo(b.markLinkSeq));
    return MichiInfoListProjection(items: _recalcMeterDiff(items));
  }

  MichiInfoListProjection _applyLinkDraft(
    MichiInfoListProjection base,
    String markLinkId,
    LinkDetailDraft draft,
  ) {
    final items = List<MarkLinkItemProjection>.from(base.items);
    final existingIndex = items.indexWhere((item) => item.id == markLinkId);
    final seq = existingIndex >= 0
        ? items[existingIndex].markLinkSeq
        : (items.isEmpty ? 0 : items.map((i) => i.markLinkSeq).reduce((a, b) => a > b ? a : b) + 1);
    final newItem = MarkLinkDraftAdapter.fromLinkDraft(
      markLinkId: markLinkId,
      markLinkSeq: seq,
      draft: draft,
    );
    if (existingIndex >= 0) {
      items[existingIndex] = newItem;
    } else {
      items.add(newItem);
    }
    items.sort((a, b) => a.markLinkSeq.compareTo(b.markLinkSeq));
    return MichiInfoListProjection(items: _recalcMeterDiff(items));
  }

  Future<void> _onTopicConfigUpdated(
    MichiInfoTopicConfigUpdated event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state is MichiInfoLoaded) {
      final current = state as MichiInfoLoaded;
      emit(current.copyWith(
        topicConfig: event.config,
        markActionItems: _buildMarkActionItems(event.config),
      ));
    }
  }

  Future<void> _onMarkActionPressed(
    MichiInfoMarkActionPressed event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (_eventId.isEmpty) return;
    try {
      final now = DateTime.now();
      final log = ActionTimeLog(
        id: const Uuid().v4(),
        eventId: _eventId,
        actionId: event.actionId,
        timestamp: now,
        createdAt: now,
        updatedAt: now,
      );
      await _eventRepository.saveActionTimeLog(log);
    } on Exception {
      // ログ記録失敗は一覧UIに影響を与えない
    }
  }

  Future<void> _onDelegateConsumed(
    MichiInfoDelegateConsumed event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state case MichiInfoLoaded current) {
      emit(current.copyWith());
    }
  }

  /// TopicConfig.markActions に基づいてアクションボタン一覧を生成する
  List<ActionItemProjection> _buildMarkActionItems(TopicConfig config) {
    final actionMap = {for (final a in _cachedActions) a.id: a};
    return config.markActions
        .map((id) => actionMap[id])
        .where((a) => a != null && a.isVisible && !a.isDeleted)
        .cast<ActionDomain>()
        .map((a) => ActionItemProjection(
              id: a.id,
              actionName: a.actionName,
              isVisible: a.isVisible,
            ))
        .toList();
  }

  /// ソート済み items を走査して displayMeterDiff を再計算する
  List<MarkLinkItemProjection> _recalcMeterDiff(
    List<MarkLinkItemProjection> items,
  ) {
    final numberFormat = NumberFormat('#,###');
    int? prevMeterValue;
    return items.map((item) {
      if (item.markLinkType != MarkOrLink.mark) return item;

      final rawMeter = item.displayMeterValue;
      if (rawMeter == null) {
        prevMeterValue = null;
        return item.copyWithMeterDiff(null);
      }
      final parsed = int.tryParse(
        rawMeter.replaceAll(',', '').replaceAll(' km', ''),
      );
      if (parsed == null) {
        prevMeterValue = null;
        return item.copyWithMeterDiff(null);
      }

      final prev = prevMeterValue;
      prevMeterValue = parsed;

      if (prev == null) return item.copyWithMeterDiff(null);

      final diff = parsed - prev;
      final sign = diff >= 0 ? '+' : '-';
      final absStr = numberFormat.format(diff.abs());
      return item.copyWithMeterDiff('$sign$absStr km');
    }).toList();
  }
}
