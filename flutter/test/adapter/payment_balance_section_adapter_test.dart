import 'package:flutter_test/flutter_test.dart';
import 'package:michi_mark/adapter/payment_balance_section_adapter.dart';
import 'package:michi_mark/domain/transaction/payment/payment_domain.dart';
import 'package:michi_mark/domain/transaction/payment/payment_type.dart';
import 'package:michi_mark/domain/master/member/member_domain.dart';

void main() {
  group('PaymentBalanceSectionAdapter', () {
    final now = DateTime.now();
    late MemberDomain testMember;
    late MemberDomain testMember2;

    setUp(() {
      testMember = MemberDomain(
        id: 'member_1',
        memberName: 'テスト太郎',
        createdAt: now,
        updatedAt: now,
      );
      testMember2 = MemberDomain(
        id: 'member_2',
        memberName: 'テスト花子',
        createdAt: now,
        updatedAt: now,
      );
    });

    // TC-001: revenue種別のみのPaymentDomainを渡した場合
    test('revenue種別のみを渡した場合、revenueItemsに格納・expenseItemsが空・revenueTotalLabelが+形式・balanceTotalLabelが正', () {
      final payments = [
        PaymentDomain(
          id: 'payment_1',
          paymentSeq: 1,
          paymentAmount: 15000,
          paymentMember: testMember,
          paymentMemo: '給与',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
        PaymentDomain(
          id: 'payment_2',
          paymentSeq: 2,
          paymentAmount: 5000,
          paymentMember: testMember,
          paymentMemo: 'ボーナス',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
      ];

      final projection = PaymentBalanceSectionAdapter.toProjection(payments);

      expect(projection.revenueItems.length, 2);
      expect(projection.expenseItems.length, 0);
      expect(projection.revenueTotalLabel, '+20,000');
      expect(projection.balanceTotalLabel, '+20,000');
      expect(projection.balanceTotalIsPositive, true);
      expect(projection.hasItems, true);
    });

    // TC-002: expense種別のみのPaymentDomainを渡した場合
    test('expense種別のみを渡した場合、expenseItemsに格納・revenueTotalLabelが+0・expenseTotalLabelが-形式・balanceTotalIsPositiveがfalse', () {
      final payments = [
        PaymentDomain(
          id: 'payment_1',
          paymentSeq: 1,
          paymentAmount: 3500,
          paymentMember: testMember,
          paymentMemo: 'ガソリン代',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
      ];

      final projection = PaymentBalanceSectionAdapter.toProjection(payments);

      expect(projection.revenueItems.length, 0);
      expect(projection.expenseItems.length, 1);
      expect(projection.revenueTotalLabel, '+0');
      expect(projection.expenseTotalLabel, '-3,500');
      expect(projection.balanceTotalLabel, '-3,500');
      expect(projection.balanceTotalIsPositive, false);
      expect(projection.hasItems, true);
    });

    // TC-003: revenue・expense両方混在の場合
    test('revenue・expense両方が混在する場合、収支合計が正しく算出される', () {
      final payments = [
        PaymentDomain(
          id: 'payment_1',
          paymentSeq: 1,
          paymentAmount: 20000,
          paymentMember: testMember,
          paymentMemo: '売上',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
        PaymentDomain(
          id: 'payment_2',
          paymentSeq: 2,
          paymentAmount: 5000,
          paymentMember: testMember,
          paymentMemo: 'ガソリン',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
        PaymentDomain(
          id: 'payment_3',
          paymentSeq: 3,
          paymentAmount: 2100,
          paymentMember: testMember,
          paymentMemo: '食事代',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
      ];

      final projection = PaymentBalanceSectionAdapter.toProjection(payments);

      expect(projection.revenueItems.length, 1);
      expect(projection.expenseItems.length, 2);
      expect(projection.revenueTotalLabel, '+20,000');
      expect(projection.expenseTotalLabel, '-7,100');
      expect(projection.balanceTotalLabel, '+12,900'); // 20000 - 7100
      expect(projection.balanceTotalIsPositive, true);
    });

    // TC-004: paymentMemoがnullまたは空の場合
    test('paymentMemoがnullまたは空の場合、フォールバック表示「支払 #N」が適用される', () {
      final payments = [
        PaymentDomain(
          id: 'payment_1',
          paymentSeq: 1,
          paymentAmount: 1000,
          paymentMember: testMember,
          paymentMemo: null,
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
        PaymentDomain(
          id: 'payment_2',
          paymentSeq: 2,
          paymentAmount: 2000,
          paymentMember: testMember,
          paymentMemo: '', // 空文字
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
        PaymentDomain(
          id: 'payment_3',
          paymentSeq: 3,
          paymentAmount: 3000,
          paymentMember: testMember,
          paymentMemo: '明示的メモ',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
      ];

      final projection = PaymentBalanceSectionAdapter.toProjection(payments);

      expect(projection.expenseItems[0].displayMemo, '支払 #1');
      expect(projection.expenseItems[1].displayMemo, '支払 #2');
      expect(projection.expenseItems[2].displayMemo, '明示的メモ');
    });

    // TC-005: isDeleted=trueのPaymentDomainが除外される
    test('isDeleted=trueのPaymentDomainが除外される', () {
      final payments = [
        PaymentDomain(
          id: 'payment_1',
          paymentSeq: 1,
          paymentAmount: 5000,
          paymentMember: testMember,
          paymentMemo: '有効',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
        PaymentDomain(
          id: 'payment_2',
          paymentSeq: 2,
          paymentAmount: 3000,
          paymentMember: testMember,
          paymentMemo: '削除済み',
          isDeleted: true,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
        PaymentDomain(
          id: 'payment_3',
          paymentSeq: 3,
          paymentAmount: 2000,
          paymentMember: testMember,
          paymentMemo: '有効2',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
      ];

      final projection = PaymentBalanceSectionAdapter.toProjection(payments);

      expect(projection.expenseItems.length, 2);
      expect(projection.expenseItems[0].displayMemo, '有効');
      expect(projection.expenseItems[1].displayMemo, '有効2');
      expect(projection.expenseTotalLabel, '-7,000'); // 5000 + 2000のみ
    });

    // TC-006: 空リストを渡した場合
    test('空リストを渡した場合、hasItemsがfalse', () {
      final payments = <PaymentDomain>[];

      final projection = PaymentBalanceSectionAdapter.toProjection(payments);

      expect(projection.hasItems, false);
      expect(projection.revenueItems.length, 0);
      expect(projection.expenseItems.length, 0);
      expect(projection.revenueTotalLabel, '+0');
      expect(projection.expenseTotalLabel, '-0');
      expect(projection.balanceTotalLabel, '+0');
    });

    // TC-007: 収支合計がマイナスの場合
    test('収支合計がマイナスの場合、balanceTotalIsPositiveがfalse・balanceTotalLabelが-形式', () {
      final payments = [
        PaymentDomain(
          id: 'payment_1',
          paymentSeq: 1,
          paymentAmount: 10000,
          paymentMember: testMember,
          paymentMemo: '売上',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
        PaymentDomain(
          id: 'payment_2',
          paymentSeq: 2,
          paymentAmount: 15000,
          paymentMember: testMember,
          paymentMemo: '支出',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
      ];

      final projection = PaymentBalanceSectionAdapter.toProjection(payments);

      expect(projection.balanceTotalIsPositive, false);
      expect(projection.balanceTotalLabel, '-5,000');
    });

    // TC-008: displayAmountが符号付き金額文字列で正しくフォーマットされるか
    test('revenue itemのdisplayAmountは+形式、expense itemのdisplayAmountは-形式', () {
      final payments = [
        PaymentDomain(
          id: 'payment_1',
          paymentSeq: 1,
          paymentAmount: 12345,
          paymentMember: testMember,
          paymentMemo: '売上',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
        PaymentDomain(
          id: 'payment_2',
          paymentSeq: 2,
          paymentAmount: 6789,
          paymentMember: testMember,
          paymentMemo: '支出',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
      ];

      final projection = PaymentBalanceSectionAdapter.toProjection(payments);

      expect(projection.revenueItems[0].displayAmount, '+12,345');
      expect(projection.revenueItems[0].isRevenue, true);
      expect(projection.expenseItems[0].displayAmount, '-6,789');
      expect(projection.expenseItems[0].isRevenue, false);
    });

    // TC-009: paymentIdが正しく保持されるか
    test('各itemのpaymentIdが正しく保持される', () {
      final payments = [
        PaymentDomain(
          id: 'unique_id_123',
          paymentSeq: 1,
          paymentAmount: 1000,
          paymentMember: testMember,
          paymentMemo: 'テスト',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
      ];

      final projection = PaymentBalanceSectionAdapter.toProjection(payments);

      expect(projection.expenseItems[0].paymentId, 'unique_id_123');
    });

    // TC-010: 大量データの合計計算が正確か（境界値テスト）
    test('大量データでの合計計算が正確', () {
      final payments = List.generate(100, (index) {
        return PaymentDomain(
          id: 'payment_$index',
          paymentSeq: index,
          paymentAmount: 1000,
          paymentMember: testMember,
          paymentMemo: 'item_$index',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: index.isEven ? PaymentType.revenue : PaymentType.expense,
        );
      });

      final projection = PaymentBalanceSectionAdapter.toProjection(payments);

      // 50個のrevenue + 50個のexpense
      expect(projection.revenueItems.length, 50);
      expect(projection.expenseItems.length, 50);
      expect(projection.revenueTotalLabel, '+50,000'); // 50 * 1000
      expect(projection.expenseTotalLabel, '-50,000'); // 50 * 1000
      expect(projection.balanceTotalLabel, '+0');
      expect(projection.balanceTotalIsPositive, true); // 0 >= 0
    });
  });
}
