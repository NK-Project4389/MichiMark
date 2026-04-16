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

## B-17: 本番シードデータ見直し

> テストデータが本番配信されているため、ユーザーが入力イメージしやすいサンプルデータに差し替える。全クリアではなくサンプルを用意する。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-432 | B-17: サンプルデータ内容の設計・要件書作成 | product-manager | `TODO` | | どんなシナリオのサンプルを用意するかユーザーと相談 |
| T-433 | B-17: Spec作成 | architect | `BLOCKED` | | T-432完了後 |
| T-434a | B-17: シードデータ実装 | flutter-dev | `BLOCKED` | | |
| T-434b | B-17: テストコード実装 | tester | `BLOCKED` | | |
| T-435 | B-17: レビュー | reviewer | `BLOCKED` | | |
| T-436 | B-17: テスト実行 | tester | `BLOCKED` | | |

---

## INFRA-1: Firebase基盤整備

> 一部タスクのみ残存。T-346b/348 はFirebase実機接続が必要なためBLOCKED。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-344 | Firebase基盤整備 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-firebase_infra.md |
| T-345 | Firebase基盤整備 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-firebase_infra.md |
| T-346a | Firebase基盤整備 実装 | flutter-dev | `DONE` | | AuthRepository・Firebase初期化・DI登録実装完了 |
| T-346b | Firebase基盤整備 テストコード実装 | tester | `BLOCKED` | | Firebase実機接続が必要なためUnit Test（fake_cloud_firestore）で対応 |
| T-347 | Firebase基盤整備 レビュー | reviewer | `DONE` | | 承認（firebase_options gitignore追加） |
| T-348 | Firebase基盤整備 テスト実行 | tester | `BLOCKED` | | |

---

## INV-2: 招待機能 中間Webページ（Next.js）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-329 | 招待Webページ 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-invitation_web_page.md |
| T-330 | 招待Webページ Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-invitation_web_page.md |
| T-331a | 招待Webページ 実装（Next.js） | flutter-dev | `TODO` | | FS-invitation_web_page.md 参照 |
| T-331b | 招待Webページ テストコード実装 | tester | `TODO` | | TC-INV2-001〜008 |
| T-332 | 招待Webページ レビュー | reviewer | `BLOCKED` | | T-331a/b完了後 |
| T-333 | 招待Webページ テスト実行 | tester | `BLOCKED` | | T-332完了後 |

---

## INV-3: 招待機能 招待コード入力画面（Flutter）

> INV-2と並行実施可能

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-334 | 招待コード入力 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-invitation_code_input.md |
| T-335 | 招待コード入力 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-invitation_code_input.md |
| T-336a | 招待コード入力 実装 | flutter-dev | `TODO` | | FS-invitation_code_input.md 参照 |
| T-336b | 招待コード入力 テストコード実装 | tester | `TODO` | | TC-INV3-001〜010 |
| T-337 | 招待コード入力 レビュー | reviewer | `BLOCKED` | | T-336a/b完了後 |
| T-338 | 招待コード入力 テスト実行 | tester | `BLOCKED` | | T-337完了後 |

---

## INV-4: 招待機能 招待リンク生成・共有（Flutter）

> ⚠️ INV-1・INV-2完了後に着手する

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-339 | 招待リンク生成・共有 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-invitation_link_share.md |
| T-340 | 招待リンク生成・共有 Spec作成 | architect | `BLOCKED` | | INV-1/2完了後に着手 |
| T-341a | 招待リンク生成・共有 実装 | flutter-dev | `BLOCKED` | | |
| T-341b | 招待リンク生成・共有 テストコード実装 | tester | `BLOCKED` | | |
| T-342 | 招待リンク生成・共有 レビュー | reviewer | `BLOCKED` | | |
| T-343 | 招待リンク生成・共有 テスト実行 | tester | `BLOCKED` | | |

---

## F-3: トピック追加（訪問作業トピック）

> ⚠️ F-2（ダッシュボード）より先に実装すること（TopicType.visitWork参照のため）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-401 | F-3: 訪問作業トピック 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-visit_work_topic.md |
| T-402 | F-3: 訪問作業トピック Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-visit_work_topic.md |
| T-403a | F-3: 訪問作業トピック 実装 | flutter-dev | `DONE` | | FS-visit_work_topic.md 参照 |
| T-403b | F-3: 訪問作業トピック テストコード実装 | tester | `DONE` | | TC-VW-I001〜I008 17件実装済み |
| T-404 | F-3: レビュー | reviewer | `DONE` | | 承認 |
| T-403c | リモート実行結果確認 | orchestrator | `DONE` | | 手動実施済み（2026-04-16） |
| T-405 | F-3: Integration Test 実行 | tester | `DONE` | | 17PASS/0FAIL/0SKIP |

---

## POST-1 / F-5: MichiInfo支払い情報登録 / MarkDetail・LinkDetailからPaymentDetail登録

> POST-1とF-5は同一機能のため統合。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-361 | POST-1/F-5: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-payment_from_mark_link.md |
| T-362 | POST-1/F-5: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-payment_from_mark_link.md |
| T-363a | POST-1/F-5: 実装 | flutter-dev | `DONE` | | FS-payment_from_mark_link.md 参照 |
| T-363b | POST-1/F-5: テストコード実装 | tester | `DONE` | | TC-PML-I001〜I010 実装済み |
| T-364 | POST-1/F-5: レビュー | reviewer | `DONE` | | 承認 |
| T-365 | POST-1/F-5: テスト実行 | tester | `DONE` | | 15PASS/0FAIL/3SKIP(LinkDetail未実装) |

---

## F-2: 期間集計機能（ダッシュボード）

> ⚠️ F-3（訪問作業トピック）完了後に実装すること（TopicType.visitWork依存）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-390 | F-2: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-dashboard.md |
| T-391 | F-2: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-dashboard.md |
| T-392a | F-2: 実装 | flutter-dev | `DONE` | | FS-dashboard.md 参照 |
| T-392b | F-2: テストコード実装 | tester | `DONE` | | TC-DB-001〜008 |
| T-393 | F-2: レビュー | reviewer | `DONE` | | 承認 |
| T-394 | F-2: テスト実行 | tester | `IN_PROGRESS` | 2026-04-16_F2-UI14テスト実行 | T-393完了後 |

---

## UI-14: MichiInfoタイムライン 罫線→道路イメージ

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-395 | UI-14: デザイン提案 | designer | `DONE` | | docs/Design/draft/michi_info_road_timeline_design.html |
| T-396 | UI-14: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-michi_info_road_timeline.md |
| T-397 | UI-14: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-michi_info_road_timeline.md |
| T-398a | UI-14: 実装 | flutter-dev | `DONE` | | FS-michi_info_road_timeline.md 参照 |
| T-398b | UI-14: テストコード実装 | tester | `DONE` | | TC-RDT-001〜005 |
| T-399 | UI-14: レビュー | reviewer | `DONE` | | 承認 |
| T-400 | UI-14: テスト実行 | tester | `IN_PROGRESS` | 2026-04-16_F2-UI14テスト実行 | T-399完了後 |

---

## INFRA-2: Google Workspace 移行（ドメイン設計 xlsx → Google Sheets）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-406 | Google Workspace MCP 動作確認 | orchestrator | `TODO` | | OAuth設定 → MCP登録 → Sheets読み書き確認 |
| T-407 | Domain設計一覧.xlsx → Google Sheets 移行 | orchestrator | `BLOCKED` | | T-406完了後 |
| T-408 | 移行後の運用ルール整備 | orchestrator | `BLOCKED` | | T-407完了後 |

---

## UTIL-1: CSV出力機能

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-409 | UTIL-1: 要件書作成 | product-manager | `TODO` | | ユーザーと伴奏して進める |
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
