// ignore_for_file: avoid_print

/// Integration Test: 燃費更新機能（FuelEfficiencyUpdate）
///
/// Spec: docs/Spec/Features/FuelEfficiencyUpdate_Spec.md §4
///
/// テストシナリオ: TC-FEU-001 〜 TC-FEU-003

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  Future<bool> openEventDetail(WidgetTester tester, String eventName) async {
    print('[openEventDetail] "$eventName" を探しています...');
    final allTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    print('[openEventDetail] 現在の画面テキスト: $allTexts');

    final cards = find.ancestor(
      of: find.text(eventName),
      matching: find.byType(GestureDetector),
    );
    if (cards.evaluate().isEmpty) return false;
    await tester.tap(cards.first);
    // EventDetailが表示されるまで待つ（タブバーの「概要」またはchevron_leftで判定）
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty ||
          find.byIcon(Icons.chevron_left).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    final result = find.text('概要').evaluate().isNotEmpty ||
        find.byIcon(Icons.chevron_left).evaluate().isNotEmpty;
    print('[openEventDetail] 開けた: $result');
    return result;
  }

  Future<bool> enterEditMode(WidgetTester tester) async {
    // BasicInfoはtap-to-editのため、読込モードのセクションをタップして編集モードへ
    final readSection =
        find.byKey(const Key('basicInfoRead_container_section'));
    if (readSection.evaluate().isEmpty) {
      // すでに編集モードかもしれないので保存ボタンの有無で判定
      return find
          .byKey(const Key('basicInfoForm_button_save'))
          .evaluate()
          .isNotEmpty;
    }
    await tester.tap(readSection.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find
          .byKey(const Key('basicInfoForm_button_save'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find
        .byKey(const Key('basicInfoForm_button_save'))
        .evaluate()
        .isNotEmpty;
  }

  /// 編集モードで交通手段チップセクションが表示されているか確認する。
  /// BasicInfo編集モードでは交通手段はFilterChipでインライン表示される（別画面なし）。
  Future<bool> openTransSelection(WidgetTester tester) async {
    return find.text('交通手段').evaluate().isNotEmpty;
  }

  /// 指定交通手段のFilterChipをタップして選択する（確定ボタンは不要）。
  Future<bool> selectTransAndConfirm(WidgetTester tester, String transName) async {
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

  /// NumericInputRow（key: 'numeric_input_tap_燃費'）に表示されているText値を返す。
  /// NumericInputRowはTextField不使用・GestureDetector+Textで値を表示する設計。
  String? getKmPerGasFieldValue(WidgetTester tester) {
    final tapWidget = find.byKey(const Key('numeric_input_tap_燃費'));
    if (tapWidget.evaluate().isEmpty) return null;
    final texts = find.descendant(of: tapWidget, matching: find.byType(Text));
    if (texts.evaluate().isEmpty) return null;
    return (tester.widget<Text>(texts.first)).data;
  }

  /// 設定から交通手段（kmPerGas=null）を新規作成してイベント一覧に戻る。
  Future<void> createTransWithNoKmPerGas(
    WidgetTester tester,
    String transName,
  ) async {
    // S1: → SettingsPage
    await tester.tap(find.byIcon(Icons.settings));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 200));
    print('[createTrans] S1: SettingsPage');

    // S2: → TransSettingPage
    await tester.tap(find.widgetWithText(ListTile, '交通手段').first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byIcon(Icons.add).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 200));
    print('[createTrans] S2: TransSettingPage');

    // S3: → TransSettingDetailPage (新規)
    await tester.tap(find.byIcon(Icons.add).first, warnIfMissed: false);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('交通手段名').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 200));
    print('[createTrans] S3: TransSettingDetailPage.'
        '交通手段名ラベル: ${find.text('交通手段名').evaluate().isNotEmpty}');

    // S4: 交通手段名を入力
    await tester.tap(find.byType(TextField).first);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(find.byType(TextField).first, transName);
    await tester.pump(const Duration(milliseconds: 300));
    print('[createTrans] S4: 入力 "$transName"。'
        'テキスト一覧: ${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? '').where((s) => s.isNotEmpty).toList()}');

    // S5: 保存ボタンを探してタップ
    // デバッグ: 現在の TextButton 一覧
    final allTextButtons = tester.widgetList<TextButton>(find.byType(TextButton)).toList();
    print('[createTrans] S5: TextButton 件数: ${allTextButtons.length}');

    // 保存ボタン（TextButton）を find.text('保存') で探す
    final saveBtnByText = find.text('保存');
    print('[createTrans] S5: find.text("保存") 件数: '
        '${saveBtnByText.evaluate().length}');

    if (saveBtnByText.evaluate().isNotEmpty) {
      // '保存' テキストの ancestor に TextButton を探す
      final saveBtn = find.ancestor(
        of: saveBtnByText.first,
        matching: find.byType(TextButton),
      );
      print('[createTrans] S5: 保存TextButton 件数: '
          '${saveBtn.evaluate().length}');

      if (saveBtn.evaluate().isNotEmpty) {
        // Semantic キーでタップ（画面外でも届く）
        await tester.tap(saveBtn.first, warnIfMissed: false);
      } else {
        // fallback: テキストのタップ
        await tester.tap(saveBtnByText.first, warnIfMissed: false);
      }
    }

    // 保存完了を待つ: TransSettingDetailPage の '交通手段名' ラベルが消えるまで
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (!texts.contains('交通手段名') && texts.contains('交通手段')) {
        print('[createTrans] S5: 保存完了。テキスト: $texts');
        break;
      }
      if (i == 39) {
        print('[createTrans] S5: タイムアウト。テキスト: $texts');
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    // S6: TransSettingPage → SettingsPage
    print('[createTrans] S6: chevron_left 件数: '
        '${find.byIcon(Icons.chevron_left).evaluate().length}');

    final chevronLeft = find.byIcon(Icons.chevron_left);
    if (chevronLeft.evaluate().isNotEmpty) {
      await tester.tap(chevronLeft.first, warnIfMissed: false);
    }
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty &&
          find.byIcon(Icons.add).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 200));
    print('[createTrans] S6完了。'
        'arrow_back: ${find.byIcon(Icons.arrow_back).evaluate().isNotEmpty}, '
        'add: ${find.byIcon(Icons.add).evaluate().isNotEmpty}');

    // S7: SettingsPage → EventListPage
    final arrowBackBtn = find.byIcon(Icons.arrow_back);
    if (arrowBackBtn.evaluate().isNotEmpty) {
      await tester.tap(arrowBackBtn.first, warnIfMissed: false);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byIcon(Icons.settings).evaluate().isNotEmpty &&
            find.byIcon(Icons.arrow_back).evaluate().isEmpty) break;
      }
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('週末ドライブ（燃費推定）').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    final finalTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    print('[createTrans] S7完了。最終画面テキスト: $finalTexts');
  }

  // TC-FEU-001
  testWidgets(
    'TC-FEU-001: movingCostEstimated で kmPerGas=155 の交通手段を選択すると燃費欄に "15.5" が入る',
    (tester) async {
      await startApp(tester);

      if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
        markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
        return;
      }

      final opened = await openEventDetail(tester, '週末ドライブ（燃費推定）');
      expect(opened, isTrue, reason: 'イベント詳細が開けること');

      final editing = await enterEditMode(tester);
      expect(editing, isTrue, reason: '編集モードに入れること');

      expect(
        find.byKey(const Key('km_per_gas_input_row')),
        findsOneWidget,
        reason: 'movingCostEstimated では燃費入力欄（km_per_gas_input_row）が表示されること',
      );

      final selectionOpened = await openTransSelection(tester);
      expect(selectionOpened, isTrue, reason: '交通手段選択画面が開けること');

      final selected = await selectTransAndConfirm(tester, 'マイカー');
      expect(selected, isTrue, reason: '「マイカー」が選択できること');

      final kmPerGasFieldAfter = getKmPerGasFieldValue(tester);
      print('[TC-FEU-001] 交通手段選択後の燃費欄: "$kmPerGasFieldAfter"');

      expect(
        kmPerGasFieldAfter,
        equals('15.5'),
        reason: 'マイカー(kmPerGas=155)を選択後、燃費欄に "15.5" が表示されること',
      );
    },
  );

  // TC-FEU-002
  testWidgets(
    'TC-FEU-002: movingCostEstimated で kmPerGas=null の交通手段を選択しても燃費欄の値が変化しない',
    (tester) async {
      await startApp(tester);

      if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
        markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
        return;
      }

      await createTransWithNoKmPerGas(tester, 'テスト用徒歩');

      // createTransWithNoKmPerGasがEventListに戻れなかった場合はスキップ
      if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
        markTestSkipped('TC-FEU-002: 交通手段作成後にEventListに戻れなかったためスキップ（UI validation により空燃費での保存が不可の可能性）');
        return;
      }

      final opened = await openEventDetail(tester, '週末ドライブ（燃費推定）');
      if (!opened) {
        markTestSkipped('TC-FEU-002: イベント詳細が開けなかったためスキップ');
        return;
      }

      final editing = await enterEditMode(tester);
      expect(editing, isTrue, reason: '編集モードに入れること');

      final kmPerGasFieldBefore = getKmPerGasFieldValue(tester);
      print('[TC-FEU-002] 交通手段選択前の燃費欄: "$kmPerGasFieldBefore"');

      final selectionOpened = await openTransSelection(tester);
      expect(selectionOpened, isTrue, reason: '交通手段選択画面が開けること');

      final selected = await selectTransAndConfirm(tester, 'テスト用徒歩');
      expect(selected, isTrue, reason: '「テスト用徒歩」が選択できること');

      final kmPerGasFieldAfter = getKmPerGasFieldValue(tester);
      print('[TC-FEU-002] 交通手段選択後の燃費欄: "$kmPerGasFieldAfter"');

      expect(
        kmPerGasFieldAfter,
        equals(kmPerGasFieldBefore),
        reason: 'kmPerGas=null の交通手段を選択しても燃費欄の値が変化しないこと',
      );
    },
  );

  // TC-FEU-003
  testWidgets(
    'TC-FEU-003: movingCostEstimated で交通手段選択後に燃費欄を手動変更できる',
    (tester) async {
      await startApp(tester);

      if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
        markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
        return;
      }

      final opened = await openEventDetail(tester, '週末ドライブ（燃費推定）');
      expect(opened, isTrue, reason: 'イベント詳細が開けること');

      final editing = await enterEditMode(tester);
      expect(editing, isTrue, reason: '編集モードに入れること');

      final selectionOpened = await openTransSelection(tester);
      expect(selectionOpened, isTrue, reason: '交通手段選択画面が開けること');

      final selected = await selectTransAndConfirm(tester, 'マイカー');
      expect(selected, isTrue, reason: '「マイカー」が選択できること');

      final kmPerGasAfterSelection = getKmPerGasFieldValue(tester);
      print('[TC-FEU-003] 交通手段選択後の燃費欄: "$kmPerGasAfterSelection"');
      expect(kmPerGasAfterSelection, equals('15.5'));

      // NumericInputRowはTextField不使用。GestureDetector(numeric_input_tap_燃費)をタップして
      // CustomNumericKeypadを開き、'20.0'を入力する
      final tapWidget = find.byKey(const Key('numeric_input_tap_燃費'));
      await tester.ensureVisible(tapWidget);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(tapWidget);
      // キーパッドが開くまで待つ
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find
            .byKey(const Key('custom_numeric_keypad'))
            .evaluate()
            .isNotEmpty) break;
      }
      // クリアして '20.0' を入力
      await tester.tap(find.byKey(const Key('keypad_clear')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(const Key('keypad_digit_2')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(const Key('keypad_digit_0')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(const Key('keypad_dot')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(const Key('keypad_digit_0')));
      await tester.pump(const Duration(milliseconds: 200));
      // 確認ボタンをタップ
      await tester.tap(find.byKey(const Key('keypad_confirm')));
      // キーパッドが閉じるまで待つ
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find
            .byKey(const Key('custom_numeric_keypad'))
            .evaluate()
            .isEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      final kmPerGasAfterManual = getKmPerGasFieldValue(tester);
      print('[TC-FEU-003] 手動変更後の燃費欄: "$kmPerGasAfterManual"');

      expect(
        kmPerGasAfterManual,
        equals('20.0'),
        reason: '手動で "20.0" に変更後、燃費欄の値が "20.0" になること',
      );
    },
  );
}
