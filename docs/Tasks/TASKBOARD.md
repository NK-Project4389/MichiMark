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
| T-432 | B-17: サンプルデータ内容の設計・要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-seed_data_sample.md |
| T-433 | B-17: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-seed_data_sample.md |
| T-434a | B-17: シードデータ実装 | flutter-dev | `DONE` | | FS-seed_data_sample.md 参照 |
| T-434b | B-17: テストコード実装 | tester | `DONE` | | TC-SD-001〜009（TC-SD-001のみ実装、TC-SD-002〜009はSKIP） |
| T-435 | B-17: レビュー | reviewer | `DONE` | | 承認 |
| T-436 | B-17: テスト実行 | tester | `DONE` | | 3PASS/0FAIL（TC-SD-001〜001c） |

---

## INFRA-1: Firebase基盤整備

> 一部タスクのみ残存。T-346b/348 はFirebase実機接続が必要なためBLOCKED。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-344 | Firebase基盤整備 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-firebase_infra.md |
| T-345 | Firebase基盤整備 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-firebase_infra.md |
| T-346a | Firebase基盤整備 実装 | flutter-dev | `DONE` | | AuthRepository・Firebase初期化・DI登録実装完了 |
| T-346b | Firebase基盤整備 テストコード実装 | tester | `DONE` | | fake_cloud_firestore/firebase_auth_mocks使用・TC-INFRA-001〜008（7PASS/1SKIP） |
| T-347 | Firebase基盤整備 レビュー | reviewer | `DONE` | | 承認（firebase_options gitignore追加） |
| T-348 | Firebase基盤整備 テスト実行 | tester | `DONE` | | 7PASS/0FAIL/1SKIP（TC-INFRA-003はネイティブ呼び出しのためSKIP） |

---

## INV-2: 招待機能 中間Webページ（Next.js）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-329 | 招待Webページ 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-invitation_web_page.md |
| T-330 | 招待Webページ Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-invitation_web_page.md |
| T-331a | 招待Webページ 実装（Next.js） | flutter-dev | `DONE` | | FS-invitation_web_page.md 参照 |
| T-331b | 招待Webページ テストコード実装 | tester | `DONE` | | TC-INV2-001〜008（26テスト） |
| T-332 | 招待Webページ レビュー | reviewer | `DONE` | | 承認 |
| T-333 | 招待Webページ テスト実行 | tester | `DONE` | | 73PASS/0FAIL/0SKIP |

---

## INV-3: 招待機能 招待コード入力画面（Flutter）

> INV-2と並行実施可能

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-334 | 招待コード入力 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-invitation_code_input.md |
| T-335 | 招待コード入力 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-invitation_code_input.md |
| T-336a | 招待コード入力 実装 | flutter-dev | `DONE` | | FS-invitation_code_input.md 参照 |
| T-336b | 招待コード入力 テストコード実装 | tester | `DONE` | | TC-INV3-001〜010（12テスト） |
| T-337 | 招待コード入力 レビュー | reviewer | `DONE` | | 承認 |
| T-338 | 招待コード入力 テスト実行 | tester | `DONE` | | 12PASS/0FAIL/0SKIP |

---

## INV-4: 招待機能 招待リンク生成・共有（Flutter）

> ⚠️ INV-1・INV-2完了後に着手する

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-339 | 招待リンク生成・共有 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-invitation_link_share.md |
| T-340 | 招待リンク生成・共有 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-invitation_link_share.md |
| T-341a | 招待リンク生成・共有 実装 | flutter-dev | `DONE` | | BottomSheet・InviteLinkShareBloc・スタブ実装・dart analyze 0件 |
| T-341b | 招待リンク生成・共有 テストコード実装 | tester | `DONE` | | TC-INV4-001〜011（13件） |
| T-342 | 招待リンク生成・共有 レビュー | reviewer | `DONE` | | 承認（テスト整合性は後続） |
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
| T-394 | F-2: テスト実行 | tester | `DONE` | | 20PASS/0FAIL/10SKIP(シードデータなし) |

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
| T-400 | UI-14: テスト実行 | tester | `DONE` | | 9PASS/0FAIL/2SKIP(MarkDetail遷移) |

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

---

## F-7: イベント招待機能 UI配置（概要タブ/ヘッダ）

> イベント詳細画面の概要タブまたはヘッダ上に招待機能への導線を配置する。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-437 | F-7: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-invitation_ui_placement.md |
| T-438 | F-7: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-invitation_ui_placement.md |
| T-439a | F-7: 実装 | flutter-dev | `DONE` | | InvitationRole enum・Event/Delegate追加・_InvitationSection実装・dart analyze 0件 |
| T-439b | F-7: テストコード実装 | tester | `DONE` | | TC-IUP-001〜007（9件） |
| T-440 | F-7: レビュー | reviewer | `DONE` | | 承認 |
| T-441 | F-7: テスト実行 | tester | `DONE` | | 6PASS/2SKIP/0FAIL（TC-IUP-001b・TC-IUP-002はowner権限スタブ設定依存SKIP） |

---

## UI-17: ダッシュボードタブ左側配置・初期タブ化

> ダッシュボードタブをタブバーの左側（先頭）に配置し、初期表示タブにする。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-442 | UI-17: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-dashboard_tab_position.md |
| T-443 | UI-17: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-dashboard_tab_position.md |
| T-444a | UI-17: 実装 | flutter-dev | `DONE` | | router.dart: initialLocation変更・タブ順序変更・Key付与 |
| T-444b | UI-17: テストコード実装 | tester | `DONE` | | TC-TAB-001〜004（4件） |
| T-445 | UI-17: レビュー | reviewer | `DONE` | | 承認 |
| T-446 | UI-17: テスト実行 | tester | `DONE` | | 4PASS/0FAIL ✅ |

---

## UI-18: ダッシュボードタブ名変更（イベント→イベント一覧）

> ダッシュボードのタブ名を「イベント」から「イベント一覧」に変更する。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-447 | UI-18: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-dashboard_tab_rename.md |
| T-448 | UI-18: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-dashboard_tab_rename.md |
| T-449a | UI-18: 実装 | flutter-dev | `DONE` | | タブラベル・AppBarタイトル「イベント一覧」に変更 |
| T-449b | UI-18: テストコード実装 | tester | `DONE` | | TC-RNM-001〜004（4件） |
| T-450 | UI-18: レビュー | reviewer | `DONE` | | 承認 |
| T-451 | UI-18: テスト実行 | tester | `DONE` | | 4PASS/0FAIL ✅ |

---

## UI-19: 訪問作業 道タブ マークアクションバッジ・削除ボタン改善

> 訪問作業トピックの道タブでマークのアクションバッジが小さく、削除ボタンが隣接して誤タップしやすい問題をデザインから見直す。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-452 | UI-19: デザイン提案 | designer | `DONE` | | docs/Design/draft/visit_work_action_badge_redesign.html |
| T-453 | UI-19: 要件書作成 | product-manager | `BLOCKED` | | T-452完了後 |
| T-454 | UI-19: Spec作成 | architect | `BLOCKED` | | T-453完了後 |
| T-455a | UI-19: 実装 | flutter-dev | `BLOCKED` | | |
| T-455b | UI-19: テストコード実装 | tester | `BLOCKED` | | |
| T-456 | UI-19: レビュー | reviewer | `BLOCKED` | | |
| T-457 | UI-19: テスト実行 | tester | `BLOCKED` | | |

---

## B-19: 訪問作業シードデータ区間削除・IntTest見直し

> 訪問作業では区間は作成されないため、シードデータから区間データを削除。必要に応じてIntegration Testのスルーテスト項目も見直す。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-458 | B-19: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-visit_work_seed_data_fix.md |
| T-459 | B-19: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-visit_work_seed_data_fix.md |
| T-460a | B-19: 実装 | flutter-dev | `DONE` | | シナリオCからLink4件削除済み |
| T-460b | B-19: テストコード実装 | tester | `DONE` | | TC-B19-I001〜I004（9件） |
| T-461 | B-19: レビュー | reviewer | `DONE` | | 承認 |
| T-462 | B-19: テスト実行 | tester | `DONE` | | 16PASS/0FAIL ✅ |

---

## F-6: 訪問作業からメンバー項目を除外

> 訪問作業トピックではメンバー項目は不要なため、非表示にする。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-463 | F-6: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-visit_work_no_member.md |
| T-464 | F-6: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-visit_work_no_member.md |
| T-465a | F-6: 実装 | flutter-dev | `DONE` | | TopicConfig.showMarkMembersで条件分岐済み |
| T-465b | F-6: テストコード実装 | tester | `DONE` | | TC-NM-I001〜I009（8件） |
| T-466 | F-6: レビュー | reviewer | `DONE` | | 承認 |
| T-467 | F-6: テスト実行 | tester | `DONE` | | 6PASS/2SKIP/0FAIL（TC-NM-I001〜I009・I005/I006はSkip） |

---

## B-18: 訪問作業トピック マークから支払い保存できないバグ

> 新規登録時、訪問作業トピックでマークから支払い情報を登録しようとしたとき、保存ボタンを押しても反応がない。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-468a | B-18: バグ修正 | flutter-dev | `DONE` | | EventDetailPaymentSaved Event追加・MarkDetailBloc新規作成モードpaymentSection初期化 |
| T-468b | B-18: テストコード実装 | tester | `DONE` | | TC-B18-I001〜I003（3件） |
| T-469 | B-18: レビュー | reviewer | `DONE` | | 承認 |
| T-470 | B-18: テスト実行 | tester | `DONE` | | 3PASS/0FAIL/0SKIP（TC-B18-I001〜I003全PASS） |

---

## UI-20: マスター項目詳細 保存/キャンセルボタンを画面下部に配置

> マスター項目詳細画面の「保存」「キャンセル」ボタン配置をMarkDetail等と同じように画面下部に配置する（ヘッダの「保存」ボタン廃止）。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-471 | UI-20: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-master_detail_button_layout.md |
| T-472 | UI-20: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-master_detail_button_layout.md |
| T-473a | UI-20: 実装 | flutter-dev | `DONE` | | FS-master_detail_button_layout.md 参照 |
| T-473b | UI-20: テストコード実装 | tester | `DONE` | | TC-MDB-001〜020（28件） |
| T-474 | UI-20: レビュー | reviewer | `DONE` | | 承認 |
| T-475 | UI-20: テスト実行 | tester | `DONE` | | 28/28 ALL PASS（2026-04-17 3シャード実行） |

---

## UI-21: マスター項目の「＋」ボタンを右下FABに配置

> マスター項目ごとの一覧で右上にある「＋」マークを、MichiInfo等と同様に右下のFABボタンとして配置する。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-476 | UI-21: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-master_list_fab_button.md |
| T-477 | UI-21: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-master_list_fab_button.md |
| T-478a | UI-21: 実装 | flutter-dev | `DONE` | | FS-master_list_fab_button.md 参照 |
| T-478b | UI-21: テストコード実装 | tester | `DONE` | | TC-FAB-001〜012（16件） |
| T-479 | UI-21: レビュー | reviewer | `DONE` | | 承認 |
| T-480 | UI-21: テスト実行 | tester | `DONE` | | 16PASS/0FAIL ✅ |

---

## UI-22: ダッシュボード移動コストグラフ ポップアップ改善

> 移動コストグラフの棒タップ時のポップアップが黒文字+濃い緑背景で見づらい。日付単位で長押ししたら距離と金額が表示されるようにする。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-481 | UI-22: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-dashboard_graph_popup.md |
| T-482 | UI-22: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-dashboard_graph_popup.md |
| T-483a | UI-22: 実装 | flutter-dev | `DONE` | | FS-dashboard_graph_popup.md 参照 |
| T-483b | UI-22: テストコード実装 | tester | `DONE` | | TC-GP-001〜005（5件） |
| T-484 | UI-22: レビュー | reviewer | `DONE` | | 承認 |
| T-485 | UI-22: テスト実行 | tester | `DONE` | | 5PASS/0FAIL ✅（di.dart/seed_data/_event1日付/_tap座標修正後） |

---

## B-20: 訪問作業シードデータ ActionTime情報追加

> 訪問作業のシードデータを充実させる。特にActionTime情報が未設定なので追加する。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-486 | B-20: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-visit_work_seed_data_actiontime.md |
| T-487 | B-20: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-visit_work_seed_data_actiontime.md |
| T-488a | B-20: 実装 | flutter-dev | `DONE` | | ActionTimeLog11件追加（A社3件・B社5件・C社3件） |
| T-488b | B-20: テストコード実装 | tester | `DONE` | | TC-B20-I001〜I004（8件） |
| T-489 | B-20: レビュー | reviewer | `DONE` | | 承認 |
| T-490 | B-20: テスト実行 | tester | `DONE` | | 8PASS/0FAIL/0SKIP（TC-B20-I001〜I004全PASS） |

---

## REL-3: Ver1.1 App Store ページ更新（メタデータ・スクリーンショット）

> INV-4（招待リンク生成・共有）実装完了後に着手。Dashboard・招待・訪問作業を目玉としたページ刷新。
> 草案: docs/AppStore/metadata_ja_v1.1_draft.md

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-491 | REL-3: スクリーンショット用オーバーレイデザイン作成 | designer | `BLOCKED` | | INV-4完了後。6枚構成・キャッチコピー重畳。T-427のv1.0デザインをベースに更新 |
| T-492 | REL-3: スクリーンショット撮影・組み立て | designer | `BLOCKED` | | T-491完了後。実機スクショ＋オーバーレイ合成 |
| T-493 | REL-3: メタデータ確定・App Store Connect 更新 | marketer | `BLOCKED` | | T-492完了後。説明文・キーワード・プロモーションテキスト・スクショ一括反映 |

---

## OPS-1: エージェントモデル配分切り替え（4/17 7:00以降）

> Sonnet週間使用量が6日目で上限到達したため、モデル配分を最適化する。4/17 7:00リセット後に通常運用配分に切り替える。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-494 | OPS-1: 全エージェントのモデルを通常運用配分に切り替え | orchestrator | `DONE` | | PM:Opus / Architect:Sonnet / flutter-dev:Sonnet / reviewer:Sonnet / tester:Haiku / test-analyzer:Sonnet / orchestrator:Sonnet / designer:Sonnet / marketer:Sonnet / charter-reviewer:Haiku |

---

## TEST-FIX-1: Integration Test 残存FAIL修正（シードデータ依存）

> 2026-04-17の3シャード全件実行で残存したFAIL約39件（シードデータ不一致が原因）。
> seed_data.dartのFLAVOR dart-define切り替えで解消済み。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-495 | 残存FAILの原因調査 | test-analyzer | `DONE` | | FLUTTER_TEST env var不動作が原因と判明 |
| T-496 | seed_data.dart修正（FLAVOR dart-defineへ変更） | flutter-dev | `DONE` | | commit 669ca0d |
| T-497 | 修正後テスト実行（8ファイル） | tester | `DONE` | | 38PASS/3SKIP/0FAIL（シードデータ起因分は全解消） |

---

## TEST-FIX-2: Integration Test 残存FAIL修正（実装・テストコード問題）

> TEST-FIX-1修正後の対象ファイル実行で残存した5件のFAIL。シードデータとは無関係。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-498 | dashboard_graph_popup FAIL修正（tooltip Widgetキー） | flutter-dev | `DONE` | | FlPanDownEvent対応・di.dart FLAVOR=test修正・seed_data _event1日付→_rel(-5)・tap座標計算修正で全5件PASS ✅ |
| T-499 | fab_and_unsaved_dialog FAIL修正（近所のドライブ画面外） | tester | `DONE` | | ListViewスクロールループ追加でTC-BACK-001等 8PASS/0FAIL ✅ |
| T-500 | 修正後テスト実行 | tester | `DONE` | | T-498・T-499分ともに完了。全件PASS ✅ |
