import 'package:equatable/equatable.dart';

/// OverviewはEvent編集を行わない。Draftはイベント参照用の最小構成。
class OverviewDraft extends Equatable {
  /// 対象イベントのID
  final String eventId;

  const OverviewDraft({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}
