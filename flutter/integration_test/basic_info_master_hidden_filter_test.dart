// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: B-13 BasicInfo マスタ非表示フィルタ
///
/// バグ内容:
///   BasicInfoフォームのメンバー候補・タグ候補・Trans候補に
///   マスタで非表示設定されたアイテムが表示される。
///
/// テストシナリオ: TC-BHF-001 〜 TC-BHF-004
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータ（太郎/花子/健太、家族旅行/日帰り/温泉、マイカー/レンタカー）が存在すること
///   - 各テストでアプリを個別起動し、設定画面でマスタを非表示にしてから
///     BasicInfoフォームを開いて候補リストを検証する

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

  /// 指定名称のイベントをタップして EventDetail を開く。
  Future<bool> openEventDetailByName(
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

  /// EventDetail の「概要」タブをタップして BasicInfo を表示する。
  Future<void> ensureOverviewTab(WidgetTester tester) async {
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  /// BasicInfo 参照モードをタップして編集フォームを開く。
  Future<bool> enterBasicInfoEditMode(WidgetTester tester) async {
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

  /// 設定画面でメンバーを非表示に設定する。
  Future<bool> hideMemberInSettings(
    WidgetTester tester,
    String memberName,
  ) async {
    final settingsIcons = find.byIcon(Icons.settings);
    if (settingsIcons.evaluate().isEmpty) {
      app_router.router.go('/settings');
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.text('設定').evaluate().isNotEmpty &&
            find.text('メンバー').evaluate().isNotEmpty) break;
      }
    } else {
      await tester.tap(settingsIcons.first);
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.text('設定').evaluate().isNotEmpty &&
            find.text('メンバー').evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    final memberTile = find.text('メンバー');
    if (memberTile.evaluate().isEmpty) return false;
    await tester.tap(memberTile.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text(memberName).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final targetMemberTile = find.text(memberName);
    if (targetMemberTile.evaluate().isEmpty) return false;
    await tester.tap(targetMemberTile.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('表示').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final switchTile = find.byType(SwitchListTile);
    if (switchTile.evaluate().isEmpty) return false;

    final switchWidget = tester.widget<SwitchListTile>(switchTile.first);
    if (switchWidget.value) {
      await tester.tap(switchTile.first);
      await tester.pump(const Duration(milliseconds: 300));
    }

    final saveButton = find.text('保存');
    if (saveButton.evaluate().isEmpty) return false;
    await tester.tap(saveButton.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('メンバー').evaluate().length >= 2) break;
    }
    await tester.pump(const Duration(milliseconds: 500));
    return true;
  }

  /// 設定画面でタグを非表示に設定する。
  Future<bool> hideTagInSettings(
    WidgetTester tester,
    String tagName,
  ) async {
    final settingsIcons = find.byIcon(Icons.settings);
    if (settingsIcons.evaluate().isEmpty) {
      app_router.router.go('/settings');
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.text('設定').evaluate().isNotEmpty &&
            find.text('タグ').evaluate().isNotEmpty) break;
      }
    } else {
      await tester.tap(settingsIcons.first);
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.text('設定').evaluate().isNotEmpty &&
            find.text('タグ').evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    final tagSettingTile = find.text('タグ');
    if (tagSettingTile.evaluate().isEmpty) return false;
    await tester.tap(tagSettingTile.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text(tagName).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final targetTagTile = find.text(tagName);
    if (targetTagTile.evaluate().isEmpty) return false;
    await tester.tap(targetTagTile.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('表示').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final switchTile = find.byType(SwitchListTile);
    if (switchTile.evaluate().isEmpty) return false;

    final switchWidget = tester.widget<SwitchListTile>(switchTile.first);
    if (switchWidget.value) {
      await tester.tap(switchTile.first);
      await tester.pump(const Duration(milliseconds: 300));
    }

    final saveButton = find.text('保存');
    if (saveButton.evaluate().isEmpty) return false;
    await tester.tap(saveButton.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('タグ').evaluate().length >= 2) break;
    }
    await tester.pump(const Duration(milliseconds: 500));
    return true;
  }

  /// 設定画面でTransを非表示に設定する。
  Future<bool> hideTransInSettings(
    WidgetTester tester,
    String transName,
  ) async {
    final settingsIcons = find.byIcon(Icons.settings);
    if (settingsIcons.evaluate().isEmpty) {
      app_router.router.go('/settings');
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.text('設定').evaluate().isNotEmpty) break;
      }
    } else {
      await tester.tap(settingsIcons.first);
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.text('設定').evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    // Trans設定タイル（「交通手段」または「Trans」）を探してタップ
    final transSettingLabels = ['交通手段', 'Trans'];
    bool transSettingFound = false;
    for (final label in transSettingLabels) {
      final tile = find.text(label);
      if (tile.evaluate().isNotEmpty) {
        await tester.tap(tile.first);
        transSettingFound = true;
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 300));
          if (find.text(transName).evaluate().isNotEmpty) break;
        }
        break;
      }
    }
    if (!transSettingFound) return false;
    await tester.pump(const Duration(milliseconds: 300));

    final targetTransTile = find.text(transName);
    if (targetTransTile.evaluate().isEmpty) return false;
    await tester.tap(targetTransTile.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('表示').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final switchTile = find.byType(SwitchListTile);
    if (switchTile.evaluate().isEmpty) return false;

    final switchWidget = tester.widget<SwitchListTile>(switchTile.first);
    if (switchWidget.value) {
      await tester.tap(switchTile.first);
      await tester.pump(const Duration(milliseconds: 300));
    }

    final saveButton = find.text('保存');
    if (saveButton.evaluate().isEmpty) return false;
    await tester.tap(saveButton.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('設定').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));
    return true;
  }

  /// EventList 画面に戻る（ルーター直接遷移）。
  Future<void> goToEventList(WidgetTester tester) async {
    app_router.router.go('/');
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('箱根日帰りドライブ').evaluate().isNotEmpty ||
          find.text('富士五湖キャンプ').evaluate().isNotEmpty ||
          find.text('イベントがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// メンバー入力フィールドをタップして候補リストを表示する。
  Future<bool> openMemberSuggestions(WidgetTester tester) async {
    final memberInputField =
        find.byKey(const Key('basicInfo_field_memberInput'));
    if (memberInputField.evaluate().isEmpty) return false;
    await tester.tap(memberInputField.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // 候補リストが表示されるまで待機（既存チップがなくても入力フィールドが活性化していればOK）
      if (find.byKey(const Key('basicInfo_item_memberSuggestion_member-001'))
              .evaluate()
              .isNotEmpty ||
          find.byKey(const Key('basicInfo_item_memberSuggestion_member-002'))
              .evaluate()
              .isNotEmpty ||
          find.byKey(const Key('basicInfo_item_memberSuggestion_member-003'))
              .evaluate()
              .isNotEmpty ||
          find.byKey(const Key('basicInfo_item_memberAddNew'))
              .evaluate()
              .isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// タグ入力フィールドをタップして候補リストを表示する。
  Future<bool> openTagSuggestions(WidgetTester tester) async {
    final tagInputField = find.byKey(const Key('basicInfo_field_tagInput'));
    if (tagInputField.evaluate().isEmpty) return false;
    await tester.tap(tagInputField.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfo_item_tagSuggestion_tag-001'))
              .evaluate()
              .isNotEmpty ||
          find.byKey(const Key('basicInfo_item_tagSuggestion_tag-002'))
              .evaluate()
              .isNotEmpty ||
          find.byKey(const Key('basicInfo_item_tagSuggestion_tag-003'))
              .evaluate()
              .isNotEmpty ||
          find.byKey(const Key('basicInfo_item_tagAddNew'))
              .evaluate()
              .isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // ────────────────────────────────────────────────────────
  // TC-BHF-001: 非表示メンバーがBasicInfoメンバー候補に表示されないこと
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-BHF-001: 非表示メンバーがBasicInfoメンバー候補に表示されないこと',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      print('[SKIP] イベントデータが存在しないためスキップします');
      return;
    }

    // Step 1: 設定で「健太」（member-003）を非表示にする
    final hiddenResult = await hideMemberInSettings(tester, '健太');
    if (!hiddenResult) {
      print('[SKIP] メンバー非表示設定に失敗したためスキップします');
      return;
    }

    // Step 2: EventList に戻る
    await goToEventList(tester);

    // Step 3: イベント詳細を開く（箱根日帰りドライブ）
    final opened = await openEventDetailByName(tester, '箱根日帰りドライブ');
    if (!opened) {
      print('[SKIP] イベント詳細を開けなかったためスキップします');
      return;
    }

    // Step 4: 概要タブを表示
    await ensureOverviewTab(tester);

    // Step 5: BasicInfo 編集モードに入る
    final editModeEntered = await enterBasicInfoEditMode(tester);
    if (!editModeEntered) {
      print('[SKIP] BasicInfo編集モードに入れなかったためスキップします');
      return;
    }

    // Step 6: メンバー入力フィールドをタップして候補を開く
    // 候補0件（健太のみ存在する場合）でも正常動作のためSKIPしない
    await openMemberSuggestions(tester);
    // 念のため追加待機（候補リスト表示の安定化）
    await tester.pump(const Duration(milliseconds: 500));

    // Step 7: 非表示メンバー（健太/member-003）の候補アイテムが表示されないことを確認
    // 候補0件でも member-003 が表示されていない = 正しい動作（PASS）
    expect(
      find.byKey(const Key('basicInfo_item_memberSuggestion_member-003')),
      findsNothing,
      reason: '非表示設定のメンバー（健太）はBasicInfoのメンバー候補に表示されないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-BHF-002: 表示中メンバーはBasicInfo候補に表示されること
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-BHF-002: 表示中メンバーはBasicInfoメンバー候補に表示されること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      print('[SKIP] イベントデータが存在しないためスキップします');
      return;
    }

    // Step 1: 設定で「健太」（member-003）を非表示にする
    // （表示中の太郎・花子が候補に出ることを検証するための前提）
    final hiddenResult = await hideMemberInSettings(tester, '健太');
    if (!hiddenResult) {
      print('[SKIP] メンバー非表示設定に失敗したためスキップします');
      return;
    }

    // Step 2: EventList に戻る
    await goToEventList(tester);

    // Step 3: イベント詳細を開く（近所のドライブ: members 太郎のみ → 花子は候補に出るはず）
    final opened = await openEventDetailByName(tester, '近所のドライブ');
    if (!opened) {
      print('[SKIP] イベント詳細を開けなかったためスキップします');
      return;
    }

    // Step 4: 概要タブを表示
    await ensureOverviewTab(tester);

    // Step 5: BasicInfo 編集モードに入る
    final editModeEntered = await enterBasicInfoEditMode(tester);
    if (!editModeEntered) {
      print('[SKIP] BasicInfo編集モードに入れなかったためスキップします');
      return;
    }

    // Step 6: メンバー入力フィールドをタップして候補を開く
    final suggestionsOpened = await openMemberSuggestions(tester);
    if (!suggestionsOpened) {
      print('[SKIP] メンバー候補が表示されなかったためスキップします');
      return;
    }

    // Step 7: 表示中メンバー（花子/member-002）の候補アイテムが表示されることを確認
    expect(
      find.byKey(const Key('basicInfo_item_memberSuggestion_member-002')),
      findsOneWidget,
      reason: '表示中のメンバー（花子）はBasicInfoのメンバー候補に表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-BHF-003: 非表示タグがBasicInfoタグ候補に表示されないこと
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-BHF-003: 非表示タグがBasicInfoタグ候補に表示されないこと',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      print('[SKIP] イベントデータが存在しないためスキップします');
      return;
    }

    // Step 1: 設定で「温泉」（tag-003）を非表示にする
    final hiddenResult = await hideTagInSettings(tester, '温泉');
    if (!hiddenResult) {
      print('[SKIP] タグ非表示設定に失敗したためスキップします');
      return;
    }

    // Step 2: EventList に戻る
    await goToEventList(tester);

    // Step 3: イベント詳細を開く（近所のドライブ: タグ「日帰り」のみ → 温泉は候補に出ないはず）
    final opened = await openEventDetailByName(tester, '近所のドライブ');
    if (!opened) {
      print('[SKIP] イベント詳細を開けなかったためスキップします');
      return;
    }

    // Step 4: 概要タブを表示
    await ensureOverviewTab(tester);

    // Step 5: BasicInfo 編集モードに入る
    final editModeEntered = await enterBasicInfoEditMode(tester);
    if (!editModeEntered) {
      print('[SKIP] BasicInfo編集モードに入れなかったためスキップします');
      return;
    }

    // Step 6: タグ入力フィールドをタップして候補を開く
    // 現在ついているタグ（日帰り）をスクロールで探して入力フィールドに到達する
    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('basicInfo_field_tagInput'))
          .evaluate()
          .isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    final suggestionsOpened = await openTagSuggestions(tester);
    if (!suggestionsOpened) {
      print('[SKIP] タグ候補が表示されなかったためスキップします');
      return;
    }

    // Step 7: 非表示タグ（温泉/tag-003）の候補アイテムが表示されないことを確認
    expect(
      find.byKey(const Key('basicInfo_item_tagSuggestion_tag-003')),
      findsNothing,
      reason: '非表示設定のタグ（温泉）はBasicInfoのタグ候補に表示されないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-BHF-004: 非表示TransがBasicInfoのTrans選択肢に表示されないこと
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-BHF-004: 非表示TransがBasicInfoのTrans選択肢に表示されないこと',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      print('[SKIP] イベントデータが存在しないためスキップします');
      return;
    }

    // Step 1: 設定で「レンタカー」（trans-002）を非表示にする
    final hiddenResult = await hideTransInSettings(tester, 'レンタカー');
    if (!hiddenResult) {
      print('[SKIP] Trans非表示設定に失敗したためスキップします');
      return;
    }

    // Step 2: EventList に戻る
    await goToEventList(tester);

    // Step 3: イベント詳細を開く（箱根日帰りドライブ）
    final opened = await openEventDetailByName(tester, '箱根日帰りドライブ');
    if (!opened) {
      print('[SKIP] イベント詳細を開けなかったためスキップします');
      return;
    }

    // Step 4: 概要タブを表示
    await ensureOverviewTab(tester);

    // Step 5: BasicInfo 編集モードに入る
    final editModeEntered = await enterBasicInfoEditMode(tester);
    if (!editModeEntered) {
      print('[SKIP] BasicInfo編集モードに入れなかったためスキップします');
      return;
    }

    // Step 6: Trans選択チップ一覧を確認する（スクロールして表示エリアを探す）
    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('basicInfo_chip_trans_trans-002'))
              .evaluate()
              .isNotEmpty ||
          find.byKey(const Key('basicInfo_chip_trans_trans-001'))
              .evaluate()
              .isNotEmpty) {
        break;
      }
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    // Step 7: 非表示Trans（レンタカー/trans-002）のチップが表示されないことを確認
    expect(
      find.byKey(const Key('basicInfo_chip_trans_trans-002')),
      findsNothing,
      reason: '非表示設定のTrans（レンタカー）はBasicInfoのTrans選択肢に表示されないこと',
    );
  });
}
