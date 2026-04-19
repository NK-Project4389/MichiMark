import 'package:flutter_test/flutter_test.dart';
import 'package:michi_mark/adapter/visit_work_aggregation_adapter.dart';
import 'package:michi_mark/domain/aggregation/aggregation_result.dart';
import 'package:michi_mark/domain/visit_work/visit_work_timeline.dart';
import 'package:michi_mark/domain/transaction/payment/payment_domain.dart';
import 'package:michi_mark/domain/transaction/payment/payment_type.dart';
import 'package:michi_mark/domain/master/member/member_domain.dart';

void main() {
  group('VisitWorkAggregationAdapter', () {
    final now = DateTime.now();
    late MemberDomain testMember;

    setUp(() {
      testMember = MemberDomain(
        id: 'member_1',
        memberName: 'テスト太郎',
        createdAt: now,
        updatedAt: now,
      );
    });

    // TC-001: revenue種別のみがrevenueTotalに集計される（expense種別は除外）
    test('TC-001: revenue種別のみがrevenueTotalに集計される', () {
      final aggregation = AggregationResult(
        totalDistance: 100,
        eventCount: 1,
      );
      final timeline = const VisitWorkTimeline(
        segments: [],
        isOngoing: false,
      );
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
          paymentAmount: 3000,
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
          paymentAmount: 5000,
          paymentMember: testMember,
          paymentMemo: '売上2',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
      ];

      final result = VisitWorkAggregationAdapter.fromResults(
        aggregation: aggregation,
        timeline: timeline,
        payments: payments,
      );

      expect(result.revenue, 15000); // 10000 + 5000のみ
    });

    // TC-002: isDeleted=trueのPaymentがrevenueTotalに含まれない
    test('TC-002: isDeleted=trueのPaymentがrevenueTotalに含まれない', () {
      final aggregation = AggregationResult(
        totalDistance: 100,
        eventCount: 1,
      );
      final timeline = const VisitWorkTimeline(
        segments: [],
        isOngoing: false,
      );
      final payments = [
        PaymentDomain(
          id: 'payment_1',
          paymentSeq: 1,
          paymentAmount: 8000,
          paymentMember: testMember,
          paymentMemo: '有効',
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
          paymentMemo: '削除済み',
          isDeleted: true,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
      ];

      final result = VisitWorkAggregationAdapter.fromResults(
        aggregation: aggregation,
        timeline: timeline,
        payments: payments,
      );

      expect(result.revenue, 8000); // 削除済みは除外
    });

    // TC-003: paymentsが空の場合 → revenue = 0
    test('TC-003: paymentsが空の場合、revenue = 0', () {
      final aggregation = AggregationResult(
        totalDistance: 100,
        eventCount: 1,
      );
      final timeline = const VisitWorkTimeline(
        segments: [],
        isOngoing: false,
      );
      final payments = <PaymentDomain>[];

      final result = VisitWorkAggregationAdapter.fromResults(
        aggregation: aggregation,
        timeline: timeline,
        payments: payments,
      );

      expect(result.revenue, 0);
    });

    // TC-004: revenue・expense混在の場合 → revenue種別のみ合計
    test('TC-004: revenue・expense混在の場合、revenue種別のみ合計', () {
      final aggregation = AggregationResult(
        totalDistance: 100,
        eventCount: 1,
      );
      final timeline = const VisitWorkTimeline(
        segments: [],
        isOngoing: false,
      );
      final payments = [
        PaymentDomain(
          id: 'payment_1',
          paymentSeq: 1,
          paymentAmount: 20000,
          paymentMember: testMember,
          paymentMemo: '売上1',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
        PaymentDomain(
          id: 'payment_2',
          paymentSeq: 2,
          paymentAmount: 2000,
          paymentMember: testMember,
          paymentMemo: '費用1',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
        PaymentDomain(
          id: 'payment_3',
          paymentSeq: 3,
          paymentAmount: 15000,
          paymentMember: testMember,
          paymentMemo: '売上2',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
        PaymentDomain(
          id: 'payment_4',
          paymentSeq: 4,
          paymentAmount: 3500,
          paymentMember: testMember,
          paymentMemo: '費用2',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
      ];

      final result = VisitWorkAggregationAdapter.fromResults(
        aggregation: aggregation,
        timeline: timeline,
        payments: payments,
      );

      expect(result.revenue, 35000); // 20000 + 15000のみ
    });

    // TC-005: AggregationResultのnullフィールドがDuration.zeroにフォールバック
    test('TC-005: AggregationResultのnullフィールドがDuration.zeroにフォールバック', () {
      final aggregation = AggregationResult(
        movingTime: null,
        waitingTime: null,
        workingTime: null,
        breakTime: null,
        totalDistance: 100,
        eventCount: 1,
      );
      final timeline = const VisitWorkTimeline(
        segments: [],
        isOngoing: false,
      );
      final payments = <PaymentDomain>[];

      final result = VisitWorkAggregationAdapter.fromResults(
        aggregation: aggregation,
        timeline: timeline,
        payments: payments,
      );

      expect(result.movingDuration, Duration.zero);
      expect(result.stayingDuration, Duration.zero);
      expect(result.workingDuration, Duration.zero);
      expect(result.breakDuration, Duration.zero);
    });

    // TC-006: AggregationResultの全フィールド指定時の正常系
    test('TC-006: AggregationResultの全フィールド指定時の正常系', () {
      final aggregation = AggregationResult(
        movingTime: const Duration(hours: 2),
        waitingTime: const Duration(minutes: 30),
        workingTime: const Duration(hours: 4),
        breakTime: const Duration(minutes: 15),
        totalDistance: 100,
        eventCount: 1,
      );
      final timeline = const VisitWorkTimeline(
        segments: [],
        isOngoing: false,
      );
      final payments = [
        PaymentDomain(
          id: 'payment_1',
          paymentSeq: 1,
          paymentAmount: 12000,
          paymentMember: testMember,
          paymentMemo: '売上',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
      ];

      final result = VisitWorkAggregationAdapter.fromResults(
        aggregation: aggregation,
        timeline: timeline,
        payments: payments,
      );

      expect(result.movingDuration, const Duration(hours: 2));
      expect(result.stayingDuration, const Duration(minutes: 30));
      expect(result.workingDuration, const Duration(hours: 4));
      expect(result.breakDuration, const Duration(minutes: 15));
      expect(result.revenue, 12000);
    });

    // TC-007: isOngoingフラグが正しく保持される
    test('TC-007: isOngoingフラグが正しく保持される', () {
      final aggregation = AggregationResult(
        totalDistance: 100,
        eventCount: 1,
      );
      final timelineOngoing = const VisitWorkTimeline(
        segments: [],
        isOngoing: true,
      );
      final payments = <PaymentDomain>[];

      final result = VisitWorkAggregationAdapter.fromResults(
        aggregation: aggregation,
        timeline: timelineOngoing,
        payments: payments,
      );

      expect(result.isOngoing, true);
    });

    // TC-008: onSiteDurationが正しく転写される
    test('TC-008: onSiteDurationが正しく転写される', () {
      final aggregation = AggregationResult(
        totalDistance: 100,
        eventCount: 1,
      );
      // CustomTimelineで onSiteDuration を返すように設定
      // （実装では VisitWorkTimeline.onSiteDuration を使用）
      final timeline = const VisitWorkTimeline(
        segments: [],
        isOngoing: false,
      );
      final payments = <PaymentDomain>[];

      final result = VisitWorkAggregationAdapter.fromResults(
        aggregation: aggregation,
        timeline: timeline,
        payments: payments,
      );

      // timeline.onSiteDuration が null の場合
      expect(result.onSiteDuration, null);
    });

    // TC-009: 大量Paymentでの合計計算が正確
    test('TC-009: 大量Paymentでの合計計算が正確', () {
      final aggregation = AggregationResult(
        totalDistance: 100,
        eventCount: 1,
      );
      final timeline = const VisitWorkTimeline(
        segments: [],
        isOngoing: false,
      );
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

      final result = VisitWorkAggregationAdapter.fromResults(
        aggregation: aggregation,
        timeline: timeline,
        payments: payments,
      );

      // 50個のrevenue * 1000
      expect(result.revenue, 50000);
    });

    // TC-010: 複合フィルター条件（isDeleted + PaymentType）
    test('TC-010: 複合フィルター条件（isDeleted + PaymentType）', () {
      final aggregation = AggregationResult(
        totalDistance: 100,
        eventCount: 1,
      );
      final timeline = const VisitWorkTimeline(
        segments: [],
        isOngoing: false,
      );
      final payments = [
        // revenue, deleted=false → カウント対象
        PaymentDomain(
          id: 'payment_1',
          paymentSeq: 1,
          paymentAmount: 7000,
          paymentMember: testMember,
          paymentMemo: '有効売上',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
        // revenue, deleted=true → 除外
        PaymentDomain(
          id: 'payment_2',
          paymentSeq: 2,
          paymentAmount: 2000,
          paymentMember: testMember,
          paymentMemo: '削除済み売上',
          isDeleted: true,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
        // expense, deleted=false → 除外（PaymentType不一致）
        PaymentDomain(
          id: 'payment_3',
          paymentSeq: 3,
          paymentAmount: 3000,
          paymentMember: testMember,
          paymentMemo: '有効費用',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.expense,
        ),
        // revenue, deleted=false → カウント対象
        PaymentDomain(
          id: 'payment_4',
          paymentSeq: 4,
          paymentAmount: 5500,
          paymentMember: testMember,
          paymentMemo: '有効売上2',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          paymentType: PaymentType.revenue,
        ),
      ];

      final result = VisitWorkAggregationAdapter.fromResults(
        aggregation: aggregation,
        timeline: timeline,
        payments: payments,
      );

      expect(result.revenue, 12500); // 7000 + 5500
    });
  });
}
