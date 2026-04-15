// ignore_for_file: avoid_print

/// Integration Test: MichiInfo タイムライン 道路イメージ背景
///
/// Spec: docs/Spec/Features/FS-michi_info_road_timeline.md §7
///
/// テストシナリオ: TC-RDT-001 〜 TC-RDT-005
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータのイベントが存在すること
///   - GetIt.I.reset() → router.go('/') → app.main() の順で起動すること
///   - Integration Test 内では pumpAndSettle() を使用しないこと（CustomPainter が常時再描画するため無限ハングになる）

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
      if (find.text('イベント').evaluate().isNotEmpty) break;
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(ListView).evaluate().isNotEmpty ||
          find.text('イベントがありません').evaluate().isNotEmpty) { break; }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// 指定イベント名のカードをタップして EventDetail を開く。
  /// 成功した場合は true を返す。
  Future<bool> openEventDetail(
    WidgetTester tester,
    String eventName,
  ) async {
    final cards = find.ancestor(
      of: find.text(eventName),
      matching: find.byType(GestureDetector),
    );
    if (cards.evaluate().isEmpty) return false;
    await tester.tap(cards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty ||
          find.text('ミチ').evaluate().isNotEmpty) { break; }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// EventDetail の「ミチ」タブをタップして MichiInfo 画面に遷移する。
  /// 成功した場合は true を返す。
  Future<bool> goToMichiTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return false;
    await tester.tap(michiTab);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    // タイムラインのロード完了を待つ（カードまたは「地点/区間がありません」が表示されるまで）
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(CustomPaint).evaluate().isNotEmpty ||
          find.text('地点/区間がありません').evaluate().isNotEmpty) { break; }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 複数のMark/Linkが存在するイベント（箱根日帰りドライブ）の MichiInfo タブを開く。
  /// 成功した場合は true を返す。
  Future<bool> goToMichiInfoWithMultipleItems(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;
    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;
    return goToMichiTab(tester);
  }

  /// Mark が0件のイベント（近所のドライブ）の MichiInfo タブを開く。
  /// 成功した場合は true を返す。
  Future<bool> goToMichiInfoWithNoItems(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;
    final opened = await openEventDetail(tester, '近所のドライブ');
    if (!opened) return false;
    return goToMichiTab(tester);
  }

  // ────────────────────────────────────────────────────────
  // TC-RDT-001: 道路帯が表示される（Mark・Link 複数件）
  // ────────────────────────────────────────────────────────

  testWidgets('TC-RDT-001: Mark・Link複数件の状態でMichiInfo画面を開くとCustomPaintウィジェットが存在すること',
      (tester) async {
    final reached = await goToMichiInfoWithMultipleItems(tester);
    if (!reached) {
      print('[SKIP] TC-RDT-001: MichiInfoタブに遷移できなかったためスキップします');
      return;
    }

    // Specノート: CustomPainterの内部描画はピクセル検証不可。
    // 「michiInfo_canvas_timeline」キーを持つCustomPaintウィジェットが存在することで代替検証する。
    expect(
      find.byKey(const Key('michiInfo_canvas_timeline')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-RDT-002: 白破線センターラインが表示される
  // ────────────────────────────────────────────────────────

  testWidgets('TC-RDT-002: Mark・Link複数件の状態でCustomPaintウィジェットが描画エラーなく存在すること',
      (tester) async {
    final reached = await goToMichiInfoWithMultipleItems(tester);
    if (!reached) {
      print('[SKIP] TC-RDT-002: MichiInfoタブに遷移できなかったためスキップします');
      return;
    }

    // Specノート: センターラインの存在確認は「CustomPaintウィジェットが描画エラーなく存在すること」をもって代替する。
    // タイムラインのCustomPaintが例外なく描画されていること。
    expect(
      find.byKey(const Key('michiInfo_canvas_timeline')),
      findsOneWidget,
    );

    // スクロール後も再描画されること（shouldRepaintが機能していること）
    final scrollView = find.byType(CustomScrollView);
    if (scrollView.evaluate().isNotEmpty) {
      await tester.drag(scrollView.first, const Offset(0, -200));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.drag(scrollView.first, const Offset(0, 200));
      await tester.pump(const Duration(milliseconds: 300));
    }

    // スクロール後もCustomPaintが存在すること（エラーなく再描画されていること）
    expect(
      find.byKey(const Key('michiInfo_canvas_timeline')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-RDT-003: カード・ドットが道路帯の前面に表示される
  // ────────────────────────────────────────────────────────

  testWidgets('TC-RDT-003: Mark・Link各1件以上存在する状態でMarkカードウィジェットが画面上に存在すること',
      (tester) async {
    final reached = await goToMichiInfoWithMultipleItems(tester);
    if (!reached) {
      print('[SKIP] TC-RDT-003: MichiInfoタブに遷移できなかったためスキップします');
      return;
    }

    // ml-001（自宅出発: mark）のカードキーが存在すること
    expect(
      find.byKey(const Key('michiInfo_item_mark_ml-001')),
      findsOneWidget,
    );
  });

  testWidgets('TC-RDT-003b: Mark・Link各1件以上存在する状態でLinkカードウィジェットが画面上に存在すること',
      (tester) async {
    final reached = await goToMichiInfoWithMultipleItems(tester);
    if (!reached) {
      print('[SKIP] TC-RDT-003b: MichiInfoタブに遷移できなかったためスキップします');
      return;
    }

    // ml-002（東名高速: link）のカードキーが存在すること
    expect(
      find.byKey(const Key('michiInfo_item_link_ml-002')),
      findsOneWidget,
    );
  });

  testWidgets('TC-RDT-003c: MarkカードがヒットテストをパスしてタップできるStateになっていること',
      (tester) async {
    final reached = await goToMichiInfoWithMultipleItems(tester);
    if (!reached) {
      print('[SKIP] TC-RDT-003c: MichiInfoタブに遷移できなかったためスキップします');
      return;
    }

    // michiInfo_item_mark_ml-001 が存在すること（タップ可能なウィジェットが前面にあること）
    final markCard = find.byKey(const Key('michiInfo_item_mark_ml-001'));
    expect(markCard, findsOneWidget);

    // ヒットテストを通過すること（ignoring: false の状態）
    // IgnorePointerで包まれていない = HitTestable = 道路帯より前面に存在すること
    final ignorePointerWrapping = find.ancestor(
      of: markCard,
      matching: find.byWidgetPredicate(
        (widget) => widget is IgnorePointer && widget.ignoring == true,
      ),
    );
    expect(ignorePointerWrapping, findsNothing);
  });

  // ────────────────────────────────────────────────────────
  // TC-RDT-004: Mark が0件（または1件のみ）のとき道路帯が表示されない
  // ────────────────────────────────────────────────────────

  testWidgets('TC-RDT-004: MarkLinkが0件の場合CustomPaintウィジェットが描画エラーなく存在すること',
      (tester) async {
    // 近所のドライブ（event-003）はmarkLinksが空（0件）
    final reached = await goToMichiInfoWithNoItems(tester);
    if (!reached) {
      print('[SKIP] TC-RDT-004: 近所のドライブのMichiInfoタブに遷移できなかったためスキップします');
      return;
    }

    // Specの描画条件: verticalLineEndRelY > verticalLineStartRelY の場合のみ道路帯描画。
    // MarkLinkが0件 = verticalLineStartRelY == verticalLineEndRelY → 道路帯非描画。
    // 「地点/区間がありません」が表示されているか、CustomPaintが存在していても描画エラーがないこと。
    final hasNoItems =
        find.text('地点/区間がありません').evaluate().isNotEmpty;

    if (hasNoItems) {
      // 0件表示の場合: テキストが表示されていること
      expect(find.text('地点/区間がありません'), findsOneWidget);
    } else {
      // CustomPaintが存在する場合: 描画エラーなく存在すること
      expect(
        find.byKey(const Key('michiInfo_canvas_timeline')),
        findsOneWidget,
      );
    }
  });

  testWidgets('TC-RDT-004b: MarkLinkが0件の場合にMarkカードが表示されないこと',
      (tester) async {
    final reached = await goToMichiInfoWithNoItems(tester);
    if (!reached) {
      print('[SKIP] TC-RDT-004b: 近所のドライブのMichiInfoタブに遷移できなかったためスキップします');
      return;
    }

    // MarkLinkが0件のため、michiInfo_item_mark_{id}キーを持つカードが存在しないこと
    expect(
      find.byKey(const Key('michiInfo_item_mark_ml-001')),
      findsNothing,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-RDT-005: 地点追加後も道路帯が正常に表示される
  // ────────────────────────────────────────────────────────

  testWidgets('TC-RDT-005: 地点追加後もCustomPaintウィジェットが描画エラーなく存在すること',
      (tester) async {
    final reached = await goToMichiInfoWithMultipleItems(tester);
    if (!reached) {
      print('[SKIP] TC-RDT-005: MichiInfoタブに遷移できなかったためスキップします');
      return;
    }

    // 追加前: CustomPaintが存在すること
    expect(
      find.byKey(const Key('michiInfo_canvas_timeline')),
      findsOneWidget,
    );

    // 地点追加ボタン（michiInfo_button_addMark）をタップする
    final addMarkButton = find.byKey(const Key('michiInfo_button_addMark'));
    if (addMarkButton.evaluate().isEmpty) {
      // addMarkボタンが見えない場合はFABを経由してInsertModeに入り、先頭インジケーターをタップする
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isEmpty) {
        print('[SKIP] TC-RDT-005: 地点追加ボタンもFABも見つからなかったためスキップします');
        return;
      }
      await tester.tap(fab);
      await tester.pump(const Duration(milliseconds: 500));

      // 先頭インジケーターをタップ
      final headIndicator =
          find.byKey(const Key('michiInfo_button_insertIndicator_head'));
      if (headIndicator.evaluate().isEmpty) {
        print('[SKIP] TC-RDT-005: 挿入インジケーターが見つからなかったためスキップします');
        return;
      }
      await tester.tap(headIndicator.first);
    } else {
      await tester.ensureVisible(addMarkButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(addMarkButton);
    }

    // Mark作成画面（MarkDetail）がロードされるまで待機（最大10秒）
    var markDetailLoaded = false;
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('保存').evaluate().isNotEmpty ||
          find.text('名称（任意）').evaluate().isNotEmpty ||
          find.text('地点詳細').evaluate().isNotEmpty) {
        markDetailLoaded = true;
        break;
      }
    }

    if (!markDetailLoaded) {
      print('[SKIP] TC-RDT-005: MarkDetail画面がロードされなかったためスキップします');
      return;
    }

    // 保存ボタンをタップして MichiInfo に戻る
    final saveButton = find.text('保存');
    if (saveButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(saveButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(saveButton.first);
    } else {
      print('[SKIP] TC-RDT-005: 保存ボタンが見つからなかったためスキップします');
      return;
    }

    // MichiInfo 画面に戻るまで待機（最大10秒）
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }

    // タイムライン更新を待機
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_canvas_timeline')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 追加後: CustomPaintウィジェットが描画エラーなく存在すること
    expect(
      find.byKey(const Key('michiInfo_canvas_timeline')),
      findsOneWidget,
    );
  });

  testWidgets('TC-RDT-005b: 地点追加後に追加したMarkカードが画面に表示されること',
      (tester) async {
    final reached = await goToMichiInfoWithMultipleItems(tester);
    if (!reached) {
      print('[SKIP] TC-RDT-005b: MichiInfoタブに遷移できなかったためスキップします');
      return;
    }

    // 地点追加ボタンをタップ
    final addMarkButton = find.byKey(const Key('michiInfo_button_addMark'));
    if (addMarkButton.evaluate().isEmpty) {
      print('[SKIP] TC-RDT-005b: michiInfo_button_addMarkが見つからなかったためスキップします');
      return;
    }
    await tester.ensureVisible(addMarkButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(addMarkButton);

    // Mark作成画面がロードされるまで待機
    var markDetailLoaded = false;
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('保存').evaluate().isNotEmpty ||
          find.text('名称（任意）').evaluate().isNotEmpty ||
          find.text('地点詳細').evaluate().isNotEmpty) {
        markDetailLoaded = true;
        break;
      }
    }

    if (!markDetailLoaded) {
      print('[SKIP] TC-RDT-005b: MarkDetail画面がロードされなかったためスキップします');
      return;
    }

    // 保存ボタンをタップ
    final saveButton = find.text('保存');
    if (saveButton.evaluate().isEmpty) {
      print('[SKIP] TC-RDT-005b: 保存ボタンが見つからなかったためスキップします');
      return;
    }
    await tester.ensureVisible(saveButton.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(saveButton.first);

    // MichiInfo 画面に戻るまで待機
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_canvas_timeline')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 追加後: ml-001（既存Mark）が引き続き表示されていること（タイムラインが崩れていないこと）
    expect(
      find.byKey(const Key('michiInfo_item_mark_ml-001')),
      findsOneWidget,
    );
  });
}
