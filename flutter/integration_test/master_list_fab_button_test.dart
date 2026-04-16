// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: UI-21 マスター一覧FABボタン
///
/// Spec: docs/Spec/Features/FS-master_list_fab_button.md
///
/// テストシナリオ: TC-FAB-001 〜 TC-FAB-012
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - 設定画面から各マスター項目一覧画面を開ける状態であること

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

  /// 交通手段設定一覧画面を開く。
  Future<void> goToTransSettingPage(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/trans');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('交通手段').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// メンバー設定一覧画面を開く。
  Future<void> goToMemberSettingPage(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/member');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('メンバー').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// タグ設定一覧画面を開く。
  Future<void> goToTagSettingPage(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/tag');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('タグ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// アクション設定一覧画面を開く。
  Future<void> goToActionSettingPage(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/action');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('行動').evaluate().isNotEmpty ||
          find.text('アクション').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────
  // TC-FAB-001〜004: AppBar右側に「＋」ボタンが表示されないこと
  // ────────────────────────────────────────────────────────

  testWidgets('TC-FAB-001: TransSetting - AppBar右側に追加ボタンが表示されないこと',
      (tester) async {
    await goToTransSettingPage(tester);

    expect(
      find.byKey(const Key('transSetting_appBar_addButton')),
      findsNothing,
    );
  });

  testWidgets('TC-FAB-002: MemberSetting - AppBar右側に追加ボタンが表示されないこと',
      (tester) async {
    await goToMemberSettingPage(tester);

    expect(
      find.byKey(const Key('memberSetting_appBar_addButton')),
      findsNothing,
    );
  });

  testWidgets('TC-FAB-003: TagSetting - AppBar右側に追加ボタンが表示されないこと',
      (tester) async {
    await goToTagSettingPage(tester);

    expect(
      find.byKey(const Key('tagSetting_appBar_addButton')),
      findsNothing,
    );
  });

  testWidgets('TC-FAB-004: ActionSetting - AppBar右側に追加ボタンが表示されないこと',
      (tester) async {
    await goToActionSettingPage(tester);

    expect(
      find.byKey(const Key('actionSetting_appBar_addButton')),
      findsNothing,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-FAB-005〜008: 画面右下にオレンジ色のFABが表示されること
  // ────────────────────────────────────────────────────────

  testWidgets('TC-FAB-005: TransSetting - 画面右下にFABが表示されること',
      (tester) async {
    await goToTransSettingPage(tester);

    expect(
      find.byKey(const Key('transSetting_fab_add')),
      findsOneWidget,
    );
  });

  testWidgets('TC-FAB-005b: TransSetting - FABにオレンジ色の背景が適用されていること',
      (tester) async {
    await goToTransSettingPage(tester);

    final fab = tester.widget<FloatingActionButton>(
      find.byKey(const Key('transSetting_fab_add')),
    );
    expect(fab.backgroundColor, const Color(0xFFF59E0B));
  });

  testWidgets('TC-FAB-006: MemberSetting - 画面右下にFABが表示されること',
      (tester) async {
    await goToMemberSettingPage(tester);

    expect(
      find.byKey(const Key('memberSetting_fab_add')),
      findsOneWidget,
    );
  });

  testWidgets('TC-FAB-006b: MemberSetting - FABにオレンジ色の背景が適用されていること',
      (tester) async {
    await goToMemberSettingPage(tester);

    final fab = tester.widget<FloatingActionButton>(
      find.byKey(const Key('memberSetting_fab_add')),
    );
    expect(fab.backgroundColor, const Color(0xFFF59E0B));
  });

  testWidgets('TC-FAB-007: TagSetting - 画面右下にFABが表示されること',
      (tester) async {
    await goToTagSettingPage(tester);

    expect(
      find.byKey(const Key('tagSetting_fab_add')),
      findsOneWidget,
    );
  });

  testWidgets('TC-FAB-007b: TagSetting - FABにオレンジ色の背景が適用されていること',
      (tester) async {
    await goToTagSettingPage(tester);

    final fab = tester.widget<FloatingActionButton>(
      find.byKey(const Key('tagSetting_fab_add')),
    );
    expect(fab.backgroundColor, const Color(0xFFF59E0B));
  });

  testWidgets('TC-FAB-008: ActionSetting - 画面右下にFABが表示されること',
      (tester) async {
    await goToActionSettingPage(tester);

    expect(
      find.byKey(const Key('actionSetting_fab_add')),
      findsOneWidget,
    );
  });

  testWidgets('TC-FAB-008b: ActionSetting - FABにオレンジ色の背景が適用されていること',
      (tester) async {
    await goToActionSettingPage(tester);

    final fab = tester.widget<FloatingActionButton>(
      find.byKey(const Key('actionSetting_fab_add')),
    );
    expect(fab.backgroundColor, const Color(0xFFF59E0B));
  });

  // ────────────────────────────────────────────────────────
  // TC-FAB-009〜012: FABタップで新規作成画面が開くこと
  // ────────────────────────────────────────────────────────

  testWidgets('TC-FAB-009: TransSetting - FABタップで新規作成画面が開くこと',
      (tester) async {
    await goToTransSettingPage(tester);

    await tester.tap(find.byKey(const Key('transSetting_fab_add')));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('transSettingDetail_button_save'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 詳細画面の保存ボタンが表示されていること = 新規作成画面が開いた
    expect(
      find.byKey(const Key('transSettingDetail_button_save')),
      findsOneWidget,
    );
  });

  testWidgets('TC-FAB-010: MemberSetting - FABタップで新規作成画面が開くこと',
      (tester) async {
    await goToMemberSettingPage(tester);

    await tester.tap(find.byKey(const Key('memberSetting_fab_add')));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('memberSettingDetail_button_save'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('memberSettingDetail_button_save')),
      findsOneWidget,
    );
  });

  testWidgets('TC-FAB-011: TagSetting - FABタップで新規作成画面が開くこと',
      (tester) async {
    await goToTagSettingPage(tester);

    await tester.tap(find.byKey(const Key('tagSetting_fab_add')));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('tagSettingDetail_button_save'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('tagSettingDetail_button_save')),
      findsOneWidget,
    );
  });

  testWidgets('TC-FAB-012: ActionSetting - FABタップで新規作成画面が開くこと',
      (tester) async {
    await goToActionSettingPage(tester);

    await tester.tap(find.byKey(const Key('actionSetting_fab_add')));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('actionSettingDetail_button_save'))
          .evaluate()
          .isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('actionSettingDetail_button_save')),
      findsOneWidget,
    );
  });
}
