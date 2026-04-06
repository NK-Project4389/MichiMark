import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/master/tag/tag_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../repository/event_repository.dart';
import '../../../repository/repository_error.dart';
import '../../../repository/tag_repository.dart';
import '../../../repository/topic_repository.dart';
import '../draft/basic_info_draft.dart';
import 'basic_info_event.dart';
import 'basic_info_state.dart';

class BasicInfoBloc extends Bloc<BasicInfoEvent, BasicInfoState> {
  BasicInfoBloc({
    required EventRepository eventRepository,
    required TopicRepository topicRepository,
    required TagRepository tagRepository,
  })  : _eventRepository = eventRepository,
        _topicRepository = topicRepository,
        _tagRepository = tagRepository,
        super(const BasicInfoLoading()) {
    on<BasicInfoStarted>(_onStarted);
    on<BasicInfoEventNameChanged>(_onEventNameChanged);
    on<BasicInfoEditTransPressed>(_onEditTransPressed);
    on<BasicInfoTransSelected>(_onTransSelected);
    on<BasicInfoEditMembersPressed>(_onEditMembersPressed);
    on<BasicInfoMembersSelected>(_onMembersSelected);
    on<BasicInfoEditTagsPressed>(_onEditTagsPressed);
    on<BasicInfoTagsSelected>(_onTagsSelected);
    on<BasicInfoTagInputChanged>(_onTagInputChanged);
    on<BasicInfoTagSuggestionSelected>(_onTagSuggestionSelected);
    on<BasicInfoTagInputConfirmed>(_onTagInputConfirmed);
    on<BasicInfoTagRemoved>(_onTagRemoved);
    on<BasicInfoEditPayMemberPressed>(_onEditPayMemberPressed);
    on<BasicInfoPayMemberSelected>(_onPayMemberSelected);
    on<BasicInfoKmPerGasChanged>(_onKmPerGasChanged);
    on<BasicInfoPricePerGasChanged>(_onPricePerGasChanged);
  }

  final EventRepository _eventRepository;
  final TopicRepository _topicRepository;
  final TagRepository _tagRepository;

  Future<void> _onStarted(
    BasicInfoStarted event,
    Emitter<BasicInfoState> emit,
  ) async {
    emit(const BasicInfoLoading());
    try {
      final domain = await _eventRepository.fetch(event.eventId);
      // initialTopicTypeがあり、かつDBのtopicがnullの場合（新規作成直後）はinitialTopicTypeを使用する
      TopicDomain? topicDomain = domain.topic;
      if (topicDomain == null && event.initialTopicType != null) {
        topicDomain = await _topicRepository.fetchByType(event.initialTopicType!);
      }
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
        selectedTopic: topicDomain,
      );
      final topicConfig = TopicConfig.fromTopicType(topicDomain?.topicType ?? event.initialTopicType);
      final allTags = await _tagRepository.fetchAll();
      emit(BasicInfoLoaded(draft: draft, topicConfig: topicConfig, allTags: allTags));
    } on NotFoundError {
      // 通常はEventDetailBlocが先に新規イベントをDBに保存するためここには入らないが念のため維持
      final initialTopicType = event.initialTopicType;
      TopicDomain? topicDomain;
      if (initialTopicType != null) {
        topicDomain = await _topicRepository.fetchByType(initialTopicType);
      }
      final draft = BasicInfoDraft(
        selectedTopic: topicDomain,
      );
      final topicConfig = TopicConfig.fromTopicType(initialTopicType);
      final allTags = await _tagRepository.fetchAll();
      emit(BasicInfoLoaded(draft: draft, topicConfig: topicConfig, allTags: allTags));
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

  Future<void> _onTagInputChanged(
    BasicInfoTagInputChanged event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;
    final input = event.input.trim();
    if (input.isEmpty) {
      emit(current.copyWith(tagSuggestions: []));
      return;
    }
    final lower = input.toLowerCase();
    final suggestions = current.allTags
        .where((t) => t.tagName.toLowerCase().contains(lower))
        .where((t) => !current.draft.selectedTags.any((s) => s.id == t.id))
        .toList();
    emit(current.copyWith(tagSuggestions: suggestions));
  }

  Future<void> _onTagSuggestionSelected(
    BasicInfoTagSuggestionSelected event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;
    final newTags = [...current.draft.selectedTags, event.tag];
    emit(current.copyWith(
      draft: current.draft.copyWith(selectedTags: newTags),
      tagSuggestions: [],
    ));
  }

  Future<void> _onTagInputConfirmed(
    BasicInfoTagInputConfirmed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;
    final input = event.input.trim();
    if (input.isEmpty) return;

    // 既に選択済みなら無視
    final alreadySelected = current.draft.selectedTags
        .any((t) => t.tagName.toLowerCase() == input.toLowerCase());
    if (alreadySelected) {
      emit(current.copyWith(tagSuggestions: []));
      return;
    }

    // 既存マスタに完全一致するタグを探す
    final matchList = current.allTags
        .where((t) => t.tagName.toLowerCase() == input.toLowerCase())
        .toList();

    final TagDomain tag;
    final List<TagDomain> newAllTags;
    if (matchList.isNotEmpty) {
      tag = matchList.first;
      newAllTags = current.allTags;
    } else {
      // マスタに存在しない → 新規タグを作成してDBに保存
      final now = DateTime.now();
      tag = TagDomain(
        id: const Uuid().v4(),
        tagName: input,
        createdAt: now,
        updatedAt: now,
      );
      await _tagRepository.save(tag);
      newAllTags = [...current.allTags, tag];
    }

    final newTags = [...current.draft.selectedTags, tag];
    emit(current.copyWith(
      draft: current.draft.copyWith(selectedTags: newTags),
      allTags: newAllTags,
      tagSuggestions: [],
    ));
  }

  Future<void> _onTagRemoved(
    BasicInfoTagRemoved event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;
    final newTags = current.draft.selectedTags
        .where((t) => t.id != event.tag.id)
        .toList();
    emit(current.copyWith(
      draft: current.draft.copyWith(selectedTags: newTags),
    ));
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
