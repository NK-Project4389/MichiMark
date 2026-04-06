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

/// 交通手段編集ボタンが押されたとき
class BasicInfoEditTransPressed extends BasicInfoEvent {
  const BasicInfoEditTransPressed();

  @override
  List<Object?> get props => [];
}

/// 選択画面から交通手段が返却されたとき
class BasicInfoTransSelected extends BasicInfoEvent {
  final TransDomain? trans;
  const BasicInfoTransSelected(this.trans);

  @override
  List<Object?> get props => [trans];
}

/// メンバー編集ボタンが押されたとき
class BasicInfoEditMembersPressed extends BasicInfoEvent {
  const BasicInfoEditMembersPressed();

  @override
  List<Object?> get props => [];
}

/// 選択画面からメンバーが返却されたとき
class BasicInfoMembersSelected extends BasicInfoEvent {
  final List<MemberDomain> members;
  const BasicInfoMembersSelected(this.members);

  @override
  List<Object?> get props => [members];
}

/// タグ編集ボタンが押されたとき（選択画面遷移用。現在は基本画面から未使用）
class BasicInfoEditTagsPressed extends BasicInfoEvent {
  const BasicInfoEditTagsPressed();

  @override
  List<Object?> get props => [];
}

/// 選択画面からタグが返却されたとき（選択画面遷移用。現在は基本画面から未使用）
class BasicInfoTagsSelected extends BasicInfoEvent {
  final List<TagDomain> tags;
  const BasicInfoTagsSelected(this.tags);

  @override
  List<Object?> get props => [tags];
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

/// ガソリン支払メンバー編集ボタンが押されたとき
class BasicInfoEditPayMemberPressed extends BasicInfoEvent {
  const BasicInfoEditPayMemberPressed();

  @override
  List<Object?> get props => [];
}

/// 選択画面からガソリン支払メンバーが返却されたとき
class BasicInfoPayMemberSelected extends BasicInfoEvent {
  final MemberDomain? payMember;
  const BasicInfoPayMemberSelected(this.payMember);

  @override
  List<Object?> get props => [payMember];
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
