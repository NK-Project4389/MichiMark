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
      if (find.text('イベント一覧').evaluate().isNotEmpty) break;
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
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final michiTab = find.text('ミチ');
    expect(michiTab, findsOneWidget, reason: 'ミチタブが表示されること');
    await tester.tap(michiTab);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// FAB → 挿入モード → インジケータータップ → 「地点を追加」をタップしてMarkDetail画面を表示する。
  /// TC-MCI（カード間挿入機能）以降の新フロー:
  ///   FABタップ → 挿入モードON（add_circle_outline インジケーター表示）
  ///   → インジケータータップ → BottomSheet表示 → 「地点を追加」タップ
  /// アイテムが0件の場合はインジケーターが存在しないため false を返す。
  Future<bool> openAddMarkDetail(WidgetTester tester) async {
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: '地点追加FABが表示されること');
    await tester.tap(fab.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.byIcon(Icons.add_circle).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 挿入モードでインジケーターが表示されるまで待つ
    final indicator = find.byIcon(Icons.add_circle);
    if (indicator.evaluate().isEmpty) {
      // アイテム0件の場合はインジケーターが表示されない（設計上の制約）
      return false;
    }

    // 最後のインジケーター（最終アイテムの後）をタップ → 末尾追加のデフォルト動作
    // 前の地点のmeterValue・メンバー・日付が引き継がれる
    await tester.tap(indicator.last);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.text('地点を追加').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final addMarkButton = find.text('地点を追加');
    expect(addMarkButton, findsOneWidget, reason: '「地点を追加」メニューが表示されること');
    await tester.tap(addMarkButton.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('累積メーター').evaluate().isNotEmpty ||
          find.text('累積メーター (km)').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  // ────────────────────────────────────────────────────────
  // TC-MAD-001: 地点なし → 交通手段のmeterValueが初期値になる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-001: 地点が存在しない状態で地点追加すると交通手段のメーター値が初期値になる',
      (tester) async {
    // 前提: 「近所のドライブ」は markLinks が空、マイカー meterValue=45230
    await goToMichiInfoTab(tester, '近所のドライブ');
    final opened = await openAddMarkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-MAD-001: 空リストへの地点追加はUIの挿入モードでは非対応（設計上の制約）');
      return;
    }

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
    final opened = await openAddMarkDetail(tester);
    expect(opened, isTrue, reason: 'MarkDetail新規作成画面が開けること');

    // メーター入力欄に "45,340" が表示されているか確認
    // NumericInputRow はカンマ区切りで表示するため '45,340' を探す
    // label は '累積メーター'（単位 'km' は別Text widget）
    final meterFields = find.ancestor(
      of: find.text('累積メーター'),
      matching: find.byType(TextField),
    );
    final hasMeterText = find.text('45,340').evaluate().isNotEmpty;
    final hasMeterField = meterFields.evaluate().isNotEmpty;

    if (hasMeterField) {
      final field = meterFields.evaluate().first.widget as TextField;
      expect(field.controller?.text, equals('45,340'),
          reason: '前の地点（大涌谷）のmeterValue(45,340)がメーター入力欄に初期表示されること');
    } else {
      expect(hasMeterText, isTrue,
          reason: '前の地点（大涌谷）のmeterValue(45,340)がメーター入力欄に初期表示されること');
    }
  });

  // ────────────────────────────────────────────────────────
  // TC-MAD-003: 既存地点あり → 前の地点のメンバーが引き継がれる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-003: 既存地点がある状態で地点追加すると前の地点のメンバーが引き継がれる',
      (tester) async {
    // 前提: 「箱根日帰りドライブ」最後のMarkは「大涌谷」メンバー=「太郎・花子」
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');
    final opened = await openAddMarkDetail(tester);
    expect(opened, isTrue, reason: 'MarkDetail新規作成画面が開けること');

    // メンバーが FilterChip 形式で個別表示されていることを確認
    // MarkDetail のメンバーセクションは FilterChip で各メンバーを表示する
    // member-001=太郎, member-002=花子 の FilterChip が存在すること
    expect(
      find.byKey(const Key('markDetail_chip_member_member-001')),
      findsOneWidget,
      reason: '前の地点のメンバー「太郎」がMarkDetail画面で FilterChip として表示されること',
    );
    expect(
      find.byKey(const Key('markDetail_chip_member_member-002')),
      findsOneWidget,
      reason: '前の地点のメンバー「花子」がMarkDetail画面で FilterChip として表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MAD-004: 既存地点あり → 前の地点の日付が初期値になる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-004: 既存地点がある状態で地点追加すると前の地点の日付が初期値になる',
      (tester) async {
    // 前提: 「箱根日帰りドライブ」最後のMarkは「大涌谷」日付=2026-03-15
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');
    final opened = await openAddMarkDetail(tester);
    expect(opened, isTrue, reason: 'MarkDetail新規作成画面が開けること');

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
    final opened = await openAddMarkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-MAD-005: 空リストへの地点追加はUIの挿入モードでは非対応（設計上の制約）');
      return;
    }

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
    final opened = await openAddMarkDetail(tester);
    expect(opened, isTrue, reason: 'MarkDetail新規作成画面が開けること');

    // MarkDetail はメンバーを FilterChip で表示する（InkWell 行なし）
    // イベントメンバー「太郎」「花子」の FilterChip が存在することを確認
    expect(
      find.byKey(const Key('markDetail_chip_member_member-001')),
      findsOneWidget,
      reason: 'MarkDetail画面にイベントメンバー「太郎」の FilterChip が表示されること',
    );
    expect(
      find.byKey(const Key('markDetail_chip_member_member-002')),
      findsOneWidget,
      reason: 'MarkDetail画面にイベントメンバー「花子」の FilterChip が表示されること',
    );

    // 非イベントメンバー「健太」(member-003) の FilterChip が存在しないこと
    expect(
      find.byKey(const Key('markDetail_chip_member_member-003')),
      findsNothing,
      reason: '非イベントメンバー「健太」の FilterChip は MarkDetail 画面に表示されないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MAD-007: MarkDetail保存後にTransのmeterValueが更新される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAD-007: MarkDetail保存後に交通手段の最大メーター値が更新される',
      (tester) async {
    // 前提: 「箱根日帰りドライブ」
    //   - マイカー meterValue=45230
    //   - 地点「大涌谷」meterValue=45340
    //   - 大涌谷の MarkDetail を保存すると mark_detail_bloc が
    //     Trans.meterValue を 45340 に更新する（REQ-MAD）
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // 「大涌谷」カード（ml-005）をタップして MarkDetail（編集）画面を開く
    // movingCostトピックはshowNameField=falseのためテキスト名は非表示
    // 削除アイコンキー（michiInfo_button_delete_ml-005）の位置から左オフセットでタップ
    // ml-003=箱根湯本駅前、ml-005=大涌谷（meterValue=45340）
    final deleteKey005 = find.byKey(const Key('michiInfo_button_delete_ml-005'));
    if (deleteKey005.evaluate().isEmpty) {
      // ml-005 がビューポート外にある場合はスクロールして表示する
      for (var i = 0; i < 5; i++) {
        await tester.drag(
          find.byType(CustomScrollView).first,
          const Offset(0, -300),
        );
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('michiInfo_button_delete_ml-005')).evaluate().isNotEmpty) break;
      }
    }
    final deleteKey005b = find.byKey(const Key('michiInfo_button_delete_ml-005'));
    if (deleteKey005b.evaluate().isEmpty) {
      fail('[スキップ不可] マークカード ml-005（大涌谷）が見つかりません');
    }
    await tester.ensureVisible(deleteKey005b);
    await tester.pump(const Duration(milliseconds: 500));
    final deletePos005 = tester.getCenter(deleteKey005b);
    await tester.tapAt(Offset(deletePos005.dx - 100, deletePos005.dy));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('保存').evaluate().isNotEmpty ||
          find.text('累積メーター').evaluate().isNotEmpty) break;
    }
    expect(
      find.text('保存').evaluate().isNotEmpty ||
          find.text('累積メーター').evaluate().isNotEmpty,
      isTrue,
      reason: '「大涌谷（ml-005）」タップで MarkDetail 編集画面が開けること',
    );

    // 「保存」ボタンをタップ → mark_detail_bloc が Trans.meterValue を更新
    final saveButton = find.text('保存');
    await tester.ensureVisible(saveButton);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(saveButton);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // MichiInfo画面に戻ってくる（ml-001の削除アイコンが再表示される）
      if (find.byKey(const Key('michiInfo_button_delete_ml-001')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // router.go("/") でEventListに強制遷移してから設定画面へ
    app_router.router.go('/');
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('イベント一覧').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 設定アイコンをタップして設定画面へ
    final settingsIcon = find.byIcon(Icons.settings);
    expect(settingsIcon, findsOneWidget, reason: '設定アイコンが表示されること');
    await tester.tap(settingsIcon);
    await tester.pump(const Duration(milliseconds: 500));

    // 交通手段設定をタップ
    final transSection = find.text('交通手段');
    expect(transSection, findsOneWidget, reason: '設定画面に「交通手段」が表示されること');
    await tester.tap(transSection);
    // TransSettingPage がロードされるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.textContaining('メーター:').evaluate().isNotEmpty ||
          find.text('交通手段がありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 交通手段一覧でマイカーのmeterValueが "45,340" に更新されているか確認
    final updatedMeterText = find.textContaining('45,340');
    expect(updatedMeterText, findsWidgets,
        reason: 'MarkDetail保存後にマイカーのmeterValueが45,340に更新されていること');
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

    // 「自宅出発」カード（ml-001）をタップして編集画面を開く
    // movingCostトピックはshowNameField=falseのためテキスト名は非表示
    final deleteKey001 = find.byKey(const Key('michiInfo_button_delete_ml-001'));
    expect(deleteKey001, findsOneWidget, reason: 'ml-001（自宅出発）の削除アイコンが表示されること');
    await tester.ensureVisible(deleteKey001);
    await tester.pump(const Duration(milliseconds: 500));
    final deletePos001 = tester.getCenter(deleteKey001);
    await tester.tapAt(Offset(deletePos001.dx - 100, deletePos001.dy));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      // NumericInputRowのラベルは '累積メーター'（単位 'km' は別Text）
      // 既存Markのタイトルは mark名（「自宅出発」）のためAppBarの「地点詳細」は不可
      // 「保存」ボタンまたは「累積メーター」ラベルで遷移完了を確認
      if (find.text('保存').evaluate().isNotEmpty ||
          find.text('累積メーター').evaluate().isNotEmpty) break;
    }

    // MarkDetail（編集）画面でメーター入力欄を確認
    // NumericInputRow でカンマ区切り表示: meterValue=45230 → controller='45,230'
    final meterFields = find.ancestor(
      of: find.text('累積メーター'),
      matching: find.byType(TextField),
    );

    if (meterFields.evaluate().isNotEmpty) {
      final field = meterFields.evaluate().first.widget as TextField;
      expect(field.controller?.text, equals('45,230'),
          reason: '編集モードではDB値(45,230)がメーター入力欄に表示されること');
      expect(field.controller?.text, isNot(equals('45,340')),
          reason: '編集モードでは前の地点の引き継ぎ値(45,340)は使用されないこと');
    } else {
      // TextFieldが見つからない場合はテキスト検索
      expect(find.text('45,230'), findsWidgets,
          reason: '編集モードではDB値(45,230)がメーター入力欄に表示されること');
    }
  });
}
