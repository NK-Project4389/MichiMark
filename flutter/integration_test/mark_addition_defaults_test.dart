// ignore_for_file: avoid_print

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

  /// アプリを起動してEventListPageが表示されるまで待つ。
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

  /// 指定イベント名のカードをタップしてミチタブまで遷移する。
  Future<void> goToMichiInfoTab(
    WidgetTester tester,
    String eventName,
  ) async {
    await startApp(tester);

    final eventCards = find.ancestor(
      of: find.text(eventName),
      matching: find.byType(GestureDetector),
    );
    expect(eventCards, findsWidgets,
        reason: '$eventName のイベントカードが見つかること');

    await tester.tap(eventCards.first);
    await tester.pumpAndSettle();

    final michiTab = find.text('ミチ');
    expect(michiTab, findsOneWidget, reason: 'ミチタブが表示されること');
    await tester.tap(michiTab);
    await tester.pumpAndSettle();
  }

  /// FAB → 「地点を追加」をタップしてMarkDetail画面を表示する。
  Future<void> openAddMarkDetail(WidgetTester tester) async {
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: '地点追加FABが表示されること');
    await tester.tap(fab.first);
    await tester.pumpAndSettle();

    final addMarkButton = find.text('地点を追加');
    expect(addMarkButton, findsOneWidget, reason: '「地点を追加」メニューが表示されること');
    await tester.tap(addMarkButton.first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
  }

  // ────────────────────────────────────────────────────────
  // TC-MAD-001: 地点なし → 交通手段のmeterValueが初期値になる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-001: 地点が存在しない状態で地点追加すると交通手段のメーター値が初期値になる',
      (tester) async {
    // 前提: 「近所のドライブ」は markLinks が空、マイカー meterValue=45230
    await goToMichiInfoTab(tester, '近所のドライブ');
    await openAddMarkDetail(tester);

    // MarkDetail画面でメーター入力TextField（累積メーター）の値を確認
    // デバッグで確認: controller="45230", label="累積メーター (km)"
    final meterFields = find.ancestor(
      of: find.text('累積メーター (km)'),
      matching: find.byType(TextField),
    );
    // TextFieldが見つかる場合はcontrollerの値で確認、
    // そうでない場合はテキスト検索で確認
    final hasMeterText = find.text('45230').evaluate().isNotEmpty;
    final hasMeterField = meterFields.evaluate().isNotEmpty;

    if (hasMeterField) {
      final field = meterFields.evaluate().first.widget as TextField;
      expect(field.controller?.text, equals('45230'),
          reason: '交通手段のmeterValue(45230)がメーター入力欄に初期表示されること');
    } else {
      expect(hasMeterText, isTrue,
          reason: '交通手段のmeterValue(45230)がメーター入力欄に初期表示されること');
    }
  });

  // ────────────────────────────────────────────────────────
  // TC-MAD-002: 既存地点あり → 前の地点のmeterValueが初期値になる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-002: 既存地点がある状態で地点追加すると前の地点のメーター値が初期値になる',
      (tester) async {
    // 前提: 「箱根日帰りドライブ」最後のMarkは「大涌谷」meterValue=45340
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');
    await openAddMarkDetail(tester);

    // メーター入力欄に "45340" が表示されているか確認
    final meterFields = find.ancestor(
      of: find.text('累積メーター (km)'),
      matching: find.byType(TextField),
    );
    final hasMeterText = find.text('45340').evaluate().isNotEmpty;
    final hasMeterField = meterFields.evaluate().isNotEmpty;

    if (hasMeterField) {
      final field = meterFields.evaluate().first.widget as TextField;
      expect(field.controller?.text, equals('45340'),
          reason: '前の地点（大涌谷）のmeterValue(45340)がメーター入力欄に初期表示されること');
    } else {
      expect(hasMeterText, isTrue,
          reason: '前の地点（大涌谷）のmeterValue(45340)がメーター入力欄に初期表示されること');
    }
  });

  // ────────────────────────────────────────────────────────
  // TC-MAD-003: 既存地点あり → 前の地点のメンバーが引き継がれる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-003: 既存地点がある状態で地点追加すると前の地点のメンバーが引き継がれる',
      (tester) async {
    // 前提: 「箱根日帰りドライブ」最後のMarkは「大涌谷」メンバー=「太郎・花子」
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');
    await openAddMarkDetail(tester);

    // メンバー表示が「太郎、花子」として表示されているか確認
    // デバッグで確認: Text("太郎、花子") が表示される
    final memberText = find.text('太郎、花子');
    expect(memberText, findsOneWidget,
        reason: '前の地点のメンバー「太郎、花子」がMarkDetail画面に選択済みで表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TC-MAD-004: 既存地点あり → 前の地点の日付が初期値になる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-004: 既存地点がある状態で地点追加すると前の地点の日付が初期値になる',
      (tester) async {
    // 前提: 「箱根日帰りドライブ」最後のMarkは「大涌谷」日付=2026-03-15
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');
    await openAddMarkDetail(tester);

    // 日付表示フォーマット: "2026/03/15"（デバッグで確認済み）
    final dateText = find.text('2026/03/15');
    expect(dateText, findsOneWidget,
        reason: '前の地点（大涌谷）の日付(2026/03/15)がMarkDetail画面に初期表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TC-MAD-005: 地点なし → 本日の日付が初期値になる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-005: 地点が存在しない状態で地点追加すると本日の日付が初期値になる',
      (tester) async {
    // 前提: 「近所のドライブ」は markLinks が空
    await goToMichiInfoTab(tester, '近所のドライブ');
    await openAddMarkDetail(tester);

    // 本日の日付を YYYY/MM/DD 形式で確認
    final now = DateTime.now();
    final monthStr = now.month.toString().padLeft(2, '0');
    final dayStr = now.day.toString().padLeft(2, '0');
    final todayFormatted = '${now.year}/$monthStr/$dayStr';

    final dateText = find.text(todayFormatted);
    expect(dateText, findsOneWidget,
        reason: '本日の日付($todayFormatted)がMarkDetail画面に初期表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TC-MAD-006: MarkDetailのメンバー選択候補がイベントメンバーのみ
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-006: MarkDetailのメンバー選択候補がイベントメンバーのみになっている',
      (tester) async {
    // 前提: 「箱根日帰りドライブ」イベントメンバー=「太郎・花子」
    //       マスターには「太郎・花子・健太」が存在する
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');
    await openAddMarkDetail(tester);

    // IconButton[1] = メンバー追加ボタンをタップして選択候補を表示
    // デバッグで確認: IconButton[1]タップで「太郎」「花子」「メンバーを選択」「確定」が表示
    final iconButtons = find.byType(IconButton);
    expect(iconButtons, findsWidgets, reason: 'MarkDetail画面にIconButtonが存在すること');
    await tester.tap(iconButtons.at(1));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));

    // 選択候補確認
    // イベントメンバー「太郎」「花子」が表示されていること
    expect(find.text('太郎'), findsOneWidget,
        reason: 'イベントメンバー「太郎」がメンバー選択候補に表示されること');
    expect(find.text('花子'), findsOneWidget,
        reason: 'イベントメンバー「花子」がメンバー選択候補に表示されること');

    // 非イベントメンバー「健太」が表示されないこと
    expect(find.text('健太'), findsNothing,
        reason: '非イベントメンバー「健太」はメンバー選択候補に表示されないこと');
  });

  // ────────────────────────────────────────────────────────
  // TC-MAD-007: EventDetail保存後にTransのmeterValueが更新される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-007: EventDetail保存後に交通手段の最大メーター値が更新される',
      (tester) async {
    // 前提: 「箱根日帰りドライブ」
    //   - マイカー meterValue=45230
    //   - 地点の最大meterValue=45340（大涌谷）
    //   - 保存後、マイカーの meterValue が 45340 に更新されるはず
    await startApp(tester);

    final eventCards = find.ancestor(
      of: find.text('箱根日帰りドライブ'),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(eventCards.first);
    await tester.pumpAndSettle();

    // EventDetail画面（BasicInfoタブがデフォルト）で保存ボタン（check icon）をタップ
    // デバッグで確認: Icons.check = IconButton[4]
    final checkIcon = find.byIcon(Icons.check);
    expect(checkIcon, findsOneWidget, reason: 'EventDetail保存ボタン（checkアイコン）が存在すること');
    await tester.tap(checkIcon);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));

    // 保存後はEventDetailに留まる（"保存しました"トーストが表示される）
    // router.go("/") でEventListに強制遷移してから設定画面へ
    app_router.router.go('/');
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('イベント').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 設定アイコンをタップして設定画面へ
    final settingsIcon = find.byIcon(Icons.settings);
    expect(settingsIcon, findsOneWidget, reason: '設定アイコンが表示されること');
    await tester.tap(settingsIcon);
    await tester.pumpAndSettle();

    // 交通手段設定をタップ
    final transSection = find.text('交通手段');
    expect(transSection, findsOneWidget, reason: '設定画面に「交通手段」が表示されること');
    await tester.tap(transSection);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));

    // 交通手段一覧でマイカーのmeterValueが "45,340 km" に更新されているか確認
    // デバッグで確認: "燃費: 15.5 km/L　メーター: 45,230 km" というフォーマット
    final updatedMeterText = find.textContaining('45,340');
    expect(updatedMeterText, findsOneWidget,
        reason: 'EventDetail保存後にマイカーのmeterValueが45,340に更新されていること');
  });

  // ────────────────────────────────────────────────────────
  // TC-MAD-008: 既存地点の編集画面はDB値が表示される（引き継ぎ適用なし）
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-008: 既存地点の編集画面を開くと初期値はDB値が表示される（引き継ぎ適用なし）',
      (tester) async {
    // 前提: 「箱根日帰りドライブ」最初のMarkは「自宅出発」meterValue=45230
    //       最後のMarkは「大涌谷」meterValue=45340
    //       自宅出発を編集で開いたとき、DB値の45230が表示されること
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // 「自宅出発」カードをタップして編集画面を開く
    final markCard = find.text('自宅出発');
    expect(markCard, findsOneWidget, reason: '「自宅出発」地点カードが表示されること');
    await tester.tap(markCard);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));

    // MarkDetail（編集）画面でメーター入力欄を確認
    // デバッグで確認: controller="45230", label="累積メーター (km)"
    final meterFields = find.ancestor(
      of: find.text('累積メーター (km)'),
      matching: find.byType(TextField),
    );

    if (meterFields.evaluate().isNotEmpty) {
      final field = meterFields.evaluate().first.widget as TextField;
      expect(field.controller?.text, equals('45230'),
          reason: '編集モードではDB値(45230)がメーター入力欄に表示されること');
      expect(field.controller?.text, isNot(equals('45340')),
          reason: '編集モードでは前の地点の引き継ぎ値(45340)は使用されないこと');
    } else {
      // TextFieldが見つからない場合はテキスト検索
      expect(find.text('45230'), findsWidgets,
          reason: '編集モードではDB値(45230)がメーター入力欄に表示されること');
    }
  });
}
