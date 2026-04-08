import 'package:equatable/equatable.dart';
import '../../../domain/master/tag/tag_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../draft/basic_info_draft.dart';

/// BasicInfoのDelegate（画面遷移・操作意図の通知）
sealed class BasicInfoDelegate extends Equatable {
  const BasicInfoDelegate();
}

class BasicInfoOpenTransSelectionDelegate extends BasicInfoDelegate {
  const BasicInfoOpenTransSelectionDelegate();

  @override
  List<Object?> get props => [];
}

class BasicInfoOpenMembersSelectionDelegate extends BasicInfoDelegate {
  const BasicInfoOpenMembersSelectionDelegate();

  @override
  List<Object?> get props => [];
}

class BasicInfoOpenTagsSelectionDelegate extends BasicInfoDelegate {
  const BasicInfoOpenTagsSelectionDelegate();

  @override
  List<Object?> get props => [];
}

class BasicInfoOpenPayMemberSelectionDelegate extends BasicInfoDelegate {
  const BasicInfoOpenPayMemberSelectionDelegate();

  @override
  List<Object?> get props => [];
}

class BasicInfoSavedDelegate extends BasicInfoDelegate {
  const BasicInfoSavedDelegate();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------

sealed class BasicInfoState extends Equatable {
  const BasicInfoState();
}

class BasicInfoLoading extends BasicInfoState {
  const BasicInfoLoading();

  @override
  List<Object?> get props => [];
}

class BasicInfoLoaded extends BasicInfoState {
  final BasicInfoDraft draft;
  final BasicInfoDelegate? delegate;

  /// 現在のTopicに基づく表示制御設定
  final TopicConfig topicConfig;

  /// タグマスタ全件キャッシュ（サジェスト検索用）
  final List<TagDomain> allTags;

  /// 現在表示中のタグサジェスト一覧
  final List<TagDomain> tagSuggestions;

  /// DB保存処理中フラグ
  final bool isSaving;

  /// キャンセル時に戻すための元のDraft（編集開始時に保持）
  final BasicInfoDraft? originalDraft;

  const BasicInfoLoaded({
    required this.draft,
    this.delegate,
    required this.topicConfig,
    this.allTags = const [],
    this.tagSuggestions = const [],
    this.isSaving = false,
    this.originalDraft,
  });

  BasicInfoLoaded copyWith({
    BasicInfoDraft? draft,
    BasicInfoDelegate? delegate,
    TopicConfig? topicConfig,
    List<TagDomain>? allTags,
    List<TagDomain>? tagSuggestions,
    bool? isSaving,
    BasicInfoDraft? originalDraft,
  }) {
    return BasicInfoLoaded(
      draft: draft ?? this.draft,
      delegate: delegate,
      topicConfig: topicConfig ?? this.topicConfig,
      allTags: allTags ?? this.allTags,
      tagSuggestions: tagSuggestions ?? this.tagSuggestions,
      isSaving: isSaving ?? this.isSaving,
      originalDraft: originalDraft ?? this.originalDraft,
    );
  }

  @override
  List<Object?> get props => [draft, delegate, topicConfig, allTags, tagSuggestions, isSaving, originalDraft];
}

class BasicInfoError extends BasicInfoState {
  final String message;
  const BasicInfoError({required this.message});

  @override
  List<Object?> get props => [message];
}
