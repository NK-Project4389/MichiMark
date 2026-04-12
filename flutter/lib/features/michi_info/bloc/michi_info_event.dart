import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../features/link_detail/draft/link_detail_draft.dart';
import '../../../features/mark_detail/draft/mark_detail_draft.dart';

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

/// ⚡ アイコンボタンがタップされたとき（ActionTime ボトムシート表示トリガー）
class MichiInfoActionButtonPressed extends MichiInfoEvent {
  final String markLinkId;
  final String eventId;
  final TopicConfig topicConfig;
  final MarkOrLink markOrLink;

  const MichiInfoActionButtonPressed({
    required this.markLinkId,
    required this.eventId,
    required this.topicConfig,
    this.markOrLink = MarkOrLink.mark,
  });

  @override
  List<Object?> get props => [markLinkId, eventId, topicConfig, markOrLink];
}

/// ボトムシートを閉じた後に状態ラベルを更新するとき
class MichiInfoActionStateLabelUpdated extends MichiInfoEvent {
  final String markLinkId;
  final String currentStateLabel;

  const MichiInfoActionStateLabelUpdated({
    required this.markLinkId,
    required this.currentStateLabel,
  });

  @override
  List<Object?> get props => [markLinkId, currentStateLabel];
}

/// delegate を消費してクリアするとき（画面遷移完了後に dispatch）
class MichiInfoDelegateConsumed extends MichiInfoEvent {
  const MichiInfoDelegateConsumed();

  @override
  List<Object?> get props => [];
}

/// FAB タップ（挿入モードのトグル）
class MichiInfoInsertModeFabPressed extends MichiInfoEvent {
  const MichiInfoInsertModeFabPressed();

  @override
  List<Object?> get props => [];
}

/// インジケータータップ（挿入ポイント確定）
/// [insertAfterSeq] 直前カードの markLinkSeq。末尾インジケーターの場合は全アイテムの最大 seq
class MichiInfoInsertPointSelected extends MichiInfoEvent {
  final int insertAfterSeq;
  const MichiInfoInsertPointSelected(this.insertAfterSeq);

  @override
  List<Object?> get props => [insertAfterSeq];
}

/// 挿入モードで Mark 追加を選択したとき
class MichiInfoInsertMarkPressed extends MichiInfoEvent {
  const MichiInfoInsertMarkPressed();

  @override
  List<Object?> get props => [];
}

/// 挿入モードで Link 追加を選択したとき
class MichiInfoInsertLinkPressed extends MichiInfoEvent {
  const MichiInfoInsertLinkPressed();

  @override
  List<Object?> get props => [];
}

/// 挿入ポイント選択をキャンセルしたとき（BottomSheet を閉じた）
class MichiInfoInsertPointCancelled extends MichiInfoEvent {
  const MichiInfoInsertPointCancelled();

  @override
  List<Object?> get props => [];
}

/// Mark/Link 詳細から戻ったとき DB からリロードするとき（ローディング表示なし）
class MichiInfoReloadRequested extends MichiInfoEvent {
  const MichiInfoReloadRequested();

  @override
  List<Object?> get props => [];
}

/// カード（Mark または Link）の削除ボタンがタップされたとき
class MichiInfoCardDeleteRequested extends MichiInfoEvent {
  final String markLinkId;
  const MichiInfoCardDeleteRequested(this.markLinkId);

  @override
  List<Object?> get props => [markLinkId];
}

/// ミチタブが非アクティブになったとき（他のタブに切り替わった）
/// 追加モード（挿入モード）をリセットするために使用する
class MichiInfoTabDeactivated extends MichiInfoEvent {
  const MichiInfoTabDeactivated();

  @override
  List<Object?> get props => [];
}
