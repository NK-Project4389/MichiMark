import 'package:flutter_bloc/flutter_bloc.dart';
import '../adapter/invite_code_input_adapter.dart';
import '../domain/invite_code_error_type.dart';
import '../repository/invitation_repository.dart';
import 'invite_code_input_event.dart';
import 'invite_code_input_state.dart';

class InviteCodeInputBloc
    extends Bloc<InviteCodeInputEvent, InviteCodeInputState> {
  final InvitationRepository _invitationRepository;

  /// コード入力フォーマット正規表現: ^[A-Z]{3}-[0-9]{4}$
  static final _codePattern = RegExp(r'^[A-Z]{3}-[0-9]{4}$');

  InviteCodeInputBloc({
    required InvitationRepository invitationRepository,
  })  : _invitationRepository = invitationRepository,
        super(const InviteCodeInputInitial()) {
    on<InviteCodeChanged>(_onCodeChanged);
    on<InviteCodeSubmitted>(_onSubmitted);
    on<InviteCodeMemberSelected>(_onMemberSelected);
    on<InviteCodeJoinConfirmed>(_onJoinConfirmed);
    on<InviteCodeBackToInput>(_onBackToInput);
  }

  void _onCodeChanged(
    InviteCodeChanged event,
    Emitter<InviteCodeInputState> emit,
  ) {
    final upper = event.code.toUpperCase();
    emit(InviteCodeInputInitial(code: upper));
  }

  Future<void> _onSubmitted(
    InviteCodeSubmitted event,
    Emitter<InviteCodeInputState> emit,
  ) async {
    final currentState = state;
    final code = switch (currentState) {
      InviteCodeInputInitial(:final code) => code,
      _ => '',
    };

    if (!_codePattern.hasMatch(code)) {
      emit(InviteCodeInputInitial(
        code: code,
        formatError: 'ABC-1234の形式で入力してください',
      ));
      return;
    }

    emit(const InviteCodeInputValidating());

    try {
      final info = await _invitationRepository.getInvitationByCode(code);
      final parsed = InviteCodeInputAdapter.fromCodeInvitationInfo(info);
      emit(InviteCodeInputMemberSelection(
        code: code,
        eventName: parsed.eventName,
        members: parsed.members,
      ));
    } on InviteCodeApiException catch (e) {
      emit(InviteCodeInputError(
        errorType: InviteCodeInputAdapter.toErrorType(e.errorType),
      ));
    } catch (_) {
      emit(const InviteCodeInputError(errorType: InviteCodeErrorType.networkError));
    }
  }

  void _onMemberSelected(
    InviteCodeMemberSelected event,
    Emitter<InviteCodeInputState> emit,
  ) {
    final currentState = state;
    if (currentState is! InviteCodeInputMemberSelection) return;

    emit(InviteCodeInputMemberSelection(
      code: currentState.code,
      eventName: currentState.eventName,
      members: currentState.members,
      selectedMemberId: event.memberId,
    ));
  }

  Future<void> _onJoinConfirmed(
    InviteCodeJoinConfirmed event,
    Emitter<InviteCodeInputState> emit,
  ) async {
    final currentState = state;
    if (currentState is! InviteCodeInputMemberSelection) return;

    final selectedMemberId = currentState.selectedMemberId;
    if (selectedMemberId == null) return;

    emit(const InviteCodeInputJoining());

    try {
      final result = await _invitationRepository.joinByCode(
        code: currentState.code,
        uid: '',
        memberId: selectedMemberId,
      );
      emit(InviteCodeInputJoined(
        eventId: result.eventId,
        eventName: currentState.eventName,
      ));
    } on InviteCodeApiException catch (e) {
      emit(InviteCodeInputError(
        errorType: InviteCodeInputAdapter.toErrorType(e.errorType),
      ));
    } catch (_) {
      emit(const InviteCodeInputError(errorType: InviteCodeErrorType.networkError));
    }
  }

  void _onBackToInput(
    InviteCodeBackToInput event,
    Emitter<InviteCodeInputState> emit,
  ) {
    emit(const InviteCodeInputInitial());
  }
}

/// 招待APIエラー例外（errorTypeはAPIの文字列をそのまま保持）
class InviteCodeApiException implements Exception {
  final String errorType;
  const InviteCodeApiException(this.errorType);
}
