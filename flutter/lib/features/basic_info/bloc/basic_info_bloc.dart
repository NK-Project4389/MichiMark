import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/master/tag/tag_domain.dart';
import '../../../domain/master/trans/trans_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../../../repository/event_repository.dart';
import '../../../repository/member_repository.dart';
import '../../../repository/repository_error.dart';
import '../../../repository/tag_repository.dart';
import '../../../repository/topic_repository.dart';
import '../../../repository/trans_repository.dart';
import '../draft/basic_info_draft.dart';
import 'basic_info_event.dart';
import 'basic_info_state.dart';

class BasicInfoBloc extends Bloc<BasicInfoEvent, BasicInfoState> {
  BasicInfoBloc({
    required EventRepository eventRepository,
    required TopicRepository topicRepository,
    required TagRepository tagRepository,
    required MemberRepository memberRepository,
    required TransRepository transRepository,
  })  : _eventRepository = eventRepository,
        _topicRepository = topicRepository,
        _tagRepository = tagRepository,
        _memberRepository = memberRepository,
        _transRepository = transRepository,
        super(const BasicInfoLoading()) {
    on<BasicInfoStarted>(_onStarted);
    on<BasicInfoEventNameChanged>(_onEventNameChanged);
    on<BasicInfoTransChipToggled>(_onTransChipToggled);
    on<BasicInfoTagInputChanged>(_onTagInputChanged);
    on<BasicInfoTagSuggestionSelected>(_onTagSuggestionSelected);
    on<BasicInfoTagInputConfirmed>(_onTagInputConfirmed);
    on<BasicInfoTagRemoved>(_onTagRemoved);
    on<BasicInfoMemberInputChanged>(_onMemberInputChanged);
    on<BasicInfoMemberSuggestionSelected>(_onMemberSuggestionSelected);
    on<BasicInfoMemberInputConfirmed>(_onMemberInputConfirmed);
    on<BasicInfoMemberRemoved>(_onMemberRemoved);
    on<BasicInfoPayMemberChipToggled>(_onPayMemberChipToggled);
    on<BasicInfoKmPerGasChanged>(_onKmPerGasChanged);
    on<BasicInfoPricePerGasChanged>(_onPricePerGasChanged);
    on<BasicInfoEditModeEntered>(_onEditModeEntered);
    on<BasicInfoSavePressed>(_onSavePressed);
    on<BasicInfoEditCancelled>(_onEditCancelled);
    on<BasicInfoDelegateConsumed>(_onDelegateConsumed);
  }

  final EventRepository _eventRepository;
  final TopicRepository _topicRepository;
  final TagRepository _tagRepository;
  final MemberRepository _memberRepository;
  final TransRepository _transRepository;
  String _eventId = '';

  /// 直近10件のイベントから頻出メンバーサジェストを生成する（選択済み除外）
  List<MemberDomain> _buildInitialMemberSuggestions(
    List<EventDomain> recentEvents,
    List<MemberDomain> selectedMembers,
  ) {
    final selectedIds = selectedMembers.map((m) => m.id).toSet();
    // 直近10件のイベントから全メンバーを収集し、出現頻度順に並べる
    final countMap = <String, int>{};
    final memberMap = <String, MemberDomain>{};
    for (final event in recentEvents) {
      for (final member in event.members) {
        countMap[member.id] = (countMap[member.id] ?? 0) + 1;
        memberMap[member.id] = member;
      }
    }
    final suggestions = memberMap.values
        .where((m) => !selectedIds.contains(m.id))
        .toList()
      ..sort((a, b) => (countMap[b.id] ?? 0).compareTo(countMap[a.id] ?? 0));
    return suggestions;
  }

  /// メンバーサジェストを構築する。
  /// input が空の場合は直近イベントサジェスト（選択済み除外）を返す。
  /// input がある場合は allMembers を部分一致フィルタ（選択済み除外）。
  List<MemberDomain> _buildMemberSuggestions(
    BasicInfoLoaded current,
    String input,
    List<MemberDomain> baseSuggestions,
  ) {
    final selectedIds = current.draft.selectedMembers.map((m) => m.id).toSet();
    if (input.isEmpty) {
      return baseSuggestions.where((m) => !selectedIds.contains(m.id)).toList();
    }
    final lower = input.toLowerCase();
    return current.allMembers
        .where((m) =>
            !selectedIds.contains(m.id) &&
            m.memberName.toLowerCase().contains(lower))
        .toList();
  }

  Future<void> _onStarted(
    BasicInfoStarted event,
    Emitter<BasicInfoState> emit,
  ) async {
    _eventId = event.eventId;
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
      final allTrans = await _transRepository.fetchAll();
      final allMembers = await _memberRepository.fetchAll();
      // 直近10件のイベントを取得してメンバーサジェストを生成
      final recentEvents = (await _eventRepository.fetchAll()).take(10).toList();
      final memberSuggestions = _buildInitialMemberSuggestions(recentEvents, draft.selectedMembers);
      emit(BasicInfoLoaded(
        draft: draft,
        topicConfig: topicConfig,
        allTags: allTags,
        allTrans: allTrans,
        allMembers: allMembers,
        memberSuggestions: memberSuggestions,
      ));
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
      final allTrans = await _transRepository.fetchAll();
      final allMembers = await _memberRepository.fetchAll();
      emit(BasicInfoLoaded(
        draft: draft,
        topicConfig: topicConfig,
        allTags: allTags,
        allTrans: allTrans,
        allMembers: allMembers,
      ));
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

  Future<void> _onTransChipToggled(
    BasicInfoTransChipToggled event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;
    final isSelected = current.draft.selectedTrans?.id == event.trans.id;
    // 同一TransをタップでOFF、別TransをタップでON（単一選択）
    // TransDomain変更時に燃費自動反映ロジックを適用する（movingCostEstimatedモードのみ）
    final TransDomain? newTrans = isSelected ? null : event.trans;
    final kmPerGas = newTrans?.kmPerGas;
    final isEstimatedMode =
        current.draft.selectedTopic?.topicType == TopicType.movingCostEstimated;
    final newKmPerGasInput = (kmPerGas != null && isEstimatedMode)
        ? (kmPerGas / 10.0).toStringAsFixed(1)
        : current.draft.kmPerGasInput;
    // copyWithはnullクリアに対応していないため、Draftを直接再構築する
    final newDraft = BasicInfoDraft(
      eventName: current.draft.eventName,
      selectedTrans: newTrans,
      selectedMembers: current.draft.selectedMembers,
      selectedTags: current.draft.selectedTags,
      selectedPayMember: current.draft.selectedPayMember,
      kmPerGasInput: newKmPerGasInput,
      pricePerGasInput: current.draft.pricePerGasInput,
      selectedTopic: current.draft.selectedTopic,
      isEditing: current.draft.isEditing,
    );
    emit(current.copyWith(draft: newDraft));
  }

  Future<void> _onTagInputChanged(
    BasicInfoTagInputChanged event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;
    final input = event.input.trim();
    final suggestions = _buildTagSuggestions(current, input);
    emit(current.copyWith(tagSuggestions: suggestions));
  }

  Future<void> _onTagSuggestionSelected(
    BasicInfoTagSuggestionSelected event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;

    // 選択タグの updatedAt を更新してマスタ側に「最近使った」日時を記録する
    final now = DateTime.now();
    final updatedTag = event.tag.copyWith(updatedAt: now);
    await _tagRepository.save(updatedTag);
    final updatedAllTags = current.allTags
        .map((t) => t.id == updatedTag.id ? updatedTag : t)
        .toList();

    final newTags = [...current.draft.selectedTags, updatedTag];
    final suggestions = _buildTagSuggestions(
      current.copyWith(allTags: updatedAllTags, draft: current.draft.copyWith(selectedTags: newTags)),
      '',
    );
    emit(current.copyWith(
      allTags: updatedAllTags,
      draft: current.draft.copyWith(selectedTags: newTags),
      tagSuggestions: suggestions,
    ));
  }

  /// タグサジェストリストを構築する。
  /// input が空の場合は全マスタタグ（未選択）を updatedAt 降順で返す。
  /// input がある場合は部分一致フィルタをかける。
  List<TagDomain> _buildTagSuggestions(BasicInfoLoaded current, String input) {
    final selectedIds = current.draft.selectedTags.map((t) => t.id).toSet();
    final candidates = current.allTags
        .where((t) => !selectedIds.contains(t.id))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (input.isEmpty) return candidates;
    final lower = input.toLowerCase();
    return candidates.where((t) => t.tagName.toLowerCase().contains(lower)).toList();
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
    final newDraft = current.draft.copyWith(selectedTags: newTags);
    // 解除したタグをレコメンドに戻す
    final suggestions = _buildTagSuggestions(
      current.copyWith(draft: newDraft),
      '',
    );
    emit(current.copyWith(
      draft: newDraft,
      tagSuggestions: suggestions,
    ));
  }

  Future<void> _onMemberInputChanged(
    BasicInfoMemberInputChanged event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;
    final input = event.input.trim();
    // 入力空→memberSuggestions（直近サジェスト）から選択済みを除外
    // 入力あり→allMembersを部分一致フィルタ（選択済み除外）
    final suggestions = _buildMemberSuggestions(current, input, current.memberSuggestions);
    emit(current.copyWith(memberSuggestions: suggestions));
  }

  Future<void> _onMemberSuggestionSelected(
    BasicInfoMemberSuggestionSelected event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;
    // 重複チェック
    final alreadySelected =
        current.draft.selectedMembers.any((m) => m.id == event.member.id);
    if (alreadySelected) return;

    final newMembers = [...current.draft.selectedMembers, event.member];
    final newDraft = current.draft.copyWith(selectedMembers: newMembers);
    // 追加したメンバーをサジェストから除外して再フィルタリング
    final newSuggestions = current.memberSuggestions
        .where((m) => m.id != event.member.id)
        .toList();
    emit(current.copyWith(
      draft: newDraft,
      memberSuggestions: newSuggestions,
    ));
  }

  Future<void> _onMemberInputConfirmed(
    BasicInfoMemberInputConfirmed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;
    final input = event.input.trim();
    if (input.isEmpty) return;

    // 既に選択済みなら無視
    final alreadySelected = current.draft.selectedMembers
        .any((m) => m.memberName.toLowerCase() == input.toLowerCase());
    if (alreadySelected) return;

    // allMembersに同名（大文字小文字区別なし）が存在するか確認
    final matchList = current.allMembers
        .where((m) => m.memberName.toLowerCase() == input.toLowerCase())
        .toList();

    final MemberDomain member;
    final List<MemberDomain> newAllMembers;
    if (matchList.isNotEmpty) {
      // マスタに存在する → そのまま追加
      member = matchList.first;
      newAllMembers = current.allMembers;
    } else {
      // 未登録 → MemberRepositoryに新規登録後、draftに追加
      final now = DateTime.now();
      member = MemberDomain(
        id: const Uuid().v4(),
        memberName: input,
        createdAt: now,
        updatedAt: now,
      );
      await _memberRepository.save(member);
      newAllMembers = [...current.allMembers, member];
    }

    final newMembers = [...current.draft.selectedMembers, member];
    final newSuggestions = current.memberSuggestions
        .where((m) => m.id != member.id)
        .toList();
    emit(current.copyWith(
      draft: current.draft.copyWith(selectedMembers: newMembers),
      allMembers: newAllMembers,
      memberSuggestions: newSuggestions,
    ));
  }

  Future<void> _onMemberRemoved(
    BasicInfoMemberRemoved event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;
    final newMembers = current.draft.selectedMembers
        .where((m) => m.id != event.member.id)
        .toList();
    // 削除メンバーがPayMemberと同一の場合はPayMemberをクリア
    final shouldClearPayMember =
        current.draft.selectedPayMember?.id == event.member.id;
    // copyWithはnullクリアに対応していないため、Draftを直接再構築する
    final newDraft = BasicInfoDraft(
      eventName: current.draft.eventName,
      selectedTrans: current.draft.selectedTrans,
      selectedMembers: newMembers,
      selectedTags: current.draft.selectedTags,
      selectedPayMember:
          shouldClearPayMember ? null : current.draft.selectedPayMember,
      kmPerGasInput: current.draft.kmPerGasInput,
      pricePerGasInput: current.draft.pricePerGasInput,
      selectedTopic: current.draft.selectedTopic,
      isEditing: current.draft.isEditing,
    );
    emit(current.copyWith(draft: newDraft));
  }

  Future<void> _onPayMemberChipToggled(
    BasicInfoPayMemberChipToggled event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;
    // 同一MemberをタップでOFF、別MemberをタップでON（単一選択）
    final isSelected = current.draft.selectedPayMember?.id == event.member.id;
    // copyWithはnullクリアに対応していないため、Draftを直接再構築する
    final newDraft = BasicInfoDraft(
      eventName: current.draft.eventName,
      selectedTrans: current.draft.selectedTrans,
      selectedMembers: current.draft.selectedMembers,
      selectedTags: current.draft.selectedTags,
      selectedPayMember: isSelected ? null : event.member,
      kmPerGasInput: current.draft.kmPerGasInput,
      pricePerGasInput: current.draft.pricePerGasInput,
      selectedTopic: current.draft.selectedTopic,
      isEditing: current.draft.isEditing,
    );
    emit(current.copyWith(draft: newDraft));
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

  Future<void> _onEditModeEntered(
    BasicInfoEditModeEntered event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      final enteredDraft = current.draft.copyWith(isEditing: true);
      // 編集モード開始時に全マスタタグをレコメンドとして設定する
      final tagSuggestions = _buildTagSuggestions(
        current.copyWith(draft: enteredDraft),
        '',
      );
      emit(current.copyWith(
        originalDraft: current.draft,
        draft: enteredDraft,
        tagSuggestions: tagSuggestions,
      ));
    }
  }

  Future<void> _onSavePressed(
    BasicInfoSavePressed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is! BasicInfoLoaded) return;
    final current = state as BasicInfoLoaded;

    emit(current.copyWith(isSaving: true));
    try {
      final existing = await _eventRepository.fetch(_eventId);
      final draft = current.draft;

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
        actionTimeLogs: existing.actionTimeLogs,
        isDeleted: existing.isDeleted,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      await _eventRepository.save(updated);

      emit(current.copyWith(
        isSaving: false,
        draft: draft.copyWith(isEditing: false),
        delegate: event.withDismiss
            ? const BasicInfoSavedAndDismissDelegate()
            : const BasicInfoSavedDelegate(),
      ));
    } on Exception catch (e) {
      if (state case BasicInfoLoaded loaded) {
        emit(BasicInfoLoaded(
          draft: loaded.draft,
          delegate: null,
          topicConfig: loaded.topicConfig,
          allTrans: loaded.allTrans,
          allMembers: loaded.allMembers,
          memberSuggestions: loaded.memberSuggestions,
          allTags: loaded.allTags,
          tagSuggestions: loaded.tagSuggestions,
          isSaving: false,
          originalDraft: loaded.originalDraft,
        ));
        emit(BasicInfoError(message: e.toString()));
      }
    }
  }

  Future<void> _onEditCancelled(
    BasicInfoEditCancelled event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      final original = current.originalDraft;
      if (original != null) {
        emit(current.copyWith(
          draft: original.copyWith(isEditing: false),
          originalDraft: original,
        ));
      } else {
        emit(current.copyWith(
          draft: current.draft.copyWith(isEditing: false),
        ));
      }
    }
  }

  Future<void> _onDelegateConsumed(
    BasicInfoDelegateConsumed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state case final BasicInfoLoaded current) {
      emit(current.copyWith(delegate: null));
    }
  }
}
