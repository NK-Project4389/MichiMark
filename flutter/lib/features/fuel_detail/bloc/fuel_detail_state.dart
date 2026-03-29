import 'package:equatable/equatable.dart';
import '../draft/fuel_detail_draft.dart';

/// FuelDetailのDelegate（親Featureへの通知）
sealed class FuelDetailDelegate extends Equatable {
  const FuelDetailDelegate();
}

/// フィールドが変更されたとき・計算完了後・クリア後に発火
class FuelDetailDraftChanged extends FuelDetailDelegate {
  final FuelDetailDraft draft;
  const FuelDetailDraftChanged(this.draft);

  @override
  List<Object?> get props => [draft];
}

// ---------------------------------------------------------------------------

class FuelDetailState extends Equatable {
  final FuelDetailDraft draft;
  final FuelDetailDelegate? delegate;

  const FuelDetailState({
    required this.draft,
    this.delegate,
  });

  FuelDetailState copyWith({
    FuelDetailDraft? draft,
    FuelDetailDelegate? delegate,
  }) {
    return FuelDetailState(
      draft: draft ?? this.draft,
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [draft, delegate];
}
