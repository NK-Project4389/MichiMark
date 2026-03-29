import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/master/tag/tag_domain.dart';
import '../../../../repository/tag_repository.dart';
import '../draft/tag_setting_detail_draft.dart';
import 'tag_setting_detail_event.dart';
import 'tag_setting_detail_state.dart';

class TagSettingDetailBloc
    extends Bloc<TagSettingDetailEvent, TagSettingDetailState> {
  TagSettingDetailBloc({required TagRepository tagRepository})
      : _tagRepository = tagRepository,
        super(const TagSettingDetailLoading()) {
    on<TagSettingDetailStarted>(_onStarted);
    on<TagSettingDetailNameChanged>(_onNameChanged);
    on<TagSettingDetailIsVisibleChanged>(_onIsVisibleChanged);
    on<TagSettingDetailSaveTapped>(_onSaveTapped);
    on<TagSettingDetailBackTapped>(_onBackTapped);
  }

  final TagRepository _tagRepository;

  Future<void> _onStarted(
    TagSettingDetailStarted event,
    Emitter<TagSettingDetailState> emit,
  ) async {
    emit(const TagSettingDetailLoading());

    if (event.tagId == null) {
      final newId = const Uuid().v4();
      emit(TagSettingDetailLoaded(
        tagId: newId,
        draft: const TagSettingDetailDraft(),
      ));
      return;
    }

    try {
      final all = await _tagRepository.fetchAll();
      final domain = all.where((t) => t.id == event.tagId).firstOrNull;
      if (domain == null) {
        emit(const TagSettingDetailError('タグが見つかりません'));
        return;
      }
      emit(TagSettingDetailLoaded(
        tagId: domain.id,
        draft: TagSettingDetailDraft(
          tagName: domain.tagName,
          isVisible: domain.isVisible,
        ),
      ));
    } on Exception catch (e) {
      emit(TagSettingDetailError(e.toString()));
    }
  }

  Future<void> _onNameChanged(
    TagSettingDetailNameChanged event,
    Emitter<TagSettingDetailState> emit,
  ) async {
    if (state is TagSettingDetailLoaded) {
      final current = state as TagSettingDetailLoaded;
      final isBlank = event.value.trim().isEmpty;
      emit(current.copyWith(
        draft: current.draft.copyWith(tagName: event.value),
        validationError: isBlank ? '空欄' : null,
        clearValidationError: !isBlank,
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onIsVisibleChanged(
    TagSettingDetailIsVisibleChanged event,
    Emitter<TagSettingDetailState> emit,
  ) async {
    if (state is TagSettingDetailLoaded) {
      final current = state as TagSettingDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(isVisible: event.value),
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onSaveTapped(
    TagSettingDetailSaveTapped event,
    Emitter<TagSettingDetailState> emit,
  ) async {
    if (state is! TagSettingDetailLoaded) return;
    final current = state as TagSettingDetailLoaded;

    if (current.draft.tagName.trim().isEmpty) {
      emit(current.copyWith(
        validationError: 'タグ名を入力してください',
      ));
      return;
    }

    emit(current.copyWith(isSaving: true, clearSaveError: true));

    try {
      final now = DateTime.now();

      // 既存かどうかを確認
      final all = await _tagRepository.fetchAll();
      final exists = all.any((t) => t.id == current.tagId);

      final domain = TagDomain(
        id: current.tagId,
        tagName: current.draft.tagName.trim(),
        isVisible: current.draft.isVisible,
        isDeleted: false,
        createdAt: exists
            ? all.firstWhere((t) => t.id == current.tagId).createdAt
            : now,
        updatedAt: now,
      );

      await _tagRepository.save(domain);

      emit(current.copyWith(
        isSaving: false,
        delegate: const TagSettingDetailDidSaveDelegate(),
      ));
    } on Exception catch (e) {
      final loaded = state as TagSettingDetailLoaded;
      emit(loaded.copyWith(
        isSaving: false,
        saveErrorMessage: '保存に失敗しました: ${e.toString()}',
      ));
    }
  }

  Future<void> _onBackTapped(
    TagSettingDetailBackTapped event,
    Emitter<TagSettingDetailState> emit,
  ) async {
    if (state is TagSettingDetailLoaded) {
      final current = state as TagSettingDetailLoaded;
      emit(current.copyWith(
        delegate: const TagSettingDetailDismissDelegate(),
      ));
    }
  }
}
