import 'package:equatable/equatable.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';

sealed class MichiInfoEvent extends Equatable {
  const MichiInfoEvent();
}

/// 画面が表示されたとき
class MichiInfoStarted extends MichiInfoEvent {
  final String eventId;
  const MichiInfoStarted(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// リストのアイテムがタップされたとき
class MichiInfoItemTapped extends MichiInfoEvent {
  final String markLinkId;
  final MarkOrLink type;
  const MichiInfoItemTapped({required this.markLinkId, required this.type});

  @override
  List<Object?> get props => [markLinkId, type];
}

/// 追加ボタンからマーク追加が選ばれたとき
class MichiInfoAddMarkPressed extends MichiInfoEvent {
  const MichiInfoAddMarkPressed();

  @override
  List<Object?> get props => [];
}

/// 追加ボタンからリンク追加が選ばれたとき
class MichiInfoAddLinkPressed extends MichiInfoEvent {
  const MichiInfoAddLinkPressed();

  @override
  List<Object?> get props => [];
}
