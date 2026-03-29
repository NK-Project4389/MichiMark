import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../adapter/settings_adapter.dart';
import '../../../../repository/trans_repository.dart';
import 'trans_setting_event.dart';
import 'trans_setting_state.dart';

class TransSettingBloc extends Bloc<TransSettingEvent, TransSettingState> {
  TransSettingBloc({required TransRepository transRepository})
      : _transRepository = transRepository,
        super(const TransSettingLoading()) {
    on<TransSettingStarted>(_onStarted);
    on<TransSettingItemSelected>(_onItemSelected);
    on<TransSettingAddTapped>(_onAddTapped);
  }

  final TransRepository _transRepository;

  Future<void> _onStarted(
    TransSettingStarted event,
    Emitter<TransSettingState> emit,
  ) async {
    emit(const TransSettingLoading());
    try {
      final domains = await _transRepository.fetchAll();
      final items = domains.map(SettingsAdapter.toTransProjection).toList();
      emit(TransSettingLoaded(items: items));
    } on Exception catch (e) {
      emit(TransSettingError(e.toString()));
    }
  }

  Future<void> _onItemSelected(
    TransSettingItemSelected event,
    Emitter<TransSettingState> emit,
  ) async {
    if (state is TransSettingLoaded) {
      final current = state as TransSettingLoaded;
      emit(current.copyWith(
        delegate: TransSettingOpenDetailDelegate(event.transId),
      ));
    }
  }

  Future<void> _onAddTapped(
    TransSettingAddTapped event,
    Emitter<TransSettingState> emit,
  ) async {
    if (state is TransSettingLoaded) {
      final current = state as TransSettingLoaded;
      emit(current.copyWith(delegate: const TransSettingOpenNewDelegate()));
    }
  }
}
