import 'package:equatable/equatable.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/master/tag/tag_domain.dart';
import '../../../domain/master/trans/trans_domain.dart';
import '../../../domain/topic/topic_domain.dart';

/// BasicInfo タブの編集状態を保持するDraft。
/// マスター系は選択済みDomainオブジェクトをそのまま保持する（SelectedXXXパターン）。
class BasicInfoDraft extends Equatable {
  /// イベント名の入力文字列
  final String eventName;

  /// 選択中の交通手段（未選択時はnull）
  final TransDomain? selectedTrans;

  /// 選択中のメンバー一覧
  final List<MemberDomain> selectedMembers;

  /// 選択中のタグ一覧
  final List<TagDomain> selectedTags;

  /// 選択中のガソリン支払メンバー（未選択時はnull）
  final MemberDomain? selectedPayMember;

  /// 燃費の入力文字列（例: "15.5"。未入力時は空文字）
  final String kmPerGasInput;

  /// ガソリン単価の入力文字列（例: "170"。未入力時は空文字）
  final String pricePerGasInput;

  /// 選択中のTopic（null = 未設定）。読み取り専用表示用（REQ-001）
  final TopicDomain? selectedTopic;

  /// 編集モードフラグ（false = 参照モード、true = 編集モード）
  final bool isEditing;

  const BasicInfoDraft({
    this.eventName = '',
    this.selectedTrans,
    this.selectedMembers = const [],
    this.selectedTags = const [],
    this.selectedPayMember,
    this.kmPerGasInput = '',
    this.pricePerGasInput = '',
    this.selectedTopic,
    this.isEditing = false,
  });

  BasicInfoDraft copyWith({
    String? eventName,
    TransDomain? selectedTrans,
    List<MemberDomain>? selectedMembers,
    List<TagDomain>? selectedTags,
    MemberDomain? selectedPayMember,
    String? kmPerGasInput,
    String? pricePerGasInput,
    TopicDomain? selectedTopic,
    bool clearSelectedTopic = false,
    bool? isEditing,
  }) {
    return BasicInfoDraft(
      eventName: eventName ?? this.eventName,
      selectedTrans: selectedTrans ?? this.selectedTrans,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      selectedTags: selectedTags ?? this.selectedTags,
      selectedPayMember: selectedPayMember ?? this.selectedPayMember,
      kmPerGasInput: kmPerGasInput ?? this.kmPerGasInput,
      pricePerGasInput: pricePerGasInput ?? this.pricePerGasInput,
      selectedTopic: clearSelectedTopic ? null : (selectedTopic ?? this.selectedTopic),
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [
        eventName,
        selectedTrans,
        selectedMembers,
        selectedTags,
        selectedPayMember,
        kmPerGasInput,
        pricePerGasInput,
        selectedTopic,
        isEditing,
      ];
}
