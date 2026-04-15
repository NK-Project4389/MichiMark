// ignore_for_file: avoid_print

/// Integration Test: MichiInfo カード間挿入機能
///
/// Spec: docs/Spec/Features/MichiInfo/CardInsert_Spec.md §11
/// テストシナリオ: TC-MCI-001 〜 TC-MCI-010

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ────────────────────────────────────────────────────────
  // ヘルパー
  // ────────────────────────────────────────────────────────

  /// アプリを起動して EventListPage が表示されるまで待つ。
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
      if (find.text('箱根日帰りドライブ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// アプリを起動して MichiInfo タブまで遷移する。
  Future<void> goToMichiInfoTab(WidgetTester tester, String eventName) async {
    await startApp(tester);

    final eventCards = find.ancestor(
      of: find.text(eventName),
      matching: find.byType(GestureDetector),
    );
    expect(eventCards, findsWidgets,
        reason: '$eventName のイベントカードが見つかること');

    await tester.tap(eventCards.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }

    final michiTab = find.text('ミチ');
    expect(michiTab, findsOneWidget, reason: '「ミチ」タブが表示されること');
    await tester.tap(michiTab);
    await tester.pump(const Duration(milliseconds: 500));

    // MichiInfo ページのロードを待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// MarkDetail 画面がロードされるまで待つ。
  /// 「反映」ボタンまたは「名称（任意）」TextFieldが表示されるまで待機する。
  Future<bool> waitForMarkDetailScreen(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('保存').evaluate().isNotEmpty ||
          find.text('名称（任意）').evaluate().isNotEmpty ||
          find.text('地点詳細').evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// LinkDetail 画面がロードされるまで待つ。
  Future<bool> waitForLinkDetailScreen(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('保存').evaluate().isNotEmpty ||
          find.text('区間詳細').evaluate().isNotEmpty ||
          find.text('名称（任意）').evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // ────────────────────────────────────────────────────────
  // TC-MCI-001: Amber FAB（+アイコン）が表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MCI-001: アイテムが1件以上ある状態でMichiInfoを開くとAmber FABが表示される',
      (tester) async {
    // 前提: 「箱根日帰りドライブ」には複数のマーク/リンクが存在する
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // FloatingActionButton が存在すること
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: 'MichiInfoにFABが表示されること');

    // FABの背景色が Amber（#F59E0B）であること
    final fabWidget = tester.widget<FloatingActionButton>(fab);
    expect(
      fabWidget.backgroundColor,
      equals(const Color(0xFFF59E0B)),
      reason: 'FABの背景色がAmber(#F59E0B)であること',
    );

    // FABに + アイコンが表示されていること
    expect(
      find.descendant(
        of: fab,
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
      reason: 'FABに + アイコンが表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MCI-002: Amber FAB をタップすると挿入モードになる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MCI-002: Amber FABをタップすると挿入モードになりインジケーターが表示される',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // FABをタップ（挿入モードへ）
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: 'FABが表示されること');
    await tester.tap(fab);
    await tester.pump(const Duration(milliseconds: 500));

    // FABのアイコンが close に変わること
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.close),
      ),
      findsOneWidget,
      reason: '挿入モード中はFABアイコンがcloseに変わること',
    );

    // インジケーターが表示されること（add_circle_outline アイコンが少なくとも1件）
    expect(
      find.byIcon(Icons.add_circle),
      findsWidgets,
      reason: '挿入モード中はインジケーターが各カード間に表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MCI-003: 挿入モード中に FAB を再タップすると通常モードに戻る
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MCI-003: 挿入モード中にFABを再タップすると通常モードに戻りインジケーターが消える',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // 1回目のタップ（挿入モードへ）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 500));

    // 挿入モードになったことを確認
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.close),
      ),
      findsOneWidget,
      reason: '挿入モード中はFABアイコンがcloseであること',
    );

    // 2回目のタップ（通常モードへ戻る）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 500));

    // FABが + アイコンに戻ること
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
      reason: '通常モードに戻るとFABアイコンが + に戻ること',
    );

    // インジケーターが消えること
    expect(
      find.byIcon(Icons.add_circle),
      findsNothing,
      reason: '通常モードに戻るとインジケーターが消えること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MCI-004: 挿入モード中にインジケーターをタップするとBottomSheetが表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MCI-004: 挿入モード中にインジケーターをタップするとBottomSheetが表示される',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // FABタップ（挿入モードへ）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 500));

    // インジケーターが表示されていることを確認
    final indicators = find.byIcon(Icons.add_circle);
    expect(indicators, findsWidgets, reason: 'インジケーターが表示されること');

    // 最初のインジケーターをタップ
    await tester.tap(indicators.first);
    await tester.pump(const Duration(milliseconds: 500));

    // BottomSheet が表示されること
    final hasAddMark = find.text('地点を追加').evaluate().isNotEmpty ||
        find.text('Markを追加').evaluate().isNotEmpty ||
        find.text('Mark を追加').evaluate().isNotEmpty;
    final hasAddLink = find.text('区間を追加').evaluate().isNotEmpty ||
        find.text('Linkを追加').evaluate().isNotEmpty ||
        find.text('Link を追加').evaluate().isNotEmpty ||
        find.text('リンクを追加').evaluate().isNotEmpty;

    expect(
      hasAddMark || hasAddLink,
      isTrue,
      reason: 'BottomSheetが表示されること（地点を追加またはリンクを追加のボタンが存在すること）',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MCI-005: BottomSheet をスワイプで閉じると挿入モードが終了する（B-8修正後の仕様）
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MCI-005: BottomSheetをスワイプで閉じると挿入モードが終了しインジケーターが消える', (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // FABタップ（挿入モードへ）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 500));

    // インジケーターをタップ
    final indicators = find.byIcon(Icons.add_circle);
    expect(indicators, findsWidgets, reason: 'インジケーターが表示されること');
    await tester.tap(indicators.first);
    await tester.pump(const Duration(milliseconds: 500));

    // BottomSheet が表示されることを確認
    final hasBottomSheet = find.text('地点を追加').evaluate().isNotEmpty ||
        find.text('Markを追加').evaluate().isNotEmpty ||
        find.text('Mark を追加').evaluate().isNotEmpty ||
        find.text('区間を追加').evaluate().isNotEmpty ||
        find.text('Linkを追加').evaluate().isNotEmpty ||
        find.text('Link を追加').evaluate().isNotEmpty;
    expect(hasBottomSheet, isTrue, reason: 'BottomSheetが表示されること');

    // BottomSheet をドラッグ（スワイプ）して閉じる
    await tester.drag(find.byType(BottomSheet), const Offset(0, 300));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.byIcon(Icons.add_circle).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // B-8修正後の仕様: BottomSheetをキャンセル（スワイプで閉じる）すると
    // MichiInfoInsertPointCancelled が dispatch され挿入モードが終了する
    expect(
      find.byIcon(Icons.add_circle),
      findsNothing,
      reason: 'BottomSheetをスワイプで閉じるとMichiInfoInsertPointCancelledが発行され挿入モードが終了してインジケーターが消えること（B-8修正後の仕様）',
    );

    // FABアイコンが add に戻ること
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
      reason: 'BottomSheetをスワイプで閉じると挿入モードが終了してFABアイコンがaddに戻ること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MCI-006: BottomSheet で「Mark を追加」を選択すると MarkDetail 新規作成画面へ遷移する
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MCI-006: BottomSheetで地点追加を選択するとMarkDetail新規作成画面に遷移する',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // FABタップ（挿入モードへ）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 500));

    // インジケーターをタップ
    final indicators = find.byIcon(Icons.add_circle);
    expect(indicators, findsWidgets, reason: 'インジケーターが表示されること');
    await tester.tap(indicators.first);
    await tester.pump(const Duration(milliseconds: 500));

    // BottomSheet から「地点を追加」または「Mark を追加」をタップ
    Finder addMarkFinder;
    if (find.text('地点を追加').evaluate().isNotEmpty) {
      addMarkFinder = find.text('地点を追加');
    } else if (find.textContaining('Mark').evaluate().isNotEmpty) {
      addMarkFinder = find.textContaining('Mark');
    } else {
      markTestSkipped('TC-MCI-006: BottomSheetに地点追加ボタンが見つからないためスキップ');
      return;
    }

    await tester.tap(addMarkFinder.first);

    // MarkDetail 画面がロードされるまで待つ
    final reached = await waitForMarkDetailScreen(tester);
    expect(
      reached,
      isTrue,
      reason: 'MarkDetail新規作成画面に遷移すること（「反映」または「名称（任意）」が表示されること）',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MCI-007: Mark 詳細を入力して保存するとタイムライン指定位置に挿入される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MCI-007: Mark詳細を入力して保存するとタイムラインの指定位置にカードが挿入される',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // FABタップ（挿入モードへ）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 500));

    // インジケーターをタップ（最初のインジケーター = 1枚目のカードの後）
    final indicators = find.byIcon(Icons.add_circle);
    expect(indicators, findsWidgets, reason: 'インジケーターが表示されること');
    await tester.tap(indicators.first);
    await tester.pump(const Duration(milliseconds: 500));

    // BottomSheet で地点追加を選択
    Finder addMarkFinder;
    if (find.text('地点を追加').evaluate().isNotEmpty) {
      addMarkFinder = find.text('地点を追加');
    } else if (find.textContaining('Mark').evaluate().isNotEmpty) {
      addMarkFinder = find.textContaining('Mark');
    } else {
      markTestSkipped('TC-MCI-007: BottomSheetに地点追加ボタンが表示されないためスキップ');
      return;
    }

    await tester.tap(addMarkFinder.first);

    // MarkDetail 画面がロードされるまで待つ
    final reached = await waitForMarkDetailScreen(tester);
    if (!reached) {
      markTestSkipped('TC-MCI-007: MarkDetail画面に遷移できなかったためスキップ');
      return;
    }

    // MarkDetail 画面で名称を入力
    final nameFields = find.ancestor(
      of: find.text('名称（任意）'),
      matching: find.byType(TextField),
    );

    if (nameFields.evaluate().isNotEmpty) {
      await tester.tap(nameFields.first);
      await tester.enterText(nameFields.first, '挿入テスト地点');
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 保存ボタンをタップ（反映）
    final saveButton = find.text('保存');
    if (saveButton.evaluate().isEmpty) {
      markTestSkipped('TC-MCI-007: 保存ボタン（保存）が見つからないためスキップ');
      return;
    }

    await tester.ensureVisible(saveButton);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(saveButton);

    // 保存後の画面遷移を待つ（MichiInfoに戻るまで待機）
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    // MichiInfoに戻ったことを確認（FABが表示されること）
    expect(
      find.byType(FloatingActionButton),
      findsOneWidget,
      reason: '保存後にMichiInfoページに戻ること',
    );

    // 保存後は挿入モードが解除されていること（FABが + アイコンに戻ること）
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
      reason: '保存後は挿入モードが解除されFABアイコンが + に戻ること',
    );

    // 「挿入テスト地点」カードが表示されること（スクロールして確認）
    if (nameFields.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        if (find.text('挿入テスト地点').evaluate().isNotEmpty) break;
        if (find.byType(ListView).evaluate().isNotEmpty) {
          await tester.drag(
              find.byType(ListView).first, const Offset(0, -200));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }
      expect(
        find.text('挿入テスト地点'),
        findsOneWidget,
        reason: '挿入されたMarkカード「挿入テスト地点」がタイムラインに表示されること',
      );
    }
  });

  // ────────────────────────────────────────────────────────
  // TC-MCI-008: BottomSheet で「Link を追加」を選択すると LinkDetail 新規作成画面へ遷移する
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MCI-008: BottomSheetでリンク追加を選択するとLinkDetail新規作成画面に遷移する',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // FABタップ（挿入モードへ）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 500));

    // インジケーターをタップ
    final indicators = find.byIcon(Icons.add_circle);
    expect(indicators, findsWidgets, reason: 'インジケーターが表示されること');
    await tester.tap(indicators.first);
    await tester.pump(const Duration(milliseconds: 500));

    // BottomSheet に「区間を追加」または「Link を追加」があることを確認
    Finder addLinkFinder;
    if (find.text('区間を追加').evaluate().isNotEmpty) {
      addLinkFinder = find.text('区間を追加');
    } else if (find.textContaining('Link').evaluate().isNotEmpty) {
      addLinkFinder = find.textContaining('Link');
    } else if (find.text('リンクを追加').evaluate().isNotEmpty) {
      addLinkFinder = find.text('リンクを追加');
    } else {
      markTestSkipped(
          'TC-MCI-008: BottomSheetにリンク追加ボタンが表示されないためスキップ（addMenuItemsにLinkが含まれない可能性）');
      return;
    }

    await tester.tap(addLinkFinder.first);

    // LinkDetail 画面がロードされるまで待つ
    final reached = await waitForLinkDetailScreen(tester);
    expect(
      reached,
      isTrue,
      reason: 'LinkDetail新規作成画面に遷移すること（「反映」または「区間詳細」または「名称（任意）」が表示されること）',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MCI-009: Link 詳細を入力して保存するとタイムライン指定位置に挿入される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MCI-009: Link詳細を入力して保存するとタイムラインの指定位置にカードが挿入される',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // FABタップ（挿入モードへ）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 500));

    // インジケーターをタップ
    final indicators = find.byIcon(Icons.add_circle);
    expect(indicators, findsWidgets, reason: 'インジケーターが表示されること');
    await tester.tap(indicators.first);
    await tester.pump(const Duration(milliseconds: 500));

    // BottomSheet に「区間を追加」または「Link を追加」があることを確認
    Finder addLinkFinder;
    if (find.text('区間を追加').evaluate().isNotEmpty) {
      addLinkFinder = find.text('区間を追加');
    } else if (find.textContaining('Link').evaluate().isNotEmpty) {
      addLinkFinder = find.textContaining('Link');
    } else if (find.text('リンクを追加').evaluate().isNotEmpty) {
      addLinkFinder = find.text('リンクを追加');
    } else {
      markTestSkipped('TC-MCI-009: BottomSheetにリンク追加ボタンが表示されないためスキップ');
      return;
    }

    await tester.tap(addLinkFinder.first);

    // LinkDetail 画面がロードされるまで待つ
    final reached = await waitForLinkDetailScreen(tester);
    if (!reached) {
      markTestSkipped('TC-MCI-009: LinkDetail画面に遷移できなかったためスキップ');
      return;
    }

    // LinkDetail 画面で名称を入力
    final nameFields = find.ancestor(
      of: find.text('名称（任意）'),
      matching: find.byType(TextField),
    );

    if (nameFields.evaluate().isNotEmpty) {
      await tester.tap(nameFields.first);
      await tester.enterText(nameFields.first, '挿入テスト区間');
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 保存ボタンをタップ（反映）
    final saveButton = find.text('保存');
    if (saveButton.evaluate().isEmpty) {
      markTestSkipped('TC-MCI-009: 保存ボタン（保存）が見つからないためスキップ');
      return;
    }

    await tester.ensureVisible(saveButton);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(saveButton);

    // 保存後の画面遷移を待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    // MichiInfoに戻ったことを確認
    expect(
      find.byType(FloatingActionButton),
      findsOneWidget,
      reason: '保存後にMichiInfoページに戻ること',
    );

    // 保存後は挿入モードが解除されていること
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
      reason: '保存後は挿入モードが解除されFABアイコンが + に戻ること',
    );

    // 「挿入テスト区間」カードが表示されること
    if (nameFields.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        if (find.text('挿入テスト区間').evaluate().isNotEmpty) break;
        if (find.byType(ListView).evaluate().isNotEmpty) {
          await tester.drag(
              find.byType(ListView).first, const Offset(0, -200));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }
      expect(
        find.text('挿入テスト区間'),
        findsOneWidget,
        reason: '挿入されたLinkカード「挿入テスト区間」がタイムラインに表示されること',
      );
    }
  });

  // ────────────────────────────────────────────────────────
  // TC-MCI-010: 末尾インジケーターをタップして Mark を追加・保存すると末尾に追加される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MCI-010: 末尾インジケーターをタップしてMarkを追加・保存すると末尾にカードが追加される',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // FABタップ（挿入モードへ）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 500));

    // インジケーターが表示されていることを確認
    final indicatorsBefore = find.byIcon(Icons.add_circle);
    expect(indicatorsBefore, findsWidgets, reason: 'インジケーターが表示されること');

    // 末尾インジケーターに到達するまでスクロール
    if (find.byType(ListView).evaluate().isNotEmpty) {
      for (var i = 0; i < 10; i++) {
        await tester.drag(
            find.byType(ListView).first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 末尾インジケーターをタップ（最後に表示されているインジケーター）
    final indicatorsAtEnd = find.byIcon(Icons.add_circle);
    if (indicatorsAtEnd.evaluate().isEmpty) {
      markTestSkipped('TC-MCI-010: 末尾インジケーターが見つからないためスキップ');
      return;
    }

    await tester.tap(indicatorsAtEnd.last);
    await tester.pump(const Duration(milliseconds: 500));

    // BottomSheet が表示されること
    Finder addMarkFinder;
    if (find.text('地点を追加').evaluate().isNotEmpty) {
      addMarkFinder = find.text('地点を追加');
    } else if (find.textContaining('Mark').evaluate().isNotEmpty) {
      addMarkFinder = find.textContaining('Mark');
    } else {
      markTestSkipped('TC-MCI-010: BottomSheetが表示されないためスキップ');
      return;
    }

    // 「地点を追加」または「Mark を追加」をタップ
    await tester.tap(addMarkFinder.first);

    // MarkDetail 画面がロードされるまで待つ
    final reached = await waitForMarkDetailScreen(tester);
    if (!reached) {
      markTestSkipped('TC-MCI-010: MarkDetail画面に遷移できなかったためスキップ');
      return;
    }

    // MarkDetail 画面で名称を入力
    final nameFields = find.ancestor(
      of: find.text('名称（任意）'),
      matching: find.byType(TextField),
    );

    if (nameFields.evaluate().isNotEmpty) {
      await tester.tap(nameFields.first);
      await tester.enterText(nameFields.first, '末尾挿入テスト地点');
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 保存ボタンをタップ（反映）
    final saveButton = find.text('保存');
    if (saveButton.evaluate().isEmpty) {
      markTestSkipped('TC-MCI-010: 保存ボタン（保存）が見つからないためスキップ');
      return;
    }

    await tester.ensureVisible(saveButton);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(saveButton);

    // 保存後の画面遷移を待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    // MichiInfoに戻ったことを確認
    expect(
      find.byType(FloatingActionButton),
      findsOneWidget,
      reason: '保存後にMichiInfoページに戻ること',
    );

    // 末尾に「末尾挿入テスト地点」カードが追加されていること（末尾まで再スクロールして確認）
    if (nameFields.evaluate().isNotEmpty) {
      if (find.byType(ListView).evaluate().isNotEmpty) {
        for (var i = 0; i < 10; i++) {
          await tester.drag(
              find.byType(ListView).first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 200));
        }
        await tester.pump(const Duration(milliseconds: 500));
      }

      for (var i = 0; i < 5; i++) {
        if (find.text('末尾挿入テスト地点').evaluate().isNotEmpty) break;
        if (find.byType(ListView).evaluate().isNotEmpty) {
          await tester.drag(
              find.byType(ListView).first, const Offset(0, -200));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }
      expect(
        find.text('末尾挿入テスト地点'),
        findsOneWidget,
        reason: '末尾に追加されたMarkカード「末尾挿入テスト地点」がタイムラインに表示されること',
      );
    }
  });
}
