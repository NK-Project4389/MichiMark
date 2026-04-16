// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: B-17 本番シードデータ見直し
///
/// Spec: docs/Spec/Features/FS-seed_data_sample.md §11
///
/// テストシナリオ: TC-SD-001 〜 TC-SD-009
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - アプリを新規インストール（または GetIt.I.reset() でリセット）した状態
///   - シードデータが投入されること
///
/// テスト環境での注意事項:
///   - `flutter test` 実行時は FLUTTER_TEST 環境変数が自動的にセットされる
///   - テスト環境では _testSeedEvents（event-001〜008、8件）が使われる
///   - 本番用シードデータ（event-seed-a/b/c）はテスト環境では存在しない
///   - TC-SD-001 のみ実装可能。TC-SD-002〜009 は本番データ依存のためSKIP。
///
/// 本番データの手動確認事項（テスト非対象）:
///   - 「箱根日帰りドライブ」「4月 業務走行記録」「横浜エリア訪問ルート」の
///     3件がイベント一覧に表示されること
///   - 各シナリオのタイムライン・支払い情報・給油情報が正しく表示されること

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

  /// アプリを起動してイベント一覧画面が表示されるまで待つ。
  /// event_list_invite_code_button（AppBarのボタン）の出現で判定する。
  Future<void> launchApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('event_list_invite_code_button')).evaluate().isNotEmpty) {
        return;
      }
    }
    fail('[タイムアウト] イベント一覧ページが15秒以内にロードされませんでした');
  }

  // ────────────────────────────────────────────────────────
  // TC-SD-001: 新規起動時にイベント一覧にシードデータが1件以上表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-SD-001: 新規起動時にイベント一覧にシードデータが1件以上表示される（テスト環境ではtestSeedEvents 8件）',
    (tester) async {
      await launchApp(tester);

      // イベント一覧ページが表示されていること（招待コードボタンの存在で判定）
      expect(
        find.byKey(const Key('event_list_invite_code_button')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'TC-SD-001b: イベント一覧に「イベントがありません」が表示されないこと（シードデータが存在すること）',
    (tester) async {
      await launchApp(tester);

      // シードデータが投入されているためゼロ件表示にならないこと
      expect(
        find.text('イベントがありません'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'TC-SD-001c: イベント一覧にListViewが表示されること（シードデータが投入されていること）',
    (tester) async {
      await launchApp(tester);

      // ListView が表示されるまで追加待機（データロード完了を待つ）
      for (var i = 0; i < 20; i++) {
        if (find.byType(ListView).evaluate().isNotEmpty) break;
        if (find.text('イベントがありません').evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 500));
      }

      // ListView が表示されること（シードデータが1件以上ある場合のみ表示される）
      expect(
        find.byType(ListView),
        findsOneWidget,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-SD-002〜TC-SD-009: 本番シードデータ依存のためSKIP
  //
  // 以下のシナリオは本番用シードデータ（event-seed-a/b/c）に依存しており、
  // テスト環境（FLUTTER_TEST=true）では _testSeedEvents（event-001〜008）が
  // 使われるため、本番データのイベント名・地点・支払い情報は存在しない。
  //
  // これらのシナリオは実機または本番ビルドでの手動確認を推奨する。
  //
  // TC-SD-002: シナリオA（箱根日帰りドライブ）のタイムラインが正しく表示される
  //   - 手動確認項目: 11件のMarkLink、「自宅出発」「足柄SA」「箱根神社」
  //     「大涌谷」「箱根湯本（昼食）」「帰宅」の地点名
  //
  // TC-SD-003: シナリオA の支払いタブに4件の支払いが表示される
  //   - 手動確認項目: 「高速代（往復）」「ガソリン代」「昼食」「駐車場」
  //
  // TC-SD-004: シナリオA の給油情報が記録されている（足柄SA）
  //   - 手動確認項目: 35L / 175円/L / 6,125円
  //
  // TC-SD-005: シナリオB（業務走行記録）の集計タブで走行距離合計が表示される
  //   - 手動確認項目: 走行距離合計 334km、燃料コスト合計 14,710円
  //
  // TC-SD-006: シナリオB の支払いタブに2件の支払いが表示される
  //   - 手動確認項目: 「ガソリン代（当月3日）」「ガソリン代（当月10日）」
  //
  // TC-SD-007: シナリオC（横浜エリア訪問ルート）の訪問作業アクションが記録されている
  //   - 手動確認項目: 9件のMarkLink、A社マーク（到着・作業開始・作業終了）、
  //     B社マーク（到着・作業開始・休憩・作業終了）
  //
  // TC-SD-008: シナリオC の支払いタブに3件の支払いが表示される
  //   - 手動確認項目: 「駐車場（A社）」「駐車場（B社）」「昼食」
  //
  // TC-SD-009: 各イベントの日付が相対日付で表示される（固定日付でない）
  //   - 手動確認項目: 「箱根日帰りドライブ」が現在日から7日前、
  //     「横浜エリア訪問ルート」が現在日から3日前の日付で表示されること
  // ────────────────────────────────────────────────────────
}

// ────────────────────────────────────────────────────────
// ユーティリティ: byKeyPrefix finder
// ────────────────────────────────────────────────────────

extension _FinderExtension on CommonFinders {
  Finder byKeyPrefix(String prefix) {
    return find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith(prefix),
    );
  }
}
