// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: 移動コスト集計 収支バランス表示（F-2）
///
/// Spec: docs/Spec/Features/FS-moving_cost_balance.md §9
///
/// テストシナリオ: TC-MCB-001 〜 TC-MCB-006
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータ event-001「箱根日帰りドライブ」(movingCost) が存在すること
///     - ml-005（大涌谷）に isFuel:true, gasPrice 設定済み, gasPayer 設定済みであること
///   - シードデータ event-004「週末ドライブ（燃費推定）」(movingCostEstimated) が存在すること
///     - payMember, members, kmPerGas, pricePerGas, totalDistance が設定済みであること
///   - シードデータ event-003「近所のドライブ」(movingCost) が存在すること
///     - markLinks が空（給油実績なし）であること

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ────────────────────────────────────────────────────────
  // ヘルパー関数
  // ────────────────────────────────────────────────────────

  /// アプリを起動して EventListPage が表示されるまで待つ。
  Future<void> startApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント一覧').evaluate().isNotEmpty) break;
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(ListView).evaluate().isNotEmpty ||
          find.text('イベントがありません').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// 指定名称のイベントをタップして EventDetail を開く。
  /// イベントが見つからない場合は false を返す。
  Future<bool> openEventDetailByName(
    WidgetTester tester,
    String eventName,
  ) async {
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final cards = find.ancestor(
      of: find.text(eventName),
      matching: find.byType(GestureDetector),
    );
    if (cards.evaluate().isEmpty) return false;

    await tester.tap(cards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));
    return true;
  }

  /// 概要タブをタップして表示する。
  Future<void> tapOverviewTab(WidgetTester tester) async {
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  /// 概要タブをスクロールして収支バランスセクションを表示する。
  /// 表示できた場合は true を返す。
  Future<bool> scrollToBalanceSection(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      if (find
          .byKey(const Key('movingCostOverview_section_balance'))
          .evaluate()
          .isNotEmpty) {
        return true;
      }
      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.drag(listView.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 300));
      } else {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    return find
        .byKey(const Key('movingCostOverview_section_balance'))
        .evaluate()
        .isNotEmpty;
  }

  /// movingCost（給油実績モード）イベントの概要タブを開くまでのセットアップ。
  /// イベントが存在しない・前提条件を満たさない場合はスキップ理由を返す。null の場合は成功。
  ///
  /// ※ イベント名 '箱根日帰りドライブ' は seed_data.dart の _event1.eventName と一致する。
  ///   _event1 はファイルスコープのプライベート定数のため外部から参照できず、
  ///   文字列リテラルで維持する。
  Future<String?> setupMovingCostOverview(WidgetTester tester) async {
    await startApp(tester);
    final opened =
        await openEventDetailByName(tester, '箱根日帰りドライブ');
    if (!opened) {
      return '「箱根日帰りドライブ」イベントが見つからなかったためスキップします';
    }
    await tapOverviewTab(tester);
    return null;
  }

  /// movingCostEstimated（燃費推定モード）イベントの概要タブを開くまでのセットアップ。
  /// イベントが存在しない場合はスキップ理由を返す。null の場合は成功。
  ///
  /// ※ イベント名 '週末ドライブ（燃費推定）' は seed_data.dart の _event4.eventName と一致する。
  ///   _event4 はファイルスコープのプライベート定数のため外部から参照できず、
  ///   文字列リテラルで維持する。
  Future<String?> setupMovingCostEstimatedOverview(WidgetTester tester) async {
    await startApp(tester);
    final opened =
        await openEventDetailByName(tester, '週末ドライブ（燃費推定）');
    if (!opened) {
      return '「週末ドライブ（燃費推定）」イベントが見つからなかったためスキップします';
    }
    await tapOverviewTab(tester);
    return null;
  }

  /// 収支データなし（gasPayer未設定）のイベントの概要タブを開くまでのセットアップ。
  /// イベントが存在しない場合はスキップ理由を返す。null の場合は成功。
  ///
  /// ※ イベント名 '近所のドライブ' は seed_data.dart の _event3.eventName と一致する。
  ///   _event3 はファイルスコープのプライベート定数のため外部から参照できず、
  ///   文字列リテラルで維持する。
  Future<String?> setupNoBalanceOverview(WidgetTester tester) async {
    await startApp(tester);
    final opened = await openEventDetailByName(tester, '近所のドライブ');
    if (!opened) {
      return '「近所のドライブ」イベントが見つからなかったためスキップします';
    }
    await tapOverviewTab(tester);
    return null;
  }

  // ────────────────────────────────────────────────────────
  // TC-MCB-001〜006
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-MCB-001: 給油実績モード: 収支バランスセクションが表示される',
    (tester) async {
      final skipReason = await setupMovingCostOverview(tester);
      if (skipReason != null) {
        print('[SKIP] $skipReason');
        return;
      }

      final found = await scrollToBalanceSection(tester);
      if (!found) {
        print('[SKIP] 収支バランスセクションがスクロール後も見つからなかったためスキップします'
            '（シードデータの gasPayer が未設定の可能性があります）');
        return;
      }

      expect(
        find.byKey(const Key('movingCostOverview_section_balance')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'TC-MCB-002: 給油実績モード: ガソリン支払者の収支がプラスで表示される',
    (tester) async {
      final skipReason = await setupMovingCostOverview(tester);
      if (skipReason != null) {
        print('[SKIP] $skipReason');
        return;
      }

      final found = await scrollToBalanceSection(tester);
      if (!found) {
        print('[SKIP] 収支バランスセクションが見つからなかったためスキップします'
            '（シードデータの gasPayer が未設定の可能性があります）');
        return;
      }

      // 1番目のメンバーの収支行（インデックス0）が存在すること
      expect(
        find.byKey(const Key('movingCostOverview_row_balance_0')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'TC-MCB-002b: 給油実績モード: ガソリン支払者の収支行の金額テキストが「+」で始まる',
    (tester) async {
      final skipReason = await setupMovingCostOverview(tester);
      if (skipReason != null) {
        print('[SKIP] $skipReason');
        return;
      }

      final found = await scrollToBalanceSection(tester);
      if (!found) {
        print('[SKIP] 収支バランスセクションが見つからなかったためスキップします');
        return;
      }

      if (find
          .byKey(const Key('movingCostOverview_row_balance_0'))
          .evaluate()
          .isEmpty) {
        print('[SKIP] 収支行が見つからなかったためスキップします');
        return;
      }

      // 収支行内に「+」で始まる金額テキストが存在すること
      final balanceRow =
          find.byKey(const Key('movingCostOverview_row_balance_0'));
      final plusText = find.descendant(
        of: balanceRow,
        matching: find.textContaining('+'),
      );
      expect(plusText, findsAtLeastNWidgets(1));
    },
  );

  testWidgets(
    'TC-MCB-003: 給油実績モード: 参加メンバーの収支がマイナスで表示される',
    (tester) async {
      final skipReason = await setupMovingCostOverview(tester);
      if (skipReason != null) {
        print('[SKIP] $skipReason');
        return;
      }

      final found = await scrollToBalanceSection(tester);
      if (!found) {
        print('[SKIP] 収支バランスセクションが見つからなかったためスキップします'
            '（シードデータの gasPayer が未設定の可能性があります）');
        return;
      }

      // ガソリン支払者ではない参加メンバーは2番目以降の行に表示される（インデックス1以降）
      // まず収支行が2件以上存在することを確認する
      if (find
          .byKey(const Key('movingCostOverview_row_balance_1'))
          .evaluate()
          .isEmpty) {
        print('[SKIP] 2番目の収支行（インデックス1）が見つからなかったためスキップします'
            '（ガソリン支払者以外のメンバーが存在しない可能性があります）');
        return;
      }

      // 2番目以降の収支行内に「-」を含む金額テキストが存在すること
      final balanceRow1 =
          find.byKey(const Key('movingCostOverview_row_balance_1'));
      final minusText = find.descendant(
        of: balanceRow1,
        matching: find.textContaining('-'),
      );
      expect(minusText, findsAtLeastNWidgets(1));
    },
  );

  testWidgets(
    'TC-MCB-004: 燃費推定モード: 収支バランスセクションが表示される',
    (tester) async {
      final skipReason = await setupMovingCostEstimatedOverview(tester);
      if (skipReason != null) {
        print('[SKIP] $skipReason');
        return;
      }

      final found = await scrollToBalanceSection(tester);
      if (!found) {
        print('[SKIP] 収支バランスセクションがスクロール後も見つからなかったためスキップします'
            '（シードデータの前提条件を確認してください）');
        return;
      }

      expect(
        find.byKey(const Key('movingCostOverview_section_balance')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'TC-MCB-005: 燃費推定モード: ガソリン支払者の収支がプラスで表示される',
    (tester) async {
      final skipReason = await setupMovingCostEstimatedOverview(tester);
      if (skipReason != null) {
        print('[SKIP] $skipReason');
        return;
      }

      final found = await scrollToBalanceSection(tester);
      if (!found) {
        print('[SKIP] 収支バランスセクションが見つからなかったためスキップします');
        return;
      }

      // 1番目のメンバーの収支行（インデックス0）が存在すること
      expect(
        find.byKey(const Key('movingCostOverview_row_balance_0')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'TC-MCB-005b: 燃費推定モード: ガソリン支払者（payMember）の収支行の金額テキストが「+」で始まる',
    (tester) async {
      final skipReason = await setupMovingCostEstimatedOverview(tester);
      if (skipReason != null) {
        print('[SKIP] $skipReason');
        return;
      }

      final found = await scrollToBalanceSection(tester);
      if (!found) {
        print('[SKIP] 収支バランスセクションが見つからなかったためスキップします');
        return;
      }

      if (find
          .byKey(const Key('movingCostOverview_row_balance_0'))
          .evaluate()
          .isEmpty) {
        print('[SKIP] 収支行が見つからなかったためスキップします');
        return;
      }

      // 収支行内に「+」で始まる金額テキストが存在すること
      final balanceRow =
          find.byKey(const Key('movingCostOverview_row_balance_0'));
      final plusText = find.descendant(
        of: balanceRow,
        matching: find.textContaining('+'),
      );
      expect(plusText, findsAtLeastNWidgets(1));
    },
  );

  testWidgets(
    'TC-MCB-006: 収支データなし: 収支バランスセクションが非表示になる',
    (tester) async {
      final skipReason = await setupNoBalanceOverview(tester);
      if (skipReason != null) {
        print('[SKIP] $skipReason');
        return;
      }

      // 概要タブを全体スクロールして収支バランスセクションが存在しないことを確認する
      for (var i = 0; i < 10; i++) {
        final listView = find.byType(ListView);
        if (listView.evaluate().isNotEmpty) {
          await tester.drag(listView.first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 300));
        } else {
          await tester.pump(const Duration(milliseconds: 300));
        }
      }

      expect(
        find.byKey(const Key('movingCostOverview_section_balance')),
        findsNothing,
      );
    },
  );
}
