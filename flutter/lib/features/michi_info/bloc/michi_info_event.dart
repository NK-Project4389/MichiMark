import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../features/mark_detail/draft/mark_detail_draft.dart';
import '../../../features/link_detail/draft/link_detail_draft.dart';

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

/// MarkDetail画面でDBへの保存が完了して戻ってきたとき
class MichiInfoMarkSaved extends MichiInfoEvent {
  final String markLinkId;
  final MarkDetailDraft draft;
  const MichiInfoMarkSaved({required this.markLinkId, required this.draft});

  @override
  List<Object?> get props => [markLinkId, draft];
}

/// EventDetailBlocからTopicConfigが更新されたとき
class MichiInfoTopicConfigUpdated extends MichiInfoEvent {
  final TopicConfig config;
  const MichiInfoTopicConfigUpdated(this.config);

  @override
  List<Object?> get props => [config];
}

/// LinkDetail画面でDBへの保存が完了して戻ってきたとき
class MichiInfoLinkSaved extends MichiInfoEvent {
  final String markLinkId;
  final LinkDetailDraft draft;
  const MichiInfoLinkSaved({required this.markLinkId, required this.draft});

  @override
  List<Object?> get props => [markLinkId, draft];
}

/// ミチ情報一覧の地点（マーク）に対するアクションボタンが押されたとき
class MichiInfoMarkActionPressed extends MichiInfoEvent {
  final String markLinkId;
  final String actionId;
  const MichiInfoMarkActionPressed({
    required this.markLinkId,
    required this.actionId,
  });

  @override
  List<Object?> get props => [markLinkId, actionId];
}

/// delegate を消費してクリアするとき（画面遷移完了後に dispatch）
class MichiInfoDelegateConsumed extends MichiInfoEvent {
  const MichiInfoDelegateConsumed();

  @override
  List<Object?> get props => [];
}
