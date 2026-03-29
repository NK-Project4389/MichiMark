import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/master/member/member_domain.dart';
import '../../../../repository/member_repository.dart';
import '../draft/member_setting_detail_draft.dart';
import 'member_setting_detail_event.dart';
import 'member_setting_detail_state.dart';

class MemberSettingDetailBloc
    extends Bloc<MemberSettingDetailEvent, MemberSettingDetailState> {
  MemberSettingDetailBloc({required MemberRepository memberRepository})
      : _memberRepository = memberRepository,
        super(const MemberSettingDetailLoading()) {
    on<MemberSettingDetailStarted>(_onStarted);
    on<MemberSettingDetailNameChanged>(_onNameChanged);
    on<MemberSettingDetailIsVisibleChanged>(_onIsVisibleChanged);
    on<MemberSettingDetailSaveTapped>(_onSaveTapped);
    on<MemberSettingDetailBackTapped>(_onBackTapped);
  }

  final MemberRepository _memberRepository;

  Future<void> _onStarted(
    MemberSettingDetailStarted event,
    Emitter<MemberSettingDetailState> emit,
  ) async {
    emit(const MemberSettingDetailLoading());

    if (event.memberId == null) {
      final newId = const Uuid().v4();
      emit(MemberSettingDetailLoaded(
        memberId: newId,
        draft: const MemberSettingDetailDraft(),
      ));
      return;
    }

    try {
      final all = await _memberRepository.fetchAll();
      final domain = all.where((m) => m.id == event.memberId).firstOrNull;
      if (domain == null) {
        emit(const MemberSettingDetailError('メンバーが見つかりません'));
        return;
      }
      emit(MemberSettingDetailLoaded(
        memberId: domain.id,
        draft: MemberSettingDetailDraft(
          memberName: domain.memberName,
          isVisible: domain.isVisible,
        ),
      ));
    } on Exception catch (e) {
      emit(MemberSettingDetailError(e.toString()));
    }
  }

  Future<void> _onNameChanged(
    MemberSettingDetailNameChanged event,
    Emitter<MemberSettingDetailState> emit,
  ) async {
    if (state is MemberSettingDetailLoaded) {
      final current = state as MemberSettingDetailLoaded;
      final isBlank = event.value.trim().isEmpty;
      emit(current.copyWith(
        draft: current.draft.copyWith(memberName: event.value),
        validationError: isBlank ? '空欄' : null,
        clearValidationError: !isBlank,
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onIsVisibleChanged(
    MemberSettingDetailIsVisibleChanged event,
    Emitter<MemberSettingDetailState> emit,
  ) async {
    if (state is MemberSettingDetailLoaded) {
      final current = state as MemberSettingDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(isVisible: event.value),
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onSaveTapped(
    MemberSettingDetailSaveTapped event,
    Emitter<MemberSettingDetailState> emit,
  ) async {
    if (state is! MemberSettingDetailLoaded) return;
    final current = state as MemberSettingDetailLoaded;

    if (current.draft.memberName.trim().isEmpty) {
      emit(current.copyWith(
        validationError: 'メンバー名を入力してください',
      ));
      return;
    }

    emit(current.copyWith(isSaving: true, clearSaveError: true));

    try {
      final now = DateTime.now();
      final all = await _memberRepository.fetchAll();
      final existing = all.where((m) => m.id == current.memberId).firstOrNull;

      final domain = MemberDomain(
        id: current.memberId,
        memberName: current.draft.memberName.trim(),
        mailAddress: existing?.mailAddress,
        isVisible: current.draft.isVisible,
        isDeleted: false,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      await _memberRepository.save(domain);

      emit(current.copyWith(
        isSaving: false,
        delegate: const MemberSettingDetailDidSaveDelegate(),
      ));
    } on Exception catch (e) {
      final loaded = state as MemberSettingDetailLoaded;
      emit(loaded.copyWith(
        isSaving: false,
        saveErrorMessage: '保存に失敗しました: ${e.toString()}',
      ));
    }
  }

  Future<void> _onBackTapped(
    MemberSettingDetailBackTapped event,
    Emitter<MemberSettingDetailState> emit,
  ) async {
    if (state is MemberSettingDetailLoaded) {
      final current = state as MemberSettingDetailLoaded;
      emit(current.copyWith(
        delegate: const MemberSettingDetailDismissDelegate(),
      ));
    }
  }
}
