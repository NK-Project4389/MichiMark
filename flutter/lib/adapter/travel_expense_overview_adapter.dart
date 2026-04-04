import '../domain/transaction/event/event_domain.dart';

// ---------------------------------------------------------------------------
// Projection
// ---------------------------------------------------------------------------

/// メンバー別トータルコスト
class MemberCostProjection {
  final String memberName;
  final int totalCost;

  const MemberCostProjection({
    required this.memberName,
    required this.totalCost,
  });
}

/// メンバー別収支バランス
class MemberBalanceProjection {
  final String memberName;

  /// 支払額 − 負担額（プラス=受け取る側、マイナス=支払う側）
  final int balance;

  const MemberBalanceProjection({
    required this.memberName,
    required this.balance,
  });
}

/// travelExpense用 Projection
class TravelExpenseOverviewProjection {
  /// 全PaymentのpaymentAmount合計（円）
  final int totalExpense;

  /// メンバー別トータルコスト一覧
  final List<MemberCostProjection> memberCosts;

  /// メンバー別収支バランス一覧
  final List<MemberBalanceProjection> memberBalances;

  const TravelExpenseOverviewProjection({
    required this.totalExpense,
    required this.memberCosts,
    required this.memberBalances,
  });
}

// ---------------------------------------------------------------------------
// Adapter
// ---------------------------------------------------------------------------

/// EventDomainを受け取りTravelExpenseOverviewProjectionを返す。
/// 収支バランス算出ロジックを担当する。
class TravelExpenseOverviewAdapter {
  TravelExpenseOverviewAdapter._();

  static TravelExpenseOverviewProjection toProjection(EventDomain event) {
    // 有効なPaymentのみ対象
    final payments = event.payments.where((p) => !p.isDeleted).toList();

    int totalExpense = 0;
    // memberName → 支払額合計
    final Map<String, int> paid = {};
    // memberName → 負担額合計
    final Map<String, int> owed = {};

    for (final payment in payments) {
      final amount = payment.paymentAmount;
      totalExpense += amount;

      final payerName = payment.paymentMember.memberName;

      // 支払者の支払額に加算
      paid[payerName] = (paid[payerName] ?? 0) + amount;

      final splitMembers = payment.splitMembers;
      if (splitMembers.isEmpty) {
        // 割り勘なし: 支払者のみ全額負担
        owed[payerName] = (owed[payerName] ?? 0) + amount;
      } else {
        // 均等割り（端数切り捨て）
        final perPerson = amount ~/ splitMembers.length;
        for (final member in splitMembers) {
          owed[member.memberName] = (owed[member.memberName] ?? 0) + perPerson;
        }
      }
    }

    // memberCosts: 負担額一覧
    final allNames = {...paid.keys, ...owed.keys};
    final memberCosts = allNames
        .map((name) => MemberCostProjection(
              memberName: name,
              totalCost: owed[name] ?? 0,
            ))
        .toList()
      ..sort((a, b) => a.memberName.compareTo(b.memberName));

    // balance = 支払額 − 負担額
    final memberBalances = allNames
        .map((name) => MemberBalanceProjection(
              memberName: name,
              balance: (paid[name] ?? 0) - (owed[name] ?? 0),
            ))
        .toList()
      ..sort((a, b) => a.memberName.compareTo(b.memberName));

    return TravelExpenseOverviewProjection(
      totalExpense: totalExpense,
      memberCosts: memberCosts,
      memberBalances: memberBalances,
    );
  }
}
