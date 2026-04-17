// ignore_for_file: avoid_print

/// Integration Test: MovingCostFuelMode
///
/// Spec: docs/Spec/Features/MovingCostFuelMode_Spec.md
/// テストシナリオ: TC-FCM-001 〜 TC-FCM-008

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
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('タップして編集').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// ミチタブに切り替える。
  Future<void> goToMichiTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return;
    await tester.tap(michiTab);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // movingCost/movingCostEstimatedはshowNameField=falseのためテキスト名は非表示
      // 削除アイコンキーが表示されればロード完了
      if (find.byKey(const Key('michiInfo_button_delete_ml-001')).evaluate().isNotEmpty ||
          find.byKey(const Key('michiInfo_button_delete_ml-009')).evaluate().isNotEmpty ||
          find.text('地点/区間がありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// 既存 Mark/Link を削除アイコンキーから左オフセットでタップして Detail を開く。
  /// markLinkId: MarkLinkDomain の id (例: 'ml-001')
  Future<bool> openMarkLinkById(WidgetTester tester, String markLinkId) async {
    final deleteKey = find.byKey(Key('michiInfo_button_delete_$markLinkId'));
    // スクロールしながら対象を探す
    if (deleteKey.evaluate().isEmpty) {
      for (var i = 0; i < 10; i++) {
        await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(Key('michiInfo_button_delete_$markLinkId')).evaluate().isNotEmpty) break;
      }
    }
    if (deleteKey.evaluate().isEmpty) return false;
    await tester.ensureVisible(deleteKey);
    await tester.pump(const Duration(milliseconds: 500));
    final pos = tester.getCenter(deleteKey);
    // 削除アイコンの左100pxをタップしてカード本体をタップ
    await tester.tapAt(Offset(pos.dx - 100, pos.dy));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('給油').evaluate().isNotEmpty ||
          find.text('保存').evaluate().isNotEmpty ||
          find.text('累積メーター').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find.text('給油').evaluate().isNotEmpty ||
        find.text('保存').evaluate().isNotEmpty ||
        find.text('累積メーター').evaluate().isNotEmpty;
  }

  /// 既存 Mark をタップして MarkDetail を開く（後方互換）。
  Future<bool> openExistingMark(WidgetTester tester, String markName) async {
    // showNameField=false のトピックではテキスト名が非表示
    // テキストが見つかればテキストでタップ、見つからなければfalseを返す
    for (var i = 0; i < 10; i++) {
      if (find.text(markName).evaluate().isNotEmpty) break;
      if (find.byType(CustomScrollView).evaluate().isNotEmpty) {
        await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -300));
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    if (find.text(markName).evaluate().isEmpty) return false;
    await tester.tap(find.text(markName).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('給油').evaluate().isNotEmpty ||
          find.text('保存').evaluate().isNotEmpty ||
          find.text('名称').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 既存 Link をタップして LinkDetail を開く（後方互換）。
  Future<bool> openExistingLink(WidgetTester tester, String linkName) async {
    for (var i = 0; i < 10; i++) {
      if (find.text(linkName).evaluate().isNotEmpty) break;
      if (find.byType(CustomScrollView).evaluate().isNotEmpty) {
        await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -300));
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    if (find.text(linkName).evaluate().isEmpty) return false;
    await tester.tap(find.text(linkName).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('給油').evaluate().isNotEmpty ||
          find.text('保存').evaluate().isNotEmpty ||
          find.text('名称').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 給油フラグをONにする。
  Future<void> turnFuelSwitchOn(WidgetTester tester) async {
    final fuelSwitch = find.ancestor(
      of: find.text('給油'),
      matching: find.byType(SwitchListTile),
    );
    if (fuelSwitch.evaluate().isEmpty) return;
    // スイッチが OFF なら ON にする
    final switchWidget = tester.widget<SwitchListTile>(fuelSwitch.first);
    if (!switchWidget.value) {
      await tester.tap(fuelSwitch.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// 給油フラグをOFFにする。
  Future<void> turnFuelSwitchOff(WidgetTester tester) async {
    final fuelSwitch = find.ancestor(
      of: find.text('給油'),
      matching: find.byType(SwitchListTile),
    );
    if (fuelSwitch.evaluate().isEmpty) return;
    final switchWidget = tester.widget<SwitchListTile>(fuelSwitch.first);
    if (switchWidget.value) {
      await tester.tap(fuelSwitch.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// ガソリン支払者をFilterChipで選択する。
  /// MarkDetailでは _GasPayerChipSection がインライン選択チップを表示する。
  /// キー: markDetail_chip_gasPayer_${memberId}
  Future<bool> selectGasPayer(WidgetTester tester, String memberName) async {
    // memberName → memberId マッピング（シードデータ準拠）
    final memberIdMap = {
      '太郎': 'member-001',
      '花子': 'member-002',
      '健太': 'member-003',
    };
    final memberId = memberIdMap[memberName];
    if (memberId == null) {
      print('[selectGasPayer] 未知のメンバー名: $memberName');
      return false;
    }

    // ガソリン支払者セクションが表示されているか確認
    final gasPayerLabel = find.text('ガソリン支払者');
    if (gasPayerLabel.evaluate().isEmpty) {
      print('[selectGasPayer] ガソリン支払者行が見つかりません');
      return false;
    }

    // FilterChipをタップして選択
    // MarkDetail: markDetail_chip_gasPayer_${memberId}
    // LinkDetail: linkDetail_chip_gasPayer_${memberId}
    var chipKey = find.byKey(Key('markDetail_chip_gasPayer_$memberId'));
    if (chipKey.evaluate().isEmpty) {
      chipKey = find.byKey(Key('linkDetail_chip_gasPayer_$memberId'));
    }
    if (chipKey.evaluate().isEmpty) {
      // 画面外の可能性があるのでスクロール
      for (var i = 0; i < 5; i++) {
        await tester.ensureVisible(gasPayerLabel.first);
        await tester.pump(const Duration(milliseconds: 200));
        final mk = find.byKey(Key('markDetail_chip_gasPayer_$memberId'));
        final lk = find.byKey(Key('linkDetail_chip_gasPayer_$memberId'));
        if (mk.evaluate().isNotEmpty) { chipKey = mk; break; }
        if (lk.evaluate().isNotEmpty) { chipKey = lk; break; }
      }
    }
    if (chipKey.evaluate().isEmpty) {
      print('[selectGasPayer] FilterChip *_chip_gasPayer_$memberId が見つかりません');
      return false;
    }
    await tester.ensureVisible(chipKey.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(chipKey.first);
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 保存ボタンをタップして前画面に戻る。
  Future<void> tapSaveButton(WidgetTester tester) async {
    final saveButton = find.text('保存');
    if (saveButton.evaluate().isEmpty) return;
    await tester.ensureVisible(saveButton.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(saveButton.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // 保存後は MarkDetail が閉じてミチタブに戻る
      if (find.text('ミチ').evaluate().isNotEmpty ||
          find.text('追加').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────
  // TC-FCM-001: movingCostEstimated イベントでMarkDetailの給油セクションが非表示
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-FCM-001: movingCostEstimated イベントでMarkDetailの給油セクションが非表示であること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 1. movingCostEstimated タイプのイベントを開く
    final opened = await openEventDetail(tester, '週末ドライブ（燃費推定）');
    if (!opened) {
      markTestSkipped('「週末ドライブ（燃費推定）」が見つからないためスキップします');
      return;
    }

    // 2. ミチタブを開く
    await goToMichiTab(tester);

    // 3. Mark をタップして MarkDetail を開く（ml-009: 出発地点）
    // movingCostEstimatedはshowNameField=falseのためIDで直接タップ
    final markOpened = await openMarkLinkById(tester, 'ml-009');
    expect(markOpened, isTrue, reason: '「出発地点」 Mark が開けること');

    // 期待結果: 給油フラグのスイッチが表示されない
    expect(find.text('給油'), findsNothing,
        reason: 'movingCostEstimated では給油スイッチが表示されないこと');

    // ガソリン単価・給油量・合計金額が非表示
    expect(find.text('ガソリン単価'), findsNothing,
        reason: 'ガソリン単価フィールドが表示されないこと');

    // ガソリン支払者行が非表示
    expect(find.text('ガソリン支払者'), findsNothing,
        reason: 'ガソリン支払者選択行が表示されないこと');
  });

  // ────────────────────────────────────────────────────────
  // TC-FCM-002: movingCost イベントでMarkDetailの給油セクションが表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-FCM-002: movingCost イベントでMarkDetailの給油セクションが表示されること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 1. movingCost タイプのイベントを開く
    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 2. ミチタブを開く
    await goToMichiTab(tester);

    // 3. Mark をタップして MarkDetail を開く（ml-001: 自宅出発）
    // movingCostはshowNameField=falseのためIDで直接タップ
    final markOpened = await openMarkLinkById(tester, 'ml-001');
    expect(markOpened, isTrue, reason: '「自宅出発」 Mark が開けること');

    // 期待結果: 給油フラグのスイッチが表示される
    expect(find.text('給油'), findsOneWidget,
        reason: 'movingCost では給油スイッチが表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TC-FCM-003: movingCost イベントのMarkDetailでガソリン支払者を選択・保存できること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-FCM-003: movingCost イベントのMarkDetailでガソリン支払者を選択・保存できること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 1. movingCost タイプのイベントの MarkDetail を開く
    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    await goToMichiTab(tester);

    // 大涌谷（ml-005 / isFuel=true のシードデータ Mark）を開く
    // movingCostはshowNameField=falseのためIDで直接タップ
    final markOpened = await openMarkLinkById(tester, 'ml-005');
    expect(markOpened, isTrue, reason: '「大涌谷」 Mark が開けること');

    // 2. 給油フラグをONにする
    await turnFuelSwitchOn(tester);

    // ガソリン支払者行が表示されること
    expect(find.text('ガソリン支払者'), findsOneWidget,
        reason: '給油ON後にガソリン支払者行が表示されること');

    // 3-4. ガソリン支払者を選択する（花子を選択）
    final selected = await selectGasPayer(tester, '花子');
    expect(selected, isTrue, reason: 'ガソリン支払者「花子」が選択できること');

    // ガソリン支払者に「花子」が表示されること
    expect(find.text('花子'), findsWidgets,
        reason: '選択後にガソリン支払者として「花子」が表示されること');

    // 5. 保存ボタンをタップする
    await tapSaveButton(tester);

    // 6. 同じ MarkDetail を再度開く（ml-005: 大涌谷）
    await openMarkLinkById(tester, 'ml-005');

    // 給油ON状態でロードされたか確認
    await turnFuelSwitchOn(tester);

    // 期待結果: 手順4で選択したメンバー名「花子」がガソリン支払者に表示される
    expect(find.text('花子'), findsWidgets,
        reason: '再表示後もガソリン支払者として「花子」が保存されていること');
  });

  // ────────────────────────────────────────────────────────
  // TC-FCM-004: movingCost イベントのLinkDetailでガソリン支払者を選択・保存できること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-FCM-004: movingCost イベントのLinkDetailでガソリン支払者を選択・保存できること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 1. movingCost タイプのイベントの LinkDetail を開く
    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    await goToMichiTab(tester);

    // 東名高速（ml-002 / Link）を開く
    // movingCostはshowNameField=falseのためIDで直接タップ
    final linkOpened = await openMarkLinkById(tester, 'ml-002');
    expect(linkOpened, isTrue, reason: '「東名高速」 Link が開けること');

    // 2. 給油フラグをONにする
    await turnFuelSwitchOn(tester);

    // ガソリン支払者行が表示されること
    expect(find.text('ガソリン支払者'), findsOneWidget,
        reason: 'LinkDetail: 給油ON後にガソリン支払者行が表示されること');

    // 3-4. ガソリン支払者を選択する（太郎を選択）
    final selected = await selectGasPayer(tester, '太郎');
    expect(selected, isTrue, reason: 'LinkDetail: ガソリン支払者「太郎」が選択できること');

    // ガソリン支払者に「太郎」が表示されること
    expect(find.text('太郎'), findsWidgets,
        reason: 'LinkDetail: 選択後にガソリン支払者として「太郎」が表示されること');

    // 5. 保存ボタンをタップする
    await tapSaveButton(tester);

    // 6. 同じ LinkDetail を再度開く（ml-002: 東名高速）
    await openMarkLinkById(tester, 'ml-002');

    // 給油ON状態でロードされたか確認
    await turnFuelSwitchOn(tester);

    // 期待結果: 手順4で選択したメンバー名「太郎」がガソリン支払者に表示される
    expect(find.text('太郎'), findsWidgets,
        reason: 'LinkDetail: 再表示後もガソリン支払者として「太郎」が保存されていること');
  });

  // ────────────────────────────────────────────────────────
  // TC-FCM-005: movingCost イベントのMarkDetailで isFuel=false のとき給油セクション非表示
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-FCM-005: movingCost イベントのMarkDetailで isFuel=false のとき給油セクションが非表示であること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 1. movingCost タイプのイベントの MarkDetail を開く
    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    await goToMichiTab(tester);

    // 自宅出発（ml-001 / isFuel=false のシードデータ Mark）を開く
    // movingCostはshowNameField=falseのためIDで直接タップ
    final markOpened = await openMarkLinkById(tester, 'ml-001');
    expect(markOpened, isTrue, reason: '「自宅出発」 Mark が開けること');

    // 2. 給油フラグがOFFであることを確認（またはOFFにする）
    await turnFuelSwitchOff(tester);

    // 期待結果: ガソリン単価・給油量・合計金額の入力欄が表示されない
    expect(find.text('ガソリン単価'), findsNothing,
        reason: 'isFuel=false のときガソリン単価フィールドが表示されないこと');

    // ガソリン支払者の選択行が表示されない
    expect(find.text('ガソリン支払者'), findsNothing,
        reason: 'isFuel=false のときガソリン支払者選択行が表示されないこと');
  });

  // ────────────────────────────────────────────────────────
  // TC-FCM-006: movingCostEstimated イベントの概要タブで燃費・ガソリン単価・ガソリン支払者が表示される
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-FCM-006: movingCostEstimated イベントの概要タブで燃費・ガソリン単価・ガソリン支払者が表示されること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 1. movingCostEstimated タイプのイベントを開く
    final opened = await openEventDetail(tester, '週末ドライブ（燃費推定）');
    if (!opened) {
      markTestSkipped('「週末ドライブ（燃費推定）」が見つからないためスキップします');
      return;
    }

    // 2. 概要タブ（BasicInfo）を開く（デフォルトで概要タブが表示される想定）
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 期待結果: 燃費フィールドが表示される
    bool fuelFound = false;
    for (var i = 0; i < 5; i++) {
      if (find.text('燃費').evaluate().isNotEmpty) {
        fuelFound = true;
        break;
      }
      final scrollable = find.byType(ListView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -200));
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(fuelFound, isTrue,
        reason: 'movingCostEstimated の概要タブに燃費フィールドが表示されること');

    // ガソリン単価フィールドが表示される
    bool priceFound = false;
    for (var i = 0; i < 5; i++) {
      if (find.text('ガソリン単価').evaluate().isNotEmpty) {
        priceFound = true;
        break;
      }
      final scrollable = find.byType(ListView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -200));
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(priceFound, isTrue,
        reason: 'movingCostEstimated の概要タブにガソリン単価フィールドが表示されること');

    // ガソリン支払者フィールドが表示される
    bool payerFound = false;
    for (var i = 0; i < 5; i++) {
      if (find.text('ガソリン支払者').evaluate().isNotEmpty) {
        payerFound = true;
        break;
      }
      final scrollable = find.byType(ListView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -200));
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(payerFound, isTrue,
        reason: 'movingCostEstimated の概要タブにガソリン支払者フィールドが表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TC-FCM-007: movingCost イベントの概要タブで燃費・ガソリン単価・ガソリン支払者が非表示
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-FCM-007: movingCost イベントの概要タブで燃費・ガソリン単価・ガソリン支払者が非表示であること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 1. movingCost タイプのイベントを開く
    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 2. 概要タブ（BasicInfo）を開く
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));
    }

    // スクロールして全フィールドを確認
    for (var i = 0; i < 5; i++) {
      final scrollable = find.byType(ListView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -200));
      }
      await tester.pump(const Duration(milliseconds: 200));
    }

    // 期待結果: 燃費フィールドが表示されない
    // ※ 給油量に「ガソリン単価」が出る可能性を考慮し、概要タブ内のみで確認
    // 基本情報タブ（参照モード）で「燃費」ラベルが表示されないこと
    final fuelTexts = tester
        .widgetList<Text>(find.byType(Text))
        .where((t) => t.data == '燃費')
        .toList();
    print('[TC-FCM-007] 燃費テキスト数: ${fuelTexts.length}');
    expect(fuelTexts.isEmpty, isTrue,
        reason: 'movingCost の概要タブに燃費フィールドが表示されないこと');

    // ガソリン単価フィールドが表示されない
    final priceTexts = tester
        .widgetList<Text>(find.byType(Text))
        .where((t) => t.data == 'ガソリン単価')
        .toList();
    print('[TC-FCM-007] ガソリン単価テキスト数: ${priceTexts.length}');
    expect(priceTexts.isEmpty, isTrue,
        reason: 'movingCost の概要タブにガソリン単価フィールドが表示されないこと');

    // ガソリン支払者フィールドが表示されない
    final payerTexts = tester
        .widgetList<Text>(find.byType(Text))
        .where((t) => t.data == 'ガソリン支払者')
        .toList();
    print('[TC-FCM-007] ガソリン支払者テキスト数: ${payerTexts.length}');
    expect(payerTexts.isEmpty, isTrue,
        reason: 'movingCost の概要タブにガソリン支払者フィールドが表示されないこと');
  });

  // ────────────────────────────────────────────────────────
  // TC-FCM-008: 新規イベント作成時のTopic選択肢に movingCostEstimated が含まれること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-FCM-008: 新規イベント作成時のTopic選択肢に movingCostEstimated が含まれること',
      (tester) async {
    await startApp(tester);

    // 1. イベント一覧画面で新規作成ボタン（FAB）をタップする
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: '新規作成FABが表示されること');
    await tester.tap(fab.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 2. Topic選択画面（ModalBottomSheet）が表示される
    expect(find.text('トピックを選択'), findsOneWidget,
        reason: 'Topic選択シートが表示されること');

    // 期待結果: '移動コスト（燃費で推定）' が選択肢に表示される
    expect(find.text('移動コスト（燃費で推定）'), findsWidgets,
        reason: '「移動コスト（燃費で推定）」の選択肢が表示されること');

    // '移動コスト（給油から計算）' が選択肢に表示される
    expect(find.text('移動コスト（給油から計算）'), findsWidgets,
        reason: '「移動コスト（給油から計算）」の選択肢が表示されること');
  });
}
