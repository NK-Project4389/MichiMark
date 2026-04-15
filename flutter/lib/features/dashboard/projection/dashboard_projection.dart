import 'package:equatable/equatable.dart';

/// 期間パラメータ（有料版拡張に備えて保持）
class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  /// 無料版: 当日起算の直近7日間を生成
  factory DateRange.last7Days() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return DateRange(start: start, end: end);
  }

  @override
  List<Object?> get props => [start, end];
}
