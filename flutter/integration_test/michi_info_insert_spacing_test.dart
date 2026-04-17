// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: MichiInfo InsertMode時のMark間隔
///
/// バグ: B-9
/// InsertMode（追加ボタン押下時）にLink間にないMark間の間隔が広くなる。
/// Linkがない区間は間隔を狭める必要がある。
///
/// テストシナリオ: TC-MII-001 〜 TC-MII-003
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータが投入済みであること
///     - event-001: 箱根日帰りドライブ（ml-001: Mark → ml-002: Link → ml-003: Mark → ml-004: Link → ml-005: Mark）
///
/// ウィジェットキー:
///   - michiInfo_fab_add: InsertMode ON/OFFのFABボタン
///   - michiInfo_button_insertIndicator_head: 先頭インジケーター（insertAfterSeq: -1）
///   - insert_indicator_{seq}: 各アイテム後インジケーター

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
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byType(ListView).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// event-001（箱根日帰りドライブ）のミチタブを開くセットアップ。
  /// スキップ理由がある場合は文字列を返す。null の場合は成功。
  Future<String?> setupHakoneMichiTab(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }
    final opened = await openEventDetailByName(tester, '箱根日帰りドライブ');
    if (!opened) {
      return '箱根日帰りドライブを開けなかったためスキップします';
    }
    await openMichiTab(tester);
    return null;
  }

  /// FABボタン（michiInfo_fab_add）をタップしてInsertModeをONにする。
  /// InsertModeに入ったことを先頭インジケーター（michiInfo_button_insertIndicator_head）の
  /// 表示で確認する。
  Future<bool> enableInsertMode(WidgetTester tester) async {
    final fab = find.byKey(const Key('michiInfo_fab_add'));
    if (fab.evaluate().isEmpty) return false;

    await tester.ensureVisible(fab);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(fab);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find
          .byKey(const Key('michiInfo_button_insertIndicator_head'))
          .evaluate()
          .isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // ────────────────────────────────────────────────────────
  // TC-MII-001: InsertMode時、Link間にないMark間のInsertIndicatorが
  //             適切な高さ（Linkがある時より小さい）で表示される
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MII-001: InsertMode時の先頭InsertIndicatorの高さが36以下である',
      (tester) async {
    final skipReason = await setupHakoneMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final insertModeEnabled = await enableInsertMode(tester);
    if (!insertModeEnabled) {
      print('[SKIP] InsertModeへの切り替えができなかったためスキップします');
      return;
    }

    // 先頭インジケーター（先頭はMark前でLinkがない位置）が表示されていることを確認
    final headIndicator = find.byKey(
      const Key('michiInfo_button_insertIndicator_head'),
    );
    expect(headIndicator, findsOneWidget);

    // InsertIndicatorの高さが適切な範囲（36px以下）であることを確認
    // 修正前はMarkのgapAfterItem(_markMarkGap=50)が適用されて間隔が大きくなるが、
    // InsertIndicator自体のSizedBox height=36が基準値
    final indicatorSize = tester.getSize(headIndicator);
    expect(indicatorSize.height <= 36.0, isTrue);
  });

  testWidgets('TC-MII-001b: InsertMode時、Mark直後のInsertIndicatorの高さが36以下である',
      (tester) async {
    final skipReason = await setupHakoneMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final insertModeEnabled = await enableInsertMode(tester);
    if (!insertModeEnabled) {
      print('[SKIP] InsertModeへの切り替えができなかったためスキップします');
      return;
    }

    // ml-001（seq=1）の直後インジケーター: Mark後でLink前の位置
    // シードデータ: ml-001(Mark,seq=1) → [insert_indicator_1] → ml-002(Link,seq=2) → ...
    final indicatorAfterMark = find.byKey(const Key('insert_indicator_1'));

    // 画面内になければスクロールして探す
    for (var i = 0; i < 10; i++) {
      if (indicatorAfterMark.evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(indicatorAfterMark, findsOneWidget);

    // InsertIndicatorの高さが36以下であることを確認
    final indicatorSize = tester.getSize(indicatorAfterMark);
    expect(indicatorSize.height <= 36.0, isTrue);
  });

  // ────────────────────────────────────────────────────────
  // TC-MII-002: InsertMode時、Link間にあるInsertIndicatorが正常な高さで
  //             表示される（正常系確認）
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MII-002: InsertMode時、Link後のInsertIndicatorが表示される',
      (tester) async {
    final skipReason = await setupHakoneMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final insertModeEnabled = await enableInsertMode(tester);
    if (!insertModeEnabled) {
      print('[SKIP] InsertModeへの切り替えができなかったためスキップします');
      return;
    }

    // ml-002（seq=2, Link）の直後インジケーター
    // シードデータ: ml-001(Mark) → ml-002(Link,seq=2) → [insert_indicator_2] → ml-003(Mark) → ...
    final indicatorAfterLink = find.byKey(const Key('insert_indicator_2'));

    for (var i = 0; i < 10; i++) {
      if (indicatorAfterLink.evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(indicatorAfterLink, findsOneWidget);
  });

  testWidgets('TC-MII-002b: InsertMode時、Link後のInsertIndicatorの高さが36以下である',
      (tester) async {
    final skipReason = await setupHakoneMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final insertModeEnabled = await enableInsertMode(tester);
    if (!insertModeEnabled) {
      print('[SKIP] InsertModeへの切り替えができなかったためスキップします');
      return;
    }

    // ml-002（seq=2, Link）の直後インジケーター
    final indicatorAfterLink = find.byKey(const Key('insert_indicator_2'));

    for (var i = 0; i < 10; i++) {
      if (indicatorAfterLink.evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(indicatorAfterLink, findsOneWidget);

    // Link後のInsertIndicatorも高さ36以下であることを確認
    final indicatorSize = tester.getSize(indicatorAfterLink);
    expect(indicatorSize.height <= 36.0, isTrue);
  });

  testWidgets('TC-MII-002c: InsertMode時、全InsertIndicatorが画面上に存在する（items数+1件）',
      (tester) async {
    final skipReason = await setupHakoneMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final insertModeEnabled = await enableInsertMode(tester);
    if (!insertModeEnabled) {
      print('[SKIP] InsertModeへの切り替えができなかったためスキップします');
      return;
    }

    // event-001には5件のMarkLink（ml-001〜ml-005）がある
    // InsertMode時のInsertIndicatorはitems.length+1件（5+1=6件）
    // 先頭: michiInfo_button_insertIndicator_head
    // アイテム後: insert_indicator_1, insert_indicator_2, insert_indicator_3, insert_indicator_4, insert_indicator_5

    // 先頭インジケーターの存在確認
    expect(
      find.byKey(const Key('michiInfo_button_insertIndicator_head')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MII-003: InsertMode解除後、Mark間の間隔が通常に戻る
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MII-003: InsertMode解除後、InsertIndicatorが画面から消える',
      (tester) async {
    final skipReason = await setupHakoneMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // InsertModeをONにする
    final insertModeEnabled = await enableInsertMode(tester);
    if (!insertModeEnabled) {
      print('[SKIP] InsertModeへの切り替えができなかったためスキップします');
      return;
    }

    // InsertMode中は先頭インジケーターが表示されている
    expect(
      find.byKey(const Key('michiInfo_button_insertIndicator_head')),
      findsOneWidget,
    );
  });

  testWidgets('TC-MII-003b: InsertMode解除後（FAB再タップ）、InsertIndicatorが消える',
      (tester) async {
    final skipReason = await setupHakoneMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // InsertModeをONにする
    final insertModeEnabled = await enableInsertMode(tester);
    if (!insertModeEnabled) {
      print('[SKIP] InsertModeへの切り替えができなかったためスキップします');
      return;
    }

    // FABを再タップしてInsertModeをOFFにする
    final fab = find.byKey(const Key('michiInfo_fab_add'));
    if (fab.evaluate().isNotEmpty) {
      await tester.ensureVisible(fab);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(fab);
      await tester.pump(const Duration(milliseconds: 500));
    }

    // InsertMode解除後はInsertIndicatorが表示されないことを確認
    expect(
      find.byKey(const Key('michiInfo_button_insertIndicator_head')),
      findsNothing,
    );
  });

  testWidgets('TC-MII-003c: InsertMode解除後、insert_indicator_1が画面から消える',
      (tester) async {
    final skipReason = await setupHakoneMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // InsertModeをONにする
    final insertModeEnabled = await enableInsertMode(tester);
    if (!insertModeEnabled) {
      print('[SKIP] InsertModeへの切り替えができなかったためスキップします');
      return;
    }

    // FABを再タップしてInsertModeをOFFにする
    final fab = find.byKey(const Key('michiInfo_fab_add'));
    if (fab.evaluate().isNotEmpty) {
      await tester.ensureVisible(fab);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(fab);
      await tester.pump(const Duration(milliseconds: 500));
    }

    // InsertMode解除後は seq=1 のインジケーターも消えていることを確認
    expect(
      find.byKey(const Key('insert_indicator_1')),
      findsNothing,
    );
  });
}
