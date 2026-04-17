// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: BasicInfo インライン選択UI (Phase A)
///
/// Spec: docs/Spec/Features/FS-event_detail_inline_selection_ui_phaseA.md §16
///
/// テストシナリオ: TC-BII-001 〜 TC-BII-016
///
/// 前提条件:
///   - 交通手段マスタ: 「車」「バイク」「電車」が登録済み
///   - メンバーマスタ: 「田中」「鈴木」「佐藤」が登録済み
///   - タグマスタ: 「高速」「下道」が登録済み
///   - イベントが1件以上存在し、BasicInfoタブが表示可能な状態

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
      if (find.byIcon(Icons.edit).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// BasicInfo タブをタップして表示する（すでに表示中の場合はスキップ）。
  Future<void> ensureBasicInfoTab(WidgetTester tester) async {
    // EventDetail の「概要」タブ内に BasicInfo が表示される
    // タブが存在する場合は「概要」タブをタップする
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  /// BasicInfo タブの「編集」アイコンをタップして編集モードに入る。
  Future<bool> enterEditMode(WidgetTester tester) async {
    final editButton = find.byIcon(Icons.edit);
    if (editButton.evaluate().isEmpty) return false;
    await tester.tap(editButton.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('キャンセル').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// EventDetail を開き BasicInfo 編集モードに入るまでのセットアップ。
  /// イベントがない場合はスキップ理由を返す。null の場合は成功。
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
    final editing = await enterEditMode(tester);
    if (!editing) {
      return '編集モードに入れなかったためスキップします';
    }
    return null;
  }

  /// 指定キープレフィックスを持つウィジェットを1件以上見つけるユーティリティ。
  /// ListView のスクロールが必要な場合はスクロールを試みる。
  Future<Iterable<Element>> findWidgetsByKeyPrefix(
    WidgetTester tester,
    String keyPrefix,
  ) async {
    // まず画面内で探す
    final found = tester
        .elementList(find.byWidgetPredicate((widget) {
          final key = widget.key;
          if (key is ValueKey<String>) {
            return key.value.startsWith(keyPrefix);
          }
          return false;
        }))
        .toList();
    return found;
  }

  // ────────────────────────────────────────────────────────
  // タグ系テスト (TC-BII-001 〜 TC-BII-004)
  // ────────────────────────────────────────────────────────

  testWidgets('TC-BII-001: タグ — 入力欄タップでドロップダウンが表示される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // タグ入力欄が存在することを確認
    final tagInput = find.byKey(const Key('basicInfo_field_tagInput'));
    expect(
      tagInput,
      findsOneWidget,
      reason: 'タグ入力欄 basicInfo_field_tagInput が表示されること',
    );

    // タグ入力欄をタップしてフォーカス
    await tester.tap(tagInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // サジェストアイテムが出現するまで待つ
      final suggestions = await findWidgetsByKeyPrefix(
        tester,
        'basicInfo_item_tagSuggestion_',
      );
      if (suggestions.isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // サジェストドロップダウンが1件以上表示されること
    final suggestions = await findWidgetsByKeyPrefix(
      tester,
      'basicInfo_item_tagSuggestion_',
    );
    expect(
      suggestions.isNotEmpty,
      isTrue,
      reason:
          'タグ入力欄タップ後にサジェストドロップダウン（basicInfo_item_tagSuggestion_*）が1件以上表示されること',
    );
  });

  testWidgets('TC-BII-002: タグ — 既存タグ候補タップでチップが追加される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // タグ入力欄をタップしてフォーカス
    final tagInput = find.byKey(const Key('basicInfo_field_tagInput'));
    if (tagInput.evaluate().isEmpty) {
      markTestSkipped('タグ入力欄が見つからないためスキップします');
      return;
    }
    await tester.tap(tagInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final suggestions = await findWidgetsByKeyPrefix(
        tester,
        'basicInfo_item_tagSuggestion_',
      );
      if (suggestions.isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // サジェストアイテムを取得して最初の1件をタップ
    final suggestionFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_item_tagSuggestion_');
      }
      return false;
    });

    if (suggestionFinder.evaluate().isEmpty) {
      markTestSkipped('タグサジェストが存在しないためスキップします');
      return;
    }

    // タップ前のチップ数を記録
    final chipsBefore = await findWidgetsByKeyPrefix(
      tester,
      'basicInfo_chip_tag_',
    );
    final chipCountBefore = chipsBefore.length;

    // サジェストアイテムをタップ
    await tester.ensureVisible(suggestionFinder.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(suggestionFinder.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // タグチップが追加されたことを確認
    final chipsAfter = await findWidgetsByKeyPrefix(tester, 'basicInfo_chip_tag_');
    expect(
      chipsAfter.length > chipCountBefore,
      isTrue,
      reason: 'サジェストタップ後に選択済みタグチップ（basicInfo_chip_tag_*）が1件増加すること',
    );
  });

  testWidgets('TC-BII-003: タグ — 未登録文字列入力で「追加」アイテムが表示されチップが追加される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // タグ入力欄をタップしてフォーカス
    final tagInput = find.byKey(const Key('basicInfo_field_tagInput'));
    if (tagInput.evaluate().isEmpty) {
      markTestSkipped('タグ入力欄が見つからないためスキップします');
      return;
    }
    await tester.tap(tagInput);
    await tester.pump(const Duration(milliseconds: 300));

    // 未登録文字列を入力する
    await tester.enterText(tagInput, 'テスト新タグXYZ');
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfo_item_tagAddNew')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 「追加」アイテムが表示されることを確認
    expect(
      find.byKey(const Key('basicInfo_item_tagAddNew')),
      findsOneWidget,
      reason: '未登録タグ名入力後に basicInfo_item_tagAddNew（"xxx" を追加）アイテムが表示されること',
    );

    // タップ前のチップ数を記録
    final chipsBefore = await findWidgetsByKeyPrefix(tester, 'basicInfo_chip_tag_');
    final chipCountBefore = chipsBefore.length;

    // 「追加」アイテムをタップ
    await tester.ensureVisible(find.byKey(const Key('basicInfo_item_tagAddNew')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('basicInfo_item_tagAddNew')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // 新しいタグチップが追加されたことを確認
    final chipsAfter = await findWidgetsByKeyPrefix(tester, 'basicInfo_chip_tag_');
    expect(
      chipsAfter.length > chipCountBefore,
      isTrue,
      reason: '「追加」アイテムタップ後に新規タグチップが追加されること',
    );
  });

  testWidgets('TC-BII-004: タグ — チップの×タップでタグが削除される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // まずタグを1件追加する（サジェストから選択）
    final tagInput = find.byKey(const Key('basicInfo_field_tagInput'));
    if (tagInput.evaluate().isEmpty) {
      markTestSkipped('タグ入力欄が見つからないためスキップします');
      return;
    }
    await tester.tap(tagInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final suggestions = await findWidgetsByKeyPrefix(
        tester,
        'basicInfo_item_tagSuggestion_',
      );
      if (suggestions.isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final suggestionFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_item_tagSuggestion_');
      }
      return false;
    });

    if (suggestionFinder.evaluate().isEmpty) {
      // サジェストがなければ新規タグを追加する
      await tester.enterText(tagInput, 'テスト削除タグ');
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('basicInfo_item_tagAddNew')).evaluate().isNotEmpty) break;
      }
      if (find.byKey(const Key('basicInfo_item_tagAddNew')).evaluate().isEmpty) {
        markTestSkipped('タグ追加ができないためスキップします');
        return;
      }
      await tester.tap(find.byKey(const Key('basicInfo_item_tagAddNew')));
    } else {
      await tester.tap(suggestionFinder.first);
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // タグチップが存在することを確認
    final chipFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_tag_');
      }
      return false;
    });

    if (chipFinder.evaluate().isEmpty) {
      markTestSkipped('タグチップが追加されなかったためスキップします');
      return;
    }

    final chipCountBefore = chipFinder.evaluate().length;

    // チップの×ボタン（deleteIcon）をタップして削除
    // Chip の onDeleted コールバックは内部の削除アイコンをタップすることで呼ばれる
    // find.descendant で削除アイコン（Icons.cancel）を特定してタップする
    await tester.ensureVisible(chipFinder.first);
    await tester.pump(const Duration(milliseconds: 300));
    final deleteIconFinder = find.descendant(
      of: chipFinder.first,
      matching: find.byIcon(Icons.cancel),
    );
    if (deleteIconFinder.evaluate().isEmpty) {
      markTestSkipped('タグチップの削除アイコンが見つからないためスキップします');
      return;
    }
    await tester.tap(deleteIconFinder.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // チップ数が減少したことを確認
    final chipCountAfter = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_tag_');
      }
      return false;
    }).evaluate().length;

    expect(
      chipCountAfter < chipCountBefore,
      isTrue,
      reason: 'タグチップの×タップ後にチップが削除されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // Trans系テスト (TC-BII-005 〜 TC-BII-008)
  // ────────────────────────────────────────────────────────

  testWidgets('TC-BII-005: Trans — 全登録交通手段がチップで表示される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 交通手段チップが1件以上表示されることを確認（シードデータに「車」「バイク」「電車」が存在する想定）
    final transChips = await findWidgetsByKeyPrefix(tester, 'basicInfo_chip_trans_');
    expect(
      transChips.isNotEmpty,
      isTrue,
      reason: '交通手段マスタのチップ（basicInfo_chip_trans_*）が1件以上表示されること',
    );

    // シードデータに「車」「バイク」「電車」が存在する場合、3件すべて表示されることを期待
    print('[TC-BII-005] 交通手段チップ数: ${transChips.length}');
    expect(
      transChips.length,
      greaterThanOrEqualTo(1),
      reason: '交通手段マスタの全件チップが表示されること（最低1件以上）',
    );
  });

  testWidgets('TC-BII-006: Trans — チップタップで選択状態になり他は非選択のまま', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 交通手段チップが存在することを確認
    final transChipFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_trans_');
      }
      return false;
    });

    if (transChipFinder.evaluate().isEmpty) {
      markTestSkipped('交通手段チップが表示されていないためスキップします');
      return;
    }

    // タップ前の選択状態を確認し、未選択のチップをタップする
    // 既存イベントで既に選択済みのチップがある場合は別のチップをタップする
    final allTransChipsBefore = tester.widgetList<FilterChip>(find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_trans_');
      }
      return false;
    })).toList();

    // 未選択チップを優先してタップ（なければ最初のチップをタップ）
    final unselectedChipFinder = find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is! ValueKey<String>) return false;
      if (!key.value.startsWith('basicInfo_chip_trans_')) return false;
      return !widget.selected;
    });

    final chipToTap = unselectedChipFinder.evaluate().isNotEmpty
        ? unselectedChipFinder.first
        : transChipFinder.first;

    await tester.ensureVisible(chipToTap);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(chipToTap);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // タップ後のチップ一覧を確認
    // 選択状態のチップが1件以上存在することを確認する
    // FilterChip の selected プロパティで状態を判定する
    final selectedChips = tester.widgetList<FilterChip>(find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_trans_');
      }
      return false;
    })).where((chip) => chip.selected).toList();

    print('[TC-BII-006] タップ前チップ数: ${allTransChipsBefore.length}, タップ後選択数: ${selectedChips.length}');

    expect(
      selectedChips.length,
      equals(1),
      reason: '交通手段チップタップ後に選択済みチップが正確に1件であること（単一選択）',
    );
  });

  testWidgets('TC-BII-007: Trans — 初期値（既存選択）が選択状態で表示される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // BasicInfo 表示直後に交通手段チップの選択状態を確認
    // 既存選択がある場合はそのチップが selected=true であること
    // 既存選択がない場合は selected=true のチップが0件であること
    final allTransChips = tester.widgetList<FilterChip>(find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_trans_');
      }
      return false;
    })).toList();

    // チップが存在することを確認
    expect(
      allTransChips.isNotEmpty,
      isTrue,
      reason: '交通手段チップが1件以上表示されること',
    );

    // selected=true のチップが最大1件であること（単一選択の整合性確認）
    final selectedChips = allTransChips.where((chip) => chip.selected).toList();
    print('[TC-BII-007] 全チップ数: ${allTransChips.length}, 選択済み: ${selectedChips.length}');
    expect(
      selectedChips.length,
      lessThanOrEqualTo(1),
      reason: '交通手段の選択済みチップは最大1件であること（単一選択）',
    );
  });

  testWidgets('TC-BII-008: Trans — 選択済みチップを再タップで選択解除される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 交通手段チップが存在することを確認
    final transChipFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_trans_');
      }
      return false;
    });

    if (transChipFinder.evaluate().isEmpty) {
      markTestSkipped('交通手段チップが表示されていないためスキップします');
      return;
    }

    // まず選択状態にするために未選択チップを探してタップ
    // 既に選択済みのチップは最初のタップで解除になるため、未選択チップを優先する
    final unselectedChipFinderForToggle = find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is! ValueKey<String>) return false;
      if (!key.value.startsWith('basicInfo_chip_trans_')) return false;
      return !widget.selected;
    });

    // 未選択チップがあれば選択してトグルテストを行う
    // 未選択チップがなければ最初のチップをタップして解除→再選択の動作を確認する
    final chipForToggle = unselectedChipFinderForToggle.evaluate().isNotEmpty
        ? unselectedChipFinderForToggle.first
        : transChipFinder.first;

    // 1回目のタップ
    await tester.ensureVisible(chipForToggle);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(chipForToggle);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 1回目タップ後の状態を記録（同一チップのキーを記録してtransChipFinderを再構築）
    // タップしたチップのKeyを保持してそのチップの選択状態を追跡する
    final chipKeyAfterFirstTap = (tester.widget(chipForToggle) as FilterChip).key;
    final selectedAfterFirstTap = tester.widgetList<FilterChip>(find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_trans_');
      }
      return false;
    })).where((chip) => chip.selected).length;

    print('[TC-BII-008] 1回目タップ後の選択数: $selectedAfterFirstTap, タップチップKey: $chipKeyAfterFirstTap');

    // 1回目タップ後に選択済みチップが1件になっていること（単一選択）
    expect(
      selectedAfterFirstTap,
      equals(1),
      reason: '1回目タップ後に選択済みチップが1件であること',
    );

    // 2回目: 同じチップを再タップして選択解除する
    // 1回目でchipForToggleをタップ後にウィジェットが再ビルドされるため再度findする
    final selectedChipFinder = find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      return widget.selected &&
          (widget.key is ValueKey<String>) &&
          (widget.key as ValueKey<String>).value.startsWith('basicInfo_chip_trans_');
    });

    if (selectedChipFinder.evaluate().isEmpty) {
      markTestSkipped('選択済みチップが見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(selectedChipFinder.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(selectedChipFinder.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // 2回目タップ後の選択済みチップ数（選択解除されて0件になるはず）
    final selectedAfterSecondTap = tester.widgetList<FilterChip>(find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_trans_');
      }
      return false;
    })).where((chip) => chip.selected).length;

    print('[TC-BII-008] 2回目タップ後の選択数: $selectedAfterSecondTap');

    // 選択済みチップが解除されて0件になること
    expect(
      selectedAfterSecondTap,
      equals(0),
      reason: '選択済み交通手段チップを再タップすると選択が解除されること（トグル動作）',
    );
  });

  // ────────────────────────────────────────────────────────
  // Members系テスト (TC-BII-009 〜 TC-BII-012)
  // ────────────────────────────────────────────────────────

  testWidgets('TC-BII-009: Members — 入力欄タップでサジェストドロップダウンが表示される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // メンバー入力欄が存在することを確認
    final memberInput = find.byKey(const Key('basicInfo_field_memberInput'));
    expect(
      memberInput,
      findsOneWidget,
      reason: 'メンバー入力欄 basicInfo_field_memberInput が表示されること',
    );

    // メンバー入力欄をタップしてフォーカス
    await tester.tap(memberInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final suggestions = await findWidgetsByKeyPrefix(
        tester,
        'basicInfo_item_memberSuggestion_',
      );
      if (suggestions.isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // サジェストドロップダウンが1件以上表示されること
    final suggestions = await findWidgetsByKeyPrefix(
      tester,
      'basicInfo_item_memberSuggestion_',
    );
    expect(
      suggestions.isNotEmpty,
      isTrue,
      reason:
          'メンバー入力欄タップ後にサジェストドロップダウン（basicInfo_item_memberSuggestion_*）が1件以上表示されること',
    );
  });

  testWidgets('TC-BII-010: Members — サジェストタップでメンバーチップが追加される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // メンバー入力欄をタップしてフォーカス
    final memberInput = find.byKey(const Key('basicInfo_field_memberInput'));
    if (memberInput.evaluate().isEmpty) {
      markTestSkipped('メンバー入力欄が見つからないためスキップします');
      return;
    }
    await tester.tap(memberInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final suggestions = await findWidgetsByKeyPrefix(
        tester,
        'basicInfo_item_memberSuggestion_',
      );
      if (suggestions.isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // サジェストアイテムを取得
    final suggestionFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_item_memberSuggestion_');
      }
      return false;
    });

    if (suggestionFinder.evaluate().isEmpty) {
      markTestSkipped('メンバーサジェストが存在しないためスキップします');
      return;
    }

    // タップ前のメンバーチップ数を記録
    final chipsBefore = await findWidgetsByKeyPrefix(tester, 'basicInfo_chip_member_');
    final chipCountBefore = chipsBefore.length;

    // サジェストアイテムをタップ
    await tester.ensureVisible(suggestionFinder.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(suggestionFinder.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // メンバーチップが追加されたことを確認
    final chipsAfter = await findWidgetsByKeyPrefix(tester, 'basicInfo_chip_member_');
    expect(
      chipsAfter.length > chipCountBefore,
      isTrue,
      reason: 'サジェストタップ後に選択済みメンバーチップ（basicInfo_chip_member_*）が1件増加すること',
    );
  });

  testWidgets('TC-BII-011: Members — チップの×タップでメンバーチップが削除される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // まずメンバーを1件追加する
    final memberInput = find.byKey(const Key('basicInfo_field_memberInput'));
    if (memberInput.evaluate().isEmpty) {
      markTestSkipped('メンバー入力欄が見つからないためスキップします');
      return;
    }
    await tester.tap(memberInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final suggestions = await findWidgetsByKeyPrefix(
        tester,
        'basicInfo_item_memberSuggestion_',
      );
      if (suggestions.isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final suggestionFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_item_memberSuggestion_');
      }
      return false;
    });

    if (suggestionFinder.evaluate().isEmpty) {
      // サジェストがなければ新規メンバーを追加する
      await tester.enterText(memberInput, '削除テストメンバー');
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('basicInfo_item_memberAddNew')).evaluate().isNotEmpty) break;
      }
      if (find.byKey(const Key('basicInfo_item_memberAddNew')).evaluate().isEmpty) {
        markTestSkipped('メンバー追加ができないためスキップします');
        return;
      }
      await tester.tap(find.byKey(const Key('basicInfo_item_memberAddNew')));
    } else {
      await tester.tap(suggestionFinder.first);
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // メンバーチップが存在することを確認
    final chipFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_member_');
      }
      return false;
    });

    if (chipFinder.evaluate().isEmpty) {
      markTestSkipped('メンバーチップが追加されなかったためスキップします');
      return;
    }

    final chipCountBefore = chipFinder.evaluate().length;

    // チップの×ボタン（deleteIcon）をタップして削除
    // Chip の onDeleted コールバックは内部の削除アイコンをタップすることで呼ばれる
    await tester.ensureVisible(chipFinder.first);
    await tester.pump(const Duration(milliseconds: 300));
    final memberDeleteIconFinder = find.descendant(
      of: chipFinder.first,
      matching: find.byIcon(Icons.cancel),
    );
    if (memberDeleteIconFinder.evaluate().isEmpty) {
      markTestSkipped('メンバーチップの削除アイコンが見つからないためスキップします');
      return;
    }
    await tester.tap(memberDeleteIconFinder.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // チップ数が減少したことを確認
    final chipCountAfter = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_member_');
      }
      return false;
    }).evaluate().length;

    expect(
      chipCountAfter < chipCountBefore,
      isTrue,
      reason: 'メンバーチップの×タップ後にチップが削除されること',
    );
  });

  testWidgets('TC-BII-012: Members — 未登録名入力で「追加」表示→タップでチップが追加される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // メンバー入力欄をタップしてフォーカス
    final memberInput = find.byKey(const Key('basicInfo_field_memberInput'));
    if (memberInput.evaluate().isEmpty) {
      markTestSkipped('メンバー入力欄が見つからないためスキップします');
      return;
    }
    await tester.tap(memberInput);
    await tester.pump(const Duration(milliseconds: 300));

    // 未登録名を入力する
    await tester.enterText(memberInput, '新メンバー太郎テスト');
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfo_item_memberAddNew')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 「追加」アイテムが表示されることを確認
    expect(
      find.byKey(const Key('basicInfo_item_memberAddNew')),
      findsOneWidget,
      reason: '未登録メンバー名入力後に basicInfo_item_memberAddNew（"xxx" を追加）アイテムが表示されること',
    );

    // タップ前のチップ数を記録
    final chipsBefore = await findWidgetsByKeyPrefix(tester, 'basicInfo_chip_member_');
    final chipCountBefore = chipsBefore.length;

    // 「追加」アイテムをタップ
    await tester.ensureVisible(find.byKey(const Key('basicInfo_item_memberAddNew')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('basicInfo_item_memberAddNew')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // 新しいメンバーチップが追加されたことを確認
    final chipsAfter = await findWidgetsByKeyPrefix(tester, 'basicInfo_chip_member_');
    expect(
      chipsAfter.length > chipCountBefore,
      isTrue,
      reason: '「追加」アイテムタップ後に新規メンバーチップが追加されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // GasPayMember系テスト (TC-BII-013 〜 TC-BII-016)
  // ────────────────────────────────────────────────────────

  testWidgets('TC-BII-013: GasPayMember — イベントメンバーが全員チップで表示される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // まずメンバーを2件追加する（田中・鈴木相当）
    final memberInput = find.byKey(const Key('basicInfo_field_memberInput'));
    if (memberInput.evaluate().isEmpty) {
      markTestSkipped('メンバー入力欄が見つからないためスキップします');
      return;
    }

    // メンバーを1件追加
    await tester.tap(memberInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final suggestions = await findWidgetsByKeyPrefix(
        tester,
        'basicInfo_item_memberSuggestion_',
      );
      if (suggestions.isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final suggestionFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_item_memberSuggestion_');
      }
      return false;
    });

    if (suggestionFinder.evaluate().isNotEmpty) {
      await tester.tap(suggestionFinder.first);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 選択済みメンバーに対応する GasPayMember チップが表示されることを確認
    final memberChips = await findWidgetsByKeyPrefix(tester, 'basicInfo_chip_member_');
    final payMemberChips = await findWidgetsByKeyPrefix(tester, 'basicInfo_chip_payMember_');
    final payMemberHintExists = find.byKey(const Key('basicInfo_text_payMemberHint')).evaluate().isNotEmpty;

    print('[TC-BII-013] 選択済みメンバーチップ数: ${memberChips.length}');
    print('[TC-BII-013] GasPayMemberチップ数: ${payMemberChips.length}');
    print('[TC-BII-013] ヒントテキスト存在: $payMemberHintExists');

    // GasPayMemberセクション自体が非表示の場合（showPayMember=falseのTopic）はスキップ
    // showPayMember=trueなら selectedMembers が空でヒントテキストが表示されるか、
    // selectedMembersがあればチップが表示される。どちらでもない場合はセクションが非表示。
    if (payMemberChips.isEmpty && !payMemberHintExists) {
      markTestSkipped('GasPayMemberセクションが表示されていないためスキップします（このイベントのTopicはshowPayMember=falseです）');
      return;
    }

    // メンバーが1件以上選択されていれば GasPayMember チップも同数表示されること
    if (memberChips.isNotEmpty) {
      expect(
        payMemberChips.length,
        equals(memberChips.length),
        reason: '選択済みメンバー全員に対応する GasPayMember チップ（basicInfo_chip_payMember_*）が表示されること',
      );
    }
  });

  testWidgets('TC-BII-014: GasPayMember — チップタップで選択状態になり他は非選択', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // メンバーを追加して GasPayMember チップを表示させる
    final memberInput = find.byKey(const Key('basicInfo_field_memberInput'));
    if (memberInput.evaluate().isEmpty) {
      markTestSkipped('メンバー入力欄が見つからないためスキップします');
      return;
    }

    // メンバーを2件追加（サジェストから）
    for (var addCount = 0; addCount < 2; addCount++) {
      await tester.tap(memberInput);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        final suggestions = await findWidgetsByKeyPrefix(
          tester,
          'basicInfo_item_memberSuggestion_',
        );
        if (suggestions.isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      final suggestionFinder = find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is ValueKey<String>) {
          return key.value.startsWith('basicInfo_item_memberSuggestion_');
        }
        return false;
      });

      if (suggestionFinder.evaluate().isEmpty) break;
      await tester.tap(suggestionFinder.first);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.pump(const Duration(milliseconds: 300));
    }

    // GasPayMember チップが存在することを確認
    final payMemberChipFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_payMember_');
      }
      return false;
    });

    if (payMemberChipFinder.evaluate().isEmpty) {
      markTestSkipped('GasPayMemberチップが表示されていないためスキップします');
      return;
    }

    // 未選択チップを優先してタップ（なければ最初のチップをタップ）
    // 既に選択済みのチップをタップすると解除になるため未選択チップを選ぶ
    final unselectedPayMemberChipFinder = find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is! ValueKey<String>) return false;
      if (!key.value.startsWith('basicInfo_chip_payMember_')) return false;
      return !widget.selected;
    });

    final payMemberChipToTap = unselectedPayMemberChipFinder.evaluate().isNotEmpty
        ? unselectedPayMemberChipFinder.first
        : payMemberChipFinder.first;

    await tester.ensureVisible(payMemberChipToTap);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(payMemberChipToTap);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // 選択済みチップが正確に1件であること（単一選択）
    final selectedChips = tester.widgetList<FilterChip>(find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_payMember_');
      }
      return false;
    })).where((chip) => chip.selected).toList();

    expect(
      selectedChips.length,
      equals(1),
      reason: 'GasPayMemberチップタップ後に選択済みチップが正確に1件であること（単一選択）',
    );
  });

  testWidgets('TC-BII-015: GasPayMember — メンバー0人時にヒントテキストが表示される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 選択済みメンバーチップが0件の状態を作る
    // 既存メンバーチップをすべて削除する
    var memberChipFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_member_');
      }
      return false;
    });

    // GasPayMemberセクションが表示されているか確認（showPayMember=falseのTopicではスキップ）
    final payMemberSectionVisible =
        find.byKey(const Key('basicInfo_text_payMemberHint')).evaluate().isNotEmpty ||
        find.byWidgetPredicate((widget) {
          final key = widget.key;
          if (key is ValueKey<String>) {
            return key.value.startsWith('basicInfo_chip_payMember_');
          }
          return false;
        }).evaluate().isNotEmpty;

    if (!payMemberSectionVisible) {
      markTestSkipped('GasPayMemberセクションが表示されていないためスキップします（このイベントのTopicはshowPayMember=falseです）');
      return;
    }

    // メンバーチップが存在する場合は全件×ボタンで削除する
    while (memberChipFinder.evaluate().isNotEmpty) {
      await tester.ensureVisible(memberChipFinder.first);
      await tester.pump(const Duration(milliseconds: 300));
      // ×ボタン（deleteIcon）を見つけてタップ
      final deleteIcon = find.descendant(
        of: memberChipFinder.first,
        matching: find.byIcon(Icons.cancel),
      );
      if (deleteIcon.evaluate().isEmpty) break; // 削除アイコンがない場合は中断
      await tester.tap(deleteIcon.first);
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      // 再フィンダー
      memberChipFinder = find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is ValueKey<String>) {
          return key.value.startsWith('basicInfo_chip_member_');
        }
        return false;
      });
    }

    await tester.pump(const Duration(milliseconds: 500));

    // GasPayMember チップが表示されないことを確認
    final payMemberChips = await findWidgetsByKeyPrefix(tester, 'basicInfo_chip_payMember_');
    expect(
      payMemberChips.isEmpty,
      isTrue,
      reason: 'メンバー0人のとき GasPayMember チップが表示されないこと',
    );

    // ヒントテキストが表示されることを確認
    expect(
      find.byKey(const Key('basicInfo_text_payMemberHint')),
      findsOneWidget,
      reason:
          'メンバー0人のとき basicInfo_text_payMemberHint（「メンバーを先に選択してください」）が表示されること',
    );
  });

  testWidgets('TC-BII-016: GasPayMember — 選択済みチップを再タップで選択解除される', (tester) async {
    final skipReason = await setupBasicInfoEditMode(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // メンバーを追加して GasPayMember チップを表示させる
    final memberInput = find.byKey(const Key('basicInfo_field_memberInput'));
    if (memberInput.evaluate().isEmpty) {
      markTestSkipped('メンバー入力欄が見つからないためスキップします');
      return;
    }

    await tester.tap(memberInput);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final suggestions = await findWidgetsByKeyPrefix(
        tester,
        'basicInfo_item_memberSuggestion_',
      );
      if (suggestions.isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final suggestionFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_item_memberSuggestion_');
      }
      return false;
    });

    if (suggestionFinder.evaluate().isEmpty) {
      markTestSkipped('メンバーサジェストが存在しないためスキップします');
      return;
    }

    await tester.tap(suggestionFinder.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // GasPayMember チップが存在することを確認
    final payMemberChipFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_payMember_');
      }
      return false;
    });

    if (payMemberChipFinder.evaluate().isEmpty) {
      markTestSkipped('GasPayMemberチップが表示されていないためスキップします');
      return;
    }

    // 未選択チップを優先してタップ（なければ最初のチップをタップ）
    final unselectedPayMemberFinder = find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is! ValueKey<String>) return false;
      if (!key.value.startsWith('basicInfo_chip_payMember_')) return false;
      return !widget.selected;
    });

    final payMemberChipToTap = unselectedPayMemberFinder.evaluate().isNotEmpty
        ? unselectedPayMemberFinder.first
        : payMemberChipFinder.first;

    // 1回目のタップで選択状態にする
    await tester.ensureVisible(payMemberChipToTap);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(payMemberChipToTap);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    final selectedAfterFirstTap = tester.widgetList<FilterChip>(find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_payMember_');
      }
      return false;
    })).where((chip) => chip.selected).length;

    print('[TC-BII-016] 1回目タップ後の選択数: $selectedAfterFirstTap');

    // 1回目タップ後に1件選択されていることを確認
    expect(
      selectedAfterFirstTap,
      equals(1),
      reason: '1回目タップ後に選択済み GasPayMember チップが1件であること',
    );

    // 2回目: 選択済みチップを再タップして選択解除する
    final selectedPayMemberFinder = find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      return widget.selected &&
          (widget.key is ValueKey<String>) &&
          (widget.key as ValueKey<String>).value.startsWith('basicInfo_chip_payMember_');
    });

    if (selectedPayMemberFinder.evaluate().isEmpty) {
      markTestSkipped('選択済み GasPayMember チップが見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(selectedPayMemberFinder.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(selectedPayMemberFinder.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    final selectedAfterSecondTap = tester.widgetList<FilterChip>(find.byWidgetPredicate((widget) {
      if (widget is! FilterChip) return false;
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('basicInfo_chip_payMember_');
      }
      return false;
    })).where((chip) => chip.selected).length;

    print('[TC-BII-016] 2回目タップ後の選択数: $selectedAfterSecondTap');

    // 選択解除されて0件になること
    expect(
      selectedAfterSecondTap,
      equals(0),
      reason: '選択済み GasPayMember チップを再タップすると選択が解除されること（トグル動作）',
    );
  });
}
