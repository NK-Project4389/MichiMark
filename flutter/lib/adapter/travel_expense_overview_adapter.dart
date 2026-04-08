import 'package:intl/intl.dart';
import '../domain/transaction/event/event_domain.dart';
import '../domain/transaction/payment/payment_domain.dart';

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

/// 単一の精算行（支払う人 → 受け取る人: 金額）
class SettlementLineProjection {
  /// 支払う人の名前（割り勘メンバー）
  final String payerName;

  /// 受け取る人の名前（立て替えた支払者）
  final String receiverName;

  /// 精算金額の表示文字列（例: "¥1,750"）
  final String displayAmount;

  const SettlementLineProjection({
    required this.payerName,
    required this.receiverName,
    required this.displayAmount,
  });
}

/// 伝票1件分の精算カード
class PerPaymentSettlementProjection {
  /// メモが空の場合 "支払 #N"、それ以外はメモ文字列
  final String displayTitle;

  /// 伝票金額の表示文字列（例: "¥3,500"）
  final String displayAmount;

  /// 精算行一覧
  final List<SettlementLineProjection> lines;

  const PerPaymentSettlementProjection({
    required this.displayTitle,
    required this.displayAmount,
    required this.lines,
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

  /// 伝票ごとの精算リスト
  final List<PerPaymentSettlementProjection> perPaymentSettlements;

  const TravelExpenseOverviewProjection({
    required this.totalExpense,
    required this.memberCosts,
    required this.memberBalances,
    required this.perPaymentSettlements,
  });
}

// ---------------------------------------------------------------------------
// Adapter
// ---------------------------------------------------------------------------

/// `List<PaymentDomain>` を受け取り `List<PerPaymentSettlementProjection>` を返す。
class PerPaymentSettlementAdapter {
  PerPaymentSettlementAdapter._();

  static final _currencyFormat = NumberFormat('#,###');

  static List<PerPaymentSettlementProjection> toProjections(
    List<PaymentDomain> payments,
  ) {
    // isDeleted == false のみ対象・paymentSeq 昇順
    final active = payments.where((p) => !p.isDeleted).toList()
      ..sort((a, b) => a.paymentSeq.compareTo(b.paymentSeq));

    final result = <PerPaymentSettlementProjection>[];
    int index = 0;

    for (final payment in active) {
      index++;
      final memo = payment.paymentMemo;
      final displayTitle =
          (memo == null || memo.isEmpty) ? '支払 #$index' : memo;
      final displayAmount = '¥${_currencyFormat.format(payment.paymentAmount)}';

      final splitMembers = payment.splitMembers;
      if (splitMembers.isEmpty) {
        // 割り勘なしは除外
        continue;
      }

      final perPerson = payment.paymentAmount ~/ splitMembers.length;
      final perPersonDisplay = '¥${_currencyFormat.format(perPerson)}';
      final receiverName = payment.paymentMember.memberName;

      final lines = splitMembers
          .map(
            (member) => SettlementLineProjection(
              payerName: member.memberName,
              receiverName: receiverName,
              displayAmount: perPersonDisplay,
            ),
          )
          .toList();

      result.add(
        PerPaymentSettlementProjection(
          displayTitle: displayTitle,
          displayAmount: displayAmount,
          lines: lines,
        ),
      );
    }

    return result;
  }
}

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

    // 伝票ごとの精算リスト
    final perPaymentSettlements =
        PerPaymentSettlementAdapter.toProjections(event.payments);

    return TravelExpenseOverviewProjection(
      totalExpense: totalExpense,
      memberCosts: memberCosts,
      memberBalances: memberBalances,
      perPaymentSettlements: perPaymentSettlements,
    );
  }
}
