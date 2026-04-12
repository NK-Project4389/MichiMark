// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: BasicInfo 参照/編集モード切替UI
///
/// Spec: docs/Spec/Features/FS-basic_info_tap_to_edit.md §16
///
/// テストシナリオ: TC-BTE-001 〜 TC-BTE-007
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - テスト用イベントが1件以上存在すること
///   - BasicInfoタブが表示された状態からテストを開始すること

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
          find.text('イベントがありません').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// イベント一覧から最初のイベントをタップして EventDetail を開く。
  Future<bool> openFirstEventDetail(WidgetTester tester) async {
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;
    final cards = find.byType(GestureDetector);
    if (cards.evaluate().isEmpty) return false;
    await tester.tap(cards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // 新UIでは編集アイコンがないため BasicInfoRead セクションの存在で判定
      if (find.byKey(const Key('basicInfoRead_container_section'))
              .evaluate()
              .isNotEmpty ||
          find.text('タップして編集').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// BasicInfo タブを「概要」タブ経由で表示する。
  Future<void> ensureBasicInfoTab(WidgetTester tester) async {
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  /// 参照モードのセクションをタップして編集モードに入る。
  Future<bool> enterEditModeByTap(WidgetTester tester) async {
    final section = find.byKey(const Key('basicInfoRead_container_section'));
    if (section.evaluate().isEmpty) return false;
    await tester.tap(section.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// BasicInfo 参照モードを表示するまでのセットアップ。
  /// イベントがない場合はスキップ理由を返す。null の場合は成功。
  Future<String?> setupBasicInfoReadMode(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }
    final opened = await openFirstEventDetail(tester);
    if (!opened) {
      return 'イベント詳細を開けなかったためスキップします';
    }
    await ensureBasicInfoTab(tester);
    return null;
  }

  /// BasicInfo 編集モードを表示するまでのセットアップ。
  Future<String?> setupBasicInfoEditMode(WidgetTester tester) async {
    final skipReason = await setupBasicInfoReadMode(tester);
    if (skipReason != null) return skipReason;
    final entered = await enterEditModeByTap(tester);
    if (!entered) {
      return '編集モードに入れなかったためスキップします';
    }
    return null;
  }

  // ────────────────────────────────────────────────────────
  // TC-BTE-001〜007
  // ────────────────────────────────────────────────────────

  testWidgets('TC-BTE-001: BasicInfoセクションに編集アイコンが表示されないこと',
      (tester) async {
    final skipReason = await setupBasicInfoReadMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    expect(find.byIcon(Icons.edit), findsNothing);
  });

  testWidgets('TC-BTE-002: 参照モード時にTeal薄背景コンテナが表示されること', (tester) async {
    final skipReason = await setupBasicInfoReadMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    expect(
      find.byKey(const Key('basicInfoRead_container_section')),
      findsOneWidget,
    );
  });

  testWidgets('TC-BTE-003: 参照モード時に「タップして編集」テキストが表示されること', (tester) async {
    final skipReason = await setupBasicInfoReadMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    expect(
      find.byKey(const Key('basicInfoRead_text_tapHint')),
      findsOneWidget,
    );
  });

  testWidgets('TC-BTE-004: 参照モードのセクションをタップすると編集モードに切り替わること',
      (tester) async {
    final skipReason = await setupBasicInfoReadMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // タップ前: 参照モードが表示されている
    expect(
      find.byKey(const Key('basicInfoRead_container_section')),
      findsOneWidget,
    );

    // セクション全体をタップして編集モードに切り替え
    await tester.tap(
        find.byKey(const Key('basicInfoRead_container_section')).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 参照モードのビューが非表示になる
    expect(
      find.byKey(const Key('basicInfoRead_container_section')),
      findsNothing,
    );
  });

  testWidgets('TC-BTE-004b: 編集モード切替後に「タップして編集」テキストが非表示になること',
      (tester) async {
    final skipReason = await setupBasicInfoReadMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    await tester.tap(
        find.byKey(const Key('basicInfoRead_container_section')).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('basicInfoRead_text_tapHint')),
      findsNothing,
    );
  });

  testWidgets('TC-BTE-004c: 編集モード切替後にキャンセルボタンが表示されること', (tester) async {
    final skipReason = await setupBasicInfoReadMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    await tester.tap(
        find.byKey(const Key('basicInfoRead_container_section')).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('basicInfoForm_button_cancel')),
      findsOneWidget,
    );
  });

  testWidgets('TC-BTE-004d: 編集モード切替後に保存ボタンが表示されること', (tester) async {
    final skipReason = await setupBasicInfoReadMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    await tester.tap(
        find.byKey(const Key('basicInfoRead_container_section')).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoForm_button_save'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('basicInfoForm_button_save')),
      findsOneWidget,
    );
  });

  testWidgets('TC-BTE-005: 編集モード時にフォーム下部にキャンセルボタンが表示されること',
      (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // フォーム下部にスクロールして確認
    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    expect(
      find.byKey(const Key('basicInfoForm_button_cancel')),
      findsOneWidget,
    );
  });

  testWidgets('TC-BTE-005b: 編集モード時にフォーム下部に保存ボタンが表示されること', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('basicInfoForm_button_save'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    expect(
      find.byKey(const Key('basicInfoForm_button_save')),
      findsOneWidget,
    );
  });

  testWidgets('TC-BTE-006: キャンセルボタンをタップすると参照モードに戻ること', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // イベント名フィールドを変更する（TextField を探して入力）
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      await tester.tap(textFields.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(textFields.first, 'キャンセルテスト用入力');
      await tester.pump(const Duration(milliseconds: 300));
    }

    // キャンセルボタンをタップ
    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    await tester.ensureVisible(
        find.byKey(const Key('basicInfoForm_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('basicInfoForm_button_cancel')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoRead_container_section'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 参照モードに戻っていること
    expect(
      find.byKey(const Key('basicInfoRead_container_section')),
      findsOneWidget,
    );
  });

  testWidgets('TC-BTE-006b: キャンセル後に「タップして編集」テキストが表示されること', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    await tester.ensureVisible(
        find.byKey(const Key('basicInfoForm_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('basicInfoForm_button_cancel')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoRead_text_tapHint'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('basicInfoRead_text_tapHint')),
      findsOneWidget,
    );
  });

  testWidgets('TC-BTE-007: 保存ボタンをタップすると保存されて参照モードに戻ること', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // イベント名フィールドに「テスト保存イベント」と入力する
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      await tester.tap(textFields.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(textFields.first, 'テスト保存イベント');
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 保存ボタンをタップ
    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('basicInfoForm_button_save'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    await tester
        .ensureVisible(find.byKey(const Key('basicInfoForm_button_save')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('basicInfoForm_button_save')));

    // 保存処理完了まで最大5秒待機
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('basicInfoRead_container_section'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 参照モードに戻っていること
    expect(
      find.byKey(const Key('basicInfoRead_container_section')),
      findsOneWidget,
    );
  });

  testWidgets('TC-BTE-007b: 保存後に「タップして編集」テキストが表示されること', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('basicInfoForm_button_save'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    await tester
        .ensureVisible(find.byKey(const Key('basicInfoForm_button_save')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('basicInfoForm_button_save')));

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('basicInfoRead_text_tapHint'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('basicInfoRead_text_tapHint')),
      findsOneWidget,
    );
  });

  testWidgets('TC-BTE-007c: 保存後に入力したイベント名が参照モードに反映されること', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    const savedEventName = 'テスト保存イベント';
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      await tester.tap(textFields.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(textFields.first, savedEventName);
      await tester.pump(const Duration(milliseconds: 300));
    }

    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('basicInfoForm_button_save'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    await tester
        .ensureVisible(find.byKey(const Key('basicInfoForm_button_save')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('basicInfoForm_button_save')));

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('basicInfoRead_container_section'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // AppBar にも同名テキストが表示されるため、BasicInfo コンテナ内で確認
    expect(
      find.descendant(
        of: find.byKey(const Key('basicInfoRead_container_section')),
        matching: find.text(savedEventName),
      ),
      findsWidgets,
    );
  });
}
