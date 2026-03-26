import 'package:equatable/equatable.dart';
import 'basic_info_projection.dart';
import 'michi_info_list_projection.dart';
import 'payment_info_projection.dart';

class EventDetailProjection extends Equatable {
  final String eventId;
  final BasicInfoProjection basicInfo;
  final MichiInfoListProjection michiInfo;
  final PaymentInfoProjection paymentInfo;

  const EventDetailProjection({
    required this.eventId,
    required this.basicInfo,
    required this.michiInfo,
    required this.paymentInfo,
  });

  static EventDetailProjection empty(String eventId) => EventDetailProjection(
        eventId: eventId,
        basicInfo: BasicInfoProjection.empty(eventId),
        michiInfo: MichiInfoListProjection.empty,
        paymentInfo: PaymentInfoProjection.empty,
      );

  @override
  List<Object?> get props => [eventId, basicInfo, michiInfo, paymentInfo];
}
