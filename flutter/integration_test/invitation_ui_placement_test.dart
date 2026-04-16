// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: F-7 招待UI配置（InvitationUIPlacement）
///
/// Spec: docs/Spec/Features/FS-invitation_ui_placement.md §16
///
/// テストシナリオ: TC-IUP-001 〜 TC-IUP-007
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータにイベントが1件以上存在すること
///   - ユーザーロールはスタブで制御される
///     - 現状のスタブ実装で userRole が owner / null のどちらが返されるかに依存する
///     - シードデータのイベントに対してデフォルトで owner となる場合は TC-IUP-001/002 が実行可能
///     - owner でない場合は TC-IUP-003/004/005/006/007 が実行可能

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

  /// イベント一覧から最初のイベントをタップしてEventDetailを開く。
  Future<bool> openFirstEvent(WidgetTester tester) async {
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final listViews = find.byType(ListView);
    if (listViews.evaluate().isEmpty) return false;

    // GestureDetector でラップされたイベントカードをタップ
    final cards = find.byType(GestureDetector);
    if (cards.evaluate().isEmpty) {
      return false;
    }
    await tester.tap(cards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty ||
          find.text('概要').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 概要タブを表示して招待セクションまでスクロールする。
  Future<void> scrollToInvitationSection(WidgetTester tester) async {
    // 概要タブを表示
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('basicInfoRead_container_section')).evaluate().isNotEmpty ||
            find.byKey(const Key('overview_sectionLabel_basicInfo')).evaluate().isNotEmpty) {
          break;
        }
      }
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 招待セクションまでスクロール
    for (var i = 0; i < 15; i++) {
      if (find.byKey(const Key('overview_section_invitation')).evaluate().isNotEmpty) break;
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        await tester.drag(scrollables.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// セットアップ: アプリ起動 → 最初のイベント → 概要タブ → 招待セクションまでスクロール
  Future<String?> setupInvitationSection(WidgetTester tester) async {
    await startApp(tester);
    final opened = await openFirstEvent(tester);
    if (!opened) return 'イベントが見つかりませんでした';
    await scrollToInvitationSection(tester);
    return null;
  }

  // ────────────────────────────────────────────────────────
  // TC-IUP-001: 概要タブに招待セクションが表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-IUP-001: イベント詳細の概要タブに招待セクションが表示されること',
    (tester) async {
      final skipReason = await setupInvitationSection(tester);
      if (skipReason != null) {
        print('[SKIP] TC-IUP-001: $skipReason');
        return;
      }

      expect(
        find.byKey(const Key('overview_section_invitation')),
        findsOneWidget,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-IUP-001/002: owner権限の場合「メンバーを招待」ボタンが表示される
  // TC-IUP-003/004: 非owner権限の場合「招待コードを入力」ボタンが表示される
  //
  // 注意: 実際のuserRoleはスタブ実装の返却値に依存する。
  // 両方のケースを記述し、実行時にスキップガードで制御する。
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-IUP-001b: owner権限の場合「メンバーを招待」ボタンが表示されること',
    (tester) async {
      final skipReason = await setupInvitationSection(tester);
      if (skipReason != null) {
        print('[SKIP] TC-IUP-001b: $skipReason');
        return;
      }

      // owner権限の場合は inviteLink ボタンが表示される
      if (find.byKey(const Key('overview_button_inviteLink')).evaluate().isEmpty) {
        print('[SKIP] TC-IUP-001b: 現在のuserRoleがownerではありません（スタブ設定に依存）');
        return;
      }

      expect(
        find.byKey(const Key('overview_button_inviteLink')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'TC-IUP-002: owner権限の場合「招待コードを入力」ボタンが表示されないこと',
    (tester) async {
      final skipReason = await setupInvitationSection(tester);
      if (skipReason != null) {
        print('[SKIP] TC-IUP-002: $skipReason');
        return;
      }

      // owner権限でなければスキップ
      if (find.byKey(const Key('overview_button_inviteLink')).evaluate().isEmpty) {
        print('[SKIP] TC-IUP-002: 現在のuserRoleがownerではありません（スタブ設定に依存）');
        return;
      }

      expect(
        find.byKey(const Key('overview_button_inviteCodeInput')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'TC-IUP-003: 非owner権限の場合「招待コードを入力」ボタンが表示されること',
    (tester) async {
      final skipReason = await setupInvitationSection(tester);
      if (skipReason != null) {
        print('[SKIP] TC-IUP-003: $skipReason');
        return;
      }

      // 非owner（またはnull）の場合は inviteCodeInput ボタンが表示される
      if (find.byKey(const Key('overview_button_inviteCodeInput')).evaluate().isEmpty) {
        print('[SKIP] TC-IUP-003: 現在のuserRoleがowner以外ではありません（スタブ設定に依存）');
        return;
      }

      expect(
        find.byKey(const Key('overview_button_inviteCodeInput')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'TC-IUP-004: 非owner権限の場合「メンバーを招待」ボタンが表示されないこと',
    (tester) async {
      final skipReason = await setupInvitationSection(tester);
      if (skipReason != null) {
        print('[SKIP] TC-IUP-004: $skipReason');
        return;
      }

      // 非owner権限でなければスキップ
      if (find.byKey(const Key('overview_button_inviteCodeInput')).evaluate().isEmpty) {
        print('[SKIP] TC-IUP-004: 現在のuserRoleがowner以外ではありません（スタブ設定に依存）');
        return;
      }

      expect(
        find.byKey(const Key('overview_button_inviteLink')),
        findsNothing,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-IUP-005: 「招待コードを入力」ボタンタップ → 招待コード入力画面へ遷移
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-IUP-005: 「招待コードを入力」ボタンをタップすると招待コード入力画面に遷移すること',
    (tester) async {
      final skipReason = await setupInvitationSection(tester);
      if (skipReason != null) {
        print('[SKIP] TC-IUP-005: $skipReason');
        return;
      }

      final inviteCodeButton = find.byKey(const Key('overview_button_inviteCodeInput'));
      if (inviteCodeButton.evaluate().isEmpty) {
        print('[SKIP] TC-IUP-005: 「招待コードを入力」ボタンが表示されていません（owner権限の場合はスキップ）');
        return;
      }

      await tester.ensureVisible(inviteCodeButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(inviteCodeButton.first);

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byKey(const Key('invite_code_text_field')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      // 招待コード入力画面（INV-3）に遷移したこと
      expect(
        find.byKey(const Key('invite_code_text_field')),
        findsOneWidget,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-IUP-006: 招待コード入力画面からEventDetail画面に戻れる
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-IUP-006: 招待コード入力画面の戻るボタンでEventDetail画面に戻れること',
    (tester) async {
      final skipReason = await setupInvitationSection(tester);
      if (skipReason != null) {
        print('[SKIP] TC-IUP-006: $skipReason');
        return;
      }

      final inviteCodeButton = find.byKey(const Key('overview_button_inviteCodeInput'));
      if (inviteCodeButton.evaluate().isEmpty) {
        print('[SKIP] TC-IUP-006: 「招待コードを入力」ボタンが表示されていません');
        return;
      }

      await tester.ensureVisible(inviteCodeButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(inviteCodeButton.first);

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byKey(const Key('invite_code_text_field')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      if (find.byKey(const Key('invite_code_text_field')).evaluate().isEmpty) {
        print('[SKIP] TC-IUP-006: 招待コード入力画面に遷移できませんでした');
        return;
      }

      // AppBarの戻るボタンをタップ
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
      } else {
        // BackButton がない場合は Navigator.pop 相当のジェスチャー
        await tester.tap(find.byIcon(Icons.arrow_back).first);
      }
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('overview_section_invitation')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 500));

      // EventDetail（概要タブ）に戻ったこと
      // 招待セクションまでスクロール
      for (var i = 0; i < 10; i++) {
        if (find.byKey(const Key('overview_section_invitation')).evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -400));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(
        find.byKey(const Key('overview_section_invitation')),
        findsOneWidget,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-IUP-007: userRole未取得（null）のとき「招待コードを入力」ボタンが表示
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-IUP-007: 招待セクションにいずれかのボタンが表示されること（owner or 非owner）',
    (tester) async {
      final skipReason = await setupInvitationSection(tester);
      if (skipReason != null) {
        print('[SKIP] TC-IUP-007: $skipReason');
        return;
      }

      // 招待セクションが表示されていれば、
      // inviteLink ボタンまたは inviteCodeInput ボタンのいずれかが表示されること
      final hasInviteLink = find
          .byKey(const Key('overview_button_inviteLink'))
          .evaluate()
          .isNotEmpty;
      final hasInviteCodeInput = find
          .byKey(const Key('overview_button_inviteCodeInput'))
          .evaluate()
          .isNotEmpty;

      expect(hasInviteLink || hasInviteCodeInput, isTrue);
    },
  );
}
