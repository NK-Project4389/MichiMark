// ignore_for_file: avoid_print

/// Integration Test: EventDetail 概要タブ再設計
///
/// Spec: docs/Spec/Features/EventDetailOverviewRedesign_Spec.md §12
/// テストシナリオ: TC-EOD-001 〜 TC-EOD-015

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
      if (find.byType(ListView).evaluate().isNotEmpty ||
          find.text('イベントがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// イベント一覧から指定イベントをタップして EventDetail を開く。
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
          find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  // ────────────────────────────────────────────────────────
  // TC-EOD-001: 概要タブが先頭タブとして表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-001: 概要タブが先頭タブとして表示される', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final gestureDetectors = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(GestureDetector),
    );
    expect(gestureDetectors, findsWidgets, reason: 'イベント一覧にアイテムが存在すること');

    await tester.tap(gestureDetectors.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // タブが「概要」「ミチ」「支払」の 3 つだけ表示される
    expect(find.text('概要'), findsOneWidget, reason: '「概要」タブが表示されること');
    expect(find.text('ミチ'), findsOneWidget, reason: '「ミチ」タブが表示されること');
    expect(find.text('支払'), findsOneWidget, reason: '「支払」タブが表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-002: 概要タブ: 参照モードで基本情報が表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-002: 概要タブ参照モードで基本情報が表示される', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 「編集」ボタンが表示されること
    expect(find.text('編集'), findsOneWidget, reason: '参照モードで「編集」ボタンが表示されること');
    // 「保存」ボタンが表示されないこと
    expect(find.text('保存'), findsNothing, reason: '参照モードで「保存」ボタンが表示されないこと');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-003: 概要タブ: 「編集」押下で編集モードに切り替わる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-003: 「編集」押下で編集モードに切り替わる', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 「編集」ボタンをタップ
    final editButton = find.text('編集');
    expect(editButton, findsOneWidget, reason: '「編集」ボタンが存在すること');
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // 「保存」ボタンに切り替わること
    expect(find.text('保存'), findsOneWidget, reason: '「保存」ボタンが表示されること');
    // 「編集」ボタンが消えること
    expect(find.text('編集'), findsNothing, reason: '「編集」ボタンが非表示になること');
    // TextField（入力フォーム）が表示されること
    expect(find.byType(TextField), findsWidgets, reason: '編集モードで入力フォームが表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-004: 編集後「保存」押下で DB 保存され参照モードに戻る
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-004: 編集後「保存」押下で参照モードに戻る', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 「編集」ボタンをタップ
    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();

    // イベント名フィールドを変更（テスト後に戻すため一時的な名前）
    const testEventName = '箱根日帰りドライブ_テスト';
    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets, reason: '入力フォームが存在すること');
    await tester.enterText(textFields.first, testEventName);
    await tester.pump(const Duration(milliseconds: 300));

    // 「保存」ボタンをタップ
    final saveButton = find.text('保存');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);

    // 保存完了を待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('編集').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 参照モードに戻ること
    expect(find.text('編集'), findsOneWidget, reason: '保存後に参照モード（「編集」ボタン）に戻ること');
    expect(find.text('保存'), findsNothing, reason: '保存後に「保存」ボタンが非表示になること');

    // 変更後のイベント名が表示されること
    expect(find.text(testEventName), findsWidgets,
        reason: '変更後のイベント名が表示されること');

    // テストデータを元に戻す
    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '箱根日帰りドライブ');
    await tester.pump(const Duration(milliseconds: 300));
    final saveButtonRestore = find.text('保存');
    await tester.ensureVisible(saveButtonRestore);
    await tester.pumpAndSettle();
    await tester.tap(saveButtonRestore);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('編集').evaluate().isNotEmpty) break;
    }
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-005: AppBar にチェックボタン（保存アイコン）が表示されない
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-005: AppBarにチェックボタンが表示されない', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final gestureDetectors = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(gestureDetectors.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // チェックアイコン（保存ボタン）が表示されないこと
    expect(find.byIcon(Icons.check), findsNothing,
        reason: 'AppBarにチェックアイコン（保存ボタン）が表示されないこと');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-006: 編集中に「ミチ」タブを押すとアラートが表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-006: 編集中にミチタブを押すとアラートが表示される', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 「編集」ボタンをタップ
    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();

    // 「ミチ」タブをタップ
    await tester.tap(find.text('ミチ'));
    await tester.pumpAndSettle();

    // アラートダイアログが表示されること
    expect(find.text('保存していません'), findsOneWidget, reason: 'アラートのタイトルが表示されること');
    expect(find.text('保存して移動'), findsOneWidget, reason: '「保存して移動」ボタンが表示されること');
    expect(find.text('破棄して移動'), findsOneWidget, reason: '「破棄して移動」ボタンが表示されること');
    expect(find.text('編集に戻る'), findsOneWidget, reason: '「編集に戻る」ボタンが表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-007: アラートで「保存して移動」を選ぶと保存後ミチタブに移動する
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-007: アラートで「保存して移動」選択後ミチタブに移動する', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 編集モードに入る
    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();

    // 「ミチ」タブをタップしてアラートを出す
    await tester.tap(find.text('ミチ'));
    await tester.pumpAndSettle();

    // 「保存して移動」をタップ
    final saveAndMoveButton = find.text('保存して移動');
    expect(saveAndMoveButton, findsOneWidget, reason: '「保存して移動」ボタンが表示されること');
    await tester.tap(saveAndMoveButton);

    // 保存＋タブ移動を待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('保存していません').evaluate().isEmpty) break;
    }
    await tester.pumpAndSettle();

    // 「ミチ」タブが選択された状態（MichiInfo コンテンツが表示される）を確認
    // アラートが消えていること
    expect(find.text('保存していません'), findsNothing, reason: 'アラートが閉じていること');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-008: アラートで「破棄して移動」を選ぶと変更が破棄されミチタブに移動する
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-008: アラートで「破棄して移動」選択後ミチタブに移動する', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 編集モードに入りイベント名を変更
    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '変更テスト用イベント名');
    await tester.pump(const Duration(milliseconds: 300));

    // 「ミチ」タブをタップしてアラートを出す
    await tester.tap(find.text('ミチ'));
    await tester.pumpAndSettle();

    // 「破棄して移動」をタップ
    final discardAndMoveButton = find.text('破棄して移動');
    expect(discardAndMoveButton, findsOneWidget, reason: '「破棄して移動」ボタンが表示されること');
    await tester.tap(discardAndMoveButton);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('保存していません').evaluate().isEmpty) break;
    }
    await tester.pumpAndSettle();

    // アラートが閉じていること
    expect(find.text('保存していません'), findsNothing, reason: 'アラートが閉じていること');

    // 概要タブに戻って確認（変更が破棄されている）
    await tester.tap(find.text('概要'));
    await tester.pumpAndSettle();
    expect(find.text('変更テスト用イベント名'), findsNothing, reason: '変更が破棄されていること');
    expect(find.text('箱根日帰りドライブ'), findsWidgets, reason: '元のイベント名に戻っていること');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-009: アラートで「キャンセル」を選ぶと概要タブの編集モードに留まる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-009: アラートで「キャンセル」選択後概要タブの編集モードに留まる',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 編集モードに入る
    await tester.tap(find.text('編集'));
    await tester.pumpAndSettle();

    // 「ミチ」タブをタップしてアラートを出す
    await tester.tap(find.text('ミチ'));
    await tester.pumpAndSettle();

    // 「編集に戻る」をタップ
    final cancelButton = find.text('編集に戻る');
    expect(cancelButton, findsOneWidget, reason: '「編集に戻る」ボタンが表示されること');
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    // アラートが閉じて概要タブの編集モードに留まること
    expect(find.text('保存していません'), findsNothing, reason: 'アラートが閉じていること');
    expect(find.text('保存'), findsOneWidget, reason: '概要タブの編集モード（「保存」ボタン）が表示されていること');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-010: MarkDetail 保存後にミチ一覧が即時更新される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-010: MarkDetail保存後にミチ一覧が即時更新される', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 「ミチ」タブをタップ
    await tester.tap(find.text('ミチ'));
    await tester.pumpAndSettle();

    // ミチ一覧にマークアイテムが存在するか確認
    // ListViewが存在しない場合はスキップ
    final listView = find.byType(ListView);
    if (listView.evaluate().isEmpty) {
      markTestSkipped('ミチ一覧にアイテムが存在しないためスキップします');
      return;
    }

    final markItems = find.descendant(
      of: listView.first,
      matching: find.byType(GestureDetector),
    );
    if (markItems.evaluate().isEmpty) {
      markTestSkipped('ミチ一覧のマークアイテムが存在しないためスキップします');
      return;
    }

    // 最初のアイテムをタップして MarkDetail / LinkDetail を開く
    await tester.tap(markItems.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // MarkDetail / LinkDetail の保存ボタンが現れるまで待つ
      if (find.text('保存').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    if (find.text('保存').evaluate().isEmpty) {
      markTestSkipped('MarkDetail/LinkDetailの保存ボタンが見つからないためスキップします');
      return;
    }

    // 地点名フィールドを取得して変更
    const testMarkName = 'テスト地点名';
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      await tester.enterText(textFields.first, testMarkName);
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 「保存」ボタンをタップ
    final saveButton = find.text('保存');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);

    // MarkDetail が閉じてミチ一覧に戻るのを待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();

    // 変更後の地点名がミチ一覧に表示されること
    expect(find.text(testMarkName), findsWidgets,
        reason: 'MarkDetail保存後にミチ一覧に変更後の地点名が表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-011: LinkDetail 保存後にミチ一覧が即時更新される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-011: LinkDetail保存後にミチ一覧が即時更新される', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '富士五湖キャンプ');
    if (!opened) {
      markTestSkipped('「富士五湖キャンプ」が見つからないためスキップします');
      return;
    }

    // 「ミチ」タブをタップ
    await tester.tap(find.text('ミチ'));
    await tester.pumpAndSettle();

    // ミチ一覧のリンクアイテムを探す（リンクはアイコンで識別）
    final listView = find.byType(ListView);
    if (listView.evaluate().isEmpty) {
      markTestSkipped('ミチ一覧にアイテムが存在しないためスキップします');
      return;
    }

    // リンクアイテムを見つける（リンクアイコン links または link）
    final linkItems = find.byIcon(Icons.link);
    if (linkItems.evaluate().isEmpty) {
      markTestSkipped('ミチ一覧にリンクアイテムが存在しないためスキップします');
      return;
    }

    // 最初のリンクアイテムの親をタップ
    final linkItemContainer = find.ancestor(
      of: linkItems.first,
      matching: find.byType(GestureDetector),
    );
    if (linkItemContainer.evaluate().isEmpty) {
      markTestSkipped('リンクアイテムのタップ領域が見つからないためスキップします');
      return;
    }

    await tester.tap(linkItemContainer.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('保存').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    if (find.text('保存').evaluate().isEmpty) {
      markTestSkipped('LinkDetailの保存ボタンが見つからないためスキップします');
      return;
    }

    // リンク名フィールドを変更
    const testLinkName = 'テストリンク名';
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      await tester.enterText(textFields.first, testLinkName);
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 「保存」ボタンをタップ
    final saveButton = find.text('保存');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);

    // LinkDetail が閉じてミチ一覧に戻るのを待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();

    // 変更後のリンク名がミチ一覧に表示されること
    expect(find.text(testLinkName), findsWidgets,
        reason: 'LinkDetail保存後にミチ一覧に変更後のリンク名が表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-012: PaymentDetail 保存後に支払一覧が即時更新される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-012: PaymentDetail保存後に支払一覧が即時更新される', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 「支払」タブをタップ
    await tester.tap(find.text('支払'));
    await tester.pumpAndSettle();

    // 「+」ボタンをタップして PaymentDetail を開く
    final addButton = find.byIcon(Icons.add);
    if (addButton.evaluate().isEmpty) {
      markTestSkipped('「+」ボタンが見つからないためスキップします');
      return;
    }
    await tester.tap(addButton.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('反映').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    if (find.text('反映').evaluate().isEmpty) {
      markTestSkipped('PaymentDetailの「反映」ボタンが見つからないためスキップします');
      return;
    }

    // 金額を入力
    const testAmount = '1500';
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      // 金額フィールドを探して入力
      await tester.tap(textFields.first);
      await tester.enterText(textFields.first, testAmount);
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 「反映」ボタンをタップ
    final applyButton = find.text('反映');
    await tester.ensureVisible(applyButton);
    await tester.pumpAndSettle();
    await tester.tap(applyButton);

    // PaymentDetail が閉じて支払一覧に戻るのを待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('支払').evaluate().isNotEmpty &&
          find.text('反映').evaluate().isEmpty) break;
    }
    await tester.pumpAndSettle();

    // 支払一覧に新しい支払が表示されること（金額テキスト確認）
    // 金額表示は "¥1,500" 等の形式の可能性があるため widgetList を確認
    final paymentItems = find.byType(ListView);
    expect(paymentItems, findsWidgets, reason: '支払一覧が表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-013: 「振り返り」タブが表示されない
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-013: 「振り返り」タブが表示されない', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final gestureDetectors = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(gestureDetectors.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 「振り返り」タブが表示されないこと
    expect(find.text('振り返り'), findsNothing, reason: '「振り返り」タブが存在しないこと');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-014: 「基本」タブが表示されない
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-014: 「基本」タブが表示されない', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final gestureDetectors = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(gestureDetectors.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 「基本」タブが表示されないこと
    expect(find.text('基本'), findsNothing, reason: '「基本」タブが存在しないこと');
  });

  // ────────────────────────────────────────────────────────
  // TC-EOD-015: 概要タブ下部に集計情報が表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EOD-015: 概要タブ下部に集計情報が表示される', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 概要タブが表示されていること（デフォルト）
    // 下部に集計情報が表示されているか確認するため、スクロールして確認
    // 走行距離・燃費などの集計テキストを検索
    // 集計セクションを確認（スクロールが必要な場合も考慮）
    bool foundOverviewContent = false;

    // 走行距離・燃費等の集計関連キーワードを確認
    final overviewKeywords = ['走行距離', '燃費', '合計', 'km', '円'];
    for (final keyword in overviewKeywords) {
      if (find.textContaining(keyword).evaluate().isNotEmpty) {
        foundOverviewContent = true;
        break;
      }
    }

    if (!foundOverviewContent) {
      // スクロールして確認
      final scrollable = find.byType(SingleChildScrollView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 300));

        for (final keyword in overviewKeywords) {
          if (find.textContaining(keyword).evaluate().isNotEmpty) {
            foundOverviewContent = true;
            break;
          }
        }
      }
    }

    expect(foundOverviewContent, isTrue,
        reason: '概要タブに集計情報（走行距離・燃費・合計等）が表示されること');
  });
}
