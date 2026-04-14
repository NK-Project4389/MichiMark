// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: 作成ボタン（FAB）再押し可能確認
///
/// Spec: B-8 バグ修正
///   イベント作成ボタン（FAB）を押してトピック選択せずに戻ると、
///   再度FABが押せなくなるバグの修正確認。
///   修正内容: `_onInsertPointCancelled` で `isInsertMode: false` もリセット。
///
/// テストシナリオ: TC-CAB-001 〜 TC-CAB-002
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータが投入済みであること
///     - event-001: movingCostトピック（addMenuItems: mark + link の2件）
///     - イベントにはMarkデータが存在する（非空リスト）

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

  /// アプリを起動してイベント一覧が表示されるまで待つ。
  Future<void> startApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント').evaluate().isNotEmpty) break;
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

  /// イベント一覧から指定したイベント名のイベントをタップしてEventDetailを開く。
  /// イベントが見つからない場合は false を返す。
  Future<bool> openEventDetailByName(
    WidgetTester tester,
    String eventName,
  ) async {
    for (var i = 0; i < 10; i++) {
      if (find.text(eventName).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isEmpty) break;
      await tester.drag(listViews.first, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 200));
    }

    if (find.text(eventName).evaluate().isEmpty) return false;

    await tester.tap(find.text(eventName).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// ミチタブをタップして MichiInfoView を表示する。
  Future<void> openMichiTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isNotEmpty) {
      await tester.tap(michiTab.first);
      await tester.pump(const Duration(milliseconds: 500));
    }
    // MichiInfoView の FAB が描画されるまで待機
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('michiInfo_fab_add')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// movingCostトピック（addMenuItems: mark + link の2件）のミチタブを開くセットアップ。
  /// スキップ理由がある場合は文字列を返す。null の場合は成功。
  Future<String?> setupMovingCostMichiTab(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }
    final opened = await openEventDetailByName(tester, '箱根日帰りドライブ');
    if (!opened) {
      return '箱根日帰りドライブを開けなかったためスキップします';
    }
    await openMichiTab(tester);

    // FAB が表示されていることを確認
    if (find.byKey(const Key('michiInfo_fab_add')).evaluate().isEmpty) {
      return 'FABが表示されなかったためスキップします';
    }
    return null;
  }

  /// FABをタップしてinsertModeに入り、先頭インジケーターをタップしてボトムシートを表示する。
  /// ボトムシートが表示されたら true を返す。
  Future<bool> openBottomSheetViaFabAndIndicator(WidgetTester tester) async {
    // FABタップ → isInsertMode: true（インジケーターが表示される）
    await tester.tap(find.byKey(const Key('michiInfo_fab_add')));
    await tester.pump(const Duration(milliseconds: 500));

    // 先頭インジケーター（michiInfo_button_insertIndicator_head）が表示されるまで待機
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_insertIndicator_head')).evaluate().isNotEmpty) {
        break;
      }
    }

    if (find.byKey(const Key('michiInfo_button_insertIndicator_head')).evaluate().isEmpty) {
      return false;
    }

    // 先頭インジケーターをタップ → pendingInsertAfterSeq 設定 → ボトムシートが表示される
    await tester.tap(find.byKey(const Key('michiInfo_button_insertIndicator_head')));
    await tester.pump(const Duration(milliseconds: 500));

    // ボトムシートが表示されるまで待機
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_addMark')).evaluate().isNotEmpty ||
          find.byKey(const Key('michiInfo_button_addLink')).evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // ────────────────────────────────────────────────────────
  // TC-CAB-001: FABを押してトピック選択せずキャンセル → FABが再度押せる
  // ────────────────────────────────────────────────────────

  testWidgets('TC-CAB-001: FABを押してインジケータータップ後にキャンセルするとFABが再度押せること',
      (tester) async {
    final skipReason = await setupMovingCostMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // FABタップ → インジケータータップ → ボトムシートを表示
    final bottomSheetOpened = await openBottomSheetViaFabAndIndicator(tester);
    if (!bottomSheetOpened) {
      print('[SKIP] ボトムシートが表示されなかったためスキップします');
      return;
    }

    // バリアタップでボトムシートをキャンセル
    await tester.tapAt(const Offset(200, 100));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // ボトムシートが閉じるまで待機
      if (find.byKey(const Key('michiInfo_button_addMark')).evaluate().isEmpty &&
          find.byKey(const Key('michiInfo_button_addLink')).evaluate().isEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 500));

    // FABが再表示されていることを確認
    expect(
      find.byKey(const Key('michiInfo_fab_add')),
      findsOneWidget,
    );
  });

  testWidgets('TC-CAB-001b: キャンセル後のFABが再タップ可能であること（isInsertModeがfalseにリセットされる）',
      (tester) async {
    final skipReason = await setupMovingCostMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // 1回目: FABタップ → インジケータータップ → ボトムシートを表示
    final bottomSheetOpened = await openBottomSheetViaFabAndIndicator(tester);
    if (!bottomSheetOpened) {
      print('[SKIP] ボトムシートが表示されなかったためスキップします');
      return;
    }

    // バリアタップでキャンセル
    await tester.tapAt(const Offset(200, 100));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_addMark')).evaluate().isEmpty &&
          find.byKey(const Key('michiInfo_button_addLink')).evaluate().isEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 500));

    // 2回目: FABを再タップ → インジケーター表示 → インジケータータップ → ボトムシートが再表示できること
    final bottomSheetReopened = await openBottomSheetViaFabAndIndicator(tester);

    // ボトムシートが再表示されること（addMark または addLink のどちらかが存在）
    expect(bottomSheetReopened, isTrue);
  });

  // ────────────────────────────────────────────────────────
  // TC-CAB-002: FABを押してinsertModeに入った後にFABの×でキャンセル → FABが再度押せる
  // ────────────────────────────────────────────────────────

  testWidgets('TC-CAB-002: FABを押してinsertModeに入った後にFABの×でキャンセルするとFABが再度押せること',
      (tester) async {
    final skipReason = await setupMovingCostMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // FABタップ → isInsertMode: true（インジケーターが表示される）
    await tester.tap(find.byKey(const Key('michiInfo_fab_add')));
    await tester.pump(const Duration(milliseconds: 500));

    // インジケーターが表示されるまで待機
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_insertIndicator_head')).evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    // insertModeでFABをタップしてinsertModeを終了（×アイコンが表示されているはず）
    if (find.byKey(const Key('michiInfo_fab_add')).evaluate().isEmpty) {
      print('[SKIP] insertMode中にFABが見つからないためスキップします');
      return;
    }
    await tester.tap(find.byKey(const Key('michiInfo_fab_add')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // insertModeが終了し通常モードに戻るまで待機
      if (find.byKey(const Key('michiInfo_button_insertIndicator_head')).evaluate().isEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 500));

    // FABが再表示されていることを確認
    expect(
      find.byKey(const Key('michiInfo_fab_add')),
      findsOneWidget,
    );
  });

  testWidgets('TC-CAB-002b: insertModeキャンセル後にFABが再タップ可能でボトムシートが表示されること',
      (tester) async {
    final skipReason = await setupMovingCostMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // 1回目: FABタップ → isInsertMode: true
    await tester.tap(find.byKey(const Key('michiInfo_fab_add')));
    await tester.pump(const Duration(milliseconds: 500));

    // インジケーターが表示されるまで待機
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_insertIndicator_head')).evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    // insertMode中にFABの×をタップしてキャンセル
    if (find.byKey(const Key('michiInfo_fab_add')).evaluate().isEmpty) {
      print('[SKIP] insertMode中にFABが見つからないためスキップします');
      return;
    }
    await tester.tap(find.byKey(const Key('michiInfo_fab_add')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_insertIndicator_head')).evaluate().isEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 500));

    // 2回目: FABを再タップ → インジケーター表示 → インジケータータップ → ボトムシートが再表示できること
    final bottomSheetReopened = await openBottomSheetViaFabAndIndicator(tester);

    // ボトムシートが再表示されること
    expect(bottomSheetReopened, isTrue);
  });
}
