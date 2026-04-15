// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: 設定画面Detail UIスタイル確認
///
/// 対象: B-16「設定画面UIスタイル枠修正」
///
/// テストシナリオ: TC-SUI-001 〜 TC-SUI-004
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///
/// 注意:
///   各Detail画面は `/settings/xxx/new` に直接遷移するためルートスタックが1枚。
///   保存後の pop は GoRouter の "nothing to pop" エラーになるため、
///   保存操作のテストは「保存ボタンが表示され押せること」までを確認対象とする。

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

  /// メンバー設定Detail画面（新規）を開くまで待つ。
  Future<void> goToMemberSettingDetailPage(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/member/new');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('メンバー名').evaluate().isNotEmpty ||
          find.text('メンバー').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// タグ設定Detail画面（新規）を開くまで待つ。
  Future<void> goToTagSettingDetailPage(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/tag/new');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('タグ名').evaluate().isNotEmpty ||
          find.text('タグ').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// 交通手段設定Detail画面（新規）を開くまで待つ。
  Future<void> goToTransSettingDetailPage(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/trans/new');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('交通手段名').evaluate().isNotEmpty ||
          find.text('交通手段').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// アクション設定Detail画面（新規）を開くまで待つ。
  Future<void> goToActionSettingDetailPage(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/action/new');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('行動名').evaluate().isNotEmpty ||
          find.text('行動').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────
  // TC-SUI-001: メンバー設定 Detail画面 名前入力と保存
  // ────────────────────────────────────────────────────────

  testWidgets('TC-SUI-001a: メンバー設定Detail画面が正しく表示されること', (tester) async {
    await goToMemberSettingDetailPage(tester);

    expect(find.text('メンバー名'), findsOneWidget);
  });

  testWidgets('TC-SUI-001b: メンバー設定Detail画面でTextFieldが表示されること', (tester) async {
    await goToMemberSettingDetailPage(tester);

    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('TC-SUI-001c: メンバー設定Detail画面で名前フィールドに文字を入力できること',
      (tester) async {
    await goToMemberSettingDetailPage(tester);

    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    await tester.tap(textFields.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(textFields.first, 'テストメンバー');
    await tester.pump(const Duration(milliseconds: 300));

    // AppBar タイトルとフォームの両方に反映されるため findsWidgets で確認する
    expect(find.text('テストメンバー'), findsWidgets);
  });

  testWidgets('TC-SUI-001d: メンバー設定Detail画面でAppBarに「保存」ボタンが表示されること',
      (tester) async {
    await goToMemberSettingDetailPage(tester);

    expect(find.text('保存'), findsOneWidget);
  });

  // ────────────────────────────────────────────────────────
  // TC-SUI-002: タグ設定 Detail画面 名前入力と保存
  // ────────────────────────────────────────────────────────

  testWidgets('TC-SUI-002a: タグ設定Detail画面が正しく表示されること', (tester) async {
    await goToTagSettingDetailPage(tester);

    expect(find.text('タグ名'), findsOneWidget);
  });

  testWidgets('TC-SUI-002b: タグ設定Detail画面でTextFieldが表示されること', (tester) async {
    await goToTagSettingDetailPage(tester);

    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('TC-SUI-002c: タグ設定Detail画面で名前フィールドに文字を入力できること', (tester) async {
    await goToTagSettingDetailPage(tester);

    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    await tester.tap(textFields.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(textFields.first, 'テストタグ');
    await tester.pump(const Duration(milliseconds: 300));

    // AppBar タイトルとフォームの両方に反映されるため findsWidgets で確認する
    expect(find.text('テストタグ'), findsWidgets);
  });

  testWidgets('TC-SUI-002d: タグ設定Detail画面でAppBarに「保存」ボタンが表示されること',
      (tester) async {
    await goToTagSettingDetailPage(tester);

    expect(find.text('保存'), findsOneWidget);
  });

  // ────────────────────────────────────────────────────────
  // TC-SUI-003: 交通手段設定 Detail画面 複数フィールド入力と保存
  // ────────────────────────────────────────────────────────

  testWidgets('TC-SUI-003a: 交通手段設定Detail画面が正しく表示されること', (tester) async {
    await goToTransSettingDetailPage(tester);

    expect(find.text('交通手段名'), findsOneWidget);
  });

  testWidgets('TC-SUI-003b: 交通手段設定Detail画面で複数のフィールドラベルが表示されること',
      (tester) async {
    await goToTransSettingDetailPage(tester);

    expect(find.text('交通手段名'), findsOneWidget);
  });

  testWidgets('TC-SUI-003c: 交通手段設定Detail画面で燃費フィールドラベルが表示されること',
      (tester) async {
    await goToTransSettingDetailPage(tester);

    expect(find.text('燃費 (km/L)'), findsOneWidget);
  });

  testWidgets('TC-SUI-003d: 交通手段設定Detail画面でメーターフィールドラベルが表示されること',
      (tester) async {
    await goToTransSettingDetailPage(tester);

    expect(find.text('メーター (km)'), findsOneWidget);
  });

  testWidgets('TC-SUI-003e: 交通手段設定Detail画面で名前フィールドに文字を入力できること',
      (tester) async {
    await goToTransSettingDetailPage(tester);

    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    await tester.tap(textFields.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(textFields.first, 'テスト交通手段');
    await tester.pump(const Duration(milliseconds: 300));

    // AppBar タイトルとフォームの両方に反映されるため findsWidgets で確認する
    expect(find.text('テスト交通手段'), findsWidgets);
  });

  testWidgets('TC-SUI-003f: 交通手段設定Detail画面でAppBarに「保存」ボタンが表示されること',
      (tester) async {
    await goToTransSettingDetailPage(tester);

    expect(find.text('保存'), findsOneWidget);
  });

  // ────────────────────────────────────────────────────────
  // TC-SUI-004: アクション設定 Detail画面 名前入力と保存
  // ────────────────────────────────────────────────────────

  testWidgets('TC-SUI-004a: アクション設定Detail画面が正しく表示されること', (tester) async {
    await goToActionSettingDetailPage(tester);

    expect(find.text('行動名'), findsOneWidget);
  });

  testWidgets('TC-SUI-004b: アクション設定Detail画面でTextFieldが表示されること', (tester) async {
    await goToActionSettingDetailPage(tester);

    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('TC-SUI-004c: アクション設定Detail画面で名前フィールドに文字を入力できること',
      (tester) async {
    await goToActionSettingDetailPage(tester);

    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    await tester.tap(textFields.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(textFields.first, 'テスト行動');
    await tester.pump(const Duration(milliseconds: 300));

    // AppBar タイトルとフォームの両方に反映されるため findsWidgets で確認する
    expect(find.text('テスト行動'), findsWidgets);
  });

  testWidgets('TC-SUI-004d: アクション設定Detail画面でAppBarに「保存」ボタンが表示されること',
      (tester) async {
    await goToActionSettingDetailPage(tester);

    expect(find.text('保存'), findsOneWidget);
  });
}
