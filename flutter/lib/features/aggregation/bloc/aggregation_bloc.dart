import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/aggregation_adapter.dart';
import '../../../adapter/aggregation_service.dart';
import '../../../domain/aggregation/aggregation_filter.dart';
import '../../../repository/event_repository.dart';
import '../../../repository/member_repository.dart';
import '../../../repository/tag_repository.dart';
import '../../../repository/topic_repository.dart';
import '../../../repository/trans_repository.dart';
import '../draft/aggregation_draft.dart';
import 'aggregation_event.dart';
import 'aggregation_state.dart';

class AggregationBloc extends Bloc<AggregationEvent, AggregationState> {
  AggregationBloc({
    required EventRepository eventRepository,
    required AggregationService aggregationService,
    required TagRepository tagRepository,
    required MemberRepository memberRepository,
    required TransRepository transRepository,
    required TopicRepository topicRepository,
  })  : _eventRepository = eventRepository,
        _aggregationService = aggregationService,
        _tagRepository = tagRepository,
        _memberRepository = memberRepository,
        _transRepository = transRepository,
        _topicRepository = topicRepository,
        super(AggregationState(
          draft: AggregationDraft(
            filter: const AggregationFilter(dateRange: ThisMonth()),
          ),
        )) {
    on<AggregationStarted>(_onStarted);
    on<AggregationDateRangeChanged>(_onDateRangeChanged);
    on<AggregationTagFilterChanged>(_onTagFilterChanged);
    on<AggregationMemberFilterChanged>(_onMemberFilterChanged);
    on<AggregationTransFilterChanged>(_onTransFilterChanged);
    on<AggregationTopicFilterChanged>(_onTopicFilterChanged);
    on<AggregationFilterCleared>(_onFilterCleared);
  }

  final EventRepository _eventRepository;
  final AggregationService _aggregationService;
  final TagRepository _tagRepository;
  final MemberRepository _memberRepository;
  final TransRepository _transRepository;
  final TopicRepository _topicRepository;

  Future<void> _onStarted(
    AggregationStarted event,
    Emitter<AggregationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    try {
      // マスターデータ読み込み
      final tags = await _tagRepository.fetchAll();
      final members = await _memberRepository.fetchAll();
      final trans = await _transRepository.fetchAll();
      final topics = await _topicRepository.fetchAll();

      final newDraft = state.draft.copyWith(
        availableTags: tags,
        availableMembers: members,
        availableTrans: trans,
        availableTopics: topics,
      );

      emit(state.copyWith(draft: newDraft));
      await _runAggregation(newDraft.filter, emit);
    } on Exception catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDateRangeChanged(
    AggregationDateRangeChanged event,
    Emitter<AggregationState> emit,
  ) async {
    final newFilter = state.draft.filter.copyWith(dateRange: event.range);
    final newDraft = state.draft.copyWith(filter: newFilter);
    emit(state.copyWith(draft: newDraft, isLoading: true));
    await _runAggregation(newFilter, emit);
  }

  Future<void> _onTagFilterChanged(
    AggregationTagFilterChanged event,
    Emitter<AggregationState> emit,
  ) async {
    final newFilter = state.draft.filter.copyWith(tagIds: event.tagIds);
    final newDraft = state.draft.copyWith(filter: newFilter);
    emit(state.copyWith(draft: newDraft, isLoading: true));
    await _runAggregation(newFilter, emit);
  }

  Future<void> _onMemberFilterChanged(
    AggregationMemberFilterChanged event,
    Emitter<AggregationState> emit,
  ) async {
    final newFilter = state.draft.filter.copyWith(memberIds: event.memberIds);
    final newDraft = state.draft.copyWith(filter: newFilter);
    emit(state.copyWith(draft: newDraft, isLoading: true));
    await _runAggregation(newFilter, emit);
  }

  Future<void> _onTransFilterChanged(
    AggregationTransFilterChanged event,
    Emitter<AggregationState> emit,
  ) async {
    final newFilter = event.transId != null
        ? state.draft.filter.copyWith(transId: event.transId)
        : state.draft.filter.copyWith(clearTransId: true);
    final newDraft = state.draft.copyWith(filter: newFilter);
    emit(state.copyWith(draft: newDraft, isLoading: true));
    await _runAggregation(newFilter, emit);
  }

  Future<void> _onTopicFilterChanged(
    AggregationTopicFilterChanged event,
    Emitter<AggregationState> emit,
  ) async {
    final newFilter = event.topicId != null
        ? state.draft.filter.copyWith(topicId: event.topicId)
        : state.draft.filter.copyWith(clearTopicId: true);
    final newDraft = state.draft.copyWith(filter: newFilter);
    emit(state.copyWith(draft: newDraft, isLoading: true));
    await _runAggregation(newFilter, emit);
  }

  Future<void> _onFilterCleared(
    AggregationFilterCleared event,
    Emitter<AggregationState> emit,
  ) async {
    final initialFilter = const AggregationFilter(dateRange: ThisMonth());
    final newDraft = state.draft.copyWith(filter: initialFilter);
    emit(state.copyWith(draft: newDraft, isLoading: true));
    await _runAggregation(initialFilter, emit);
  }

  Future<void> _runAggregation(
    AggregationFilter filter,
    Emitter<AggregationState> emit,
  ) async {
    try {
      final events = await _eventRepository.fetchByFilter(filter);
      final result = await _aggregationService.aggregateEvents(events);
      final projection = AggregationAdapter.toProjection(result, filter);
      emit(state.copyWith(
        projection: projection,
        isLoading: false,
      ));
    } on Exception catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
