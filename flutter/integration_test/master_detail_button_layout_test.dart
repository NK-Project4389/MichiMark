// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: UI-20 マスター詳細ボタン下部配置
///
/// Spec: docs/Spec/Features/FS-master_detail_button_layout.md
///
/// テストシナリオ: TC-MDB-001 〜 TC-MDB-020
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - 設定画面から各マスター項目詳細画面を開ける状態であること
///
/// 注意:
///   各Detail画面は `/settings/xxx/new` に直接遷移する。
///   キャンセル後の pop は GoRouter の "nothing to pop" になるため、
///   キャンセル・保存テストでは画面が閉じた結果として
///   DetailのKeyが消えることで確認する。

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

  /// 交通手段設定Detail画面（新規）を開く。
  Future<void> goToTransSettingDetail(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/trans/new');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('交通手段名').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// メンバー設定Detail画面（新規）を開く。
  Future<void> goToMemberSettingDetail(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/member/new');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('メンバー名').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// タグ設定Detail画面（新規）を開く。
  Future<void> goToTagSettingDetail(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/tag/new');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('タグ名').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// アクション設定Detail画面（新規）を開く。
  Future<void> goToActionSettingDetail(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/settings/action/new');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('行動名').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// ボタンをスクロールで表示する。
  Future<void> scrollToButton(WidgetTester tester, Key buttonKey) async {
    for (var i = 0; i < 10; i++) {
      if (find.byKey(buttonKey).evaluate().isNotEmpty) break;
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        await tester.drag(scrollables.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
  }

  // ────────────────────────────────────────────────────────
  // TC-MDB-001〜004: AppBarに「保存」ボタンが表示されないこと
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MDB-001: TransSettingDetail - AppBarに「保存」ボタンが表示されないこと',
      (tester) async {
    await goToTransSettingDetail(tester);

    expect(
      find.byKey(const Key('transSettingDetail_appBar_saveButton')),
      findsNothing,
    );
  });

  testWidgets('TC-MDB-002: MemberSettingDetail - AppBarに「保存」ボタンが表示されないこと',
      (tester) async {
    await goToMemberSettingDetail(tester);

    expect(
      find.byKey(const Key('memberSettingDetail_appBar_saveButton')),
      findsNothing,
    );
  });

  testWidgets('TC-MDB-003: TagSettingDetail - AppBarに「保存」ボタンが表示されないこと',
      (tester) async {
    await goToTagSettingDetail(tester);

    expect(
      find.byKey(const Key('tagSettingDetail_appBar_saveButton')),
      findsNothing,
    );
  });

  testWidgets('TC-MDB-004: ActionSettingDetail - AppBarに「保存」ボタンが表示されないこと',
      (tester) async {
    await goToActionSettingDetail(tester);

    expect(
      find.byKey(const Key('actionSettingDetail_appBar_saveButton')),
      findsNothing,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MDB-005〜008: AppBar左に戻るアイコンが表示されること
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MDB-005: TransSettingDetail - AppBar左に戻るアイコンが表示されること',
      (tester) async {
    await goToTransSettingDetail(tester);

    expect(
      find.byKey(const Key('transSettingDetail_appBar_backButton')),
      findsOneWidget,
    );
  });

  testWidgets('TC-MDB-006: MemberSettingDetail - AppBar左に戻るアイコンが表示されること',
      (tester) async {
    await goToMemberSettingDetail(tester);

    expect(
      find.byKey(const Key('memberSettingDetail_appBar_backButton')),
      findsOneWidget,
    );
  });

  testWidgets('TC-MDB-007: TagSettingDetail - AppBar左に戻るアイコンが表示されること',
      (tester) async {
    await goToTagSettingDetail(tester);

    expect(
      find.byKey(const Key('tagSettingDetail_appBar_backButton')),
      findsOneWidget,
    );
  });

  testWidgets('TC-MDB-008: ActionSettingDetail - AppBar左に戻るアイコンが表示されること',
      (tester) async {
    await goToActionSettingDetail(tester);

    expect(
      find.byKey(const Key('actionSettingDetail_appBar_backButton')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MDB-009〜012: フォーム最下部にキャンセル/保存ボタンが表示されること
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-MDB-009: TransSettingDetail - フォーム最下部にキャンセルボタンが表示されること',
      (tester) async {
    await goToTransSettingDetail(tester);
    await scrollToButton(
        tester, const Key('transSettingDetail_button_cancel'));

    expect(
      find.byKey(const Key('transSettingDetail_button_cancel')),
      findsOneWidget,
    );
  });

  testWidgets('TC-MDB-009b: TransSettingDetail - フォーム最下部に保存ボタンが表示されること',
      (tester) async {
    await goToTransSettingDetail(tester);
    await scrollToButton(tester, const Key('transSettingDetail_button_save'));

    expect(
      find.byKey(const Key('transSettingDetail_button_save')),
      findsOneWidget,
    );
  });

  testWidgets(
      'TC-MDB-009c: TransSettingDetail - キャンセルが左・保存が右に配置されていること',
      (tester) async {
    await goToTransSettingDetail(tester);
    await scrollToButton(
        tester, const Key('transSettingDetail_button_cancel'));

    final cancelRect =
        tester.getRect(find.byKey(const Key('transSettingDetail_button_cancel')));
    final saveRect =
        tester.getRect(find.byKey(const Key('transSettingDetail_button_save')));
    expect(cancelRect.left < saveRect.left, isTrue);
  });

  testWidgets(
      'TC-MDB-010: MemberSettingDetail - フォーム最下部にキャンセルボタンが表示されること',
      (tester) async {
    await goToMemberSettingDetail(tester);
    await scrollToButton(
        tester, const Key('memberSettingDetail_button_cancel'));

    expect(
      find.byKey(const Key('memberSettingDetail_button_cancel')),
      findsOneWidget,
    );
  });

  testWidgets(
      'TC-MDB-010b: MemberSettingDetail - フォーム最下部に保存ボタンが表示されること',
      (tester) async {
    await goToMemberSettingDetail(tester);
    await scrollToButton(
        tester, const Key('memberSettingDetail_button_save'));

    expect(
      find.byKey(const Key('memberSettingDetail_button_save')),
      findsOneWidget,
    );
  });

  testWidgets(
      'TC-MDB-010c: MemberSettingDetail - キャンセルが左・保存が右に配置されていること',
      (tester) async {
    await goToMemberSettingDetail(tester);
    await scrollToButton(
        tester, const Key('memberSettingDetail_button_cancel'));

    final cancelRect = tester
        .getRect(find.byKey(const Key('memberSettingDetail_button_cancel')));
    final saveRect = tester
        .getRect(find.byKey(const Key('memberSettingDetail_button_save')));
    expect(cancelRect.left < saveRect.left, isTrue);
  });

  testWidgets(
      'TC-MDB-011: TagSettingDetail - フォーム最下部にキャンセルボタンが表示されること',
      (tester) async {
    await goToTagSettingDetail(tester);
    await scrollToButton(
        tester, const Key('tagSettingDetail_button_cancel'));

    expect(
      find.byKey(const Key('tagSettingDetail_button_cancel')),
      findsOneWidget,
    );
  });

  testWidgets('TC-MDB-011b: TagSettingDetail - フォーム最下部に保存ボタンが表示されること',
      (tester) async {
    await goToTagSettingDetail(tester);
    await scrollToButton(tester, const Key('tagSettingDetail_button_save'));

    expect(
      find.byKey(const Key('tagSettingDetail_button_save')),
      findsOneWidget,
    );
  });

  testWidgets(
      'TC-MDB-011c: TagSettingDetail - キャンセルが左・保存が右に配置されていること',
      (tester) async {
    await goToTagSettingDetail(tester);
    await scrollToButton(
        tester, const Key('tagSettingDetail_button_cancel'));

    final cancelRect =
        tester.getRect(find.byKey(const Key('tagSettingDetail_button_cancel')));
    final saveRect =
        tester.getRect(find.byKey(const Key('tagSettingDetail_button_save')));
    expect(cancelRect.left < saveRect.left, isTrue);
  });

  testWidgets(
      'TC-MDB-012: ActionSettingDetail - フォーム最下部にキャンセルボタンが表示されること',
      (tester) async {
    await goToActionSettingDetail(tester);
    await scrollToButton(
        tester, const Key('actionSettingDetail_button_cancel'));

    expect(
      find.byKey(const Key('actionSettingDetail_button_cancel')),
      findsOneWidget,
    );
  });

  testWidgets(
      'TC-MDB-012b: ActionSettingDetail - フォーム最下部に保存ボタンが表示されること',
      (tester) async {
    await goToActionSettingDetail(tester);
    await scrollToButton(
        tester, const Key('actionSettingDetail_button_save'));

    expect(
      find.byKey(const Key('actionSettingDetail_button_save')),
      findsOneWidget,
    );
  });

  testWidgets(
      'TC-MDB-012c: ActionSettingDetail - キャンセルが左・保存が右に配置されていること',
      (tester) async {
    await goToActionSettingDetail(tester);
    await scrollToButton(
        tester, const Key('actionSettingDetail_button_cancel'));

    final cancelRect = tester
        .getRect(find.byKey(const Key('actionSettingDetail_button_cancel')));
    final saveRect = tester
        .getRect(find.byKey(const Key('actionSettingDetail_button_save')));
    expect(cancelRect.left < saveRect.left, isTrue);
  });

  // ────────────────────────────────────────────────────────
  // TC-MDB-013〜016: キャンセルタップで画面が閉じること
  // （新規作成モードで直接遷移のため、popすると別画面に戻る or エラー。
  //  ボタンが消えることで画面遷移を確認する）
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MDB-013: TransSettingDetail - キャンセルタップで画面が閉じること',
      (tester) async {
    await goToTransSettingDetail(tester);
    await scrollToButton(
        tester, const Key('transSettingDetail_button_cancel'));

    await tester.ensureVisible(
        find.byKey(const Key('transSettingDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('transSettingDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('transSettingDetail_button_cancel'))
          .evaluate()
          .isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // Detail画面のキャンセルボタンが消えている = 画面遷移した
    expect(
      find.byKey(const Key('transSettingDetail_button_cancel')),
      findsNothing,
    );
  });

  testWidgets('TC-MDB-014: MemberSettingDetail - キャンセルタップで画面が閉じること',
      (tester) async {
    await goToMemberSettingDetail(tester);
    await scrollToButton(
        tester, const Key('memberSettingDetail_button_cancel'));

    await tester.ensureVisible(
        find.byKey(const Key('memberSettingDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester
        .tap(find.byKey(const Key('memberSettingDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('memberSettingDetail_button_cancel'))
          .evaluate()
          .isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('memberSettingDetail_button_cancel')),
      findsNothing,
    );
  });

  testWidgets('TC-MDB-015: TagSettingDetail - キャンセルタップで画面が閉じること',
      (tester) async {
    await goToTagSettingDetail(tester);
    await scrollToButton(
        tester, const Key('tagSettingDetail_button_cancel'));

    await tester.ensureVisible(
        find.byKey(const Key('tagSettingDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('tagSettingDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('tagSettingDetail_button_cancel'))
          .evaluate()
          .isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('tagSettingDetail_button_cancel')),
      findsNothing,
    );
  });

  testWidgets('TC-MDB-016: ActionSettingDetail - キャンセルタップで画面が閉じること',
      (tester) async {
    await goToActionSettingDetail(tester);
    await scrollToButton(
        tester, const Key('actionSettingDetail_button_cancel'));

    await tester.ensureVisible(
        find.byKey(const Key('actionSettingDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester
        .tap(find.byKey(const Key('actionSettingDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('actionSettingDetail_button_cancel'))
          .evaluate()
          .isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('actionSettingDetail_button_cancel')),
      findsNothing,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MDB-017〜020: 保存タップで保存されて画面が閉じること
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-MDB-017: TransSettingDetail - 保存タップで保存されて画面が閉じること',
      (tester) async {
    await goToTransSettingDetail(tester);

    // 名称フィールドに入力
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      await tester.tap(textFields.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(textFields.first, 'テスト交通手段');
      await tester.pump(const Duration(milliseconds: 300));
    }

    await scrollToButton(tester, const Key('transSettingDetail_button_save'));
    await tester.ensureVisible(
        find.byKey(const Key('transSettingDetail_button_save')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('transSettingDetail_button_save')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('transSettingDetail_button_save'))
          .evaluate()
          .isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 保存ボタンが消えている = 画面遷移した
    expect(
      find.byKey(const Key('transSettingDetail_button_save')),
      findsNothing,
    );
  });

  testWidgets(
      'TC-MDB-018: MemberSettingDetail - 保存タップで保存されて画面が閉じること',
      (tester) async {
    await goToMemberSettingDetail(tester);

    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      await tester.tap(textFields.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(textFields.first, 'テストメンバー');
      await tester.pump(const Duration(milliseconds: 300));
    }

    await scrollToButton(
        tester, const Key('memberSettingDetail_button_save'));
    await tester.ensureVisible(
        find.byKey(const Key('memberSettingDetail_button_save')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester
        .tap(find.byKey(const Key('memberSettingDetail_button_save')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('memberSettingDetail_button_save'))
          .evaluate()
          .isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('memberSettingDetail_button_save')),
      findsNothing,
    );
  });

  testWidgets('TC-MDB-019: TagSettingDetail - 保存タップで保存されて画面が閉じること',
      (tester) async {
    await goToTagSettingDetail(tester);

    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      await tester.tap(textFields.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(textFields.first, 'テストタグ');
      await tester.pump(const Duration(milliseconds: 300));
    }

    await scrollToButton(tester, const Key('tagSettingDetail_button_save'));
    await tester.ensureVisible(
        find.byKey(const Key('tagSettingDetail_button_save')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('tagSettingDetail_button_save')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('tagSettingDetail_button_save'))
          .evaluate()
          .isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('tagSettingDetail_button_save')),
      findsNothing,
    );
  });

  testWidgets(
      'TC-MDB-020: ActionSettingDetail - 保存タップで保存されて画面が閉じること',
      (tester) async {
    await goToActionSettingDetail(tester);

    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      await tester.tap(textFields.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(textFields.first, 'テストアクション');
      await tester.pump(const Duration(milliseconds: 300));
    }

    await scrollToButton(
        tester, const Key('actionSettingDetail_button_save'));
    await tester.ensureVisible(
        find.byKey(const Key('actionSettingDetail_button_save')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester
        .tap(find.byKey(const Key('actionSettingDetail_button_save')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('actionSettingDetail_button_save'))
          .evaluate()
          .isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('actionSettingDetail_button_save')),
      findsNothing,
    );
  });
}
