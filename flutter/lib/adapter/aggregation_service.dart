import '../domain/action_time/action_state.dart';
import '../domain/aggregation/aggregation_result.dart';
import '../domain/transaction/event/event_domain.dart';
import '../domain/transaction/mark_link/mark_or_link.dart';
import '../repository/action_repository.dart';
import '../domain/master/action/action_domain.dart';

/// 集計ロジックを一元管理するサービス。
/// Domain・Repositoryに依存するが、UIに依存しない。
class AggregationService {
  final ActionRepository _actionRepository;

  AggregationService({required ActionRepository actionRepository})
      : _actionRepository = actionRepository;

  /// イベント1件の集計
  Future<AggregationResult> aggregateEvent(EventDomain event) async {
    final actions = await _actionRepository.fetchAll();
    final actionMap = {for (final a in actions) a.id: a};
    return _aggregate([event], actionMap);
  }

  /// 複数Eventの集計（期間単位）
  Future<AggregationResult> aggregateEvents(List<EventDomain> events) async {
    final actions = await _actionRepository.fetchAll();
    final actionMap = {for (final a in actions) a.id: a};
    return _aggregate(events, actionMap);
  }

  AggregationResult _aggregate(
    List<EventDomain> events,
    Map<String, ActionDomain> actionMap,
  ) {
    Duration? movingTime;
    Duration? workingTime;
    Duration? breakTime;
    Duration? waitingTime;
    int totalDistance = 0;
    int? totalGasQuantity;
    int? totalGasPrice;
    int? totalPayment;

    for (final event in events) {
      // 時間集計
      final logs = event.actionTimeLogs
          .where((l) => !l.isDeleted)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (logs.length >= 2) {
        for (int i = 0; i < logs.length - 1; i++) {
          final currentLog = logs[i];
          final nextLog = logs[i + 1];
          final action = actionMap[currentLog.actionId];
          if (action == null) continue;

          final toState = action.toState;
          if (toState == null) continue;

          final duration = nextLog.timestamp.difference(currentLog.timestamp);

          switch (toState) {
            case ActionState.moving:
              movingTime = (movingTime ?? Duration.zero) + duration;
            case ActionState.working:
              workingTime = (workingTime ?? Duration.zero) + duration;
            case ActionState.break_:
              breakTime = (breakTime ?? Duration.zero) + duration;
            case ActionState.waiting:
              waitingTime = (waitingTime ?? Duration.zero) + duration;
          }
        }
      }

      // 走行距離・給油集計（Linkのみ）
      for (final ml in event.markLinks.where((ml) => !ml.isDeleted && ml.markLinkType == MarkOrLink.link)) {
        // 距離採用優先順位: distanceValue > meterValue差分（ここではdistanceValueのみ集計）
        totalDistance += ml.distanceValue ?? 0;

        if (ml.isFuel) {
          final qty = ml.gasQuantity;
          if (qty != null) {
            totalGasQuantity = (totalGasQuantity ?? 0) + qty;
          }
          final price = ml.gasPrice;
          if (price != null) {
            totalGasPrice = (totalGasPrice ?? 0) + price;
          }
        }
      }

      // Payment集計
      for (final pay in event.payments.where((p) => !p.isDeleted)) {
        totalPayment = (totalPayment ?? 0) + pay.paymentAmount;
      }
    }

    return AggregationResult(
      movingTime: movingTime,
      workingTime: workingTime,
      breakTime: breakTime,
      waitingTime: waitingTime,
      totalDistance: totalDistance,
      totalGasQuantity: totalGasQuantity,
      totalGasPrice: totalGasPrice,
      totalPayment: totalPayment,
      eventCount: events.length,
    );
  }
}
