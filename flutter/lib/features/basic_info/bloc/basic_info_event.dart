import 'package:equatable/equatable.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/master/tag/tag_domain.dart';
import '../../../domain/master/trans/trans_domain.dart';
import '../../../domain/topic/topic_domain.dart';

sealed class BasicInfoEvent extends Equatable {
  const BasicInfoEvent();
}

/// 画面が表示されたとき
class BasicInfoStarted extends BasicInfoEvent {
  final String eventId;

  /// 新規作成時のTopic種別。既存イベントでは null を渡す（DB値を使用）
  final TopicType? initialTopicType;

  const BasicInfoStarted(this.eventId, {this.initialTopicType});

  @override
  List<Object?> get props => [eventId, initialTopicType];
}

/// イベント名が変更されたとき
class BasicInfoEventNameChanged extends BasicInfoEvent {
  final String name;
  const BasicInfoEventNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

/// TransチップがタップされたときMFY（同一TransでOFF、別TransでON）
class BasicInfoTransChipToggled extends BasicInfoEvent {
  final TransDomain trans;
  const BasicInfoTransChipToggled(this.trans);

  @override
  List<Object?> get props => [trans];
}

/// タグ入力フィールドのテキストが変化したとき
class BasicInfoTagInputChanged extends BasicInfoEvent {
  final String input;
  const BasicInfoTagInputChanged(this.input);

  @override
  List<Object?> get props => [input];
}

/// サジェストリストからタグが選択されたとき
class BasicInfoTagSuggestionSelected extends BasicInfoEvent {
  final TagDomain tag;
  const BasicInfoTagSuggestionSelected(this.tag);

  @override
  List<Object?> get props => [tag];
}

/// タグ入力フィールドで確定（新規タグ作成を含む）
class BasicInfoTagInputConfirmed extends BasicInfoEvent {
  final String input;
  const BasicInfoTagInputConfirmed(this.input);

  @override
  List<Object?> get props => [input];
}

/// 選択済みタグが削除されたとき
class BasicInfoTagRemoved extends BasicInfoEvent {
  final TagDomain tag;
  const BasicInfoTagRemoved(this.tag);

  @override
  List<Object?> get props => [tag];
}

/// メンバー入力欄のテキストが変化したとき
class BasicInfoMemberInputChanged extends BasicInfoEvent {
  final String input;
  const BasicInfoMemberInputChanged(this.input);

  @override
  List<Object?> get props => [input];
}

/// サジェストリストからメンバーが選択されたとき
class BasicInfoMemberSuggestionSelected extends BasicInfoEvent {
  final MemberDomain member;
  const BasicInfoMemberSuggestionSelected(this.member);

  @override
  List<Object?> get props => [member];
}

/// メンバー入力欄でキーボード確定時（マスタ一致→追加、未登録→マスタ登録+追加）
class BasicInfoMemberInputConfirmed extends BasicInfoEvent {
  final String input;
  const BasicInfoMemberInputConfirmed(this.input);

  @override
  List<Object?> get props => [input];
}

/// 選択済みメンバーが削除されたとき
class BasicInfoMemberRemoved extends BasicInfoEvent {
  final MemberDomain member;
  const BasicInfoMemberRemoved(this.member);

  @override
  List<Object?> get props => [member];
}

/// GasPayMemberチップがタップされたとき（同一MemberでOFF、別MemberでON）
class BasicInfoPayMemberChipToggled extends BasicInfoEvent {
  final MemberDomain member;
  const BasicInfoPayMemberChipToggled(this.member);

  @override
  List<Object?> get props => [member];
}

/// 燃費入力が変更されたとき
class BasicInfoKmPerGasChanged extends BasicInfoEvent {
  final String input;
  const BasicInfoKmPerGasChanged(this.input);

  @override
  List<Object?> get props => [input];
}

/// ガソリン単価入力が変更されたとき
class BasicInfoPricePerGasChanged extends BasicInfoEvent {
  final String input;
  const BasicInfoPricePerGasChanged(this.input);

  @override
  List<Object?> get props => [input];
}

/// 編集モードに入ったとき
class BasicInfoEditModeEntered extends BasicInfoEvent {
  const BasicInfoEditModeEntered();

  @override
  List<Object?> get props => [];
}

/// 保存ボタンが押されたとき（DB保存）
/// [withDismiss] が true の場合、保存後に画面を閉じる（「保存して戻る」）
class BasicInfoSavePressed extends BasicInfoEvent {
  final bool withDismiss;
  const BasicInfoSavePressed({this.withDismiss = false});

  @override
  List<Object?> get props => [withDismiss];
}

/// 編集がキャンセルされたとき
class BasicInfoEditCancelled extends BasicInfoEvent {
  const BasicInfoEditCancelled();

  @override
  List<Object?> get props => [];
}

/// delegateを消費したとき（再タップを有効にするためdelegateをnullにリセット）
class BasicInfoDelegateConsumed extends BasicInfoEvent {
  const BasicInfoDelegateConsumed();

  @override
  List<Object?> get props => [];
}
