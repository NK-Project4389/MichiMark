import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/event_detail_adapter.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/topic/topic_theme_color.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../../../repository/event_repository.dart';
import '../../../repository/repository_error.dart';
import '../draft/event_detail_draft.dart';
import 'event_detail_event.dart';
import 'event_detail_state.dart';

class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  EventDetailBloc({
    required EventRepository eventRepository,
  })  : _eventRepository = eventRepository,
        super(const EventDetailLoading()) {
    on<EventDetailStarted>(_onStarted);
    on<EventDetailTabSelected>(_onTabSelected);
    on<EventDetailDismissPressed>(_onDismissPressed);
    on<EventDetailOpenMarkRequested>(_onOpenMarkRequested);
    on<EventDetailOpenLinkRequested>(_onOpenLinkRequested);
    on<EventDetailOpenPaymentRequested>(_onOpenPaymentRequested);
    on<EventDetailAddMarkLinkRequested>(_onAddMarkLinkRequested);
    on<EventDetailSaveRequested>(_onSaveRequested);
  }

  final EventRepository _eventRepository;

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
        final newDomain = EventDomain(
          id: event.eventId,
          eventName: '',
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
        emit(EventDetailLoaded(
          projection: projection,
          draft: const EventDetailDraft(),
          topicConfig: topicConfig,
          cachedEvent: newDomain,
          topicThemeColor: topicThemeColor,
          topicDisplayName: (topicDisplayName?.isNotEmpty ?? false) ? topicDisplayName : null,
          delegate: EventDetailTopicConfigPropagateDelegate(topicConfig),
        ));
        return;
      }
      final projection = EventDetailAdapter.toProjection(domain);
      final topicConfig = TopicConfig.fromTopicType(domain.topic?.topicType);
      final resolvedThemeColor = _resolveThemeColor(domain.topic);
      final resolvedDisplayName = _resolveDisplayName(domain.topic);
      emit(EventDetailLoaded(
        projection: projection,
        draft: const EventDetailDraft(),
        topicConfig: topicConfig,
        cachedEvent: domain,
        topicThemeColor: resolvedThemeColor,
        topicDisplayName: resolvedDisplayName,
        delegate: EventDetailTopicConfigPropagateDelegate(topicConfig),
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

  Future<void> _onSaveRequested(
    EventDetailSaveRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is! EventDetailLoaded) return;
    final current = state as EventDetailLoaded;

    emit(current.copyWith(isSaving: true));

    try {
      final existing = await _eventRepository.fetch(event.eventId);
      final draft = event.basicInfoDraft;

      final kmPerGas = draft.kmPerGasInput.isEmpty
          ? null
          : (double.tryParse(draft.kmPerGasInput) != null
              ? (double.parse(draft.kmPerGasInput) * 10).round()
              : null);

      final pricePerGas = draft.pricePerGasInput.isEmpty
          ? null
          : int.tryParse(draft.pricePerGasInput);

      final updated = EventDomain(
        id: existing.id,
        eventName: draft.eventName,
        trans: draft.selectedTrans,
        members: draft.selectedMembers,
        tags: draft.selectedTags,
        kmPerGas: kmPerGas,
        pricePerGas: pricePerGas,
        payMember: draft.selectedPayMember,
        topic: draft.selectedTopic,
        markLinks: existing.markLinks,
        payments: existing.payments,
        isDeleted: existing.isDeleted,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      await _eventRepository.save(updated);

      final projection = EventDetailAdapter.toProjection(updated);
      final updatedThemeColor = _resolveThemeColor(updated.topic);
      final updatedDisplayName = _resolveDisplayName(updated.topic);
      emit(EventDetailLoaded(
        projection: projection,
        draft: current.draft,
        delegate: const EventDetailSavedDelegate(),
        isSaving: false,
        topicConfig: current.topicConfig,
        cachedEvent: updated,
        topicThemeColor: updatedThemeColor,
        topicDisplayName: updatedDisplayName,
      ));
    } on Exception catch (e) {
      emit(current.copyWith(
        isSaving: false,
        saveErrorMessage: e.toString(),
      ));
    }
  }

}
