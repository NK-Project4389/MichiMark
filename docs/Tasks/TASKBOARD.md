# MichiMark タスクボード

## 運用ルール

1. **セッション開始時に必ずこのファイルを読む**
2. `IN_PROGRESS` のタスクには別セッションは手を出さない
3. タスクを着手するとき → `status` を `IN_PROGRESS`、`locked_by` に `YYYY-MM-DD_[作業内容]` を記入
4. 完了したとき → `status` を `DONE`、`locked_by` を空欄に
5. 着手できない状態のとき → `status` を `BLOCKED`、`notes` に理由を記入
6. **全タスクDONEのセクションは `TASKBOARD_ARCHIVE.md` へ移動する**

## ステータス凡例

| status | 意味 |
|---|---|
| `TODO` | 未着手・着手可能 |
| `IN_PROGRESS` | 別セッションが作業中 → 触らない |
| `DONE` | 完了 |
| `BLOCKED` | ブロックあり（依存タスク未完了など） |

---

## UI-19: 訪問作業 アクション操作UI改善

> 訪問作業トピックの道タブでマークのアクションバッジが小さく、削除ボタンが隣接して誤タップしやすい問題をデザインから見直す。
> 合わせて以下のバグ修正も本セクションで対応する：
> - アクションボタンの配置・サイズ未反映（中央寄り・横幅縦幅大きく）
> - 訪問作業の「休憩」アクションを削除（トグル休憩と重複）
> - アクション表示順変更（到着→作業開始→作業終了→出発）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-452 | UI-19: デザイン提案（バッジ・削除ボタン） | designer | `DONE` | | 最新: docs/Design/draft/visit_work_action_button_center_design.html（旧: visit_work_action_badge_redesign.html） |
| T-453 | UI-19: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-visit_work_action_ui.md |
| T-454 | UI-19: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-visit_work_action_ui.md |
| T-455a | UI-19: 実装 | flutter-dev | `DONE` | | 実装完了・reviewerレビュー承認 |
| T-455b | UI-19: テストコード実装 | tester | `DONE` | | TC-VWA-001〜006全件実装・reviewer承認・テスト実行待ち（環境問題で次回） |
| T-456 | UI-19: レビュー | reviewer | `DONE` | | 設計憲章・Spec準拠確認完了・APPROVED |
| T-457 | UI-19: テスト実行 | tester | `DONE` | | 6PASS/0FAIL（TC-VWA-001〜006全件PASS）・michiInfo_item_mark_キー追加で修正 |

---

## F-8: PaymentDetail売上追加 + OverView収支集計

> PaymentDetailに売上項目を追加。訪問作業のイベント概要OverViewセクションに支払項目・収支合計（売上-支払）を表示する。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-504 | F-8: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-payment_detail_sales.md（v確定・収支タブ追記） |
| T-505 | F-8: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-payment_detail_sales.md |
| T-506a | F-8: 実装 | flutter-dev | `DONE` | | schemaVersion v7→v8・dart analyze 0件 |
| T-506b | F-8: テストコード実装 | tester | `DONE` | | TC-PDS-001〜010 全件実装完了 |
| T-507 | F-8: レビュー | reviewer | `DONE` | | APPROVED（テストコード3点修正・Spec schemaVersion更新後に承認） |
| T-508 | F-8: テスト実行 | tester | `DONE` | | 4PASS/6SKIP/0FAIL（TC-PDS-001/008/009/010 PASS） |

---

## F-9: ActionLog 時間変更機能

> 登録時間とは別に「変更後の時間」をDomainに追加。ActionTime画面では変更後の時間を優先してソート。
> UI上で時間をタップすると変更できる。変更後=登録時間になった場合はNULLに戻す。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-521 | F-9: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-action_log_time_edit.md |
| T-522 | F-9: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-action_log_time_edit.md |
| T-523a | F-9: 実装 | flutter-dev | `DONE` | | schemaVersion v7・全ファイル実装完了・dart analyze エラー0件 |
| T-523b | F-9: テストコード実装 | tester | `DONE` | | TC-ALTE-001〜008実装（005・006はSKIP設計） |
| T-524 | F-9: レビュー | reviewer | `DONE` | | 設計憲章・Spec準拠確認・APPROVED |
| T-525 | F-9: テスト実行 | tester | `DONE` | | 5PASS/0FAIL/3SKIP（005・006・008はSKIP設計）・全件PASS |

---

## TEST-QUALITY-1: テスト品質改善（固有データハードコード廃止・Unit Test追加）

> IntegrationTestの安定性向上とロジックバグ早期検出のための施策。
> - シードデータ固有値（メンバー名・イベント名・交通手段名）のハードコードを廃止し `seed_data.dart` 定数参照に統一
> - Bloc/Domain Unit Test（`flutter test`）を追加してロジックバグをIntegrationTestに頼らず検出

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-601 | ルール整備（seed_dataレビュー・Unit Testサイクル） | orchestrator | `DONE` | | integration-test.md・workflow.mdに追加完了（2026-04-20） |
| T-602 | 固有データハードコード廃止（IntegrationTest修正） | flutter-dev | `IN_PROGRESS` | 2026-04-20_T-602_固有データハードコード廃止 | 対象: fuel_detail_design_test・member_required_guard_test・basic_info_trans_fuel_test・seed_fix_test・payment_info_redesign_test・payment_info_delete_test・moving_cost_balance_test |
| T-603 | Bloc/Domain Unit Test追加（第1弾: PaymentDomain・BasicInfoBloc） | tester | `TODO` | | T-602完了後が望ましい（BLOCKED解除可） |
| T-604 | Bloc/Domain Unit Test追加（第2弾: EventDetailBloc・OverviewBloc） | tester | `BLOCKED` | | T-603完了後 |

---

## INFRA-2: Google Workspace 移行（ドメイン設計 xlsx → Google Sheets）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-406 | Google Workspace MCP 動作確認 | orchestrator | `DONE` | | MCP登録完了・✓ Connected確認済み（~/.claude.json, npx @isaacphi/mcp-gdrive） |
| T-407 | Domain設計一覧.xlsx → Google Sheets 移行 | orchestrator | `DONE` | | 移行完了・v8に更新済み（ActionTimeLogs追加・各Domain新フィールド追加） |
| T-408 | 移行後の運用ルール整備 | orchestrator | `TODO` | | T-407完了後 |

---

## UTIL-1: CSV出力機能

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-409 | UTIL-1: 要件書作成 | product-manager | `BLOCKED` | | サブスク化実装後に着手 |
| T-410 | UTIL-1: Spec作成 | architect | `BLOCKED` | | T-409完了後 |
| T-411a | UTIL-1: 実装 | flutter-dev | `BLOCKED` | | |
| T-411b | UTIL-1: テストコード実装 | tester | `BLOCKED` | | |
| T-412 | UTIL-1: レビュー | reviewer | `BLOCKED` | | |
| T-413 | UTIL-1: テスト実行 | tester | `BLOCKED` | | |

---

## UI-15: イベントフィルター機能（日付・トピック）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-414 | UI-15: 要件書作成 | product-manager | `TODO` | | ユーザーと伴奏して進める |
| T-415 | UI-15: Spec作成 | architect | `BLOCKED` | | T-414完了後 |
| T-416a | UI-15: 実装 | flutter-dev | `BLOCKED` | | |
| T-416b | UI-15: テストコード実装 | tester | `BLOCKED` | | |
| T-417 | UI-15: レビュー | reviewer | `BLOCKED` | | |
| T-418 | UI-15: テスト実行 | tester | `BLOCKED` | | |

---

## UI-16: スプラッシュ画面改善

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-419 | UI-16: 要件書作成 | product-manager | `TODO` | | |
| T-420 | UI-16: Spec作成 | architect | `BLOCKED` | | T-419完了後 |
| T-421a | UI-16: 実装 | flutter-dev | `BLOCKED` | | |
| T-421b | UI-16: テストコード実装 | tester | `BLOCKED` | | |
| T-422 | UI-16: レビュー | reviewer | `BLOCKED` | | |
| T-423 | UI-16: テスト実行 | tester | `BLOCKED` | | |

---

## REL-2: App Store 公開後 改善サイクル

> 🎉 App Store 公開（2026-04-16）を受けて開始する公開後の改善サイクル。
> marketer が戦略立案・分析・草案提示を担当。ビジュアル制作は designer に連携。

### Phase 1: 現状把握・戦略立案

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-424 | App Store ページ現状レビュー・改善草案作成 | marketer | `DONE` | | docs/Marketing/appstore-1.0.0-2026-04-16.md |
| T-425 | SNS発信戦略立案・初投稿文草案作成 | marketer | `DONE` | | docs/Marketing/sns/ |
| T-426 | サクセスストーリー草案作成 | marketer | `DONE` | | docs/Marketing/stories/ |

### Phase 2: ビジュアル制作

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-427 | App Store スクリーンショット用デザイン作成 | designer | `DONE` | | docs/Design/draft/appstore_screenshot_overlay_design.html |
| T-428 | SNS用バナー・投稿ビジュアル作成 | designer | `TODO` | | T-425ユーザー承認後 |

### Phase 3: 月次分析サイクル（運用開始）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-429 | 月次分析レポート作成・改善提案（初回） | marketer | `BLOCKED` | | T-424〜428完了後・公開から1ヶ月後（2026-05-16目安）|
| T-430 | UX/機能改善要件書作成（分析結果から） | product-manager | `BLOCKED` | | T-429完了後 |
| T-431 | App Store メタデータ更新草案作成 | marketer | `BLOCKED` | | T-429完了後 |

---

## REL-3: Ver1.1 App Store ページ更新（メタデータ・スクリーンショット）

> INV-4（招待リンク生成・共有）実装完了後に着手。Dashboard・招待・訪問作業を目玉としたページ刷新。
> 草案: docs/AppStore/metadata_ja_v1.1_draft.md

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-491 | REL-3: スクリーンショット用オーバーレイデザイン作成 | designer | `BLOCKED` | | INV-4完了後。6枚構成・キャッチコピー重畳。T-427のv1.0デザインをベースに更新 |
| T-492 | REL-3: スクリーンショット撮影・組み立て | designer | `BLOCKED` | | T-491完了後。実機スクショ＋オーバーレイ合成 |
| T-493 | REL-3: メタデータ確定・App Store Connect 更新 | marketer | `BLOCKED` | | T-492完了後。説明文・キーワード・プロモーションテキスト・スクショ一括反映 |
