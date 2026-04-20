/// Unit Test: VisitWorkDashboardAdapter
///
/// Spec: docs/Spec/Features/F-3_VisitWork.md §12
///
/// テストシナリオ: TC-DA-001, TC-DA-002
///
/// 対象: workBreakdown の actionName が正しく構築されること

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:michi_mark/domain/action_time/action_time_log.dart';
import 'package:michi_mark/domain/master/action/action_domain.dart';
import 'package:michi_mark/domain/master/member/member_domain.dart';
import 'package:michi_mark/domain/master/trans/trans_domain.dart';
import 'package:michi_mark/domain/topic/topic_domain.dart';
import 'package:michi_mark/domain/transaction/event/event_domain.dart';
import 'package:michi_mark/domain/transaction/mark_link/mark_link_domain.dart';
import 'package:michi_mark/domain/transaction/mark_link/mark_or_link.dart';
import 'package:michi_mark/features/dashboard/adapter/visit_work_dashboard_adapter.dart';
import 'package:michi_mark/features/dashboard/projection/dashboard_projection.dart';

void main() {
  group('VisitWorkDashboardAdapter.toProjection', () {
    late DateTime baseDate;

    setUp(() {
      baseDate = DateTime(2026, 4, 20);
    });

    // ────────────────────────────────────────────────────────
    // TC-DA-001: actionNameMapが正しく構築されること
    // ────────────────────────────────────────────────────────
    test('TC-DA-001: workBreakdown[i].actionNameがactionIdではなく正しいアクション名であること',
        () {
      // テストデータ: visitWorkアクション（出発・作業開始・作業終了）
      final visitWorkAction1 = ActionDomain(
        id: 'visit_work_depart_test',
        actionName: '出発',
        toState: null,
        isToggle: false,
        needsTransition: false,
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      final visitWorkAction2 = ActionDomain(
        id: 'visit_work_start_test',
        actionName: '作業開始',
        toState: null,
        isToggle: false,
        needsTransition: false,
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      final visitWorkAction3 = ActionDomain(
        id: 'visit_work_end_test',
        actionName: '作業終了',
        toState: null,
        isToggle: false,
        needsTransition: false,
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      // テストメンバー
      final testMember = MemberDomain(
        id: 'member-test-001',
        memberName: 'テスト太郎',
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      // テスト交通手段
      final testTrans = TransDomain(
        id: 'trans-test-001',
        transName: 'テストカー',
        kmPerGas: 100,
        meterValue: 45000,
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      // visitWorkトピック
      final visitWorkTopic = TopicDomain(
        id: 'topic-visit-work-test',
        topicName: '訪問作業テスト',
        topicType: TopicType.visitWork,
        isVisible: true,
        isDeleted: false,
        createdAt: baseDate,
        updatedAt: baseDate,
        color: 'skyBlue',
      );

      // 訪問作業イベント
      final testEvent = EventDomain(
        id: 'event-visit-work-test',
        eventName: 'テスト訪問作業',
        topic: visitWorkTopic,
        trans: testTrans,
        members: [testMember],
        tags: [],
        payMember: testMember,
        markLinks: [
          MarkLinkDomain(
            id: 'ml-test-001',
            markLinkSeq: 1,
            markLinkType: MarkOrLink.mark,
            markLinkDate: baseDate.add(const Duration(hours: 9)),
            markLinkName: 'テスト営業所1',
            members: [testMember],
            actions: [visitWorkAction1, visitWorkAction2, visitWorkAction3],
            createdAt: baseDate.add(const Duration(hours: 9)),
            updatedAt: baseDate.add(const Duration(hours: 9)),
          ),
        ],
        payments: [],
        actionTimeLogs: [
          // 出発: 09:00 - 09:05 (5分)
          ActionTimeLog(
            id: 'atl-test-001',
            eventId: 'event-visit-work-test',
            actionId: 'visit_work_depart_test',
            timestamp: baseDate.add(const Duration(hours: 9, minutes: 0)),
            createdAt: baseDate.add(const Duration(hours: 9, minutes: 0)),
            updatedAt: baseDate.add(const Duration(hours: 9, minutes: 0)),
          ),
          ActionTimeLog(
            id: 'atl-test-002',
            eventId: 'event-visit-work-test',
            actionId: 'visit_work_depart_test',
            timestamp: baseDate.add(const Duration(hours: 9, minutes: 5)),
            createdAt: baseDate.add(const Duration(hours: 9, minutes: 5)),
            updatedAt: baseDate.add(const Duration(hours: 9, minutes: 5)),
          ),
          // 作業開始: 09:10 - 11:50 (160分)
          ActionTimeLog(
            id: 'atl-test-003',
            eventId: 'event-visit-work-test',
            actionId: 'visit_work_start_test',
            timestamp: baseDate.add(const Duration(hours: 9, minutes: 10)),
            createdAt: baseDate.add(const Duration(hours: 9, minutes: 10)),
            updatedAt: baseDate.add(const Duration(hours: 9, minutes: 10)),
          ),
          ActionTimeLog(
            id: 'atl-test-004',
            eventId: 'event-visit-work-test',
            actionId: 'visit_work_start_test',
            timestamp: baseDate.add(const Duration(hours: 11, minutes: 50)),
            createdAt: baseDate.add(const Duration(hours: 11, minutes: 50)),
            updatedAt: baseDate.add(const Duration(hours: 11, minutes: 50)),
          ),
          // 作業終了: 12:00 - 12:10 (10分)
          ActionTimeLog(
            id: 'atl-test-005',
            eventId: 'event-visit-work-test',
            actionId: 'visit_work_end_test',
            timestamp: baseDate.add(const Duration(hours: 12, minutes: 0)),
            createdAt: baseDate.add(const Duration(hours: 12, minutes: 0)),
            updatedAt: baseDate.add(const Duration(hours: 12, minutes: 0)),
          ),
          ActionTimeLog(
            id: 'atl-test-006',
            eventId: 'event-visit-work-test',
            actionId: 'visit_work_end_test',
            timestamp: baseDate.add(const Duration(hours: 12, minutes: 10)),
            createdAt: baseDate.add(const Duration(hours: 12, minutes: 10)),
            updatedAt: baseDate.add(const Duration(hours: 12, minutes: 10)),
          ),
        ],
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      // テスト実行
      final period = DateRange(
        start: baseDate,
        end: baseDate.add(const Duration(days: 7)),
      );

      final projection = VisitWorkDashboardAdapter.toProjection([testEvent], period);

      // 検証: workBreakdown が3要素を持つこと（出発・作業開始・作業終了）
      expect(
        projection.workBreakdown.length,
        3,
        reason: 'workBreakdownに3つのアクションエントリが存在すること',
      );

      // 検証: actionName が正しいアクション名であること（actionIdではなく）
      final actionNames = projection.workBreakdown.map((e) => e.actionName).toSet();
      expect(
        actionNames.contains('出発'),
        isTrue,
        reason: 'workBreakdown に「出発」というアクション名が含まれること',
      );

      expect(
        actionNames.contains('作業開始'),
        isTrue,
        reason: 'workBreakdown に「作業開始」というアクション名が含まれること',
      );

      expect(
        actionNames.contains('作業終了'),
        isTrue,
        reason: 'workBreakdown に「作業終了」というアクション名が含まれること',
      );

      // actionIdが含まれていないことを確認
      expect(
        actionNames.contains('visit_work_depart_test'),
        isFalse,
        reason: 'actionId（例: visit_work_depart_test）がactionNameに含まれないこと',
      );

      // print('TC-DA-001: actionName正常性確認 OK（names: $actionNames）');
    });

    // ────────────────────────────────────────────────────────
    // TC-DA-002: markLink.actionsが空の場合、フォールバック動作すること
    // ────────────────────────────────────────────────────────
    test('TC-DA-002: markLink.actionsが空の場合、workBreakdownが空であること', () {
      // テスト交通手段
      final testTrans = TransDomain(
        id: 'trans-test-002',
        transName: 'テストカー',
        kmPerGas: 100,
        meterValue: 45000,
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      // visitWorkトピック
      final visitWorkTopic = TopicDomain(
        id: 'topic-visit-work-test-2',
        topicName: '訪問作業テスト2',
        topicType: TopicType.visitWork,
        isVisible: true,
        isDeleted: false,
        createdAt: baseDate,
        updatedAt: baseDate,
        color: 'skyBlue',
      );

      // テストメンバー
      final testMember = MemberDomain(
        id: 'member-test-002',
        memberName: 'テスト太郎2',
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      // 訪問作業イベント（actionTimeLogs なし = actionsが空）
      final testEvent = EventDomain(
        id: 'event-visit-work-test-2',
        eventName: 'テスト訪問作業2',
        topic: visitWorkTopic,
        trans: testTrans,
        members: [testMember],
        tags: [],
        payMember: testMember,
        markLinks: [
          MarkLinkDomain(
            id: 'ml-test-002',
            markLinkSeq: 1,
            markLinkType: MarkOrLink.mark,
            markLinkDate: baseDate.add(const Duration(hours: 9)),
            markLinkName: 'テスト営業所2',
            members: [testMember],
            actions: [], // 空 → actionTimeLogs がない
            createdAt: baseDate.add(const Duration(hours: 9)),
            updatedAt: baseDate.add(const Duration(hours: 9)),
          ),
        ],
        payments: [],
        actionTimeLogs: [], // 空
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      // テスト実行
      final period = DateRange(
        start: baseDate,
        end: baseDate.add(const Duration(days: 7)),
      );

      final projection = VisitWorkDashboardAdapter.toProjection([testEvent], period);

      // 検証: workBreakdown が空であること
      expect(
        projection.workBreakdown.isEmpty,
        isTrue,
        reason: 'actionTimeLogs が空の場合、workBreakdown も空であること',
      );

      // 検証: totalWorkTimeLabel が "---" であること
      expect(
        projection.totalWorkTimeLabel,
        '---',
        reason: 'actionTimeLogs が空の場合、totalWorkTimeLabel が「---」であること',
      );

      // print('TC-DA-002: 空actionTimeLogs時フォールバック確認 OK');
    });
  });
}
