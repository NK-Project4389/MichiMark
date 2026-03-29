import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/master/trans/trans_domain.dart';
import '../../../../repository/trans_repository.dart';
import '../draft/trans_setting_detail_draft.dart';
import 'trans_setting_detail_event.dart';
import 'trans_setting_detail_state.dart';

class TransSettingDetailBloc
    extends Bloc<TransSettingDetailEvent, TransSettingDetailState> {
  TransSettingDetailBloc({required TransRepository transRepository})
      : _transRepository = transRepository,
        super(const TransSettingDetailLoading()) {
    on<TransSettingDetailStarted>(_onStarted);
    on<TransSettingDetailNameChanged>(_onNameChanged);
    on<TransSettingDetailKmPerGasChanged>(_onKmPerGasChanged);
    on<TransSettingDetailMeterValueChanged>(_onMeterValueChanged);
    on<TransSettingDetailIsVisibleChanged>(_onIsVisibleChanged);
    on<TransSettingDetailSaveTapped>(_onSaveTapped);
    on<TransSettingDetailBackTapped>(_onBackTapped);
  }

  final TransRepository _transRepository;
  static final _numberFormat = NumberFormat('#,###');

  Future<void> _onStarted(
    TransSettingDetailStarted event,
    Emitter<TransSettingDetailState> emit,
  ) async {
    emit(const TransSettingDetailLoading());

    if (event.transId == null) {
      final newId = const Uuid().v4();
      emit(TransSettingDetailLoaded(
        transId: newId,
        draft: const TransSettingDetailDraft(),
      ));
      return;
    }

    try {
      final all = await _transRepository.fetchAll();
      final domain = all.where((t) => t.id == event.transId).firstOrNull;
      if (domain == null) {
        emit(const TransSettingDetailError('交通手段が見つかりません'));
        return;
      }
      emit(TransSettingDetailLoaded(
        transId: domain.id,
        draft: TransSettingDetailDraft(
          transName: domain.transName,
          displayKmPerGas: domain.kmPerGas != null
              ? (domain.kmPerGas! / 10.0).toStringAsFixed(1)
              : '',
          displayMeterValue: domain.meterValue != null
              ? _numberFormat.format(domain.meterValue)
              : '',
          isVisible: domain.isVisible,
        ),
      ));
    } on Exception catch (e) {
      emit(TransSettingDetailError(e.toString()));
    }
  }

  Future<void> _onNameChanged(
    TransSettingDetailNameChanged event,
    Emitter<TransSettingDetailState> emit,
  ) async {
    if (state is TransSettingDetailLoaded) {
      final current = state as TransSettingDetailLoaded;
      final isBlank = event.value.trim().isEmpty;
      emit(current.copyWith(
        draft: current.draft.copyWith(transName: event.value),
        nameError: isBlank ? '空欄' : null,
        clearNameError: !isBlank,
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onKmPerGasChanged(
    TransSettingDetailKmPerGasChanged event,
    Emitter<TransSettingDetailState> emit,
  ) async {
    if (state is TransSettingDetailLoaded) {
      final current = state as TransSettingDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(displayKmPerGas: event.value),
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onMeterValueChanged(
    TransSettingDetailMeterValueChanged event,
    Emitter<TransSettingDetailState> emit,
  ) async {
    if (state is TransSettingDetailLoaded) {
      final current = state as TransSettingDetailLoaded;
      // カンマ整形
      final raw = event.value.replaceAll(',', '');
      final formatted = int.tryParse(raw) != null
          ? _numberFormat.format(int.parse(raw))
          : event.value;
      emit(current.copyWith(
        draft: current.draft.copyWith(displayMeterValue: formatted),
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onIsVisibleChanged(
    TransSettingDetailIsVisibleChanged event,
    Emitter<TransSettingDetailState> emit,
  ) async {
    if (state is TransSettingDetailLoaded) {
      final current = state as TransSettingDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(isVisible: event.value),
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onSaveTapped(
    TransSettingDetailSaveTapped event,
    Emitter<TransSettingDetailState> emit,
  ) async {
    if (state is! TransSettingDetailLoaded) return;
    final current = state as TransSettingDetailLoaded;

    final errors = _validate(current.draft);
    if (errors.nameError != null ||
        errors.kmPerGasError != null ||
        errors.meterValueError != null) {
      emit(current.copyWith(
        nameError: errors.nameError,
        kmPerGasError: errors.kmPerGasError,
        meterValueError: errors.meterValueError,
      ));
      return;
    }

    emit(current.copyWith(isSaving: true, clearSaveError: true));

    try {
      final now = DateTime.now();
      final all = await _transRepository.fetchAll();
      final existing = all.where((t) => t.id == current.transId).firstOrNull;

      final domain = TransDomain(
        id: current.transId,
        transName: current.draft.transName.trim(),
        kmPerGas: current.draft.kmPerGas,
        meterValue: current.draft.meterValue,
        isVisible: current.draft.isVisible,
        isDeleted: false,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      await _transRepository.save(domain);

      emit(current.copyWith(
        isSaving: false,
        delegate: const TransSettingDetailDidSaveDelegate(),
      ));
    } on Exception catch (e) {
      final loaded = state as TransSettingDetailLoaded;
      emit(loaded.copyWith(
        isSaving: false,
        saveErrorMessage: '保存に失敗しました: ${e.toString()}',
      ));
    }
  }

  Future<void> _onBackTapped(
    TransSettingDetailBackTapped event,
    Emitter<TransSettingDetailState> emit,
  ) async {
    if (state is TransSettingDetailLoaded) {
      final current = state as TransSettingDetailLoaded;
      emit(current.copyWith(
        delegate: const TransSettingDetailDismissDelegate(),
      ));
    }
  }

  _ValidationErrors _validate(TransSettingDetailDraft draft) {
    String? nameError;
    String? kmPerGasError;
    String? meterValueError;

    if (draft.transName.trim().isEmpty) {
      nameError = '交通手段名を入力してください';
    }

    final kmRaw = draft.displayKmPerGas.trim();
    if (kmRaw.isEmpty) {
      kmPerGasError = '燃費を入力してください';
    } else {
      final regex = RegExp(r'^\d+(\.\d)?$');
      if (!regex.hasMatch(kmRaw)) {
        kmPerGasError = '燃費は小数第1位までの数値で入力してください';
      }
    }

    final meterRaw = draft.displayMeterValue.replaceAll(',', '').trim();
    if (meterRaw.isEmpty) {
      meterValueError = 'メーターを入力してください';
    } else if (int.tryParse(meterRaw) == null) {
      meterValueError = 'メーターは正の整数で入力してください';
    }

    return _ValidationErrors(
      nameError: nameError,
      kmPerGasError: kmPerGasError,
      meterValueError: meterValueError,
    );
  }
}

class _ValidationErrors {
  final String? nameError;
  final String? kmPerGasError;
  final String? meterValueError;

  const _ValidationErrors({
    this.nameError,
    this.kmPerGasError,
    this.meterValueError,
  });
}
