// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: BUG-4 招待ボタン遷移先修正（招待コード入力→招待リンク共有）
///
/// バグ内容:
/// イベント詳細の「メンバーを招待」ボタンが招待コード入力画面に遷移しているが、
/// 正しくは招待リンク作成・共有画面（INV-4: InviteLinkShare）へ遷移させるべき。
///
/// Spec: docs/Spec/Features/FS-invitation_link_share.md §20
///
/// テストシナリオ: TC-BUG4-001 〜 TC-BUG4-002
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータにイベントが1件以上存在すること
///   - 現在のユーザーが owner 権限であること（スタブで userRole = InvitationRole.owner を返す）
///   - F-7（招待UI配置）の実装が完了していること
///   - INV-4（招待リンク生成・共有）の実装が完了していること

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

  /// アプリを起動してイベント一覧が表示されるまで待つ。
  Future<void> startApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    for (var i = 0; i < 30; i++) {
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

  /// イベント一覧から最初のイベントを開く。
  Future<bool> openFirstEvent(WidgetTester tester) async {
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final cards = find.byType(GestureDetector);
    if (cards.evaluate().isEmpty) return false;
    await tester.tap(cards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 概要タブの招待セクションまでスクロールし、「メンバーを招待」ボタンを表示する。
  Future<bool> scrollToInviteLinkButton(WidgetTester tester) async {
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('overview_sectionLabel_basicInfo')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 招待セクションまでスクロール
    for (var i = 0; i < 15; i++) {
      if (find.byKey(const Key('overview_button_inviteLink')).evaluate().isNotEmpty) return true;
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        await tester.drag(scrollables.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
    return find.byKey(const Key('overview_button_inviteLink')).evaluate().isNotEmpty;
  }

  // ────────────────────────────────────────────────────────
  // TC-BUG4-001: 招待ボタンをタップすると招待リンク共有画面が表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-BUG4-001: 「メンバーを招待」ボタンをタップするとInviteLinkShare画面（BottomSheet）が表示されること',
    (tester) async {
      await startApp(tester);

      final opened = await openFirstEvent(tester);
      if (!opened) {
        print('[SKIP] TC-BUG4-001: イベントが見つかりませんでした');
        return;
      }

      final found = await scrollToInviteLinkButton(tester);
      if (!found) {
        print('[SKIP] TC-BUG4-001: 「メンバーを招待」ボタンが見つかりません（userRoleがownerでない可能性）');
        return;
      }

      // 「メンバーを招待」ボタンをタップ
      final inviteLinkButton = find.byKey(const Key('overview_button_inviteLink'));
      await tester.ensureVisible(inviteLinkButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(inviteLinkButton.first);

      // 招待リンク共有画面（BottomSheet）が表示されるまで待つ
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('inviteLinkShare_sheet_root')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      // 期待結果: inviteLinkShare_sheet_root が表示される（招待リンク共有画面が開く）
      expect(
        find.byKey(const Key('inviteLinkShare_sheet_root')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'TC-BUG4-001b: InviteLinkShare画面に「招待リンクを作成」ボタンが表示されること（招待コード入力画面ではない）',
    (tester) async {
      await startApp(tester);

      final opened = await openFirstEvent(tester);
      if (!opened) {
        print('[SKIP] TC-BUG4-001b: イベントが見つかりませんでした');
        return;
      }

      final found = await scrollToInviteLinkButton(tester);
      if (!found) {
        print('[SKIP] TC-BUG4-001b: 「メンバーを招待」ボタンが見つかりません（userRoleがownerでない可能性）');
        return;
      }

      final inviteLinkButton = find.byKey(const Key('overview_button_inviteLink'));
      await tester.ensureVisible(inviteLinkButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(inviteLinkButton.first);

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('inviteLinkShare_sheet_root')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      // スクロールして「招待リンクを作成」ボタンを表示
      for (var i = 0; i < 5; i++) {
        if (find.byKey(const Key('inviteLinkShare_button_create')).evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.last, const Offset(0, -200));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      // 期待結果: 招待リンク共有画面のボタンが表示されること（招待コード入力画面ではない）
      expect(
        find.byKey(const Key('inviteLinkShare_button_create')),
        findsOneWidget,
      );

      // 負の条件: 招待コード入力画面のテキストフィールドが表示されていないこと
      expect(
        find.byKey(const Key('invite_code_text_field')),
        findsNothing,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-BUG4-002: 招待リンク共有画面を閉じると元のイベント詳細に戻る
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-BUG4-002: InviteLinkShare画面を閉じるとイベント詳細画面に戻ること',
    (tester) async {
      await startApp(tester);

      final opened = await openFirstEvent(tester);
      if (!opened) {
        print('[SKIP] TC-BUG4-002: イベントが見つかりませんでした');
        return;
      }

      final found = await scrollToInviteLinkButton(tester);
      if (!found) {
        print('[SKIP] TC-BUG4-002: 「メンバーを招待」ボタンが見つかりません（userRoleがownerでない可能性）');
        return;
      }

      final inviteLinkButton = find.byKey(const Key('overview_button_inviteLink'));
      await tester.ensureVisible(inviteLinkButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(inviteLinkButton.first);

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('inviteLinkShare_sheet_root')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      // BottomSheetが表示されていることを確認
      expect(
        find.byKey(const Key('inviteLinkShare_sheet_root')),
        findsOneWidget,
      );

      // BottomSheetの背景（ダークオーバーレイ）をタップして閉じる
      // ModalBarrier を直接タップする代わりに、BottomSheet外の座標をタップする
      await tester.tapAt(const Offset(200, 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('inviteLinkShare_sheet_root')).evaluate().isEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      // 期待結果: BottomSheetが閉じて、inviteLinkShare_sheet_root が表示されていないこと
      expect(
        find.byKey(const Key('inviteLinkShare_sheet_root')),
        findsNothing,
      );

      // イベント詳細画面が表示されていることを確認（概要タブのテキストが見える）
      expect(
        find.text('概要'),
        findsWidgets,
      );
    },
  );
}
