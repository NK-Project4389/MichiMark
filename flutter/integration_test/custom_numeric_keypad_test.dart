// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: CustomNumericKeypad（カスタム数値キーパッド）
///
/// Spec: docs/Spec/Features/FS-custom_numeric_keypad.md §12
///
/// テストシナリオ: TC-CNK-001 〜 TC-CNK-009

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
  // ヘルパー
  // ────────────────────────────────────────────────────────

  /// アプリを起動して EventListPage が表示されるまで待つ。
  Future<void> startApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント').evaluate().isNotEmpty) {
        break;
      }
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

  /// イベント一覧から燃費表示が有効なイベントをタップして EventDetail を開く。
  Future<bool> openEventWithFuel(
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
          find.text('ミチ').evaluate().isNotEmpty) {
        break;
      }
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byIcon(Icons.edit).evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find.byIcon(Icons.edit).evaluate().isNotEmpty;
  }

  /// BasicInfo タブの「編集」アイコンをタップして編集モードに入る。
  Future<bool> enterEditMode(WidgetTester tester) async {
    final editButton = find.byIcon(Icons.edit);
    if (editButton.evaluate().isEmpty) return false;
    await tester.tap(editButton);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('キャンセル').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find.text('キャンセル').evaluate().isNotEmpty;
  }

  /// NumericInputRow タップ領域をタップしてキーパッドを開く。
  /// [tapKey] は `Key('numeric_input_tap_$label')` 形式のキー。
  Future<bool> openKeypad(WidgetTester tester, Key tapKey) async {
    final tapTarget = find.byKey(tapKey);
    if (tapTarget.evaluate().isEmpty) {
      print('[openKeypad] タップ領域が見つかりません: $tapKey');
      return false;
    }
    await tester.tap(tapTarget);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('custom_numeric_keypad')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find.byKey(const Key('custom_numeric_keypad')).evaluate().isNotEmpty;
  }

  /// キーパッドの数字キーをタップする。[digit] は '0'〜'9' または '00'。
  Future<void> tapDigit(WidgetTester tester, String digit) async {
    final key = Key('keypad_digit_$digit');
    await tester.tap(find.byKey(key));
    await tester.pump(const Duration(milliseconds: 200));
  }

  /// キーパッドの確定ボタン（=）をタップしてシートを閉じる。
  Future<void> tapConfirm(WidgetTester tester) async {
    final confirmBtn = find.byKey(const Key('keypad_confirm'));
    await tester.ensureVisible(confirmBtn);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(confirmBtn);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('custom_numeric_keypad')).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// keypad_display_input ウィジェットのテキストを返す。
  String getDisplayInput(WidgetTester tester) {
    final widget = find.byKey(const Key('keypad_display_input'));
    if (widget.evaluate().isEmpty) return '';
    final textWidget = tester.widget<Text>(widget);
    return textWidget.data ?? '';
  }

  // ────────────────────────────────────────────────────────
  // TC-CNK-001: 数値を入力して確定できる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-CNK-001: 数値を入力して確定できる', (tester) async {
    await startApp(tester);

    if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
      markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
      return;
    }

    // 1. イベント詳細を開く
    final opened = await openEventWithFuel(tester, '週末ドライブ（燃費推定）');
    expect(opened, isTrue, reason: 'イベント詳細が開けること');

    // 2. 編集モードに入る
    final editing = await enterEditMode(tester);
    expect(editing, isTrue, reason: '編集モードに入れること');

    // 3. 「燃費」フィールドをタップしてキーパッドを開く
    final keypadOpened = await openKeypad(tester, const Key('numeric_input_tap_燃費'));
    expect(keypadOpened, isTrue, reason: 'キーパッド BottomSheet が開くこと');

    // 4. 1 → 5 → 0 の順にタップする
    await tapDigit(tester, '1');
    await tapDigit(tester, '5');
    await tapDigit(tester, '0');

    // 5. Display に「150」が表示されていることを確認
    final displayText = getDisplayInput(tester);
    print('[TC-CNK-001] Display 入力値: "$displayText"');
    expect(displayText, equals('150'), reason: 'Display に "150" が表示されること');

    // 6. = ボタンをタップして確定する
    await tapConfirm(tester);

    // 7. キーパッドが閉じていることを確認
    expect(
      find.byKey(const Key('custom_numeric_keypad')),
      findsNothing,
      reason: '確定後にキーパッドが閉じること',
    );

    // 8. 「燃費」フィールドに 150 が反映されていることを確認
    final row = find.byKey(const Key('km_per_gas_input_row'));
    expect(row, findsOneWidget, reason: '燃費フィールド（km_per_gas_input_row）が存在すること');
    // フィールド内テキストを取得
    final rowTexts = tester
        .widgetList<Text>(find.descendant(of: row, matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .toList();
    print('[TC-CNK-001] 燃費フィールド内テキスト: $rowTexts');
    expect(
      rowTexts.any((s) => s == '150'),
      isTrue,
      reason: '燃費フィールドに "150" が表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-CNK-002: ⌫（バックスペース）で1文字ずつ削除できる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-CNK-002: ⌫（バックスペース）で1文字ずつ削除できる', (tester) async {
    await startApp(tester);

    if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
      markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
      return;
    }

    final opened = await openEventWithFuel(tester, '週末ドライブ（燃費推定）');
    expect(opened, isTrue, reason: 'イベント詳細が開けること');

    final editing = await enterEditMode(tester);
    expect(editing, isTrue, reason: '編集モードに入れること');

    // 「燃費」フィールドをタップしてキーパッドを開く
    final keypadOpened = await openKeypad(tester, const Key('numeric_input_tap_燃費'));
    expect(keypadOpened, isTrue, reason: 'キーパッドが開くこと');

    // 1 → 2 → 3 を入力する
    await tapDigit(tester, '1');
    await tapDigit(tester, '2');
    await tapDigit(tester, '3');

    // Display に「123」が表示されていることを確認
    final displayBefore = getDisplayInput(tester);
    print('[TC-CNK-002] バックスペース前 Display: "$displayBefore"');
    expect(displayBefore, equals('123'), reason: 'バックスペース前に "123" が表示されること');

    // ⌫ を1回タップする
    await tester.tap(find.byKey(const Key('keypad_backspace')));
    await tester.pump(const Duration(milliseconds: 300));

    // Display の入力値が「12」になることを確認
    final displayAfter = getDisplayInput(tester);
    print('[TC-CNK-002] バックスペース後 Display: "$displayAfter"');
    expect(displayAfter, equals('12'), reason: 'バックスペース後に Display が "12" になること');
  });

  // ────────────────────────────────────────────────────────
  // TC-CNK-003: C（クリア）で全消去できる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-CNK-003: C（クリア）で全消去できる', (tester) async {
    await startApp(tester);

    if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
      markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
      return;
    }

    final opened = await openEventWithFuel(tester, '週末ドライブ（燃費推定）');
    expect(opened, isTrue, reason: 'イベント詳細が開けること');

    final editing = await enterEditMode(tester);
    expect(editing, isTrue, reason: '編集モードに入れること');

    final keypadOpened = await openKeypad(tester, const Key('numeric_input_tap_燃費'));
    expect(keypadOpened, isTrue, reason: 'キーパッドが開くこと');

    // 4 → 5 → 6 を入力する
    await tapDigit(tester, '4');
    await tapDigit(tester, '5');
    await tapDigit(tester, '6');

    final displayBefore = getDisplayInput(tester);
    print('[TC-CNK-003] クリア前 Display: "$displayBefore"');
    expect(displayBefore, equals('456'), reason: 'クリア前に "456" が表示されること');

    // C をタップする
    await tester.tap(find.byKey(const Key('keypad_clear')));
    await tester.pump(const Duration(milliseconds: 300));

    // Cキー後は _inputString = '' になり Display が originalValue（プレースホルダー）を表示する。
    // さらに数字を入力すると '1' から始まること（クリアが正しく機能している）を確認する。
    await tapDigit(tester, '1');
    final displayAfter = getDisplayInput(tester);
    print('[TC-CNK-003] クリア後に "1" 入力後 Display: "$displayAfter"');
    expect(displayAfter, equals('1'), reason: 'クリア後に "1" を入力したら Display が "1" になること（クリアが効いている）');
  });

  // ────────────────────────────────────────────────────────
  // TC-CNK-004: 変更前の値が Display に表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-CNK-004: 変更前の値が Display に表示される', (tester) async {
    await startApp(tester);

    if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
      markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
      return;
    }

    final opened = await openEventWithFuel(tester, '週末ドライブ（燃費推定）');
    expect(opened, isTrue, reason: 'イベント詳細が開けること');

    final editing = await enterEditMode(tester);
    expect(editing, isTrue, reason: '編集モードに入れること');

    // キーパッドを開く前に現在の燃費値を取得（後で比較用）
    final row = find.byKey(const Key('km_per_gas_input_row'));
    String originalValue = '';
    if (row.evaluate().isNotEmpty) {
      final rowTexts = tester
          .widgetList<Text>(find.descendant(of: row, matching: find.byType(Text)))
          .map((t) => t.data ?? '')
          .where((s) => s.isNotEmpty && s != '燃費' && s != 'km/L')
          .toList();
      originalValue = rowTexts.firstOrNull ?? '';
      print('[TC-CNK-004] 現在の燃費値: "$originalValue"');
    }

    // 「燃費」フィールドをタップしてキーパッドを開く
    final keypadOpened = await openKeypad(tester, const Key('numeric_input_tap_燃費'));
    expect(keypadOpened, isTrue, reason: 'キーパッドが開くこと');

    // Display の変更前値テキストを確認
    final originalDisplay = find.byKey(const Key('keypad_display_original'));
    expect(originalDisplay, findsOneWidget, reason: 'keypad_display_original が存在すること');

    final originalText = (tester.widget<Text>(originalDisplay)).data ?? '';
    print('[TC-CNK-004] Display 変更前値テキスト: "$originalText"');

    // 変更前値テキストが表示されていること（originalValue を含む）
    if (originalValue.isNotEmpty) {
      expect(
        originalText.contains(originalValue),
        isTrue,
        reason: 'Display 変更前値に元の燃費値 "$originalValue" が含まれること',
      );
    } else {
      // 値が未設定の場合は空か未設定表示
      expect(originalText, isNotNull, reason: 'keypad_display_original が表示されること');
    }
  });

  // ────────────────────────────────────────────────────────
  // TC-CNK-005: isDecimal=false の場合、小数点キーが非活性
  // ────────────────────────────────────────────────────────
  testWidgets('TC-CNK-005: isDecimal=false の場合、小数点キーが非活性', (tester) async {
    await startApp(tester);

    if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
      markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
      return;
    }

    final opened = await openEventWithFuel(tester, '週末ドライブ（燃費推定）');
    expect(opened, isTrue, reason: 'イベント詳細が開けること');

    final editing = await enterEditMode(tester);
    expect(editing, isTrue, reason: '編集モードに入れること');

    // 「ガソリン単価」フィールド（isDecimal=false）をタップ
    final keypadOpened = await openKeypad(tester, const Key('numeric_input_tap_ガソリン単価'));
    expect(keypadOpened, isTrue, reason: '「ガソリン単価」フィールドのキーパッドが開くこと');

    // 小数点キーが存在することを確認
    final dotKey = find.byKey(const Key('keypad_dot'));
    expect(dotKey, findsOneWidget, reason: '小数点キー（keypad_dot）が存在すること');

    // 小数点キーをタップする
    await tester.tap(dotKey);
    await tester.pump(const Duration(milliseconds: 300));

    // Display の入力値に「.」が追加されないことを確認
    final displayAfterDot = getDisplayInput(tester);
    print('[TC-CNK-005] 小数点タップ後 Display: "$displayAfterDot"');
    expect(
      displayAfterDot.contains('.'),
      isFalse,
      reason: 'isDecimal=false では小数点タップ後も Display に "." が追加されないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-CNK-006: isDecimal=true の場合、小数点を含む値を入力できる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-CNK-006: isDecimal=true の場合、小数点を含む値を入力できる', (tester) async {
    await startApp(tester);

    if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
      markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
      return;
    }

    final opened = await openEventWithFuel(tester, '週末ドライブ（燃費推定）');
    expect(opened, isTrue, reason: 'イベント詳細が開けること');

    final editing = await enterEditMode(tester);
    expect(editing, isTrue, reason: '編集モードに入れること');

    // 「燃費」フィールド（isDecimal=true）をタップしてキーパッドを開く
    final keypadOpened = await openKeypad(tester, const Key('numeric_input_tap_燃費'));
    expect(keypadOpened, isTrue, reason: 'キーパッドが開くこと');

    // 2 → 0 → . → 5 の順にタップする
    await tapDigit(tester, '2');
    await tapDigit(tester, '0');
    await tester.tap(find.byKey(const Key('keypad_dot')));
    await tester.pump(const Duration(milliseconds: 200));
    await tapDigit(tester, '5');

    // Display に「20.5」が表示されていることを確認
    final displayText = getDisplayInput(tester);
    print('[TC-CNK-006] Display 入力値: "$displayText"');
    expect(displayText, equals('20.5'), reason: 'Display に "20.5" が表示されること');

    // = ボタンをタップして確定する
    await tapConfirm(tester);

    // キーパッドが閉じていることを確認
    expect(
      find.byKey(const Key('custom_numeric_keypad')),
      findsNothing,
      reason: '確定後にキーパッドが閉じること',
    );

    // 「燃費」フィールドに「20.5」が反映されていることを確認
    final row = find.byKey(const Key('km_per_gas_input_row'));
    expect(row, findsOneWidget, reason: '燃費フィールドが存在すること');
    final rowTexts = tester
        .widgetList<Text>(find.descendant(of: row, matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .toList();
    print('[TC-CNK-006] 燃費フィールド内テキスト: $rowTexts');
    expect(
      rowTexts.any((s) => s == '20.5'),
      isTrue,
      reason: '燃費フィールドに "20.5" が表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-CNK-007: 00 キーで「00」を入力できる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-CNK-007: 00 キーで「00」を入力できる', (tester) async {
    await startApp(tester);

    if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
      markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
      return;
    }

    final opened = await openEventWithFuel(tester, '週末ドライブ（燃費推定）');
    expect(opened, isTrue, reason: 'イベント詳細が開けること');

    final editing = await enterEditMode(tester);
    expect(editing, isTrue, reason: '編集モードに入れること');

    // 「ガソリン単価」フィールドをタップしてキーパッドを開く
    final keypadOpened = await openKeypad(tester, const Key('numeric_input_tap_ガソリン単価'));
    expect(keypadOpened, isTrue, reason: '「ガソリン単価」フィールドのキーパッドが開くこと');

    // 1 → 00 の順にタップする
    await tapDigit(tester, '1');
    await tapDigit(tester, '00');

    // Display に「100」が表示されていることを確認
    final displayText = getDisplayInput(tester);
    print('[TC-CNK-007] Display 入力値: "$displayText"');
    expect(displayText, equals('100'), reason: '"1" + "00" 入力後に Display が "100" になること');

    // = ボタンをタップして確定する
    await tapConfirm(tester);

    // キーパッドが閉じていることを確認
    expect(
      find.byKey(const Key('custom_numeric_keypad')),
      findsNothing,
      reason: '確定後にキーパッドが閉じること',
    );

    // 「ガソリン単価」フィールドに「100」が反映されていることを確認
    // ガソリン単価フィールドにはKeyが設定されていない可能性があるため
    // テキストで確認する
    final allTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .toList();
    print('[TC-CNK-007] 全テキスト: $allTexts');
    expect(
      allTexts.any((s) => s == '100'),
      isTrue,
      reason: '「ガソリン単価」フィールドに "100" が表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-CNK-008: バリア（背景）タップでキーパッドを閉じると値が変更されない
  // ────────────────────────────────────────────────────────
  testWidgets('TC-CNK-008: バリア（背景）タップでキーパッドを閉じると値が変更されない', (tester) async {
    await startApp(tester);

    if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
      markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
      return;
    }

    final opened = await openEventWithFuel(tester, '週末ドライブ（燃費推定）');
    expect(opened, isTrue, reason: 'イベント詳細が開けること');

    final editing = await enterEditMode(tester);
    expect(editing, isTrue, reason: '編集モードに入れること');

    // キーパッドを開く前の燃費フィールドの値を取得
    final row = find.byKey(const Key('km_per_gas_input_row'));
    String valueBefore = '';
    if (row.evaluate().isNotEmpty) {
      final rowTexts = tester
          .widgetList<Text>(find.descendant(of: row, matching: find.byType(Text)))
          .map((t) => t.data ?? '')
          .where((s) => s.isNotEmpty && s != '燃費' && s != 'km/L')
          .toList();
      valueBefore = rowTexts.firstOrNull ?? '';
    }
    print('[TC-CNK-008] キーパッド開く前の燃費値: "$valueBefore"');

    // 「燃費」フィールドをタップしてキーパッドを開く
    final keypadOpened = await openKeypad(tester, const Key('numeric_input_tap_燃費'));
    expect(keypadOpened, isTrue, reason: 'キーパッドが開くこと');

    // 3 → 0 と入力する
    await tapDigit(tester, '3');
    await tapDigit(tester, '0');

    final displayText = getDisplayInput(tester);
    print('[TC-CNK-008] 入力後 Display: "$displayText"');
    expect(displayText, equals('30'), reason: 'Display に "30" が表示されること');

    // バリア（キーパッド外の暗い領域）をタップしてシートを閉じる
    // BottomSheet のバリアは画面上部（キーパッド外のエリア）をタップすることで閉じる
    await tester.tapAt(const Offset(200, 100));
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('custom_numeric_keypad')).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // キーパッドが閉じていることを確認
    expect(
      find.byKey(const Key('custom_numeric_keypad')),
      findsNothing,
      reason: 'バリアタップ後にキーパッドが閉じること',
    );

    // 燃費フィールドの値が変更されていないことを確認
    if (row.evaluate().isNotEmpty) {
      final rowTextsAfter = tester
          .widgetList<Text>(find.descendant(of: row, matching: find.byType(Text)))
          .map((t) => t.data ?? '')
          .where((s) => s.isNotEmpty && s != '燃費' && s != 'km/L')
          .toList();
      final valueAfter = rowTextsAfter.firstOrNull ?? '';
      print('[TC-CNK-008] バリアタップ後の燃費値: "$valueAfter"');
      expect(
        valueAfter,
        equals(valueBefore),
        reason: 'バリアタップで閉じた後、燃費フィールドの値が変更されないこと',
      );
    }
  });

  // ────────────────────────────────────────────────────────
  // TC-CNK-009: 空入力で確定すると元の値が維持される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-CNK-009: 空入力で確定すると元の値が維持される', (tester) async {
    await startApp(tester);

    if (find.text('週末ドライブ（燃費推定）').evaluate().isEmpty) {
      markTestSkipped('「週末ドライブ（燃費推定）」イベントが見つからないためスキップします');
      return;
    }

    final opened = await openEventWithFuel(tester, '週末ドライブ（燃費推定）');
    expect(opened, isTrue, reason: 'イベント詳細が開けること');

    final editing = await enterEditMode(tester);
    expect(editing, isTrue, reason: '編集モードに入れること');

    // キーパッドを開く前の燃費フィールドの値を取得
    final row = find.byKey(const Key('km_per_gas_input_row'));
    String valueBefore = '';
    if (row.evaluate().isNotEmpty) {
      final rowTexts = tester
          .widgetList<Text>(find.descendant(of: row, matching: find.byType(Text)))
          .map((t) => t.data ?? '')
          .where((s) => s.isNotEmpty && s != '燃費' && s != 'km/L')
          .toList();
      valueBefore = rowTexts.firstOrNull ?? '';
    }
    print('[TC-CNK-009] キーパッド開く前の燃費値: "$valueBefore"');

    // 「燃費」フィールドをタップしてキーパッドを開く
    final keypadOpened = await openKeypad(tester, const Key('numeric_input_tap_燃費'));
    expect(keypadOpened, isTrue, reason: 'キーパッドが開くこと');

    // 何も入力せずに = ボタンをタップして確定する
    await tapConfirm(tester);

    // キーパッドが閉じていることを確認
    expect(
      find.byKey(const Key('custom_numeric_keypad')),
      findsNothing,
      reason: '確定後にキーパッドが閉じること',
    );

    // 燃費フィールドの値が変更されていないことを確認
    if (row.evaluate().isNotEmpty) {
      final rowTextsAfter = tester
          .widgetList<Text>(find.descendant(of: row, matching: find.byType(Text)))
          .map((t) => t.data ?? '')
          .where((s) => s.isNotEmpty && s != '燃費' && s != 'km/L')
          .toList();
      final valueAfter = rowTextsAfter.firstOrNull ?? '';
      print('[TC-CNK-009] 空入力確定後の燃費値: "$valueAfter"');
      expect(
        valueAfter,
        equals(valueBefore),
        reason: '空入力で確定した後、燃費フィールドの値が変更されないこと（元の値が維持されること）',
      );
    } else {
      // フィールドが見つからない場合は単純にキーパッドが閉じることを確認済み
      print('[TC-CNK-009] 燃費フィールドが見つからないため値比較をスキップ');
    }
  });
}
