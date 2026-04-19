import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../../domain/visit_work/visit_work_aggregation.dart';
import '../../../domain/visit_work/visit_work_timeline.dart';
import '../../overview/projection/payment_balance_section_projection.dart';

/// visitWork 向け表示用 Projection
class VisitWorkProjection extends Equatable {
  final VisitWorkTimeline timeline;
  final VisitWorkAggregation aggregation;

  /// 収支セクション表示データ。PaymentDomain 0件の場合 null
  final PaymentBalanceSectionProjection? balanceSection;

  const VisitWorkProjection({
    required this.timeline,
    required this.aggregation,
    this.balanceSection,
  });

  static final _currencyFormat = NumberFormat('#,###');

  String get movingLabel => _formatDuration(aggregation.movingDuration);
  String get stayingLabel => _formatDuration(aggregation.stayingDuration);
  String get workingLabel => _formatDuration(aggregation.workingDuration);
  String get breakLabel => _formatDuration(aggregation.breakDuration);

  String get onSiteLabel {
    final d = aggregation.onSiteDuration;
    return d != null ? _formatDuration(d) : '---';
  }

  String get revenueLabel {
    final rev = aggregation.revenue;
    return rev != null ? '¥${_currencyFormat.format(rev)}' : '---';
  }

  /// 作業時間 0 または売上 null の場合は null（行ごと非表示）
  String? get revenuePerHourLabel {
    final rph = aggregation.revenuePerHour;
    return rph != null ? '¥${_currencyFormat.format(rph)} / h' : null;
  }

  static String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}m';
  }

  @override
  List<Object?> get props => [timeline, aggregation, balanceSection];
}
