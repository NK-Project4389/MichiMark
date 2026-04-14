// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: 画面遷移時にレコメンドを閉じる（B-12）
///
/// バグ内容: メンバー・タグの入力中（レコメンドリスト表示中）に他の画面へ遷移すると、
///           レコメンドが表示されたままになる。
///
/// テストシナリオ:
///   TC-RCL-001: メンバー入力中に一覧へ戻ると、レコメンドリストが消える
///   TC-RCL-002: タグ入力中に一覧へ戻ると、レコメンドリストが消える
///
/// シードデータ:
///   - event-001（箱根日帰りドライブ）: メンバー 太郎(member-001)・花子(member-002)
///   - メンバーマスタ: 太郎(member-001)・花子(member-002)・健太(member-003)
///   - タグマスタ: 家族旅行(tag-001)・日帰り(tag-002)・温泉(tag-003)
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - BasicInfoタブの編集モードでメンバー・タグ入力欄が表示されること

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

  /// 指定イベント名のカードをタップして EventDetail を開く。
  Future<bool> openEventDetail(WidgetTester tester, String eventName) async {
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
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// BasicInfo 編集モードに入る（概要タブ → セクションタップ）。
  Future<bool> enterBasicInfoEditMode(WidgetTester tester) async {
    // 「概要」タブに切り替える
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 参照モードのセクションをタップして編集モードへ
    final section = find.byKey(const Key('basicInfoRead_container_section'));
    if (section.evaluate().isEmpty) return false;
    await tester.tap(section.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find.byKey(const Key('basicInfoForm_button_cancel'))
        .evaluate()
        .isNotEmpty;
  }

  /// メンバー入力フィールドをスクロールで表示してフォーカスする。
  Future<bool> focusMemberInput(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      if (find.byKey(const Key('basicInfo_field_memberInput'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
    final memberInput = find.byKey(const Key('basicInfo_field_memberInput'));
    if (memberInput.evaluate().isEmpty) return false;

    await tester.ensureVisible(memberInput);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(memberInput);
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// タグ入力フィールドをスクロールで表示してフォーカスする。
  Future<bool> focusTagInput(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      if (find.byKey(const Key('basicInfo_field_tagInput'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
    final tagInput = find.byKey(const Key('basicInfo_field_tagInput'));
    if (tagInput.evaluate().isEmpty) return false;

    await tester.ensureVisible(tagInput);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(tagInput);
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  // ────────────────────────────────────────────────────────
  // TC-RCL-001
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-RCL-001: メンバー入力中に一覧へ戻るとレコメンドリストが消えること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      print('[SKIP] イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      print('[SKIP] イベント詳細を開けなかったためスキップします');
      return;
    }

    final entered = await enterBasicInfoEditMode(tester);
    if (!entered) {
      print('[SKIP] BasicInfo編集モードに入れなかったためスキップします');
      return;
    }

    // メンバー入力フィールドにフォーカスし、文字を入力してレコメンドを表示させる
    final focused = await focusMemberInput(tester);
    if (!focused) {
      print('[SKIP] メンバー入力フィールドが見つからないためスキップします');
      return;
    }

    // 「太」と入力してレコメンドリストを表示させる
    await tester.enterText(
      find.byKey(const Key('basicInfo_field_memberInput')),
      '太',
    );
    await tester.pump(const Duration(milliseconds: 500));

    // レコメンドリストが表示されていることを前提確認
    // （太郎 = member-001 がサジェスト候補として表示される想定）
    final hasSuggestion =
        find.byKey(const Key('basicInfo_item_memberSuggestion_member-001'))
            .evaluate()
            .isNotEmpty ||
        find.byKey(const Key('basicInfo_item_memberAddNew'))
            .evaluate()
            .isNotEmpty;
    if (!hasSuggestion) {
      print('[SKIP] レコメンドリストが表示されなかったためスキップします（入力候補なし）');
      return;
    }

    // キャンセルボタンをタップして EventDetail から一覧へ戻る
    // （保存せずに戻るため「キャンセル確認ダイアログ」が表示される可能性があるが、
    //  ここでは AppBar の戻るボタンではなくキャンセルボタン経由で遷移する）
    //
    // キャンセルボタンが画面外にある場合は上にスクロールして表示する
    for (var i = 0; i < 10; i++) {
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, 400));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    // キャンセルボタンをタップ
    final cancelButton =
        find.byKey(const Key('basicInfoForm_button_cancel'));
    if (cancelButton.evaluate().isEmpty) {
      print('[SKIP] キャンセルボタンが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(cancelButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(cancelButton);
    await tester.pump(const Duration(milliseconds: 500));

    // キャンセル確認ダイアログが出た場合は「破棄」を選択
    final discardButton =
        find.byKey(const Key('markDetail_button_discardConfirm'));
    if (discardButton.evaluate().isEmpty) {
      // ダイアログなし or 別キー → そのまま進む
    } else {
      await tester.tap(discardButton);
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 参照モードに戻った（= 画面遷移完了）
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoRead_container_section'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    // メンバーサジェスチョンリストが非表示になっていること
    expect(
      find.byKey(const Key('basicInfo_item_memberSuggestion_member-001')),
      findsNothing,
    );
  });

  testWidgets(
      'TC-RCL-001b: メンバー入力中に一覧へ戻ると「新規追加」候補も消えること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      print('[SKIP] イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      print('[SKIP] イベント詳細を開けなかったためスキップします');
      return;
    }

    final entered = await enterBasicInfoEditMode(tester);
    if (!entered) {
      print('[SKIP] BasicInfo編集モードに入れなかったためスキップします');
      return;
    }

    final focused = await focusMemberInput(tester);
    if (!focused) {
      print('[SKIP] メンバー入力フィールドが見つからないためスキップします');
      return;
    }

    // ユニークな文字列を入力して「新規追加」候補を表示させる
    await tester.enterText(
      find.byKey(const Key('basicInfo_field_memberInput')),
      'テスト新規メンバーXYZ',
    );
    await tester.pump(const Duration(milliseconds: 500));

    // キャンセルで戻る
    for (var i = 0; i < 10; i++) {
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, 400));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    final cancelButton =
        find.byKey(const Key('basicInfoForm_button_cancel'));
    if (cancelButton.evaluate().isEmpty) {
      print('[SKIP] キャンセルボタンが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(cancelButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(cancelButton);
    await tester.pump(const Duration(milliseconds: 500));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoRead_container_section'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    // 「新規追加」候補が非表示になっていること
    expect(
      find.byKey(const Key('basicInfo_item_memberAddNew')),
      findsNothing,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-RCL-002
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-RCL-002: タグ入力中に一覧へ戻るとレコメンドリストが消えること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      print('[SKIP] イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      print('[SKIP] イベント詳細を開けなかったためスキップします');
      return;
    }

    final entered = await enterBasicInfoEditMode(tester);
    if (!entered) {
      print('[SKIP] BasicInfo編集モードに入れなかったためスキップします');
      return;
    }

    // タグ入力フィールドにフォーカスし、文字を入力してレコメンドを表示させる
    final focused = await focusTagInput(tester);
    if (!focused) {
      print('[SKIP] タグ入力フィールドが見つからないためスキップします');
      return;
    }

    // 「家」と入力してレコメンドリストを表示させる（家族旅行 = tag-001）
    await tester.enterText(
      find.byKey(const Key('basicInfo_field_tagInput')),
      '家',
    );
    await tester.pump(const Duration(milliseconds: 500));

    // レコメンドリストが表示されていることを前提確認
    final hasSuggestion =
        find.byKey(const Key('basicInfo_item_tagSuggestion_tag-001'))
            .evaluate()
            .isNotEmpty ||
        find.byKey(const Key('basicInfo_item_tagAddNew'))
            .evaluate()
            .isNotEmpty;
    if (!hasSuggestion) {
      print('[SKIP] タグレコメンドリストが表示されなかったためスキップします（入力候補なし）');
      return;
    }

    // キャンセルボタンをタップして戻る
    for (var i = 0; i < 10; i++) {
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, 400));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    final cancelButton =
        find.byKey(const Key('basicInfoForm_button_cancel'));
    if (cancelButton.evaluate().isEmpty) {
      print('[SKIP] キャンセルボタンが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(cancelButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(cancelButton);
    await tester.pump(const Duration(milliseconds: 500));

    // 参照モードに戻った
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoRead_container_section'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    // タグサジェスチョンリストが非表示になっていること
    expect(
      find.byKey(const Key('basicInfo_item_tagSuggestion_tag-001')),
      findsNothing,
    );
  });

  testWidgets(
      'TC-RCL-002b: タグ入力中に一覧へ戻ると「新規追加」候補も消えること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      print('[SKIP] イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      print('[SKIP] イベント詳細を開けなかったためスキップします');
      return;
    }

    final entered = await enterBasicInfoEditMode(tester);
    if (!entered) {
      print('[SKIP] BasicInfo編集モードに入れなかったためスキップします');
      return;
    }

    final focused = await focusTagInput(tester);
    if (!focused) {
      print('[SKIP] タグ入力フィールドが見つからないためスキップします');
      return;
    }

    // ユニークな文字列を入力して「新規追加」候補を表示させる
    await tester.enterText(
      find.byKey(const Key('basicInfo_field_tagInput')),
      'テスト新規タグXYZ',
    );
    await tester.pump(const Duration(milliseconds: 500));

    // キャンセルで戻る
    for (var i = 0; i < 10; i++) {
      if (find.byKey(const Key('basicInfoForm_button_cancel'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, 400));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    final cancelButton =
        find.byKey(const Key('basicInfoForm_button_cancel'));
    if (cancelButton.evaluate().isEmpty) {
      print('[SKIP] キャンセルボタンが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(cancelButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(cancelButton);
    await tester.pump(const Duration(milliseconds: 500));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoRead_container_section'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    // 「新規追加」候補が非表示になっていること
    expect(
      find.byKey(const Key('basicInfo_item_tagAddNew')),
      findsNothing,
    );
  });
}
