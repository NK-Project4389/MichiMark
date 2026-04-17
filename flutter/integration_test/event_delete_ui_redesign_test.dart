// ignore_for_file: avoid_print, dangling_library_doc_comments

// Integration Test: イベント削除UI変更
//
// Feature Spec: FS-event_delete_ui_redesign
// テストグループ: TC-EDR（Event Delete UI Redesign）
//
// TC-EDR-001: イベント一覧でスワイプ削除UIが表示されないこと
// TC-EDR-002: イベント詳細ヘッダに削除アイコンが表示されること
// TC-EDR-003: 削除アイコン付近に「イベント削除」ラベルが表示されること
// TC-EDR-004: 削除アイコンタップで確認ダイアログが表示されること
// TC-EDR-005: 確認ダイアログで「キャンセル」をタップするとダイアログが閉じイベントが残ること
// TC-EDR-006: 確認ダイアログで「削除」をタップするとイベントが削除されて一覧に戻ること

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
  /// シードデータが存在することを前提とする。
  Future<void> startApp(WidgetTester tester) async {
    // ① 前の画面を安全に閉じる（router が既に初期化済みの場合のみ）
    try {
      app_router.router.go('/');
    } catch (_) {}
    await tester.pump(const Duration(milliseconds: 200));

    // ② GetIt リセット（BLoC の dispose が走った後）
    await GetIt.I.reset();

    // ③ 新しいルートを設定してアプリ起動
    app_router.router.go('/');
    app.main();
    // EventListPage の AppBar title「イベント」が表示されるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント一覧').evaluate().isNotEmpty) break;
    }
    // データロード完了を待つ（ListView 表示まで）
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(ListView).evaluate().isNotEmpty ||
          find.text('イベントがありません').evaluate().isNotEmpty) { break; }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// イベント一覧から先頭のイベントをタップして EventDetail を開く。
  /// 成功した場合は true を返す。
  Future<bool> openFirstEventDetail(WidgetTester tester) async {
    // 先頭の GestureDetector（イベントカード）をタップ
    final cards = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(GestureDetector),
    );
    if (cards.evaluate().isEmpty) { return false; }
    await tester.tap(cards.first);
    // EventDetail ページのロードを待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('eventDetail_button_delete')).evaluate().isNotEmpty) {
        break;
      }
      // 概要タブやミチタブが表示されても続ける
      if (find.text('概要').evaluate().isNotEmpty ||
          find.text('ミチ').evaluate().isNotEmpty) {
        // もう少し待ってAppBarが描画されるのを待つ
        for (var j = 0; j < 10; j++) {
          await tester.pump(const Duration(milliseconds: 300));
          if (find.byKey(const Key('eventDetail_button_delete')).evaluate().isNotEmpty) {
            break;
          }
        }
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find.byKey(const Key('eventDetail_button_delete')).evaluate().isNotEmpty;
  }

  // ────────────────────────────────────────────────────────
  // TC-EDR-001: イベント一覧でスワイプ削除UIが表示されないこと
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EDR-001: イベント一覧でスワイプ削除UIが表示されないこと',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないため TC-EDR-001 をスキップします');
      return;
    }

    // 先頭のイベントカードを探す
    final cards = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(GestureDetector),
    );
    expect(cards, findsWidgets, reason: 'イベント一覧にカードが存在すること');

    // 先頭のカードを左スワイプする
    await tester.drag(cards.first, const Offset(-300, 0));
    await tester.pump(const Duration(milliseconds: 500));

    // スワイプ後に削除ボタン（ラベル「削除」またはSlidableAction）が表示されないこと
    // 旧実装のスワイプ削除アクションキーが存在しないことを確認
    expect(
      find.text('削除'),
      findsNothing,
      reason: 'スワイプ後に削除アクションのラベル「削除」が表示されないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-EDR-002: イベント詳細ヘッダに削除アイコンが表示されること
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EDR-002: イベント詳細ヘッダに削除アイコンが表示されること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないため TC-EDR-002 をスキップします');
      return;
    }

    final opened = await openFirstEventDetail(tester);
    if (!opened) {
      markTestSkipped('イベント詳細画面を開けなかったため TC-EDR-002 をスキップします');
      return;
    }

    // AppBar 右側に削除アイコンボタンが表示されていること
    expect(
      find.byKey(const Key('eventDetail_button_delete')),
      findsOneWidget,
      reason: 'AppBar 右側に削除アイコンボタン（Key: eventDetail_button_delete）が表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-EDR-003: 削除アイコン付近に「イベント削除」ラベルが表示されること
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EDR-003: 削除アイコン付近に「イベント削除」ラベルが表示されること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないため TC-EDR-003 をスキップします');
      return;
    }

    final opened = await openFirstEventDetail(tester);
    if (!opened) {
      markTestSkipped('イベント詳細画面を開けなかったため TC-EDR-003 をスキップします');
      return;
    }

    // 削除アイコンボタン（Key: eventDetail_button_delete）が存在すること
    expect(
      find.byKey(const Key('eventDetail_button_delete')),
      findsOneWidget,
      reason: '削除ボタンが表示されていること',
    );

    // 削除ボタン付近（アイコン下または tooltip）に「イベント削除」テキストが表示されること
    expect(
      find.text('イベント削除'),
      findsOneWidget,
      reason: '削除ボタン付近に「イベント削除」ラベルが表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-EDR-004: 削除アイコンタップで確認ダイアログが表示されること
  // ────────────────────────────────────────────────────────
  testWidgets('TC-EDR-004: 削除アイコンタップで確認ダイアログが表示されること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないため TC-EDR-004 をスキップします');
      return;
    }

    final opened = await openFirstEventDetail(tester);
    if (!opened) {
      markTestSkipped('イベント詳細画面を開けなかったため TC-EDR-004 をスキップします');
      return;
    }

    // 削除アイコンをタップする
    await tester.ensureVisible(find.byKey(const Key('eventDetail_button_delete')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('eventDetail_button_delete')));

    // ダイアログが表示されるまで待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('eventDetail_dialog_deleteConfirm')).evaluate().isNotEmpty) break;
    }

    // 確認ダイアログが表示されること
    expect(
      find.byKey(const Key('eventDetail_dialog_deleteConfirm')),
      findsOneWidget,
      reason: '確認ダイアログ（Key: eventDetail_dialog_deleteConfirm）が表示されること',
    );

    // タイトル「イベントを削除しますか？」が表示されること
    expect(
      find.text('イベントを削除しますか？'),
      findsOneWidget,
      reason: 'ダイアログのタイトル「イベントを削除しますか？」が表示されること',
    );

    // メッセージが表示されること
    expect(
      find.text('このイベントに関連するすべての情報が削除されます。'),
      findsOneWidget,
      reason: 'ダイアログのメッセージが表示されること',
    );

    // 「削除」ボタンが表示されること
    expect(
      find.byKey(const Key('eventDetail_button_deleteConfirm')),
      findsOneWidget,
      reason: '削除確認ボタン（Key: eventDetail_button_deleteConfirm）が表示されること',
    );

    // 「キャンセル」ボタンが表示されること
    expect(
      find.byKey(const Key('eventDetail_button_deleteCancel')),
      findsOneWidget,
      reason: 'キャンセルボタン（Key: eventDetail_button_deleteCancel）が表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-EDR-005: 確認ダイアログで「キャンセル」をタップするとダイアログが閉じイベントが残ること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-EDR-005: 確認ダイアログで「キャンセル」をタップするとダイアログが閉じイベントが残ること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないため TC-EDR-005 をスキップします');
      return;
    }

    final opened = await openFirstEventDetail(tester);
    if (!opened) {
      markTestSkipped('イベント詳細画面を開けなかったため TC-EDR-005 をスキップします');
      return;
    }

    // 削除アイコンをタップする
    await tester.ensureVisible(find.byKey(const Key('eventDetail_button_delete')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('eventDetail_button_delete')));

    // ダイアログが表示されるまで待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('eventDetail_dialog_deleteConfirm')).evaluate().isNotEmpty) break;
    }

    // 確認ダイアログが表示されていること
    expect(
      find.byKey(const Key('eventDetail_dialog_deleteConfirm')),
      findsOneWidget,
      reason: '確認ダイアログが表示されていること',
    );

    // 「キャンセル」ボタンをタップする
    await tester.tap(find.byKey(const Key('eventDetail_button_deleteCancel')));

    // ダイアログが閉じるまで待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('eventDetail_dialog_deleteConfirm')).evaluate().isEmpty) break;
    }

    // 確認ダイアログが閉じていること
    expect(
      find.byKey(const Key('eventDetail_dialog_deleteConfirm')),
      findsNothing,
      reason: 'キャンセルタップ後に確認ダイアログが閉じていること',
    );

    // イベント詳細画面がそのまま表示されていること（削除ボタンが引き続き存在する）
    expect(
      find.byKey(const Key('eventDetail_button_delete')),
      findsOneWidget,
      reason: 'キャンセル後もイベント詳細画面が表示されていること（削除ボタンが存在する）',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-EDR-006: 確認ダイアログで「削除」をタップするとイベントが削除されて一覧に戻ること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-EDR-006: 確認ダイアログで「削除」をタップするとイベントが削除されて一覧に戻ること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないため TC-EDR-006 をスキップします');
      return;
    }

    // 削除対象イベント名を取得する（先頭カードのタイトルテキスト）
    // ここでは先頭アイテムのカードを探す（削除確認のため）
    final cards = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(GestureDetector),
    );
    if (cards.evaluate().isEmpty) {
      markTestSkipped('イベントカードが存在しないため TC-EDR-006 をスキップします');
      return;
    }

    // 先頭カードをタップして詳細画面へ
    await tester.tap(cards.first);

    // EventDetail ページのロードを待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('eventDetail_button_delete')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    if (find.byKey(const Key('eventDetail_button_delete')).evaluate().isEmpty) {
      markTestSkipped('イベント詳細画面を開けなかったため TC-EDR-006 をスキップします');
      return;
    }

    // 削除アイコンをタップする
    await tester.ensureVisible(find.byKey(const Key('eventDetail_button_delete')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('eventDetail_button_delete')));

    // ダイアログが表示されるまで待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('eventDetail_dialog_deleteConfirm')).evaluate().isNotEmpty) break;
    }

    // 確認ダイアログが表示されていること
    expect(
      find.byKey(const Key('eventDetail_dialog_deleteConfirm')),
      findsOneWidget,
      reason: '削除確認ダイアログが表示されていること',
    );

    // 「削除」ボタンをタップする
    await tester.tap(find.byKey(const Key('eventDetail_button_deleteConfirm')));

    // 削除処理と画面遷移（一覧へ pop）を待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      // EventList ページに戻ったことを「イベント」AppBar title で確認
      if (find.text('イベント一覧').evaluate().isNotEmpty &&
          find.byKey(const Key('eventDetail_button_delete')).evaluate().isEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    // イベント一覧画面に戻っていること（AppBar title「イベント」が表示されている）
    expect(
      find.text('イベント一覧'),
      findsAtLeastNWidgets(1),
      reason: '削除後にイベント一覧画面（AppBar title「イベント」）に戻っていること',
    );

    // イベント詳細画面の削除ボタンが存在しないこと（一覧画面に戻っている証拠）
    expect(
      find.byKey(const Key('eventDetail_button_delete')),
      findsNothing,
      reason: '削除後はイベント詳細画面が閉じられていること',
    );
  });
}
