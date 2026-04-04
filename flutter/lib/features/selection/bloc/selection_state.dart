import 'package:equatable/equatable.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/master/tag/tag_domain.dart';
import '../../../domain/master/trans/trans_domain.dart';
import '../../../domain/topic/topic_domain.dart';
import '../draft/selection_draft.dart';
import '../projection/selection_projection.dart';
import '../selection_result.dart';

/// SelectionのDelegate（画面遷移・操作意図の通知）
sealed class SelectionDelegate extends Equatable {
  const SelectionDelegate();
}

class SelectionConfirmedDelegate extends SelectionDelegate {
  final SelectionResult result;
  const SelectionConfirmedDelegate(this.result);

  @override
  List<Object?> get props => [];
}

class SelectionDismissedDelegate extends SelectionDelegate {
  const SelectionDismissedDelegate();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------

sealed class SelectionState extends Equatable {
  const SelectionState();
}

class SelectionLoading extends SelectionState {
  const SelectionLoading();

  @override
  List<Object?> get props => [];
}

class SelectionLoaded extends SelectionState {
  final SelectionProjection projection;
  final SelectionDraft draft;
  final SelectionDelegate? delegate;

  /// 確定時に Domain を返すためにキャッシュ
  final List<TransDomain> cachedTrans;
  final List<MemberDomain> cachedMembers;
  final List<TagDomain> cachedTags;
  final List<ActionDomain> cachedActions;
  final List<TopicDomain> cachedTopics;

  const SelectionLoaded({
    required this.projection,
    required this.draft,
    this.delegate,
    this.cachedTrans = const [],
    this.cachedMembers = const [],
    this.cachedTags = const [],
    this.cachedActions = const [],
    this.cachedTopics = const [],
  });

  SelectionLoaded copyWith({
    SelectionProjection? projection,
    SelectionDraft? draft,
    SelectionDelegate? delegate,
  }) {
    return SelectionLoaded(
      projection: projection ?? this.projection,
      draft: draft ?? this.draft,
      delegate: delegate,
      cachedTrans: cachedTrans,
      cachedMembers: cachedMembers,
      cachedTags: cachedTags,
      cachedActions: cachedActions,
      cachedTopics: cachedTopics,
    );
  }

  @override
  List<Object?> get props => [projection, draft, delegate];
}

class SelectionError extends SelectionState {
  final String message;
  const SelectionError({required this.message});

  @override
  List<Object?> get props => [message];
}
