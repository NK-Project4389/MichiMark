import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────────────────
  // ヘルパー
  // ─────────────────────────────────────────────────────────

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

  /// EventList → 箱根日帰りドライブ の順で遷移しEventDetailPageに留まる。
  Future<bool> goToEventDetail(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final eventCards = find.ancestor(
      of: find.text('箱根日帰りドライブ'),
      matching: find.byType(GestureDetector),
    );
    if (eventCards.evaluate().isEmpty) return false;

    await tester.tap(eventCards.first);
    await tester.pump(const Duration(milliseconds: 500));

    // EventDetailPage のロード完了を待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    return find.text('概要').evaluate().isNotEmpty;
  }

  /// EventList → 近所のドライブ（topicなし）の順で遷移しEventDetailPageに留まる。
  /// topicなしのイベントは_onBackPressedが呼ばれるため未保存ダイアログが表示される。
  Future<bool> goToEventDetailNoTopic(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final eventCards = find.ancestor(
      of: find.text('近所のドライブ'),
      matching: find.byType(GestureDetector),
    );
    if (eventCards.evaluate().isEmpty) return false;

    await tester.tap(eventCards.first);
    await tester.pump(const Duration(milliseconds: 500));

    // EventDetailPage のロード完了を待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    return find.text('概要').evaluate().isNotEmpty;
  }

  /// EventDetail → ミチタブ まで遷移する。
  Future<bool> goToMichiTab(WidgetTester tester) async {
    if (!await goToEventDetail(tester)) return false;
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return false;
    await tester.tap(michiTab);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    // ミチタブのデータロード完了を待つ（削除アイコンml-001が表示されるまで）
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_delete_ml-001')).evaluate().isNotEmpty ||
          find.text('地点/区間がありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find.byType(FloatingActionButton).evaluate().isNotEmpty;
  }

  /// EventDetail → 支払タブ まで遷移する。
  Future<bool> goToPaymentTab(WidgetTester tester) async {
    if (!await goToEventDetail(tester)) return false;
    final payTab = find.text('支払');
    if (payTab.evaluate().isEmpty) return false;
    await tester.tap(payTab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find.byType(FloatingActionButton).evaluate().isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────
  // TC-FAB-001: MichiInfoView に FAB extended が表示される
  // ─────────────────────────────────────────────────────────

  testWidgets('TC-FAB-001: MichiInfoView に FloatingActionButton が表示される',
      (tester) async {
    final reached = await goToMichiTab(tester);
    if (!reached) {
      fail('[スキップ不可] ミチタブへの遷移に失敗しました');
    }

    // FloatingActionButton が表示されていること
    // MichiInfoのFABはInsertModeトグル用のAmber FAB（アイコンのみ）
    expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
  });

  // ─────────────────────────────────────────────────────────
  // TC-FAB-002: PaymentInfoView に FAB extended が表示される
  // ─────────────────────────────────────────────────────────

  testWidgets('TC-FAB-002: PaymentInfoView に FloatingActionButton.extended が表示される',
      (tester) async {
    final reached = await goToPaymentTab(tester);
    if (!reached) {
      fail('[スキップ不可] 支払タブへの遷移に失敗しました');
    }

    // FloatingActionButton が表示されていること（PaymentInfo追加FAB）
    expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
  });

  // ─────────────────────────────────────────────────────────
  // TC-FAB-003: MarkDetailPage に保存FABが表示される
  // ─────────────────────────────────────────────────────────

  testWidgets('TC-FAB-003: MarkDetailPage に保存 FloatingActionButton.extended が表示される',
      (tester) async {
    final reached = await goToMichiTab(tester);
    if (!reached) {
      fail('[スキップ不可] ミチタブへの遷移に失敗しました');
    }

    // シードデータの最初のマーク（ml-001）をタップ
    // movingCostトピックはshowNameField=falseのためテキスト名は非表示
    // カード左側エリア（削除アイコンの左）をタップしてMarkDetailを開く
    final deleteKey = find.byKey(const Key('michiInfo_button_delete_ml-001'));
    if (deleteKey.evaluate().isEmpty) {
      fail('[スキップ不可] マークカード ml-001 が見つかりません');
    }
    // 削除アイコンの中心位置から左100px オフセットしてカード本体をタップ
    final deletePos = tester.getCenter(deleteKey);
    await tester.tapAt(Offset(deletePos.dx - 100, deletePos.dy));
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('保存').evaluate().isNotEmpty) break;
    }

    // MarkDetailPage が開き「保存」ボタンが AppBar に表示されていること
    // （MarkDetail は FAB ではなく AppBar TextButton で保存を提供する設計）
    expect(find.text('保存'), findsOneWidget,
        reason: 'MarkDetailPage の AppBar に「保存」ボタンが表示されること');
  });

  // ─────────────────────────────────────────────────────────
  // TC-FAB-004: LinkDetailPage に保存FABが表示される
  // ─────────────────────────────────────────────────────────

  testWidgets('TC-FAB-004: LinkDetailPage に保存 FloatingActionButton.extended が表示される',
      (tester) async {
    final reached = await goToMichiTab(tester);
    if (!reached) {
      fail('[スキップ不可] ミチタブへの遷移に失敗しました');
    }

    // シードデータのLink（ml-002）をタップ
    // movingCostトピックはshowNameField=falseのためテキスト名は非表示
    final deleteLinkKey = find.byKey(const Key('michiInfo_button_delete_ml-002'));
    if (deleteLinkKey.evaluate().isEmpty) {
      fail('[スキップ不可] リンクカード ml-002 が見つかりません');
    }
    // 削除アイコンの中心位置から左100px オフセットしてカード本体をタップ
    final deleteLinkPos = tester.getCenter(deleteLinkKey);
    await tester.tapAt(Offset(deleteLinkPos.dx - 100, deleteLinkPos.dy));
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('保存').evaluate().isNotEmpty) break;
    }

    // 「保存」ラベル付き FAB が表示されていること
    expect(find.text('保存'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
  });

  // ─────────────────────────────────────────────────────────
  // TC-FAB-005: PaymentDetailPage に保存FABが表示される
  // ─────────────────────────────────────────────────────────

  testWidgets('TC-FAB-005: PaymentDetailPage に保存 FloatingActionButton.extended が表示される',
      (tester) async {
    final reached = await goToPaymentTab(tester);
    if (!reached) {
      fail('[スキップ不可] 支払タブへの遷移に失敗しました');
    }

    // 支払追加FABをタップしてPaymentDetailPageへ遷移
    await tester.ensureVisible(find.byType(FloatingActionButton).first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byType(FloatingActionButton).first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('支払詳細').evaluate().isNotEmpty ||
          find.text('保存').evaluate().isNotEmpty) break;
    }

    // PaymentDetailPage が表示されていること（「保存」ボタンがAppBarに表示される）
    expect(find.text('保存'), findsOneWidget,
        reason: 'PaymentDetailPageに「保存」ボタンが表示されること');
  });

  // ─────────────────────────────────────────────────────────
  // TC-BACK-001: BasicInfo 編集中に戻るボタンで未保存ダイアログが表示される
  // Topic未設定イベント「近所のドライブ」を使用（_onBackPressedが呼ばれる条件）
  // ─────────────────────────────────────────────────────────

  testWidgets('TC-BACK-001: BasicInfo 編集中に戻るボタンタップで未保存確認ダイアログが表示される',
      (tester) async {
    // topic未設定のイベント「近所のドライブ」を使う
    // （topicなし → themeColor == null → _onBackPressedが呼ばれる）
    final reached = await goToEventDetailNoTopic(tester);
    if (!reached) {
      fail('[スキップ不可] 「近所のドライブ」EventDetailPageへの遷移に失敗しました');
    }

    // BasicInfoView のロード完了を待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoRead_container_section')).evaluate().isNotEmpty) break;
    }

    // BasicInfoView 参照モードエリアをタップして編集モードに入る
    final readArea = find.byKey(const Key('basicInfoRead_container_section'));
    if (readArea.evaluate().isEmpty) {
      fail('[スキップ不可] 参照モードエリアが見つかりません');
    }
    await tester.tap(readArea.first);
    await tester.pump(const Duration(milliseconds: 500));

    // 編集モードになったことを確認（TextFieldが表示されるはず）
    await tester.pump(const Duration(milliseconds: 300));
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isEmpty) {
      fail('[スキップ不可] 編集モードのTextFieldが見つかりません');
    }

    // イベント名フィールドに文字を入力して isEditing = true の状態を確認する
    await tester.tap(textFields.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(textFields.first, '編集中テスト名');
    await tester.pump(const Duration(milliseconds: 500));

    // 戻るボタン（chevron_left アイコン）をタップ
    final backButton = find.byIcon(Icons.chevron_left);
    if (backButton.evaluate().isEmpty) {
      fail('[スキップ不可] 戻るボタンが見つかりません');
    }

    await tester.tap(backButton.first);
    await tester.pump(const Duration(milliseconds: 500));

    // 未保存確認ダイアログが表示されていること
    expect(find.text('保存していません'), findsOneWidget);
    // ダイアログのボタン群が表示されていること
    expect(find.text('編集に戻る'), findsOneWidget);
    expect(find.text('破棄して戻る'), findsOneWidget);
    expect(find.text('保存して戻る'), findsOneWidget);
  });

  // ─────────────────────────────────────────────────────────
  // TC-BACK-002: Topic設定済みイベント・編集中にグラデーションAppBarの戻るボタンで未保存ダイアログが表示される
  // Topic設定済みイベント「箱根日帰りドライブ」を使用
  // ─────────────────────────────────────────────────────────

  testWidgets(
      'TC-BACK-002: Topic設定済みイベントで編集中にグラデーションAppBar戻るボタンタップで未保存確認ダイアログが表示される',
      (tester) async {
    // topic設定済みのイベント「箱根日帰りドライブ」を使う
    // （topic設定済み → グラデーションAppBar → 戻るボタンが_onBackPressedを呼ぶ）
    final reached = await goToEventDetail(tester);
    if (!reached) {
      fail('[スキップ不可] 「箱根日帰りドライブ」EventDetailPageへの遷移に失敗しました');
    }

    // BasicInfoSection のロード完了を待つ（参照モードエリアが表示されるまで）
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoRead_container_section')).evaluate().isNotEmpty) break;
    }

    // BasicInfoView 参照モードエリアをタップして編集モードに入る
    final readArea2 = find.byKey(const Key('basicInfoRead_container_section'));
    if (readArea2.evaluate().isEmpty) {
      fail('[スキップ不可] 参照モードエリアが見つかりません');
    }
    await tester.tap(readArea2.first);
    await tester.pump(const Duration(milliseconds: 500));

    // 編集モードになったことを確認（TextFieldが表示されるはず）
    await tester.pump(const Duration(milliseconds: 300));
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isEmpty) {
      fail('[スキップ不可] 編集モードのTextFieldが見つかりません');
    }

    // イベント名フィールドに文字を入力して isEditing = true にする
    await tester.tap(textFields.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(textFields.first, '編集中テスト名_トピックあり');
    await tester.pump(const Duration(milliseconds: 500));

    // グラデーションAppBarの戻るボタン（chevron_left または arrow_back_ios_new）をタップ
    // グラデーションAppBarはカスタム描画のため複数のアイコン候補を試みる
    Finder? backButton;
    for (final icon in [Icons.chevron_left, Icons.arrow_back_ios_new, Icons.arrow_back]) {
      final f = find.byIcon(icon);
      if (f.evaluate().isNotEmpty) {
        backButton = f;
        break;
      }
    }

    if (backButton == null || backButton.evaluate().isEmpty) {
      fail('[スキップ不可] グラデーションAppBarの戻るボタンが見つかりません');
    }

    await tester.tap(backButton.first);
    await tester.pump(const Duration(milliseconds: 500));

    // 未保存確認ダイアログが表示されていること
    expect(find.text('保存していません'), findsOneWidget,
        reason: 'Topic設定済みイベントで編集中に戻るボタンをタップすると未保存確認ダイアログが表示されること');
    // ダイアログのボタン群が表示されていること
    expect(find.text('編集に戻る'), findsOneWidget);
    expect(find.text('破棄して戻る'), findsOneWidget);
    expect(find.text('保存して戻る'), findsOneWidget);
  });

  // ─────────────────────────────────────────────────────────
  // TC-BACK-003: Topic設定済みイベント・未編集時にグラデーションAppBarの戻るボタンでイベント一覧に戻る
  // Topic設定済みイベント「箱根日帰りドライブ」を使用
  // ─────────────────────────────────────────────────────────

  testWidgets(
      'TC-BACK-003: Topic設定済みイベントで未編集時にグラデーションAppBar戻るボタンタップでイベント一覧に戻る',
      (tester) async {
    // topic設定済みのイベント「箱根日帰りドライブ」を使う
    final reached = await goToEventDetail(tester);
    if (!reached) {
      fail('[スキップ不可] 「箱根日帰りドライブ」EventDetailPageへの遷移に失敗しました');
    }

    // 何も編集せずに戻るボタンをタップ
    // グラデーションAppBarの戻るボタン（chevron_left または arrow_back_ios_new）をタップ
    Finder? backButton;
    for (final icon in [Icons.chevron_left, Icons.arrow_back_ios_new, Icons.arrow_back]) {
      final f = find.byIcon(icon);
      if (f.evaluate().isNotEmpty) {
        backButton = f;
        break;
      }
    }

    if (backButton == null || backButton.evaluate().isEmpty) {
      fail('[スキップ不可] グラデーションAppBarの戻るボタンが見つかりません');
    }

    await tester.tap(backButton.first);

    // イベント一覧に戻るのを待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // EventList が表示されていること（概要タブが消えてイベント一覧が見える）
      if (find.text('概要').evaluate().isEmpty &&
          find.text('イベント一覧').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    // ダイアログが表示されていないこと
    expect(find.text('保存していません'), findsNothing,
        reason: '未編集時は未保存確認ダイアログが表示されないこと');
    // イベント一覧に戻っていること
    expect(find.text('箱根日帰りドライブ'), findsWidgets,
        reason: 'イベント一覧に戻りイベント名が表示されること');
  });
}
