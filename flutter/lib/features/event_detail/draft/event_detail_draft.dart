import 'package:equatable/equatable.dart';

/// EventDetailで選択中のタブ
enum EventDetailTab { basicInfo, michiInfo, paymentInfo, overview }

/// EventDetailのDraft
/// タブ選択状態のみを保持する（編集状態は各子Featureが管理する）
class EventDetailDraft extends Equatable {
  final EventDetailTab selectedTab;

  const EventDetailDraft({this.selectedTab = EventDetailTab.basicInfo});

  EventDetailDraft copyWith({EventDetailTab? selectedTab}) {
    return EventDetailDraft(selectedTab: selectedTab ?? this.selectedTab);
  }

  @override
  List<Object?> get props => [selectedTab];
}
