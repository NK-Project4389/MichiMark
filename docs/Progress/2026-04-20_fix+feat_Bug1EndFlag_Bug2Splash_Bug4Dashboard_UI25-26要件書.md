# 2026-04-20 Bug修正3件（EndFlag/Splash/Dashboard凡例）・UI-25/26要件書作成

## 完了した作業

### Bug修正

#### Bug1: ActionTimeで出発記録（EndFlag=1）があるのもMarkカードがグレーにならない

- **原因1**: `MichiInfoBloc._onMarkActionPressed` でActionTimeLogに `markLinkId` が未設定
- **原因2**: アクション記録後にprojection（isDone）が再計算されない
- **原因3（追加）**: `seed_data.dart` の `visit_work_depart` に `endFlag: true` が未設定
- **修正**:
  - `michi_info_bloc.dart`: `_onMarkActionPressed` に `markLinkId: event.markLinkId` 追加、保存後にprojectionをリロードして `isDone` を再計算・emitする処理を追加
  - `seed_data.dart`: `visit_work_depart` に `endFlag: true` を追加

#### Bug2: スプラッシュ画像が未更新（BRAND-1実装漏れ）

- **原因**: T-614でsplash_logo.pngを更新せず背景色のみ変更していた
- **修正**: `flutter/assets/icon/app_icon.png`（Logo_v2）を `flutter/assets/images/splash_logo.png` にコピー

#### Bug4: ダッシュボード（訪問作業）の円グラフ凡例がコードIDになっている

- **原因**: `VisitWorkDashboardAdapter.toProjection()` でactionIdをkeyにしたMapを構築しており、actionNameではなくactionIdが凡例ラベルに使われていた
- **修正**:
  - `visit_work_dashboard_adapter.dart`: `actionNameMap` を `markLink.actions` から構築し、`workBreakdown.actionName` / `workTimeBreakdownLabels` のkeyに `actionNameMap[actionId]` を使用

### テスト

#### Integration Test: `action_time_endflag_test.dart`（新規）

- TC-AEF-001: SKIP（ActionTimeボトムシート内ボタン操作がテスト環境で困難・設計上許容）
- TC-AEF-002: PASS（アクション記録なしの場合、完了バッジが存在しないこと）

#### Unit Test: `test/adapter/visit_work_dashboard_adapter_test.dart`（新規）

- TC-DA-001: PASS（actionNameがactionIdでなく正しいアクション名であること）
- TC-DA-002: PASS（markLink.actionsが空の場合workBreakdownが空であること）

### 要件書作成

#### UI-25: スプラッシュ「MICHIMARK」テキスト表示

- `docs/Requirements/REQ-splash_michimark_text.md` 作成
- 課題: Android向けヒラギノ角丸フォント対応方法（A〜D案）はユーザー確認待ち

#### UI-26: ダッシュボードタブ上スクロールリロード

- `docs/Requirements/REQ-dashboard_pull_to_refresh.md` 作成

## テスト結果

| テスト | PASS | SKIP | FAIL |
|---|---|---|---|
| action_time_endflag_test（Integration） | 1 | 1 | 0 |
| visit_work_dashboard_adapter_test（Unit） | 2 | 0 | 0 |
| **合計** | **3** | **1** | **0** |

## 変更ファイル

- `flutter/lib/features/michi_info/bloc/michi_info_bloc.dart` — Bug1: markLinkId設定・isDone再計算追加
- `flutter/lib/repository/impl/in_memory/seed_data.dart` — Bug1: visit_work_depart に endFlag: true 追加
- `flutter/lib/features/dashboard/adapter/visit_work_dashboard_adapter.dart` — Bug4: actionNameMap構築・凡例にactionName使用
- `flutter/assets/images/splash_logo.png` — Bug2: Logo_v2に更新
- `flutter/integration_test/action_time_endflag_test.dart` — 新規: EndFlag Integration Test
- `flutter/test/adapter/visit_work_dashboard_adapter_test.dart` — 新規: Dashboard凡例 Unit Test
- `docs/Requirements/REQ-splash_michimark_text.md` — 新規: UI-25要件書
- `docs/Requirements/REQ-dashboard_pull_to_refresh.md` — 新規: UI-26要件書
- `docs/Tasks/TASKBOARD.md` — タスク追加・DONE更新

## 次回セッションで最初にやること

1. **UI-25 Android向けフォント対応方法をユーザーに確認**（A: カスタムフォントバンドル / B: 代替フリーフォント / C: google_fonts / D: Androidはデフォルト）
2. **UI-25 architect Spec作成**（T-627）→ flutter-dev/tester 並行実装（T-628a/b）
3. **UI-26 architect Spec作成**（T-632）→ flutter-dev/tester 並行実装（T-633a/b）
4. BRAND-1 T-615: testerテスト実行（T-611 BLOCKED継続）

## コミット

コミットは本ファイル作成後に実施予定
