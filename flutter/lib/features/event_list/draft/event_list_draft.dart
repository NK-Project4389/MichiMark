import 'package:equatable/equatable.dart';

/// EventList はイベント一覧の表示のみを担う。
/// 編集状態を持たないため Draft は空とする。
class EventListDraft extends Equatable {
  const EventListDraft();

  @override
  List<Object?> get props => [];
}
