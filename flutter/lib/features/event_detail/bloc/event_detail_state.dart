import 'package:equatable/equatable.dart';
import '../draft/event_detail_draft.dart';
import '../projection/event_detail_projection.dart';

/// EventDetailのDelegate（画面遷移・操作意図の通知）
sealed class EventDetailDelegate extends Equatable {
  const EventDetailDelegate();
}

class EventDetailDismissDelegate extends EventDetailDelegate {
  const EventDetailDismissDelegate();

  @override
  List<Object?> get props => [];
}

class EventDetailOpenMarkDelegate extends EventDetailDelegate {
  final String markLinkId;
  const EventDetailOpenMarkDelegate(this.markLinkId);

  @override
  List<Object?> get props => [markLinkId];
}

class EventDetailOpenLinkDelegate extends EventDetailDelegate {
  final String markLinkId;
  const EventDetailOpenLinkDelegate(this.markLinkId);

  @override
  List<Object?> get props => [markLinkId];
}

class EventDetailOpenPaymentDelegate extends EventDetailDelegate {
  final String paymentId;
  const EventDetailOpenPaymentDelegate(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class EventDetailAddMarkLinkDelegate extends EventDetailDelegate {
  const EventDetailAddMarkLinkDelegate();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------

sealed class EventDetailState extends Equatable {
  const EventDetailState();
}

class EventDetailLoading extends EventDetailState {
  const EventDetailLoading();

  @override
  List<Object?> get props => [];
}

class EventDetailLoaded extends EventDetailState {
  final EventDetailProjection projection;
  final EventDetailDraft draft;
  final EventDetailDelegate? delegate;

  const EventDetailLoaded({
    required this.projection,
    required this.draft,
    this.delegate,
  });

  EventDetailLoaded copyWith({
    EventDetailProjection? projection,
    EventDetailDraft? draft,
    EventDetailDelegate? delegate,
  }) {
    return EventDetailLoaded(
      projection: projection ?? this.projection,
      draft: draft ?? this.draft,
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [projection, draft, delegate];
}

class EventDetailError extends EventDetailState {
  final String message;
  const EventDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
