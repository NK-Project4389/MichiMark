import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/event_detail_adapter.dart';
import '../../../domain/invitation/invitation_role.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/topic/topic_theme_color.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../../../repository/event_repository.dart';
import '../../../repository/repository_error.dart';
import '../../../repository/topic_repository.dart';
import '../../invite_code_input/repository/invitation_repository.dart';
import '../draft/event_detail_draft.dart';
import 'event_detail_event.dart';
import 'event_detail_state.dart';

class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  EventDetailBloc({
    required EventRepository eventRepository,
    required TopicRepository topicRepository,
    required InvitationRepository invitationRepository,
  })  : _eventRepository = eventRepository,
        _topicRepository = topicRepository,
        _invitationRepository = invitationRepository,
        super(const EventDetailLoading()) {
    on<EventDetailStarted>(_onStarted);
    on<EventDetailTabSelected>(_onTabSelected);
    on<EventDetailDismissPressed>(_onDismissPressed);
    on<EventDetailOpenMarkRequested>(_onOpenMarkRequested);
    on<EventDetailOpenLinkRequested>(_onOpenLinkRequested);
    on<EventDetailOpenPaymentRequested>(_onOpenPaymentRequested);
    on<EventDetailAddMarkLinkRequested>(_onAddMarkLinkRequested);
    on<EventDetailCachedEventUpdateRequested>(_onCachedEventUpdateRequested);
    on<EventDetailDeleteButtonPressed>(_onDeleteButtonPressed);
    on<EventDetailDeleteConfirmed>(_onDeleteConfirmed);
    on<EventDetailDeleteDialogDismissed>(_onDeleteDialogDismissed);
    on<EventDetailDelegateConsumed>(_onDelegateConsumed);
    on<EventDetailChildSaved>(_onChildSaved);
    on<EventDetailPaymentSaved>(_onPaymentSaved);
    on<EventDetailInviteLinkButtonPressed>(_onInviteLinkButtonPressed);
    on<EventDetailInviteCodeButtonPressed>(_onInviteCodeButtonPressed);
  }

  final EventRepository _eventRepository;
  final TopicRepository _topicRepository;
  final InvitationRepository _invitationRepository;

  Future<void> _onStarted(
    EventDetailStarted event,
    Emitter<EventDetailState> emit,
  ) async {
    emit(const EventDetailLoading());
    try {
      final EventDomain domain;
      try {
        domain = await _eventRepository.fetch(event.eventId);
      } on NotFoundError {
        // 新規作成モード: 空ドメインを生成してRepositoryに保存
        final now = DateTime.now();
        // initialTopicTypeが指定されている場合はtopicも初期保存する（戻ったときにカードグレー化を防ぐ）
        TopicDomain? initialTopic;
        if (event.initialTopicType != null) {
          initialTopic = await _topicRepository.fetchByType(event.initialTopicType!);
        }
        final newDomain = EventDomain(
          id: event.eventId,
          eventName: '',
          topic: initialTopic,
          createdAt: now,
          updatedAt: now,
        );
        await _eventRepository.save(newDomain);
        final projection = EventDetailAdapter.toProjection(newDomain);
        // initialTopicType が指定されている場合はそのTopicConfigを使用する
        final initialTopicType = event.initialTopicType;
        final topicConfig = TopicConfig.fromTopicType(initialTopicType);
        final topicThemeColor = initialTopicType != null
            ? TopicConfig.forType(initialTopicType).themeColor
            : null;
        final topicDisplayName = initialTopicType != null
            ? TopicConfig.forType(initialTopicType).displayName
            : null;
        final newUserRole = await _fetchUserRoleSafe(event.eventId);
        emit(EventDetailLoaded(
          projection: projection,
          draft: const EventDetailDraft(),
          topicConfig: topicConfig,
          cachedEvent: newDomain,
          topicThemeColor: topicThemeColor,
          topicDisplayName: (topicDisplayName?.isNotEmpty ?? false) ? topicDisplayName : null,
          delegate: EventDetailTopicConfigPropagateDelegate(topicConfig),
          isNewEvent: true,
          isSavedAtLeastOnce: false,
          userRole: newUserRole,
        ));
        return;
      }
      final projection = EventDetailAdapter.toProjection(domain);
      final topicConfig = TopicConfig.fromTopicType(domain.topic?.topicType);
      final resolvedThemeColor = _resolveThemeColor(domain.topic);
      final resolvedDisplayName = _resolveDisplayName(domain.topic);
      final userRole = await _fetchUserRoleSafe(event.eventId);
      emit(EventDetailLoaded(
        projection: projection,
        draft: const EventDetailDraft(),
        topicConfig: topicConfig,
        cachedEvent: domain,
        topicThemeColor: resolvedThemeColor,
        topicDisplayName: resolvedDisplayName,
        delegate: EventDetailTopicConfigPropagateDelegate(topicConfig),
        userRole: userRole,
      ));
    } on Exception catch (e) {
      emit(EventDetailError(message: e.toString()));
    }
  }

  Future<void> _onTabSelected(
    EventDetailTabSelected event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedTab: event.tab),
      ));
    }
  }

  Future<void> _onDismissPressed(
    EventDetailDismissPressed event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      if (current.isNewEvent && !current.isSavedAtLeastOnce) {
        final eventId = current.projection.eventId;
        try {
          await _eventRepository.delete(eventId);
        } on Exception {
          // 削除失敗は無視してDismissへ進む
        }
      }
      emit(current.copyWith(delegate: const EventDetailDismissDelegate()));
    }
  }

  Future<void> _onOpenMarkRequested(
    EventDetailOpenMarkRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        delegate: EventDetailOpenMarkDelegate(event.markLinkId),
      ));
    }
  }

  Future<void> _onOpenLinkRequested(
    EventDetailOpenLinkRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        delegate: EventDetailOpenLinkDelegate(event.markLinkId),
      ));
    }
  }

  Future<void> _onOpenPaymentRequested(
    EventDetailOpenPaymentRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        delegate: EventDetailOpenPaymentDelegate(event.paymentId),
      ));
    }
  }

  Future<void> _onAddMarkLinkRequested(
    EventDetailAddMarkLinkRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        delegate: const EventDetailAddMarkLinkDelegate(),
      ));
    }
  }

  /// Topic から TopicThemeColor を解決する。Topic未設定時は null。
  TopicThemeColor? _resolveThemeColor(TopicDomain? topic) {
    if (topic == null) return null;
    return topic.themeColor;
  }

  /// Topic から displayName を解決する。Topic未設定時は null。
  String? _resolveDisplayName(TopicDomain? topic) {
    if (topic == null) return null;
    return TopicConfig.forType(topic.topicType).displayName;
  }

  Future<void> _onDeleteButtonPressed(
    EventDetailDeleteButtonPressed event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(showDeleteConfirmDialog: true));
    }
  }

  Future<void> _onDeleteConfirmed(
    EventDetailDeleteConfirmed event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is! EventDetailLoaded) return;
    final current = state as EventDetailLoaded;
    final eventId = current.projection.eventId;
    try {
      await _eventRepository.delete(eventId);
      emit(current.copyWith(
        showDeleteConfirmDialog: false,
        delegate: const EventDetailDeletedDelegate(),
      ));
    } on Exception catch (e) {
      emit(EventDetailError(message: e.toString()));
    }
  }

  Future<void> _onDeleteDialogDismissed(
    EventDetailDeleteDialogDismissed event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(showDeleteConfirmDialog: false));
    }
  }

  Future<void> _onDelegateConsumed(
    EventDetailDelegateConsumed event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(delegate: null));
    }
  }

  Future<void> _onChildSaved(
    EventDetailChildSaved event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(isSavedAtLeastOnce: true));
    }
  }

  Future<void> _onPaymentSaved(
    EventDetailPaymentSaved event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(isSavedAtLeastOnce: true));
    }
    // cachedEventを最新状態に更新する
    add(const EventDetailCachedEventUpdateRequested());
  }

  Future<void> _onCachedEventUpdateRequested(
    EventDetailCachedEventUpdateRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is! EventDetailLoaded) return;
    final current = state as EventDetailLoaded;
    final eventId = current.projection.eventId;
    try {
      final updated = await _eventRepository.fetch(eventId);
      final projection = EventDetailAdapter.toProjection(updated);
      final updatedThemeColor = _resolveThemeColor(updated.topic);
      final updatedDisplayName = _resolveDisplayName(updated.topic);
      emit(EventDetailLoaded(
        projection: projection,
        draft: current.draft,
        topicConfig: current.topicConfig,
        cachedEvent: updated,
        topicThemeColor: updatedThemeColor,
        topicDisplayName: updatedDisplayName,
        isNewEvent: current.isNewEvent,
        isSavedAtLeastOnce: current.isSavedAtLeastOnce,
        userRole: current.userRole,
      ));
    } on Exception {
      // キャッシュ更新失敗は無視（現在の表示を維持）
    }
  }

  Future<void> _onInviteLinkButtonPressed(
    EventDetailInviteLinkButtonPressed event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        delegate: const EventDetailOpenInviteLinkDelegate(),
      ));
    }
  }

  Future<void> _onInviteCodeButtonPressed(
    EventDetailInviteCodeButtonPressed event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        delegate: const EventDetailOpenInviteCodeInputDelegate(),
      ));
    }
  }

  /// userRole を取得する。取得失敗時は null を返す（画面表示を壊さないため）。
  Future<InvitationRole?> _fetchUserRoleSafe(String eventId) async {
    try {
      return await _invitationRepository.fetchUserRole(eventId);
    } on Exception {
      return null;
    }
  }

}
