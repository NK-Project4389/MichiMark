// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: UI-16 スプラッシュ画面改善
///
/// Spec: docs/Spec/Features/FS-splash_screen_improvement.md §17
///
/// テストシナリオ: TC-UI16-I001 〜 TC-UI16-I003
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - スプラッシュ画面がアプリ起動時に表示されること
///   - Integration Test の既存テストは router.go('/') でスプラッシュをスキップすること

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

  /// アプリを通常起動してスプラッシュ画面またはDashboardが表示されるまで待つ。
  /// router.go('/') を先行させず、スプラッシュ画面を経由する。
  Future<void> startAppWithSplash(WidgetTester tester) async {
    await GetIt.I.reset();
    // router.go('/') を呼ばない。initialLocation = '/splash' のままアプリ起動
    app.main();
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      // スプラッシュ画面または Dashboard が表示されたら成功
      if (find.byKey(const Key('splash_container_background')).evaluate().isNotEmpty) {
        return;
      }
      if (find.text('ダッシュボード').evaluate().isNotEmpty) {
        return;
      }
    }
    fail('[タイムアウト] スプラッシュ画面またはダッシュボードが20秒以内にロードされませんでした');
  }

  /// アプリを通常起動し、スプラッシュをスキップしてEventListが表示されるまで待つ。
  /// 既存の Integration Test パターン: router.go('/') を app.main() より先に呼ぶ。
  Future<void> startApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント一覧').evaluate().isNotEmpty) return;
    }
    fail('[タイムアウト] イベント一覧が表示されませんでした');
  }

  // ────────────────────────────────────────────────────────
  // TC-UI16-I001: スプラッシュ画面のウィジェット表示確認
  // ────────────────────────────────────────────────────────

  testWidgets('TC-UI16-I001: スプラッシュ画面の背景コンテナが表示される',
      (tester) async {
    await startAppWithSplash(tester);

    // スプラッシュ背景コンテナが表示されていることを確認
    expect(
      find.byKey(const Key('splash_container_background')),
      findsOneWidget,
    );
  });

  testWidgets('TC-UI16-I001b: スプラッシュ画面のロゴが表示される', (tester) async {
    await startAppWithSplash(tester);

    // スプラッシュロゴが表示されていることを確認
    expect(
      find.byKey(const Key('splash_image_logo')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-UI16-I002: アニメーション完了後にDashboardへ遷移
  // ────────────────────────────────────────────────────────

  testWidgets('TC-UI16-I002: スプラッシュ画面からDashboardへ遷移する',
      (tester) async {
    await startAppWithSplash(tester);

    // 初期状態: スプラッシュ背景が表示されている
    expect(
      find.byKey(const Key('splash_container_background')),
      findsOneWidget,
    );

    // 最低表示時間（1秒）+ アニメーション時間（最大2秒）を考慮して待機
    // pump(Duration(milliseconds: 500)) を最大10回繰り返す = 最大5秒
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('dashboard_tab')).evaluate().isNotEmpty) {
        break;
      }
    }

    // Dashboard画面のボトムナビゲーションタブが表示されていることを確認
    expect(
      find.byKey(const Key('dashboard_tab')),
      findsOneWidget,
    );
  });

  testWidgets('TC-UI16-I002b: Dashboard遷移後にスプラッシュ画面が非表示になる',
      (tester) async {
    await startAppWithSplash(tester);

    // スプラッシュアニメーション完了を待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('dashboard_tab')).evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    // スプラッシュ背景が非表示になっていることを確認
    expect(
      find.byKey(const Key('splash_container_background')),
      findsNothing,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-UI16-I003: router.go('/') でスプラッシュをスキップできる互換性確認
  // ────────────────────────────────────────────────────────

  testWidgets('TC-UI16-I003: router.go(\'/\') でスプラッシュをスキップしてEventListが表示される',
      (tester) async {
    await startApp(tester);

    // EventList画面のタイトル「イベント一覧」が表示されていることを確認
    // findsWidgets: AppBarとボトムナビ等で複数表示されるケースに対応
    expect(
      find.text('イベント一覧'),
      findsWidgets,
    );
  });

  testWidgets('TC-UI16-I003b: router.go(\'/\') スキップ時にスプラッシュ画面が表示されない',
      (tester) async {
    await startApp(tester);

    // スプラッシュ背景が表示されていないことを確認
    expect(
      find.byKey(const Key('splash_container_background')),
      findsNothing,
    );
  });

  testWidgets('TC-UI16-I003c: router.go(\'/\') スキップ時にスプラッシュロゴが表示されない',
      (tester) async {
    await startApp(tester);

    // スプラッシュロゴが表示されていないことを確認
    expect(
      find.byKey(const Key('splash_image_logo')),
      findsNothing,
    );
  });
}
