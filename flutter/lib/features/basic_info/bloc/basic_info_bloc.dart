import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../repository/event_repository.dart';
import '../../../repository/repository_error.dart';
import '../../../repository/topic_repository.dart';
import '../draft/basic_info_draft.dart';
import 'basic_info_event.dart';
import 'basic_info_state.dart';

class BasicInfoBloc extends Bloc<BasicInfoEvent, BasicInfoState> {
  BasicInfoBloc({
    required EventRepository eventRepository,
    required TopicRepository topicRepository,
  })  : _eventRepository = eventRepository,
        _topicRepository = topicRepository,
        super(const BasicInfoLoading()) {
    on<BasicInfoStarted>(_onStarted);
    on<BasicInfoEventNameChanged>(_onEventNameChanged);
    on<BasicInfoEditTransPressed>(_onEditTransPressed);
    on<BasicInfoTransSelected>(_onTransSelected);
    on<BasicInfoEditMembersPressed>(_onEditMembersPressed);
    on<BasicInfoMembersSelected>(_onMembersSelected);
    on<BasicInfoEditTagsPressed>(_onEditTagsPressed);
    on<BasicInfoTagsSelected>(_onTagsSelected);
    on<BasicInfoEditPayMemberPressed>(_onEditPayMemberPressed);
    on<BasicInfoPayMemberSelected>(_onPayMemberSelected);
    on<BasicInfoKmPerGasChanged>(_onKmPerGasChanged);
    on<BasicInfoPricePerGasChanged>(_onPricePerGasChanged);
  }

  final EventRepository _eventRepository;
  final TopicRepository _topicRepository;

  Future<void> _onStarted(
    BasicInfoStarted event,
    Emitter<BasicInfoState> emit,
  ) async {
    emit(const BasicInfoLoading());
    try {
      final domain = await _eventRepository.fetch(event.eventId);
      // 既存イベント: DB値からDraftを初期化（initialTopicTypeは無視）
      final draft = BasicInfoDraft(
        eventName: domain.eventName,
        selectedTrans: domain.trans,
        selectedMembers: domain.members,
        selectedTags: domain.tags,
        selectedPayMember: domain.payMember,
        kmPerGasInput: domain.kmPerGas != null
            ? (domain.kmPerGas! / 10.0).toString()
            : '',
        pricePerGasInput: domain.pricePerGas?.toString() ?? '',
        selectedTopic: domain.topic,
      );
      final topicConfig = TopicConfig.fromTopicType(domain.topic?.topicType);
      emit(BasicInfoLoaded(draft: draft, topicConfig: topicConfig));
    } on NotFoundError {
      // 新規イベント: initialTopicTypeでDraftを初期化
      final initialTopicType = event.initialTopicType;
      TopicDomain? topicDomain;
      if (initialTopicType != null) {
        topicDomain = await _topicRepository.fetchByType(initialTopicType);
      }
      final draft = BasicInfoDraft(
        selectedTopic: topicDomain,
      );
      final topicConfig = TopicConfig.fromTopicType(initialTopicType);
      emit(BasicInfoLoaded(draft: draft, topicConfig: topicConfig));
    } on Exception catch (e) {
      emit(BasicInfoError(message: e.toString()));
    }
  }

  Future<void> _onEventNameChanged(
    BasicInfoEventNameChanged event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(eventName: event.name),
      ));
    }
  }

  Future<void> _onEditTransPressed(
    BasicInfoEditTransPressed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        delegate: const BasicInfoOpenTransSelectionDelegate(),
      ));
    }
  }

  Future<void> _onTransSelected(
    BasicInfoTransSelected event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedTrans: event.trans),
      ));
    }
  }

  Future<void> _onEditMembersPressed(
    BasicInfoEditMembersPressed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        delegate: const BasicInfoOpenMembersSelectionDelegate(),
      ));
    }
  }

  Future<void> _onMembersSelected(
    BasicInfoMembersSelected event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedMembers: event.members),
      ));
    }
  }

  Future<void> _onEditTagsPressed(
    BasicInfoEditTagsPressed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        delegate: const BasicInfoOpenTagsSelectionDelegate(),
      ));
    }
  }

  Future<void> _onTagsSelected(
    BasicInfoTagsSelected event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedTags: event.tags),
      ));
    }
  }

  Future<void> _onEditPayMemberPressed(
    BasicInfoEditPayMemberPressed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        delegate: const BasicInfoOpenPayMemberSelectionDelegate(),
      ));
    }
  }

  Future<void> _onPayMemberSelected(
    BasicInfoPayMemberSelected event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedPayMember: event.payMember),
      ));
    }
  }

  Future<void> _onKmPerGasChanged(
    BasicInfoKmPerGasChanged event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(kmPerGasInput: event.input),
      ));
    }
  }

  Future<void> _onPricePerGasChanged(
    BasicInfoPricePerGasChanged event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(pricePerGasInput: event.input),
      ));
    }
  }
}
