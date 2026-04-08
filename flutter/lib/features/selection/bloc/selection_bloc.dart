import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/selection_adapter.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../repository/action_repository.dart';
import '../../../repository/member_repository.dart';
import '../../../repository/tag_repository.dart';
import '../../../repository/topic_repository.dart';
import '../../../repository/trans_repository.dart';
import '../draft/selection_draft.dart';
import '../selection_args.dart';
import '../selection_result.dart';
import 'selection_event.dart';
import 'selection_state.dart';

class SelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  SelectionBloc({
    required SelectionType type,
    required Set<String> selectedIds,
    Set<String> fixedSelectedIds = const {},
    List<MemberDomain>? candidateMembers,
    required TransRepository transRepository,
    required MemberRepository memberRepository,
    required TagRepository tagRepository,
    required ActionRepository actionRepository,
    required TopicRepository topicRepository,
  })  : _type = type,
        _selectedIds = selectedIds,
        _fixedSelectedIds = fixedSelectedIds,
        _candidateMembers = candidateMembers,
        _transRepository = transRepository,
        _memberRepository = memberRepository,
        _tagRepository = tagRepository,
        _actionRepository = actionRepository,
        _topicRepository = topicRepository,
        super(const SelectionLoading()) {
    on<SelectionStarted>(_onStarted);
    on<SelectionItemToggled>(_onItemToggled);
    on<SelectionConfirmed>(_onConfirmed);
    on<SelectionDismissed>(_onDismissed);
  }

  final SelectionType _type;
  final Set<String> _selectedIds;
  final Set<String> _fixedSelectedIds;

  /// REQ-MAD-004: メンバー選択候補（null の場合は MemberRepository.fetchAll() を使用）
  final List<MemberDomain>? _candidateMembers;

  final TransRepository _transRepository;
  final MemberRepository _memberRepository;
  final TagRepository _tagRepository;
  final ActionRepository _actionRepository;
  final TopicRepository _topicRepository;

  Future<void> _onStarted(
    SelectionStarted event,
    Emitter<SelectionState> emit,
  ) async {
    emit(const SelectionLoading());
    try {
      final draft = SelectionDraft(selectedIds: _selectedIds);
      switch (_type) {
        case SelectionType.eventTrans:
          final items = await _transRepository.fetchAll();
          final projection = SelectionAdapter.fromTrans(
            type: _type,
            items: items,
            selectedIds: _selectedIds,
          );
          emit(SelectionLoaded(
            projection: projection,
            draft: draft,
            cachedTrans: items,
          ));

        case SelectionType.markMembers:
        case SelectionType.linkMembers:
          // REQ-MAD-004: 候補リストが指定されている場合はそちらを優先する
          final items =
              _candidateMembers ?? await _memberRepository.fetchAll();
          final projection = SelectionAdapter.fromMembers(
            type: _type,
            items: items,
            selectedIds: _selectedIds,
            fixedSelectedIds: _fixedSelectedIds,
          );
          emit(SelectionLoaded(
            projection: projection,
            draft: draft,
            cachedMembers: items,
          ));

        case SelectionType.eventMembers:
        case SelectionType.gasPayMember:
        case SelectionType.payMember:
        case SelectionType.splitMembers:
          final items = await _memberRepository.fetchAll();
          final projection = SelectionAdapter.fromMembers(
            type: _type,
            items: items,
            selectedIds: _selectedIds,
            fixedSelectedIds: _fixedSelectedIds,
          );
          emit(SelectionLoaded(
            projection: projection,
            draft: draft,
            cachedMembers: items,
          ));

        case SelectionType.eventTags:
          final items = await _tagRepository.fetchAll();
          final projection = SelectionAdapter.fromTags(
            type: _type,
            items: items,
            selectedIds: _selectedIds,
          );
          emit(SelectionLoaded(
            projection: projection,
            draft: draft,
            cachedTags: items,
          ));

        case SelectionType.markActions:
        case SelectionType.linkActions:
          final items = await _actionRepository.fetchAll();
          final projection = SelectionAdapter.fromActions(
            type: _type,
            items: items,
            selectedIds: _selectedIds,
          );
          emit(SelectionLoaded(
            projection: projection,
            draft: draft,
            cachedActions: items,
          ));

        case SelectionType.eventTopic:
          final items = await _topicRepository.fetchAll();
          final projection = SelectionAdapter.fromTopics(
            type: _type,
            items: items,
            selectedIds: _selectedIds,
          );
          emit(SelectionLoaded(
            projection: projection,
            draft: draft,
            cachedTopics: items,
          ));
      }
    } on Exception catch (e) {
      emit(SelectionError(message: e.toString()));
    }
  }

  Future<void> _onItemToggled(
    SelectionItemToggled event,
    Emitter<SelectionState> emit,
  ) async {
    if (state is SelectionLoaded) {
      final current = state as SelectionLoaded;
      // 固定IDはトグル不可
      if (_fixedSelectedIds.contains(event.id)) return;
      final newDraft =
          current.draft.toggle(event.id, current.projection.mode);
      final newProjection = SelectionAdapter.rebuild(
        current: current.projection,
        selectedIds: newDraft.selectedIds,
      );
      emit(current.copyWith(draft: newDraft, projection: newProjection));
    }
  }

  Future<void> _onConfirmed(
    SelectionConfirmed event,
    Emitter<SelectionState> emit,
  ) async {
    if (state is SelectionLoaded) {
      final current = state as SelectionLoaded;
      final result = _buildResult(current);
      emit(current.copyWith(
        delegate: SelectionConfirmedDelegate(result),
      ));
    }
  }

  Future<void> _onDismissed(
    SelectionDismissed event,
    Emitter<SelectionState> emit,
  ) async {
    if (state is SelectionLoaded) {
      final current = state as SelectionLoaded;
      emit(current.copyWith(delegate: const SelectionDismissedDelegate()));
    }
  }

  SelectionResult _buildResult(SelectionLoaded state) {
    switch (_type) {
      case SelectionType.eventTrans:
        final id = state.draft.selectedIds.firstOrNull;
        final selected =
            id != null ? state.cachedTrans.where((t) => t.id == id).firstOrNull : null;
        return TransSelectionResult(selected);

      case SelectionType.eventMembers:
      case SelectionType.markMembers:
      case SelectionType.linkMembers:
      case SelectionType.splitMembers:
        final allSelectedIds = {
          ...state.draft.selectedIds,
          ..._fixedSelectedIds,
        };
        final selected = state.cachedMembers
            .where((m) => allSelectedIds.contains(m.id))
            .toList();
        return MembersSelectionResult(selected);

      case SelectionType.gasPayMember:
      case SelectionType.payMember:
        final id = state.draft.selectedIds.firstOrNull;
        final selected = id != null
            ? state.cachedMembers.where((m) => m.id == id).firstOrNull
            : null;
        return MembersSelectionResult(selected != null ? [selected] : []);

      case SelectionType.eventTags:
        final selected = state.cachedTags
            .where((t) => state.draft.selectedIds.contains(t.id))
            .toList();
        return TagsSelectionResult(selected);

      case SelectionType.markActions:
      case SelectionType.linkActions:
        final selected = state.cachedActions
            .where((a) => state.draft.selectedIds.contains(a.id))
            .toList();
        return ActionsSelectionResult(selected);

      case SelectionType.eventTopic:
        final id = state.draft.selectedIds.firstOrNull;
        final selected = id != null
            ? state.cachedTopics.where((t) => t.id == id).firstOrNull
            : null;
        return TopicSelectionResult(selected);
    }
  }
}
