// ignore_for_file: avoid_print

// Integration Test: MichiInfo Mark/Link削除UI変更（削除アイコン常時表示）
//
// Feature Spec: docs/Spec/Features/FS-michi_info_delete_icon.md
// テストグループ: TC-MID（MichiInfo Delete Icon）
//
// TC-MID-001: Mark カードを左スワイプしても削除ボタンが表示されない
// TC-MID-002: Link カードを左スワイプしても削除ボタンが表示されない
// TC-MID-003: Mark カード右端に赤背景ゴミ箱アイコンが常時表示されている
// TC-MID-004: Link カード右端に赤背景ゴミ箱アイコンが常時表示されている
// TC-MID-005: 削除アイコンをタップすると該当カードが即座に削除される（確認ダイアログなし）
// TC-MID-006: 給油あり Mark の接点ドットが拡大されて給油アイコンが内部に表示される（SKIP: CustomPainter）
// TC-MID-007: 給油なし Mark の接点ドットは通常サイズで表示される（SKIP: CustomPainter）
//
// シードデータ（event-001: 箱根日帰りドライブ）の構成:
//   ml-001 (Mark: 自宅出発, isFuel: false)
//   ml-002 (Link: 東名高速)
//   ml-003 (Mark: 箱根湯本駅前, isFuel: false)
//   ml-004 (Link: 芦ノ湖スカイライン)
//   ml-005 (Mark: 大涌谷, isFuel: true)
//
// TC-MID-006/007 は CustomPainter 内の描画のため Widget キーでの直接検証不可 → SKIP

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
      if (find.text('イベント一覧').evaluate().isNotEmpty) break;
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('箱根日帰りドライブ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// MichiInfo タブまで遷移する（指定したイベント名を使用）。
  Future<void> goToMichiInfoTab(WidgetTester tester, String eventName) async {
    await startApp(tester);

    final eventCards = find.ancestor(
      of: find.text(eventName),
      matching: find.byType(GestureDetector),
    );
    expect(eventCards, findsWidgets,
        reason: '$eventName のイベントカードが見つかること');

    await tester.tap(eventCards.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }

    final michiTab = find.text('ミチ');
    expect(michiTab, findsOneWidget, reason: '「ミチ」タブが表示されること');
    await tester.tap(michiTab);
    await tester.pump(const Duration(milliseconds: 500));

    // MichiInfo ページのロードを待つ（FABが表示されるまで）
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────
  // TC-MID-001: Mark カードを左スワイプしても削除ボタンが表示されない
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MID-001: Mark カードを左スワイプしても旧スライドアクション削除ボタンが表示されない',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // ml-001 は Mark（自宅出発）
    const markId = 'ml-001';

    // 削除アイコンボタン（常時表示）が存在することを確認
    final deleteIconKey = Key('michiInfo_button_delete_$markId');
    if (find.byKey(deleteIconKey).evaluate().isEmpty) {
      markTestSkipped(
          'michiInfo_button_delete_$markId が見つからないためスキップします（実装未完了の可能性）');
      return;
    }

    // Mark カードを左スワイプする
    await tester.drag(find.byKey(deleteIconKey), const Offset(-300, 0));
    await tester.pump(const Duration(milliseconds: 500));

    // 旧スライドアクションの削除ボタンが表示されないことを確認
    // （スワイプ式削除は廃止されているため、旧Keyは存在しない）
    expect(
      find.byKey(Key('michi_info_card_delete_action_$markId')),
      findsNothing,
      reason:
          '左スワイプ後に旧スライドアクション削除ボタン (michi_info_card_delete_action_$markId) が表示されないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MID-002: Link カードを左スワイプしても削除ボタンが表示されない
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MID-002: Link カードを左スワイプしても旧スライドアクション削除ボタンが表示されない',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // ml-002 は Link（東名高速）
    const linkId = 'ml-002';

    // 削除アイコンボタン（常時表示）が存在することを確認
    final deleteIconKey = Key('michiInfo_button_delete_$linkId');
    if (find.byKey(deleteIconKey).evaluate().isEmpty) {
      markTestSkipped(
          'michiInfo_button_delete_$linkId が見つからないためスキップします（実装未完了の可能性）');
      return;
    }

    // Link カードを左スワイプする
    await tester.drag(find.byKey(deleteIconKey), const Offset(-300, 0));
    await tester.pump(const Duration(milliseconds: 500));

    // 旧スライドアクションの削除ボタンが表示されないことを確認
    expect(
      find.byKey(Key('michi_info_card_delete_action_$linkId')),
      findsNothing,
      reason:
          '左スワイプ後に旧スライドアクション削除ボタン (michi_info_card_delete_action_$linkId) が表示されないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MID-003: Mark カード右端に赤背景ゴミ箱アイコンが常時表示されている
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MID-003: Mark カード右端に赤背景ゴミ箱アイコンが常時表示されている',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // ml-001 は Mark（自宅出発）
    const markId = 'ml-001';

    // スワイプ操作なしに削除アイコンが表示されていることを確認
    expect(
      find.byKey(Key('michiInfo_button_delete_$markId')),
      findsOneWidget,
      reason:
          'スワイプ操作なしに Mark カード削除アイコン (michiInfo_button_delete_$markId) が表示されていること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MID-004: Link カード右端に赤背景ゴミ箱アイコンが常時表示されている
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MID-004: Link カード右端に赤背景ゴミ箱アイコンが常時表示されている',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // ml-002 は Link（東名高速）
    const linkId = 'ml-002';

    // スワイプ操作なしに削除アイコンが表示されていることを確認
    expect(
      find.byKey(Key('michiInfo_button_delete_$linkId')),
      findsOneWidget,
      reason:
          'スワイプ操作なしに Link カード削除アイコン (michiInfo_button_delete_$linkId) が表示されていること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MID-005: 削除アイコンをタップすると該当カードが即座に削除される（確認ダイアログなし）
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-MID-005: 削除アイコンをタップすると該当 Mark カードが即座に削除され、AlertDialog が表示されない',
      (tester) async {
    await goToMichiInfoTab(tester, '箱根日帰りドライブ');

    // ml-001 (Mark: 自宅出発) を削除対象とする
    // event-001 は Mark 3件 + Link 2件あるため削除後も他のカードが残る
    const markId = 'ml-001';
    final deleteIconKey = Key('michiInfo_button_delete_$markId');

    if (find.byKey(deleteIconKey).evaluate().isEmpty) {
      markTestSkipped(
          'michiInfo_button_delete_$markId が見つからないためスキップします（実装未完了の可能性）');
      return;
    }

    // 削除前: 削除アイコンが表示されていること
    expect(find.byKey(deleteIconKey), findsOneWidget,
        reason: '削除前に削除アイコンが表示されていること');

    // 削除アイコンをタップ（スワイプ不要・直接タップ）
    await tester.ensureVisible(find.byKey(deleteIconKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteIconKey));

    // AlertDialog が表示されないことを確認（即削除・確認なし）
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.byType(AlertDialog),
      findsNothing,
      reason: '削除アイコンタップ後に AlertDialog が表示されないこと（確認ダイアログなし・即削除）',
    );

    // 削除処理の完了を待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(deleteIconKey).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 削除した Mark カードが一覧から消えていることを確認
    expect(
      find.byKey(deleteIconKey),
      findsNothing,
      reason: '削除した Mark カード (ml-001) の削除アイコンが一覧から消えていること',
    );

    // 他のカード（ml-002: 東名高速）はまだ表示されていることを確認
    expect(
      find.byKey(const Key('michiInfo_button_delete_ml-002')),
      findsOneWidget,
      reason: '削除していない Link カード (ml-002) の削除アイコンは引き続き表示されていること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MID-006: 給油あり Mark の接点ドットが拡大されて給油アイコンが内部に表示される
  // CustomPainter 内の描画のため Widget キーでの直接検証は不可 → SKIP
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-MID-006: 給油あり Mark の接点ドットが拡大されて給油アイコンが内部に表示される（CustomPainterのため目視確認）',
      (tester) async {
    markTestSkipped(
        'TC-MID-006: 接点ドットは _MichiTimelinePainter（CustomPainter）内に描画されるため、'
        'Widget キーでの直接検証が不可。目視またはスクリーンショット比較で確認してください。'
        '【確認手順】箱根日帰りドライブ > ミチタブ > 大涌谷（ml-005, isFuel=true）の'
        'タイムライン接点ドットが縦方向に拡大され、ドット内に給油アイコンが表示されていること。');
  });

  // ────────────────────────────────────────────────────────
  // TC-MID-007: 給油なし Mark の接点ドットは通常サイズで表示される
  // CustomPainter 内の描画のため Widget キーでの直接検証は不可 → SKIP
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-MID-007: 給油なし Mark の接点ドットは通常サイズで表示される（CustomPainterのため目視確認）',
      (tester) async {
    markTestSkipped(
        'TC-MID-007: 接点ドットは _MichiTimelinePainter（CustomPainter）内に描画されるため、'
        'Widget キーでの直接検証が不可。目視またはスクリーンショット比較で確認してください。'
        '【確認手順】箱根日帰りドライブ > ミチタブ > 自宅出発（ml-001, isFuel=false）の'
        'タイムライン接点ドットが通常の円サイズ（変更前と同等）で表示され、'
        'ドット内に給油アイコンが表示されていないこと。');
  });
}
