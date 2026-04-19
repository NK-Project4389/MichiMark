// ignore_for_file: avoid_print

/// Integration Test: BasicInfoBloc 交通手段選択時の燃費単位変換バグ修正
///
/// バグ修正概要:
///   BasicInfoBloc._onTransSelected で TransDomain.kmPerGas（0.1km/L の10倍整数値）を
///   正しく変換して燃費フィールドに転記するよう修正。
///   修正前: kmPerGas.toString() → 155 が "155" になる
///   修正後: (kmPerGas / 10.0).toString() → 155 が "15.5" になる
///
/// テストシナリオ: TC-BTF-001 〜 TC-BTF-002

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;
import 'package:michi_mark/repository/impl/in_memory/seed_data.dart';

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
    // BasicInfoSection のロード完了を待つ（「タップして編集」ヒントが表示されるまで）
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('タップして編集').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// BasicInfo タブの参照モードエリアをタップして編集モードに入る。
  Future<bool> enterEditMode(WidgetTester tester) async {
    final readArea = find.byKey(const Key('basicInfoRead_container_section'));
    if (readArea.evaluate().isEmpty) return false;
    await tester.tap(readArea);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // 編集モードでは「キャンセル」ボタンが表示される
      if (find.text('キャンセル').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find.text('キャンセル').evaluate().isNotEmpty;
  }

  /// 編集モードで交通手段チップセクションが表示されているか確認する。
  /// BasicInfo編集モードでは交通手段はFilterChipでインライン表示される（別画面なし）。
  Future<bool> openTransSelection(WidgetTester tester) async {
    // 編集モードでは交通手段チップが直接表示される。「交通手段」ラベルが見えているかを確認する。
    return find.text('交通手段').evaluate().isNotEmpty;
  }

  /// 指定交通手段のFilterChipをタップして選択する（確定ボタンは不要）。
  Future<bool> selectTransAndConfirm(
    WidgetTester tester,
    String transName,
  ) async {
    // FilterChip の中の Text をターゲットにする
    final chip = find.ancestor(
      of: find.text(transName),
      matching: find.byType(FilterChip),
    );
    if (chip.evaluate().isEmpty) {
      print('[selectTransAndConfirm] "$transName" のFilterChipが見つかりませんでした');
      return false;
    }
    await tester.tap(chip.first);
    await tester.pump(const Duration(milliseconds: 500));
    return true;
  }

  /// 編集モードで「保存」ボタンをタップして参照モードに戻る。
  Future<void> saveDraft(WidgetTester tester) async {
    final saveButton = find.text('保存');
    if (saveButton.evaluate().isEmpty) return;
    await tester.ensureVisible(saveButton);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(saveButton);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // 参照モードに戻ると「タップして編集」ヒントが表示される
      if (find.text('タップして編集').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────
  // TC-BTF-001: 交通手段選択で燃費が正しく転記される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-BTF-001: 交通手段選択で燃費が正しく変換されて転記される', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 1. 週末ドライブ（燃費推定）（movingCostEstimated トピック・showKmPerGas=true）を開く
    //    movingCost トピックは showKmPerGas=false のため燃費フィールドが非表示になった
    //    movingCostEstimated は showKmPerGas=true のため燃費フィールドが表示される
    final opened = await openEventDetail(tester, '週末ドライブ（燃費推定）');
    if (!opened) {
      markTestSkipped('「週末ドライブ（燃費推定）」が見つからないためスキップします');
      return;
    }

    // 2. 「編集」ボタンをタップして編集モードに入る
    final editing = await enterEditMode(tester);
    expect(editing, isTrue, reason: '「編集」ボタンが存在し、編集モードに入れること');

    // 3. 「マイカー」が交通手段として表示されていることを確認
    expect(
      find.text(seedTrans[0].transName),
      findsOneWidget,
      reason: '編集モードで交通手段「マイカー」が表示されること',
    );

    // 4. 交通手段選択画面を開く
    final selectionOpened = await openTransSelection(tester);
    expect(selectionOpened, isTrue, reason: '交通手段選択画面が開けること');

    // 5. 「マイカー」を選択して「確定」をタップして戻る
    final selected = await selectTransAndConfirm(tester, seedTrans[0].transName);
    expect(selected, isTrue, reason: '「マイカー」が選択できること');

    // 6. 保存して参照モードに戻る
    await saveDraft(tester);

    // 7. 参照モードで燃費の表示値を確認
    //    シードデータ: マイカーの kmPerGas = 155 (= 15.5 km/L)
    //    バグ修正前: "155 km/L" が表示される
    //    バグ修正後: "15.5 km/L" が表示される
    final fuelRowTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .toList();
    print('[TC-BTF-001] 画面上のテキスト一覧: $fuelRowTexts');

    // "155 km/L" が表示されていないこと（誤変換の検出）
    expect(
      find.text('155 km/L'),
      findsNothing,
      reason: '交通手段選択後の燃費が "155 km/L"（誤変換）で表示されないこと',
    );

    // "15.5 km/L" が表示されていること（正しい変換の確認）
    expect(
      find.text('15.5 km/L'),
      findsOneWidget,
      reason: '交通手段選択後の燃費が "15.5 km/L"（正しい変換）で表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-BTF-002: 交通手段なしの場合は燃費フィールドが大きな整数値にならない
  // ────────────────────────────────────────────────────────
  testWidgets('TC-BTF-002: 交通手段選択後に燃費フィールドが大きな整数値にならない', (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 1. 週末ドライブ（燃費推定）（movingCostEstimated トピック・showKmPerGas=true）を開く
    final opened = await openEventDetail(tester, '週末ドライブ（燃費推定）');
    if (!opened) {
      markTestSkipped('「週末ドライブ（燃費推定）」が見つからないためスキップします');
      return;
    }

    // 2. 「編集」ボタンをタップして編集モードに入る
    final editing = await enterEditMode(tester);
    expect(editing, isTrue, reason: '編集モードに入れること');

    // 3. 交通手段選択画面を開いてマイカーを選択・確定する
    final selectionOpened = await openTransSelection(tester);
    expect(selectionOpened, isTrue, reason: '交通手段選択画面が開けること');

    final selected = await selectTransAndConfirm(tester, seedTrans[0].transName);
    expect(selected, isTrue, reason: '交通手段が選択できること');

    // 4. 保存して参照モードに戻る
    await saveDraft(tester);

    // 5. 燃費フィールドに "155" "1550" "3000" など100以上の大きな整数値が
    //    "km/L" 付きで表示されていないことを確認（誤変換パターンの検出）
    final allTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .toList();
    print('[TC-BTF-002] 画面上のテキスト一覧: $allTexts');

    final hasLargeIntegerFuel = allTexts.any((text) {
      if (!text.contains('km/L')) return false;
      // "155 km/L" のような 3桁以上の整数値を含むパターンを検出
      final match = RegExp(r'^(\d+)\s*km/L$').firstMatch(text.trim());
      if (match == null) return false;
      final numStr = match.group(1)!;
      final num = double.tryParse(numStr);
      if (num == null) return false;
      // 100以上の整数値は誤変換の可能性が高い（15.5 → 155 のバグ）
      return num >= 100;
    });

    expect(
      hasLargeIntegerFuel,
      isFalse,
      reason: '交通手段選択後に燃費フィールドが 100 以上の整数値 km/L（誤変換）で表示されないこと',
    );
  });
}
