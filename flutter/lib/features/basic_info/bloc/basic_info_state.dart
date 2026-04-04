import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/topic/topic_domain.dart';
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

/// Topic選択画面を開く
class BasicInfoOpenTopicSelectionDelegate extends BasicInfoDelegate {
  const BasicInfoOpenTopicSelectionDelegate();

  @override
  List<Object?> get props => [];
}

/// Topic変更をEventDetailBlocに通知する
class BasicInfoTopicChangedDelegate extends BasicInfoDelegate {
  final TopicDomain? topic;
  const BasicInfoTopicChangedDelegate(this.topic);

  @override
  List<Object?> get props => [topic];
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

  const BasicInfoLoaded({
    required this.draft,
    this.delegate,
    required this.topicConfig,
  });

  BasicInfoLoaded copyWith({
    BasicInfoDraft? draft,
    BasicInfoDelegate? delegate,
    TopicConfig? topicConfig,
  }) {
    return BasicInfoLoaded(
      draft: draft ?? this.draft,
      delegate: delegate,
      topicConfig: topicConfig ?? this.topicConfig,
    );
  }

  @override
  List<Object?> get props => [draft, delegate, topicConfig];
}

class BasicInfoError extends BasicInfoState {
  final String message;
  const BasicInfoError({required this.message});

  @override
  List<Object?> get props => [message];
}
