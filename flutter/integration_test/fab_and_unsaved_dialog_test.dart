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
      if (find.text('イベント').evaluate().isNotEmpty) break;
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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

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
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
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

  testWidgets('TC-FAB-001: MichiInfoView に FloatingActionButton.extended が表示される',
      (tester) async {
    final reached = await goToMichiTab(tester);
    if (!reached) {
      fail('[スキップ不可] ミチタブへの遷移に失敗しました');
    }

    // FloatingActionButton が表示されていること
    expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
    // FABに「追加」ラベルが含まれること（extended の証）
    expect(find.text('追加'), findsOneWidget);
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

    // FloatingActionButton が表示されていること
    expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
    // FABに「追加」ラベルが含まれること（extended の証）
    expect(find.text('追加'), findsOneWidget);
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

    // シードデータの最初のマーク「自宅出発」をタップ
    final markCard = find.text('自宅出発');
    if (markCard.evaluate().isEmpty) {
      fail('[スキップ不可] マークカード「自宅出発」が見つかりません');
    }
    await tester.tap(markCard.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('保存').evaluate().isNotEmpty) break;
    }

    // 「保存」ラベル付き FAB が表示されていること
    expect(find.text('保存'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
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

    // シードデータのLink「東名高速」をタップ
    final linkCard = find.text('東名高速');
    if (linkCard.evaluate().isEmpty) {
      fail('[スキップ不可] リンクカード「東名高速」が見つかりません');
    }
    await tester.tap(linkCard.first);
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
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton).first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('支払詳細').evaluate().isNotEmpty) break;
    }

    // 「保存」ラベル付き FAB が表示されていること
    expect(find.text('保存'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
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

    // BasicInfoView 参照モードの「編集」アイコンボタン (Icons.edit) をタップ
    final editIconButton = find.byIcon(Icons.edit);
    if (editIconButton.evaluate().isEmpty) {
      fail('[スキップ不可] 編集アイコンボタンが見つかりません');
    }
    await tester.tap(editIconButton.first);
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    // 未保存確認ダイアログが表示されていること
    expect(find.text('保存していません'), findsOneWidget);
    // ダイアログのボタン群が表示されていること
    expect(find.text('編集に戻る'), findsOneWidget);
    expect(find.text('破棄して戻る'), findsOneWidget);
    expect(find.text('保存して戻る'), findsOneWidget);
  });
}
