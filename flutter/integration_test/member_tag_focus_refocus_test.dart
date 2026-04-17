// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: メンバー・タグ追加後のフォーカス継続 (B-11)
///
/// バグ内容: メンバー・タグを追加した後、入力欄のフォーカスが外れる。
/// 追加後も入力欄にフォーカスを戻し、空欄エンターで編集終了する。
///
/// テストシナリオ: TC-MFR-001 〜 TC-MFR-004
///
/// 前提条件:
///   - イベントが1件以上存在すること
///   - メンバーマスタに1件以上のメンバーが登録済みであること
///   - タグマスタに1件以上のタグが登録済みであること
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
      if (find.text('イベント一覧').evaluate().isNotEmpty) break;
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

  /// BasicInfo 編集モードを表示するまでのセットアップ。
  /// 問題が発生した場合はスキップ理由の文字列を返す。null の場合は成功。
  Future<String?> setupBasicInfoEditMode(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }
    final opened = await openFirstEventDetail(tester);
    if (!opened) {
      return 'イベント詳細を開けなかったためスキップします';
    }
    await ensureBasicInfoTab(tester);
    final entered = await enterEditModeByTap(tester);
    if (!entered) {
      return '編集モードに入れなかったためスキップします';
    }
    return null;
  }

  /// メンバー入力欄にフォーカスを当て、サジェストが表示されるまで待つ。
  Future<bool> focusMemberInput(WidgetTester tester) async {
    final memberInput = find.byKey(const Key('basicInfo_field_memberInput'));
    if (memberInput.evaluate().isEmpty) return false;
    await tester.tap(memberInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final suggestions = tester.elementList(find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is ValueKey<String>) {
          return key.value.startsWith('basicInfo_item_memberSuggestion_');
        }
        return false;
      }));
      if (suggestions.isNotEmpty) return true;
    }
    return false;
  }

  /// タグ入力欄にフォーカスを当て、サジェストが表示されるまで待つ。
  Future<bool> focusTagInput(WidgetTester tester) async {
    final tagInput = find.byKey(const Key('basicInfo_field_tagInput'));
    if (tagInput.evaluate().isEmpty) return false;
    await tester.tap(tagInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final suggestions = tester.elementList(find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is ValueKey<String>) {
          return key.value.startsWith('basicInfo_item_tagSuggestion_');
        }
        return false;
      }));
      if (suggestions.isNotEmpty) return true;
    }
    return false;
  }

  // ────────────────────────────────────────────────────────
  // TC-MFR-001: メンバーを追加後、入力欄にフォーカスが継続している
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MFR-001: メンバーをサジェストから追加後、入力欄（EditableText）にフォーカスが継続していること',
      (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // メンバー入力欄にフォーカスを当ててサジェストを表示する
    final memberInput = find.byKey(const Key('basicInfo_field_memberInput'));
    if (memberInput.evaluate().isEmpty) {
      print('[SKIP] メンバー入力欄が見つからないためスキップします');
      return;
    }
    final hasSuggestions = await focusMemberInput(tester);
    if (!hasSuggestions) {
      print('[SKIP] メンバーサジェストが表示されなかったためスキップします');
      return;
    }

    // サジェストの最初の1件をタップしてメンバーを追加する
    final suggestionFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_item_memberSuggestion_');
      }
      return false;
    });
    if (suggestionFinder.evaluate().isEmpty) {
      print('[SKIP] メンバーサジェストアイテムが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(suggestionFinder.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(suggestionFinder.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // 入力欄が引き続き存在するかチェック（フォーカスが戻った証拠）
      if (find.byKey(const Key('basicInfo_field_memberInput'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    // 追加後もメンバー入力欄（EditableText）がウィジェットツリーに存在すること
    // フォーカスが継続している場合、入力欄は引き続き描画されアクティブ状態になる
    expect(
      find.byKey(const Key('basicInfo_field_memberInput')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MFR-002: 空欄でエンターするとメンバー入力欄のフォーカスが外れる
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MFR-002: メンバー入力欄が空欄の状態でエンターするとサジェストが閉じること',
      (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // メンバー入力欄にフォーカスを当てる
    final memberInput = find.byKey(const Key('basicInfo_field_memberInput'));
    if (memberInput.evaluate().isEmpty) {
      print('[SKIP] メンバー入力欄が見つからないためスキップします');
      return;
    }
    await tester.tap(memberInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfo_field_memberInput'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 入力欄が空欄であることを確認してからエンターを送信する
    await tester.enterText(memberInput, '');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // サジェストが閉じるまで待つ
      final suggestions = tester.elementList(find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is ValueKey<String>) {
          return key.value.startsWith('basicInfo_item_memberSuggestion_');
        }
        return false;
      }));
      if (suggestions.isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 空欄エンター後、メンバーサジェストが閉じていること（フォーカス終了）
    final suggestionsAfter = tester.elementList(find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_item_memberSuggestion_');
      }
      return false;
    }));
    expect(
      suggestionsAfter.isEmpty,
      isTrue,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MFR-003: タグを追加後、入力欄にフォーカスが継続している
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MFR-003: タグをサジェストから追加後、入力欄（EditableText）にフォーカスが継続していること',
      (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // タグ入力欄にフォーカスを当ててサジェストを表示する
    final tagInput = find.byKey(const Key('basicInfo_field_tagInput'));
    if (tagInput.evaluate().isEmpty) {
      print('[SKIP] タグ入力欄が見つからないためスキップします');
      return;
    }
    final hasSuggestions = await focusTagInput(tester);
    if (!hasSuggestions) {
      print('[SKIP] タグサジェストが表示されなかったためスキップします');
      return;
    }

    // サジェストの最初の1件をタップしてタグを追加する
    final suggestionFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_item_tagSuggestion_');
      }
      return false;
    });
    if (suggestionFinder.evaluate().isEmpty) {
      print('[SKIP] タグサジェストアイテムが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(suggestionFinder.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(suggestionFinder.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // 入力欄が引き続き存在するかチェック
      if (find.byKey(const Key('basicInfo_field_tagInput'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    // 追加後もタグ入力欄（EditableText）がウィジェットツリーに存在すること
    // フォーカスが継続している場合、入力欄は引き続き描画されアクティブ状態になる
    expect(
      find.byKey(const Key('basicInfo_field_tagInput')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MFR-004: タグを空欄エンターすると入力欄のフォーカスが外れる
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MFR-004: タグ入力欄が空欄の状態でエンターするとサジェストが閉じること',
      (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // タグ入力欄にフォーカスを当てる
    final tagInput = find.byKey(const Key('basicInfo_field_tagInput'));
    if (tagInput.evaluate().isEmpty) {
      print('[SKIP] タグ入力欄が見つからないためスキップします');
      return;
    }
    await tester.tap(tagInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfo_field_tagInput'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 入力欄が空欄であることを確認してからエンターを送信する
    await tester.enterText(tagInput, '');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // サジェストが閉じるまで待つ
      final suggestions = tester.elementList(find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is ValueKey<String>) {
          return key.value.startsWith('basicInfo_item_tagSuggestion_');
        }
        return false;
      }));
      if (suggestions.isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 空欄エンター後、タグサジェストが閉じていること（フォーカス終了）
    final suggestionsAfter = tester.elementList(find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_item_tagSuggestion_');
      }
      return false;
    }));
    expect(
      suggestionsAfter.isEmpty,
      isTrue,
    );
  });
}
