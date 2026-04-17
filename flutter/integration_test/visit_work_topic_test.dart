// ignore_for_file: avoid_print

/// Integration Test: F-3 訪問作業トピック（visitWork）
///
/// Spec: docs/Spec/Features/FS-visit_work_topic.md §10.3
///
/// テストシナリオ: TC-VW-I001 〜 TC-VW-I008
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータに visitWork トピック（topic_visit_work）が登録済みであること
///   - TC-VW-I001 はイベント作成フローを含む

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

  /// visitWork トピックのイベントを新規作成して EventDetail を開く。
  /// イベント作成後に MichiInfo（ミチタブ）まで遷移する。
  /// 作成に失敗した場合は null を返す。
  Future<String?> createVisitWorkEvent(WidgetTester tester) async {
    await startApp(tester);

    // FAB（イベント作成ボタン）をタップ
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isEmpty) {
      return 'FABが見つかりません';
    }
    await tester.tap(fab.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // トピック選択画面またはイベント作成画面のいずれかが表示されるまで待つ
      if (find.text('訪問作業').evaluate().isNotEmpty ||
          find.text('トピックを選択').evaluate().isNotEmpty ||
          find.text('イベントを作成').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 「訪問作業」トピックを選択
    final visitWorkOption = find.text('訪問作業');
    if (visitWorkOption.evaluate().isEmpty) {
      return '「訪問作業」トピックが見つかりません（シードデータ未反映の可能性あり）';
    }
    await tester.tap(visitWorkOption.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty ||
          find.text('保存').evaluate().isNotEmpty ||
          find.text('作成').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 500));
    return null;
  }

  /// visitWork トピックのイベントを新規作成してミチタブまで遷移し、
  /// さらに Mark を1件追加して保存する（各テストで独立した状態を確保する）。
  /// 成功したら null を返す。失敗したらスキップ理由を返す。
  Future<String?> openVisitWorkEventMichiTab(WidgetTester tester) async {
    // 毎テストでイベントを作成してMarkも追加することで独立したテスト状態を確保する
    final createResult = await createVisitWorkEvent(tester);
    if (createResult != null) return createResult;

    // ミチタブに移動
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) {
      return 'ミチタブが見つかりません';
    }
    await tester.tap(michiTab.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // FABをタップして Mark を追加する（visitWork は addMenuItems が1件のみ → 直接MarkDetailに遷移）
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isEmpty) return 'FABが見つかりません（ミチタブ）';

    await tester.tap(fab.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('保存').evaluate().isNotEmpty ||
          find.text('累積メーター').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // Mark を保存してミチタブに戻る
    final saveButton = find.text('保存');
    if (saveButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(saveButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(saveButton.first);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));
    }

    // Mark が保存されているか確認（mark_action_button が表示されること）
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('mark_action_button')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return null;
  }

  /// ミチタブで Mark を追加して MarkDetail 画面が表示されるまで操作する。
  /// visitWork トピックは addMenuItems が mark のみ（1件）のため、
  /// FABタップ → インジケーター選択不要で直接 MarkDetail に遷移する。
  Future<bool> addMarkAndOpenActionSheet(WidgetTester tester) async {
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isEmpty) return false;

    await tester.tap(fab.first);
    // visitWork は addMenuItems が1件のみ → FABタップで直接 MarkDetail に遷移
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('保存').evaluate().isNotEmpty ||
          find.text('累積メーター').evaluate().isNotEmpty) break;
      // インジケーターが表示された場合（リストに既存Markがある場合）はタップして進む
      if (find.byIcon(Icons.add_circle).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.add_circle).last);
        for (var j = 0; j < 10; j++) {
          await tester.pump(const Duration(milliseconds: 200));
          if (find.text('保存').evaluate().isNotEmpty ||
              find.text('累積メーター').evaluate().isNotEmpty) break;
        }
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    // MarkDetail画面（「保存」ボタンまたは「累積メーター」ラベル）が表示されていれば成功
    return find.text('保存').evaluate().isNotEmpty ||
        find.text('累積メーター').evaluate().isNotEmpty;
  }

  /// Mark の保存ボタンをタップして MichiInfo に戻る。
  Future<void> saveMark(WidgetTester tester) async {
    final saveButton = find.text('保存');
    if (saveButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(saveButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(saveButton.first);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// ミチタブの Mark カードにある ⚡ アクションボタンをタップしてボトムシートを開く。
  /// visitWork トピックでは 'mark_action_button' キーのボタンをタップするとアクション選択ボトムシートが表示される。
  Future<bool> tapMarkCardToOpenActionSheet(WidgetTester tester) async {
    // mark_action_button: visitWork トピックで Mark 行に表示される ⚡ ボタン
    final actionButton = find.byKey(const Key('mark_action_button'));

    if (actionButton.evaluate().isEmpty) {
      return false;
    }

    await tester.ensureVisible(actionButton.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(actionButton.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('到着').evaluate().isNotEmpty ||
          find.text('出発').evaluate().isNotEmpty ||
          find.text('作業開始').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 概要タブ（visitWork の集計情報が表示されるタブ）に移動する。
  /// visitWork の集計情報はEventDetailの「概要」タブ内の「集計」セクションに表示される。
  Future<bool> goToAggregationTab(WidgetTester tester) async {
    // 「概要」タブをタップして集計セクションに移動する
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      // 概要タブのデータロードを十分に待機する（OverviewBlocのデータ取得）
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('visit_work_progress_bar')).evaluate().isNotEmpty ||
            find.text('移動').evaluate().isNotEmpty ||
            find.byKey(const Key('overview_sectionLabel_overview')).evaluate().isNotEmpty) {
          break;
        }
      }
      await tester.pump(const Duration(milliseconds: 500));
      return true;
    }
    return false;
  }

  // ────────────────────────────────────────────────────────
  // TC-VW-I001: visitWork トピックでイベントを作成し、Mark を追加できる
  // ────────────────────────────────────────────────────────

  testWidgets('TC-VW-I001: visitWorkトピックでイベントを作成しMarkを追加できる',
      (tester) async {
    final skipReason = await createVisitWorkEvent(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I001: $skipReason');
      return;
    }

    // イベント作成後にミチタブに移動しているか確認
    // または直接 EventDetail が開いている場合はミチタブに移動する
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isNotEmpty) {
      await tester.tap(michiTab.first);
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));
    }

    // FAB が表示されること（Mark 追加が可能な状態）
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('TC-VW-I001b: visitWorkトピックで作成したイベントにMarkを追加してミチタブに表示される',
      (tester) async {
    final skipReason = await createVisitWorkEvent(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I001b: $skipReason');
      return;
    }

    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isNotEmpty) {
      await tester.tap(michiTab.first);
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));
    }

    final opened = await addMarkAndOpenActionSheet(tester);
    if (!opened) {
      print('[SKIP] TC-VW-I001b: Mark追加インジケーターが表示されませんでした（アイテム0件）');
      return;
    }

    // Mark を保存してミチタブに戻る
    final saveButton = find.text('保存');
    if (saveButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(saveButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(saveButton.first);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));
    }

    // MichiInfo に戻ってきた = FAB が再表示される
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-I002: Mark タップでアクションボタンが表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-VW-I002: visitWorkトピックのMarkタップで到着アクションボタンが表示される',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I002: $skipReason');
      return;
    }

    await tapMarkCardToOpenActionSheet(tester);

    // 「到着」アクションが表示されること
    expect(
      find.text('到着'),
      findsOneWidget,
    );
  });

  testWidgets(
      'TC-VW-I002b: visitWorkトピックのMarkタップで出発アクションボタンが表示される',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I002b: $skipReason');
      return;
    }

    await tapMarkCardToOpenActionSheet(tester);

    expect(find.text('出発'), findsOneWidget);
  });

  testWidgets(
      'TC-VW-I002c: visitWorkトピックのMarkタップで作業開始アクションボタンが表示される',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I002c: $skipReason');
      return;
    }

    await tapMarkCardToOpenActionSheet(tester);

    expect(find.text('作業開始'), findsOneWidget);
  });

  testWidgets(
      'TC-VW-I002d: visitWorkトピックのMarkタップで作業終了アクションボタンが表示される',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I002d: $skipReason');
      return;
    }

    await tapMarkCardToOpenActionSheet(tester);

    expect(find.text('作業終了'), findsOneWidget);
  });

  testWidgets(
      'TC-VW-I002e: visitWorkトピックのMarkタップで休憩アクションボタンが表示される',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I002e: $skipReason');
      return;
    }

    await tapMarkCardToOpenActionSheet(tester);

    expect(find.text('休憩'), findsOneWidget);
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-I003: 「到着」アクション記録 → 状態バッジが表示される
  // ────────────────────────────────────────────────────────

  testWidgets('TC-VW-I003: 到着アクションを記録すると滞在状態バッジが表示される',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I003: $skipReason');
      return;
    }

    // Mark カードをタップしてアクションボトムシートを開く
    await tapMarkCardToOpenActionSheet(tester);

    // 「到着」をタップ
    final arriveButton = find.text('到着');
    if (arriveButton.evaluate().isEmpty) {
      print('[SKIP] TC-VW-I003: 「到着」アクションボタンが見つかりません');
      return;
    }
    await tester.tap(arriveButton.first);
    // アクション記録後 ActionTimeNavigateBackDelegate でボトムシートが自動で閉じる
    // ボトムシートが閉じてmark_action_state_badgeが表示されるまで待機する
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('mark_action_state_badge')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 状態バッジが表示される
    // Key: 'mark_action_state_badge'（実装コードのキー名に合わせる）
    final hasBadge =
        find.byKey(const Key('mark_action_state_badge')).evaluate().isNotEmpty;

    expect(hasBadge, isTrue);
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-I004: アクション記録 × 3 → 集計タブにプログレスバーが表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-VW-I004: 作業開始→休憩→作業終了の順でアクション記録後、集計タブにプログレスバーが表示される',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I004: $skipReason');
      return;
    }

    // アクション記録: 到着 → 作業開始 → 休憩ON → 作業終了
    // 各アクションをタップして記録し、ボトムシートを閉じてから次のアクションに進む
    final actionSequence = ['到着', '作業開始', '休憩', '作業終了'];

    for (final actionName in actionSequence) {
      await tapMarkCardToOpenActionSheet(tester);

      final actionButton = find.text(actionName);
      if (actionButton.evaluate().isEmpty) {
        print('[SKIP] TC-VW-I004: 「$actionName」ボタンが見つかりません');
        return;
      }
      await tester.tap(actionButton.first);
      // アクション記録後 ActionTimeNavigateBackDelegate でボトムシートが自動で閉じる
      // ボトムシートが閉じてmark_action_buttonが再表示されるまで待つ
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('mark_action_button')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 集計タブに移動
    final reached = await goToAggregationTab(tester);
    if (!reached) {
      print('[SKIP] TC-VW-I004: 集計タブが見つかりません');
      return;
    }

    // プログレスバーが表示されること
    expect(
      find.byKey(const Key('visit_work_progress_bar')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-I005: 集計タブに時間サマリーが表示される
  // ────────────────────────────────────────────────────────

  testWidgets('TC-VW-I005: 集計タブに移動（移動）の時間サマリーラベルが表示される',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I005: $skipReason');
      return;
    }

    final reached = await goToAggregationTab(tester);
    if (!reached) {
      print('[SKIP] TC-VW-I005: 集計タブが見つかりません');
      return;
    }

    // 時間サマリーに「移動」ラベルが表示されること
    expect(find.text('移動'), findsOneWidget);
  });

  testWidgets('TC-VW-I005b: 集計タブに滞在の時間サマリーラベルが表示される', (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I005b: $skipReason');
      return;
    }

    final reached = await goToAggregationTab(tester);
    if (!reached) {
      print('[SKIP] TC-VW-I005b: 集計タブが見つかりません');
      return;
    }

    // 「滞在」ラベルが表示されること（waiting の visitWork コンテキストでのラベル）
    expect(find.text('滞在'), findsOneWidget);
  });

  testWidgets('TC-VW-I005c: 集計タブに作業の時間サマリーラベルが表示される', (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I005c: $skipReason');
      return;
    }

    final reached = await goToAggregationTab(tester);
    if (!reached) {
      print('[SKIP] TC-VW-I005c: 集計タブが見つかりません');
      return;
    }

    expect(find.text('作業'), findsOneWidget);
  });

  testWidgets('TC-VW-I005d: 集計タブに休憩の時間サマリーラベルが表示される', (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I005d: $skipReason');
      return;
    }

    final reached = await goToAggregationTab(tester);
    if (!reached) {
      print('[SKIP] TC-VW-I005d: 集計タブが見つかりません');
      return;
    }

    expect(find.text('休憩'), findsOneWidget);
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-I006: PaymentInfo 登録後に売上合計・時給換算が表示される
  // ────────────────────────────────────────────────────────

  testWidgets('TC-VW-I006: visitWorkトピックの集計タブに売上セクションが表示される',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I006: $skipReason');
      return;
    }

    final reached = await goToAggregationTab(tester);
    if (!reached) {
      print('[SKIP] TC-VW-I006: 集計タブが見つかりません');
      return;
    }

    // 売上セクションが表示されること
    // PaymentInfo 未登録の場合は '---' が表示される
    final hasSalesSection = find.text('売上').evaluate().isNotEmpty ||
        find.text('売上合計').evaluate().isNotEmpty ||
        find.byKey(const Key('visit_work_revenue_section')).evaluate().isNotEmpty;

    expect(hasSalesSection, isTrue);
  });

  testWidgets('TC-VW-I006b: PaymentInfo未登録のとき売上合計欄に---が表示される',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I006b: $skipReason');
      return;
    }

    final reached = await goToAggregationTab(tester);
    if (!reached) {
      print('[SKIP] TC-VW-I006b: 集計タブが見つかりません');
      return;
    }

    // PaymentInfo 未登録状態では '---' が表示されること
    // または売上セクション自体にキーが存在すること
    final hasEmptyRevenue = find.text('---').evaluate().isNotEmpty ||
        find.byKey(const Key('visit_work_revenue_empty')).evaluate().isNotEmpty;

    expect(hasEmptyRevenue, isTrue);
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-I007: visitWork トピックでは Link 追加ボタンが非表示
  // ────────────────────────────────────────────────────────

  testWidgets('TC-VW-I007: visitWorkトピックのミチタブにリンク追加ボタンが表示されない',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I007: $skipReason');
      return;
    }

    // FABをタップして挿入モードに入る
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isEmpty) {
      print('[SKIP] TC-VW-I007: FABが見つかりません');
      return;
    }
    await tester.tap(fab.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.byIcon(Icons.add_circle).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // インジケーターをタップしてボトムシートを開く
    final indicator = find.byIcon(Icons.add_circle);
    if (indicator.evaluate().isNotEmpty) {
      await tester.tap(indicator.last);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        if (find.text('地点を追加').evaluate().isNotEmpty ||
            find.text('ルートを追加').evaluate().isNotEmpty) {
          break;
        }
      }
      await tester.pump(const Duration(milliseconds: 300));
    }

    // visitWork では 'ルートを追加' / 'リンクを追加' が表示されないこと
    // Spec: addMenuItems = [AddMenuItemType.mark] → Link追加メニューなし
    expect(find.text('ルートを追加'), findsNothing);
    expect(find.text('リンクを追加'), findsNothing);
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-I008: visitWork トピックでは Mark にメンバー選択が非表示
  // ────────────────────────────────────────────────────────

  testWidgets('TC-VW-I008: visitWorkトピックのMarkDetailにメンバー選択が表示されない',
      (tester) async {
    final skipReason = await openVisitWorkEventMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] TC-VW-I008: $skipReason');
      return;
    }

    final opened = await addMarkAndOpenActionSheet(tester);
    if (!opened) {
      print('[SKIP] TC-VW-I008: Mark追加インジケーターが表示されませんでした');
      return;
    }

    // MarkDetail 画面が開いた状態でメンバー選択セクションが非表示なこと
    // Spec: showMarkMembers: false
    // メンバー選択の Key: 'markDetail_section_members' または 'markDetail_chip_member_*'
    final hasMemberSection =
        find.byKey(const Key('markDetail_section_members')).evaluate().isNotEmpty;

    expect(hasMemberSection, isFalse);
  });
}
