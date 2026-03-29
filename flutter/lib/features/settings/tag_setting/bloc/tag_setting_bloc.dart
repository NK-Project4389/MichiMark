import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../adapter/settings_adapter.dart';
import '../../../../repository/tag_repository.dart';
import 'tag_setting_event.dart';
import 'tag_setting_state.dart';

class TagSettingBloc extends Bloc<TagSettingEvent, TagSettingState> {
  TagSettingBloc({required TagRepository tagRepository})
      : _tagRepository = tagRepository,
        super(const TagSettingLoading()) {
    on<TagSettingStarted>(_onStarted);
    on<TagSettingItemSelected>(_onItemSelected);
    on<TagSettingAddTapped>(_onAddTapped);
  }

  final TagRepository _tagRepository;

  Future<void> _onStarted(
    TagSettingStarted event,
    Emitter<TagSettingState> emit,
  ) async {
    emit(const TagSettingLoading());
    try {
      final domains = await _tagRepository.fetchAll();
      final items = domains.map(SettingsAdapter.toTagProjection).toList();
      emit(TagSettingLoaded(items: items));
    } on Exception catch (e) {
      emit(TagSettingError(e.toString()));
    }
  }

  Future<void> _onItemSelected(
    TagSettingItemSelected event,
    Emitter<TagSettingState> emit,
  ) async {
    if (state is TagSettingLoaded) {
      final current = state as TagSettingLoaded;
      emit(current.copyWith(
        delegate: TagSettingOpenDetailDelegate(event.tagId),
      ));
    }
  }

  Future<void> _onAddTapped(
    TagSettingAddTapped event,
    Emitter<TagSettingState> emit,
  ) async {
    if (state is TagSettingLoaded) {
      final current = state as TagSettingLoaded;
      emit(current.copyWith(delegate: const TagSettingOpenNewDelegate()));
    }
  }
}
