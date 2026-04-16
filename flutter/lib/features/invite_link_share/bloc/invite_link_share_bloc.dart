import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repository/auth_repository.dart';
import '../../invite_code_input/repository/invitation_repository.dart';
import '../adapter/invite_link_share_adapter.dart';
import '../draft/invite_link_share_draft.dart';
import 'invite_link_share_event.dart';
import 'invite_link_share_state.dart';

class InviteLinkShareBloc
    extends Bloc<InviteLinkShareEvent, InviteLinkShareState> {
  final InvitationRepository _invitationRepository;
  final AuthRepository _authRepository;
  final String eventId;

  InviteLinkShareBloc({
    required InvitationRepository invitationRepository,
    required AuthRepository authRepository,
    required this.eventId,
  })  : _invitationRepository = invitationRepository,
        _authRepository = authRepository,
        super(const InviteLinkShareSetting(
          draft: InviteLinkShareDraft(),
        )) {
    on<InviteLinkShareStarted>(_onStarted);
    on<InviteLinkRoleChanged>(_onRoleChanged);
    on<InviteLinkExpiresHoursChanged>(_onExpiresHoursChanged);
    on<InviteLinkMaxUsesChanged>(_onMaxUsesChanged);
    on<InviteLinkCreatePressed>(_onCreatePressed);
  }

  void _onStarted(
    InviteLinkShareStarted event,
    Emitter<InviteLinkShareState> emit,
  ) {
    emit(const InviteLinkShareSetting(
      draft: InviteLinkShareDraft(),
    ));
  }

  void _onRoleChanged(
    InviteLinkRoleChanged event,
    Emitter<InviteLinkShareState> emit,
  ) {
    final currentDraft = _currentDraft;
    if (currentDraft == null) return;
    emit(InviteLinkShareSetting(
      draft: currentDraft.copyWith(role: event.role),
    ));
  }

  void _onExpiresHoursChanged(
    InviteLinkExpiresHoursChanged event,
    Emitter<InviteLinkShareState> emit,
  ) {
    final currentDraft = _currentDraft;
    if (currentDraft == null) return;
    emit(InviteLinkShareSetting(
      draft: currentDraft.copyWith(expiresHours: event.expiresHours),
    ));
  }

  void _onMaxUsesChanged(
    InviteLinkMaxUsesChanged event,
    Emitter<InviteLinkShareState> emit,
  ) {
    final currentDraft = _currentDraft;
    if (currentDraft == null) return;
    emit(InviteLinkShareSetting(
      draft: currentDraft.copyWith(maxUses: () => event.maxUses),
    ));
  }

  Future<void> _onCreatePressed(
    InviteLinkCreatePressed event,
    Emitter<InviteLinkShareState> emit,
  ) async {
    final currentDraft = _currentDraft;
    if (currentDraft == null) return;

    emit(InviteLinkShareCreating(draft: currentDraft));

    try {
      final uid = _authRepository.currentUid;
      if (uid == null) {
        emit(InviteLinkShareError(
          errorMessage: '認証情報が取得できませんでした',
          draft: currentDraft,
        ));
        return;
      }

      final request = InviteLinkShareAdapter.toCreateRequest(
        currentDraft,
        eventId,
        uid,
      );
      final response =
          await _invitationRepository.createInvitation(request);
      final result = InviteLinkShareAdapter.toResult(response);
      emit(InviteLinkShareCreated(result: result));
    } on Exception catch (e) {
      emit(InviteLinkShareError(
        errorMessage: e.toString(),
        draft: currentDraft,
      ));
    }
  }

  /// 現在のStateからDraftを取得する。
  InviteLinkShareDraft? get _currentDraft {
    final current = state;
    return switch (current) {
      InviteLinkShareSetting(:final draft) => draft,
      InviteLinkShareCreating(:final draft) => draft,
      InviteLinkShareError(:final draft) => draft,
      InviteLinkShareCreated() => null,
    };
  }
}
