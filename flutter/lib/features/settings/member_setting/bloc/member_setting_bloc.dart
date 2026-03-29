import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../adapter/settings_adapter.dart';
import '../../../../repository/member_repository.dart';
import 'member_setting_event.dart';
import 'member_setting_state.dart';

class MemberSettingBloc extends Bloc<MemberSettingEvent, MemberSettingState> {
  MemberSettingBloc({required MemberRepository memberRepository})
      : _memberRepository = memberRepository,
        super(const MemberSettingLoading()) {
    on<MemberSettingStarted>(_onStarted);
    on<MemberSettingItemSelected>(_onItemSelected);
    on<MemberSettingAddTapped>(_onAddTapped);
  }

  final MemberRepository _memberRepository;

  Future<void> _onStarted(
    MemberSettingStarted event,
    Emitter<MemberSettingState> emit,
  ) async {
    emit(const MemberSettingLoading());
    try {
      final domains = await _memberRepository.fetchAll();
      final items = domains.map(SettingsAdapter.toMemberProjection).toList();
      emit(MemberSettingLoaded(items: items));
    } on Exception catch (e) {
      emit(MemberSettingError(e.toString()));
    }
  }

  Future<void> _onItemSelected(
    MemberSettingItemSelected event,
    Emitter<MemberSettingState> emit,
  ) async {
    if (state is MemberSettingLoaded) {
      final current = state as MemberSettingLoaded;
      emit(current.copyWith(
        delegate: MemberSettingOpenDetailDelegate(event.memberId),
      ));
    }
  }

  Future<void> _onAddTapped(
    MemberSettingAddTapped event,
    Emitter<MemberSettingState> emit,
  ) async {
    if (state is MemberSettingLoaded) {
      final current = state as MemberSettingLoaded;
      emit(current.copyWith(delegate: const MemberSettingOpenNewDelegate()));
    }
  }
}
