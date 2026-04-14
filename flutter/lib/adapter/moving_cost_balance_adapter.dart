import '../domain/transaction/event/event_domain.dart';
import '../domain/topic/topic_domain.dart';
import 'travel_expense_overview_adapter.dart';

/// EventDomain を受け取り、移動コスト収支バランスの List<MemberBalanceProjection> を返す。
///
/// topicType が movingCostEstimated の場合は燃費推定モード、
/// それ以外（movingCost または null）の場合は給油実績モードで計算する。
class MovingCostBalanceAdapter {
  MovingCostBalanceAdapter._();

  static List<MemberBalanceProjection> toBalances(
    EventDomain event,
    TopicType? topicType,
  ) {
    if (topicType == TopicType.movingCostEstimated) {
      return _calcEstimated(event);
    }
    return _calcActual(event);
  }

  /// 給油実績モード: isFuel == true のMarkLinkを集計
  static List<MemberBalanceProjection> _calcActual(EventDomain event) {
    final fuelLinks = event.markLinks.where(
      (ml) =>
          ml.isFuel &&
          !ml.isDeleted &&
          ml.gasPayer != null &&
          ml.gasPrice != null &&
          ml.members.isNotEmpty,
    );

    if (fuelLinks.isEmpty) return [];

    // memberName → 支払額合計
    final Map<String, int> paid = {};
    // memberName → 負担額合計
    final Map<String, int> owed = {};

    for (final ml in fuelLinks) {
      final gasPayer = ml.gasPayer;
      final gasPrice = ml.gasPrice;
      if (gasPayer == null || gasPrice == null) continue;

      final payerName = gasPayer.memberName;
      paid[payerName] = (paid[payerName] ?? 0) + gasPrice;

      final perPerson = gasPrice ~/ ml.members.length;
      for (final member in ml.members) {
        owed[member.memberName] = (owed[member.memberName] ?? 0) + perPerson;
      }
    }

    final allNames = {...paid.keys, ...owed.keys};
    return allNames
        .map((name) => MemberBalanceProjection(
              memberName: name,
              balance: (paid[name] ?? 0) - (owed[name] ?? 0),
            ))
        .toList()
      ..sort((a, b) => a.memberName.compareTo(b.memberName));
  }

  /// 燃費推定モード: イベント全体のガソリン支払者・メンバーから算出
  static List<MemberBalanceProjection> _calcEstimated(EventDomain event) {
    final payMember = event.payMember;
    final members = event.members;
    final kmPerGas = event.kmPerGas;
    final pricePerGas = event.pricePerGas;

    // 条件チェック
    if (payMember == null) return [];
    if (members.isEmpty) return [];
    if (kmPerGas == null || kmPerGas <= 0) return [];
    if (pricePerGas == null) return [];

    // totalDistance は AggregationResult 経由でなく EventDomain から直接は取得できない。
    // Spec の計算式は totalDistance を使用するが、EventDomain には含まれていないため
    // MarkLink の distanceValue を合算して totalDistance を算出する。
    final totalDistance = event.markLinks
        .where((ml) => !ml.isDeleted && ml.distanceValue != null)
        .fold<int>(0, (sum, ml) => sum + (ml.distanceValue ?? 0));

    if (totalDistance <= 0) return [];

    // 推計ガソリン代 = totalDistance / (kmPerGas / 10.0) * pricePerGas（切り捨て）
    final estimatedGasPrice =
        (totalDistance / (kmPerGas / 10.0) * pricePerGas).floor();

    // 支払額
    final Map<String, int> paid = {
      payMember.memberName: estimatedGasPrice,
    };

    // 負担額（均等割り・切り捨て）
    final Map<String, int> owed = {};
    final perPerson = estimatedGasPrice ~/ members.length;
    for (final member in members) {
      owed[member.memberName] = (owed[member.memberName] ?? 0) + perPerson;
    }

    final allNames = {...paid.keys, ...owed.keys};
    return allNames
        .map((name) => MemberBalanceProjection(
              memberName: name,
              balance: (paid[name] ?? 0) - (owed[name] ?? 0),
            ))
        .toList()
      ..sort((a, b) => a.memberName.compareTo(b.memberName));
  }
}
