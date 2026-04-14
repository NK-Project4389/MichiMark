# MichiMark タスクボード

## 運用ルール

1. **セッション開始時に必ずこのファイルを読む**
2. `IN_PROGRESS` のタスクには別セッションは手を出さない
3. タスクを着手するとき → `status` を `IN_PROGRESS`、`locked_by` に `YYYY-MM-DD_[作業内容]` を記入
4. 完了したとき → `status` を `DONE`、`locked_by` を空欄に
5. 着手できない状態のとき → `status` を `BLOCKED`、`notes` に理由を記入

## ステータス凡例

| status | 意味 |
|---|---|
| `TODO` | 未着手・着手可能 |
| `IN_PROGRESS` | 別セッションが作業中 → 触らない |
| `DONE` | 完了 |
| `BLOCKED` | ブロックあり（依存タスク未完了など） |

---

## UI-1: イベント削除UI変更（スワイプ廃止→詳細画面削除アイコン）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-210 | イベント削除UI変更 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-event_delete_ui_redesign.md |
| T-211 | イベント削除UI変更 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-event_delete_ui_redesign.md |
| T-212a | イベント削除UI変更 実装 | flutter-dev | `DONE` | | FS-event_delete_ui_redesign.md 参照 |
| T-212b | イベント削除UI変更 テストコード実装 | tester | `DONE` | | TC-EDR-001〜006 実装済み |
| T-213 | イベント削除UI変更 レビュー | reviewer | `DONE` | | 合格 |
| T-214 | イベント削除UI変更 テスト実行 | tester | `DONE` | | 6件全件PASS（startAppクリーンアップ修正込み） |

---

## UI-2: BasicInfo参照タップ編集UI改善（デザイン調整あり）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-220 | BasicInfo参照タップ編集 デザイン提案 | designer | `DONE` | | docs/Design/draft/basic_info_tap_to_edit_design.html |
| T-221 | BasicInfo参照タップ編集 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-basic_info_tap_to_edit.md |
| T-222 | BasicInfo参照タップ編集 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-basic_info_tap_to_edit.md |
| T-222a | BasicInfo参照タップ編集 実装 | flutter-dev | `DONE` | | FS-basic_info_tap_to_edit.md 参照 |
| T-222b | BasicInfo参照タップ編集 テストコード実装 | tester | `DONE` | | TC-BTE-001〜007 実装済み（integration_test/basic_info_tap_to_edit_test.dart） |
| T-223 | BasicInfo参照タップ編集 レビュー | reviewer | `DONE` | | 合格 |
| T-224 | BasicInfo参照タップ編集 テスト実行 | tester | `DONE` | | 14件PASS/0FAIL/0SKIP |

---

## UI-3: MichiInfo Mark/Link削除UI変更（デザイン調整あり）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-230 | MichiInfo削除UI変更 デザイン提案 | designer | `DONE` | | docs/Design/draft/michi_info_delete_icon_design.html |
| T-231 | MichiInfo削除UI変更 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-michi_info_delete_icon.md |
| T-232 | MichiInfo削除UI変更 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-michi_info_delete_icon.md |
| T-232a | MichiInfo削除UI変更 実装 | flutter-dev | `DONE` | | FS-michi_info_delete_icon.md 参照 |
| T-232b | MichiInfo削除UI変更 テストコード実装 | tester | `DONE` | | TC-MID-001〜007 実装済み（006/007 はCustomPainterのためSKIP） |
| T-233 | MichiInfo削除UI変更 レビュー | reviewer | `DONE` | | 合格 |
| T-234 | MichiInfo削除UI変更 テスト実行 | tester | `DONE` | | 5PASS/2SKIP/0FAIL（TC-MID-001〜005 PASS・006/007 SKIP） |

---

## UI-4: PaymentInfo カード削除UI変更

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-240 | PaymentInfo削除UI変更 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-payment_info_delete_icon.md |
| T-241 | PaymentInfo削除UI変更 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-payment_info_delete_icon.md |
| T-242a | PaymentInfo削除UI変更 実装 | flutter-dev | `DONE` | | FS-payment_info_delete_icon.md 参照 |
| T-242b | PaymentInfo削除UI変更 テストコード実装 | tester | `DONE` | | TC-PID2-001〜003 実装済み |
| T-243 | PaymentInfo削除UI変更 レビュー | reviewer | `DONE` | | 合格 |
| T-244 | PaymentInfo削除UI変更 テスト実行 | tester | `DONE` | | 3PASS/0FAIL/0SKIP |

---

## UI-5: MarkDetail/LinkDetail/PaymentDetail UI改善

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-250 | Detail画面UI改善 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-detail_screen_ui_improvement.md |
| T-251 | Detail画面UI改善 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-detail_screen_ui_improvement.md |
| T-252a | Detail画面UI改善 実装 | flutter-dev | `DONE` | | FS-detail_screen_ui_improvement.md 参照 |
| T-252b | Detail画面UI改善 テストコード実装 | tester | `DONE` | | TC-DSI-001〜015 実装済み |
| T-253 | Detail画面UI改善 レビュー | reviewer | `DONE` | | 合格 |
| T-254 | Detail画面UI改善 テスト実行 | tester | `DONE` | | 18件PASS・openLinkDetailヘルパー修正込み |

---

## B-6: 給油計算 ガソリン支払い者インラインチップ選択（Phase C）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-269 | B-6: Phase C Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-gas_payer_chip_selection_phaseC.md |
| T-270a | B-6: ガソリン支払い者チップ選択 実装 | flutter-dev | `DONE` | | FS-gas_payer_chip_selection_phaseC.md 参照 |
| T-270b | B-6: テストコード実装 | tester | `DONE` | | TC-GPS-001〜008 実装済み（gas_payer_chip_test.dart） |
| T-271 | B-6: レビュー | reviewer | `DONE` | | 合格 |
| T-272 | B-6: テスト実行 | tester | `DONE` | | 8PASS/0FAIL/0SKIP（TC-GPS-001〜008 全件PASS） |

---

## UI-6: 概要タブ セクション名追加（基本情報・集計）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-264 | 概要タブセクション名 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-overview_tab_section_labels.md |
| T-265 | 概要タブセクション名 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-overview_tab_section_labels.md |
| T-266a | 概要タブセクション名 実装 | flutter-dev | `DONE` | | FS-overview_tab_section_labels.md 参照 |
| T-266b | 概要タブセクション名 テストコード実装 | tester | `DONE` | | TC-OSL-001〜002 実装済み |
| T-267 | 概要タブセクション名 レビュー | reviewer | `DONE` | | 合格 |
| T-268 | 概要タブセクション名 テスト実行 | tester | `DONE` | | 4PASS/0FAIL/0SKIP（TC-OSL-001〜002 全件PASS） |

---

## UI-7: MichiInfo / PaymentInfo 削除確認ダイアログ追加

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-280 | 削除確認ダイアログ 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-delete_confirmation_dialog.md |
| T-281 | 削除確認ダイアログ Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-delete_confirmation_dialog.md |
| T-282a | 削除確認ダイアログ 実装 | flutter-dev | `DONE` | | MichiInfo/PaymentInfo両対応・CupertinoDialog・StatefulWidget化 |
| T-282b | 削除確認ダイアログ テストコード実装 | tester | `DONE` | | TC-DCD-001〜006b 17件実装済み |
| T-283 | 削除確認ダイアログ レビュー | reviewer | `DONE` | | 承認 |
| T-284 | 削除確認ダイアログ テスト実行 | tester | `DONE` | | 17PASS/0FAIL（showCupertinoDialog<bool>修正後・全件PASS） |

---

## UI-8: イベント追加ボタン 選択肢スキップ遷移

> 地点登録のみ / 区間登録のみ利用可能な場合、選択肢画面を経由せず直接登録画面へ遷移する

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-285 | イベント追加スキップ遷移 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-event_add_skip_selection.md |
| T-286 | イベント追加スキップ遷移 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-event_add_skip_selection.md |
| T-287a | イベント追加スキップ遷移 実装 | flutter-dev | `DONE` | | |
| T-287b | イベント追加スキップ遷移 テストコード実装 | tester | `DONE` | | TC-EAS-001〜006 実装済み |
| T-288 | イベント追加スキップ遷移 レビュー | reviewer | `DONE` | | 承認 |
| T-289 | イベント追加スキップ遷移 テスト実行 | tester | `DONE` | | 6PASS/0FAIL/0SKIP（TC-EAS-001〜006 全件PASS） |

---

## B-7: 削除後 集計即時反映バグ修正

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-290 | 削除後集計即時反映 バグ修正実装 | flutter-dev | `DONE` | | MichiInfoReloadedDelegate / PaymentInfoReloadedDelegate を削除ハンドラに追加 |
| T-290b | 削除後集計即時反映 テストコード実装 | tester | `DONE` | | TC-DAU-001〜002c 6件実装済み |
| T-291 | 削除後集計即時反映 レビュー | reviewer | `DONE` | | 承認 |
| T-292 | 削除後集計即時反映 テスト実行 | tester | `DONE` | | 6PASS/0FAIL/0SKIP（UI-7対応: 削除ヘルパー関数をダイアログキーに修正） |

---

## F-2: 移動コスト集計 収支バランス追加

> 旅費集計と同様の収支バランス表示を燃費・給油集計にも追加

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-293 | 移動コスト集計収支バランス 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-moving_cost_balance.md |
| T-294 | 移動コスト集計収支バランス Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-moving_cost_balance.md |
| T-295a | 移動コスト集計収支バランス 実装 | flutter-dev | `IN_PROGRESS` | 2026-04-14_UI8-F2-F4実装 | |
| T-295b | 移動コスト集計収支バランス テストコード実装 | tester | `IN_PROGRESS` | 2026-04-14_UI8-F2-F4実装 | |
| T-296 | 移動コスト集計収支バランス レビュー | reviewer | `TODO` | | |
| T-297 | 移動コスト集計収支バランス テスト実行 | tester | `DONE` | | 8PASS/0FAIL/0SKIP（TC-MCB-001〜006 全件PASS） |

---

## F-3: 給油集計 「満タン給油で算出」文言追加

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-298 | 給油集計文言追加 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-fuel_aggregation_fulltank_label.md |
| T-299 | 給油集計文言追加 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-fuel_aggregation_fulltank_label.md |
| T-300a | 給油集計文言追加 実装 | flutter-dev | `DONE` | | Projection hasFuelData追加・Adapter算出・View サブテキスト追加 |
| T-300b | 給油集計文言追加 テストコード実装 | tester | `DONE` | | TC-FFL-001〜002 4件実装済み |
| T-301 | 給油集計文言追加 レビュー | reviewer | `DONE` | | 承認 |
| T-302 | 給油集計文言追加 テスト実行 | tester | `DONE` | | 4PASS/0FAIL/0SKIP（TC-FFL-001〜002 全件PASS） |

---

## UI-9: 旅費集計「支払いごとの精算」誤認防止デザイン変更

> タップできるように見えてしまう問題を解消するデザイン変更

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-303 | 精算行誤認防止 デザイン提案 | designer | `DONE` | | docs/Design/draft/payment_settlement_display_design.html（B案採用） |
| T-304 | 精算行誤認防止 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-payment_settlement_display.md |
| T-305 | 精算行誤認防止 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-payment_settlement_display.md |
| T-306a | 精算行誤認防止 実装 | flutter-dev | `DONE` | | Card→Container置き換え・Specキー名準拠 |
| T-306b | 精算行誤認防止 テストコード実装 | tester | `DONE` | | TC-PSD-001〜002 実装済み |
| T-307 | 精算行誤認防止 レビュー | reviewer | `DONE` | | 承認 |
| T-308 | 精算行誤認防止 テスト実行 | tester | `DONE` | | TC-PSD-001〜002 3PASS/0FAIL/0SKIP |

---

## F-4: MichiInfoカード トピック別表示切り替え部品

> MichiInfoの一覧カードをトピックに応じて表示内容を変更できるカード部品に刷新

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-309 | MichiInfoカードトピック別表示 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-michi_info_card_topic_view.md |
| T-310 | MichiInfoカードトピック別表示 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-michi_info_card_topic_view.md |
| T-311a | MichiInfoカードトピック別表示 実装 | flutter-dev | `DONE` | | |
| T-311b | MichiInfoカードトピック別表示 テストコード実装 | tester | `DONE` | | TC-MCV-001〜007 11件実装済み |
| T-312 | MichiInfoカードトピック別表示 レビュー | reviewer | `DONE` | | 承認 |
| T-313 | MichiInfoカードトピック別表示 テスト実行 | tester | `DONE` | | 11PASS/0FAIL/0SKIP（TC-MCV-001〜007 全件PASS） |

---

## UI-10: 移動コストトピック MarkDetail/LinkDetail 名称項目非表示

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-314 | 移動コスト名称非表示 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-moving_cost_name_hidden.md |
| T-315 | 移動コスト名称非表示 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-moving_cost_name_hidden.md（movingCostEstimatedも非表示確定） |
| T-316a | 移動コスト名称非表示 実装 | flutter-dev | `DONE` | | topic_config.dart showNameField追加・MarkDetail/LinkDetail条件分岐 |
| T-316b | 移動コスト名称非表示 テストコード実装 | tester | `DONE` | | TC-MCN-001〜003 実装済み |
| T-317 | 移動コスト名称非表示 レビュー | reviewer | `DONE` | | 承認 |
| T-318 | 移動コスト名称非表示 テスト実行 | tester | `DONE` | | 3PASS/0FAIL/0SKIP（TC-MCN-001〜003 全件PASS） |

---

## UI-11: メンバー選択 全選択/全解除ボタン追加

> MarkDetail・LinkDetail・PaymentDetailのメンバー選択に全選択・全解除ボタン追加。支払者は解除不可。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-319 | メンバー全選択全解除 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-member_select_all_clear.md |
| T-320 | メンバー全選択全解除 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-member_select_all_clear.md |
| T-321a | メンバー全選択全解除 実装 | flutter-dev | `DONE` | | 6イベント追加・3Bloc・3View対応 |
| T-321b | メンバー全選択全解除 テストコード実装 | tester | `DONE` | | TC-MSA-001〜006b 7件実装済み（Specキー名準拠） |
| T-322 | メンバー全選択全解除 レビュー | reviewer | `DONE` | | 承認 |
| T-323 | メンバー全選択全解除 テスト実行 | tester | `DONE` | | 7PASS/0FAIL/0SKIP（DB初期化後再実行） |

---

## REL-1: AppStore無料版リリース準備

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-260 | AppStore無料版リリース準備 | orchestrator | `TODO` | | 下書き: docs/Requirements/REQ-DRAFT-appstore_free_release.md |

---

## INFRA-1: Firebase基盤整備

> ⚠️ REL-1（AppStoreリリース）完了後に着手する。INV-1〜4すべての前提。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-344 | Firebase基盤整備 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-firebase_infra.md（叩き作成済み） |
| T-345 | Firebase基盤整備 Spec作成 | architect | `BLOCKED` | | REL-1完了後に着手 |
| T-346a | Firebase基盤整備 実装 | flutter-dev | `BLOCKED` | | Anonymous Auth＋Apple Sign In＋Firestore移行 |
| T-346b | Firebase基盤整備 テストコード実装 | tester | `BLOCKED` | | |
| T-347 | Firebase基盤整備 レビュー | reviewer | `BLOCKED` | | |
| T-348 | Firebase基盤整備 テスト実行 | tester | `BLOCKED` | | |

---

## INV-1: 招待機能 バックエンド実装

> ⚠️ REL-1（AppStoreリリース）完了・INFRA-1完了後に着手する

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-324 | 招待機能バックエンド 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-invitation_backend.md |
| T-325 | 招待機能バックエンド Spec作成 | architect | `BLOCKED` | | INFRA-1完了後に着手 |
| T-326a | 招待機能バックエンド 実装（Next.js） | flutter-dev | `BLOCKED` | | |
| T-326b | 招待機能バックエンド テストコード実装 | tester | `BLOCKED` | | |
| T-327 | 招待機能バックエンド レビュー | reviewer | `BLOCKED` | | |
| T-328 | 招待機能バックエンド テスト実行 | tester | `BLOCKED` | | |

---

## INV-2: 招待機能 中間Webページ（Next.js）

> ⚠️ INV-1完了後に着手する

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-329 | 招待Webページ 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-invitation_web_page.md |
| T-330 | 招待Webページ Spec作成 | architect | `BLOCKED` | | INV-1完了後に着手 |
| T-331a | 招待Webページ 実装（Next.js） | flutter-dev | `BLOCKED` | | |
| T-331b | 招待Webページ テストコード実装 | tester | `BLOCKED` | | |
| T-332 | 招待Webページ レビュー | reviewer | `BLOCKED` | | |
| T-333 | 招待Webページ テスト実行 | tester | `BLOCKED` | | |

---

## INV-3: 招待機能 招待コード入力画面（Flutter）

> ⚠️ INV-1完了後に着手する（INV-2と並行可能）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-334 | 招待コード入力 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-invitation_code_input.md |
| T-335 | 招待コード入力 Spec作成 | architect | `BLOCKED` | | INV-1完了後に着手 |
| T-336a | 招待コード入力 実装 | flutter-dev | `BLOCKED` | | |
| T-336b | 招待コード入力 テストコード実装 | tester | `BLOCKED` | | |
| T-337 | 招待コード入力 レビュー | reviewer | `BLOCKED` | | |
| T-338 | 招待コード入力 テスト実行 | tester | `BLOCKED` | | |

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

## B-9: MichiInfo追加ボタン時のMark間隔

> 追加ボタン押下時（InsertMode）にLink間にない区間でもMark間の間隔が広くなる。Linkがない区間は間隔を狭める

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-366a | B-9: MichiInfo Mark間隔 バグ修正実装 | flutter-dev | `TODO` | | |
| T-366b | B-9: MichiInfo Mark間隔 テストコード実装 | tester | `TODO` | | |
| T-367 | B-9: レビュー | reviewer | `TODO` | | |
| T-368 | B-9: テスト実行 | tester | `TODO` | | |

---

## B-10: マスタ非表示の項目がDetailに表示される

> マスタで非表示設定のメンバー・タグ・アクション等がMarkDetail/LinkDetail/PaymentDetailに表示されてしまう。
> また既にイベントに登録済みのマスタが後から非表示になった場合、別の項目を選択したタイミングで非表示にする。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-369a | B-10: マスタ非表示フィルタ バグ修正実装 | flutter-dev | `TODO` | | |
| T-369b | B-10: マスタ非表示フィルタ テストコード実装 | tester | `TODO` | | |
| T-370 | B-10: レビュー | reviewer | `TODO` | | |
| T-371 | B-10: テスト実行 | tester | `TODO` | | |

---

## B-11: メンバー・タグ追加後のフォーカス継続

> メンバー・タグを追加した後、入力欄のフォーカスが外れて再タップが必要になる。
> 追加後も入力欄にフォーカスを戻す。空欄でエンターした時だけ編集を終了する。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-372a | B-11: メンバー・タグ追加後フォーカス継続 バグ修正実装 | flutter-dev | `TODO` | | |
| T-372b | B-11: メンバー・タグ追加後フォーカス継続 テストコード実装 | tester | `TODO` | | |
| T-373 | B-11: レビュー | reviewer | `TODO` | | |
| T-374 | B-11: テスト実行 | tester | `TODO` | | |

---

## B-12: メンバー・タグ入力中画面遷移時にレコメンドを閉じる

> メンバー・タグの入力中（レコメンドリスト表示中）に他の画面へ遷移すると、レコメンドが表示されたままになる。
> 画面遷移時にレコメンドを閉じる（フォーカスを外す）。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-375a | B-12: 画面遷移時レコメンドを閉じる バグ修正実装 | flutter-dev | `TODO` | | |
| T-375b | B-12: 画面遷移時レコメンドを閉じる テストコード実装 | tester | `TODO` | | |
| T-376 | B-12: レビュー | reviewer | `TODO` | | |
| T-377 | B-12: テスト実行 | tester | `TODO` | | |

---

## B-8: 作成ボタン再押し不可バグ修正

> イベント作成ボタンを押してトピック選択せずに戻ると、再度作成ボタンが押せなくなる

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-350a | B-8: 作成ボタン再押し不可 バグ修正実装 | flutter-dev | `DONE` | | isInsertMode: false リセット漏れ修正 |
| T-350b | B-8: 作成ボタン再押し不可 テストコード実装 | tester | `DONE` | | TC-CAB-001〜002b 実装済み |
| T-351 | B-8: レビュー | reviewer | `DONE` | | 承認 |
| T-352 | B-8: テスト実行 | tester | `DONE` | | 4PASS/0FAIL/0SKIP（TC-CAB-001〜002b 全件PASS・テストフロー修正込み） |

---

## UI-12: 未保存新規イベント自動削除

> 概要タブBasicInfo・MarkDetail・LinkDetail・PaymentDetailで何も保存せずにイベント一覧へ戻った場合、イベントを削除する

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-353 | UI-12: 未保存新規イベント自動削除 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-unsaved_event_auto_delete.md |
| T-354a | UI-12: 未保存新規イベント自動削除 実装 | flutter-dev | `DONE` | | |
| T-354b | UI-12: 未保存新規イベント自動削除 テストコード実装 | tester | `DONE` | | flutter/integration_test/unsaved_event_auto_delete_test.dart |
| T-355 | UI-12: レビュー | reviewer | `DONE` | | 承認 |
| T-356 | UI-12: テスト実行 | tester | `DONE` | | 5PASS/0FAIL/0SKIP（TC-UAE-001〜005 PASS、TC-UAE-004は新規イベントメンバーなし制約でスキップ） |

---

## UI-13: Detail画面 キャンセル確認ダイアログ

> MarkDetail・LinkDetail・PaymentDetailでキャンセル押下時、ProjectionとDraftが異なれば確認ダイアログを表示

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-357 | UI-13: Detail画面キャンセル確認 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-detail_cancel_confirmation.md |
| T-358a | UI-13: Detail画面キャンセル確認 実装 | flutter-dev | `DONE` | | MarkDetail・LinkDetail・PaymentDetail: initialDraft/showCancelConfirmDialog追加、DismissPressed差分判定、CancelDiscardConfirmed/CancelDialogDismissed Event追加、CupertinoAlertDialog Widget追加 |
| T-358b | UI-13: Detail画面キャンセル確認 テストコード実装 | tester | `DONE` | | TC-DCC-001〜012 16件実装済み（integration_test/detail_cancel_confirmation_test.dart） |
| T-359 | UI-13: レビュー | reviewer | `DONE` | | 承認 |
| T-360 | UI-13: テスト実行 | tester | `DONE` | | 16PASS/0FAIL/0SKIP（TC-DCC-001〜012 全件PASS・カード遷移ヘルパー・NumericInputRow入力方式修正込み） |

---

## POST-1: MichiInfoで支払い情報を登録できるようにする

> ⚠️ AppStoreリリース（REL-1）完了後に着手する

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-361 | POST-1: MichiInfo支払い情報登録 要件書作成 | product-manager | `BLOCKED` | | REL-1完了後に着手 |
| T-362 | POST-1: MichiInfo支払い情報登録 Spec作成 | architect | `BLOCKED` | | |
| T-363a | POST-1: MichiInfo支払い情報登録 実装 | flutter-dev | `BLOCKED` | | |
| T-363b | POST-1: MichiInfo支払い情報登録 テストコード実装 | tester | `BLOCKED` | | |
| T-364 | POST-1: レビュー | reviewer | `BLOCKED` | | |
| T-365 | POST-1: テスト実行 | tester | `BLOCKED` | | |

---

---

## アーカイブ（DONE完了）

### Phase 14: イベント削除機能 + スワイプ削除UI

| ID | タスク | 役割 | status | notes |
|---|---|---|---|---|
| T-130 | イベント削除機能 要件書作成 | product-manager | `DONE` | 要件書: ユーザー提示仕様（カスケード削除・確認ダイアログなし・flutter_slidable使用） |
| T-131 | イベント削除機能 Spec作成 | architect | `DONE` | docs/Spec/Features/EventDelete_Spec.md |
| T-132 | イベント削除機能 実装 | flutter-dev | `DONE` | EventDelete_Spec.md 参照 |
| T-133 | イベント削除機能 レビュー | reviewer | `DONE` | 承認・違反なし |
| T-134 | イベント削除機能 テスト | tester | `DONE` | 3PASS/0FAIL |

### Phase 15: バグ修正（B-1〜B-4）

| ID | タスク | 役割 | status | notes |
|---|---|---|---|---|
| T-140 | B-1/B-2: BasicInfo燃費/ガソリン単価 単位表示・即時反映修正 | flutter-dev | `DONE` | _NumberInputField → NumericInputRow置き換え |
| T-141 | B-3: MichiInfo 0件時 追加ボタン修正 | flutter-dev | `DONE` | items.empty時 pendingInsertAfterSeq=-1設定 |
| T-142 | B-4: MichiInfo InsertMode時タイムライン座標ズレ修正 | flutter-dev | `DONE` | InsertMode時CustomPaint非表示 |
| T-143 | バグ修正 レビュー | reviewer | `DONE` | |
| T-144 | バグ修正 テスト | tester | `DONE` | 84PASS/19SKIP/0FAIL |

### Phase 16: MichiInfo カード削除機能

| ID | タスク | 役割 | status | notes |
|---|---|---|---|---|
| T-150 | MichiInfo カード削除 要件書作成 | product-manager | `DONE` | docs/Requirements/REQ-michi_info_card_delete.md |
| T-151 | MichiInfo カード削除 Spec作成 | architect | `DONE` | docs/Spec/Features/MichiInfoCardDelete_Spec.md |
| T-152 | MichiInfo カード削除 実装 | flutter-dev | `DONE` | MichiInfoCardDelete_Spec.md 参照 |
| T-152b | MichiInfo カード削除 テストコード実装（Phase1） | tester | `DONE` | TC-MCD-001〜010 実装済み |
| T-153 | MichiInfo カード削除 レビュー | reviewer | `DONE` | 承認・違反なし |
| T-154 | MichiInfo カード削除 テスト実行（Phase2） | tester | `DONE` | 9PASS/1SKIP/0FAIL |

### Phase 17: PaymentInfo カード削除機能

| ID | タスク | 役割 | status | notes |
|---|---|---|---|---|
| T-155 | PaymentInfo カード削除 要件書作成 | product-manager | `DONE` | docs/Requirements/REQ-payment_info_card_delete.md |
| T-156 | PaymentInfo カード削除 Spec作成 | architect | `DONE` | docs/Spec/Features/PaymentInfoCardDelete_Spec.md |
| T-157 | PaymentInfo カード削除 実装 | flutter-dev | `DONE` | PaymentInfoCardDelete_Spec.md 参照 |
| T-157b | PaymentInfo カード削除 テストコード実装（Phase1） | tester | `DONE` | TC-PID-001〜005 実装済み |
| T-158 | PaymentInfo カード削除 レビュー | reviewer | `DONE` | 承認・違反なし |
| T-159 | PaymentInfo カード削除 テスト実行（Phase2） | tester | `DONE` | 4PASS/1SKIP/0FAIL |

### Phase 18: MichiInfo 挿入ボタン改善

| ID | タスク | 役割 | status | notes |
|---|---|---|---|---|
| T-160 | MIB-001+003統合/002: Spec作成 | architect | `DONE` | docs/Spec/Features/FS-michi_info_insert_button_size.md (v2.0) |
| T-161 | MIB-001+003統合/002: 実装 | flutter-dev | `DONE` | |
| T-162 | MIB-001+003統合/002: レビュー | reviewer | `DONE` | 承認・違反なし |
| T-163 | MIB-001+003統合/002: テスト | tester | `DONE` | 5PASS/0FAIL |
| T-164 | MIB-003: デザイン提案（「＋」アイコンのみ変更） | designer | `DONE` | docs/Design/draft/michi_info_insert_icon_design.html |
| T-165 | MIB-003: デザインレビュー・ユーザー確認 | product-manager | `DONE` | C案採用・MIB-001と統合。負のmargin不採用 |

### F-1: カスタム数値キーパッド

| ID | タスク | 役割 | status | notes |
|---|---|---|---|---|
| T-180 | カスタムキーパッド 要件書作成 | product-manager | `DONE` | docs/Requirements/REQ-custom_numeric_keypad.md |
| T-181 | カスタムキーパッド Spec作成 | architect | `DONE` | docs/Spec/Features/FS-custom_numeric_keypad.md |
| T-182 | カスタムキーパッド 実装 | flutter-dev | `DONE` | |
| T-182b | カスタムキーパッド テストコード実装 | tester | `DONE` | TC-CNK-001〜009 実装済み |
| T-183 | カスタムキーパッド レビュー | reviewer | `DONE` | 承認・違反なし |
| T-184 | カスタムキーパッド テスト実行 | tester | `DONE` | 9PASS/0SKIP/0FAIL |
| T-185 | 四則演算 要件書作成 | product-manager | `DONE` | docs/Requirements/REQ-custom_numeric_keypad_phase2.md |
| T-186 | 四則演算 Spec作成 | architect | `DONE` | docs/Spec/Features/FS-custom_numeric_keypad_phase2.md |
| T-187 | 四則演算 実装 | flutter-dev | `DONE` | |
| T-187b | 四則演算 テストコード実装 | tester | `DONE` | TC-CNK-010〜019 実装済み |
| T-188 | 四則演算 レビュー | reviewer | `DONE` | 承認・違反なし |
| T-189b | 四則演算 テスト実行 | tester | `DONE` | 19PASS/0SKIP/0FAIL |
| T-189 | Phase3 要件書・Spec作成 | product-manager / architect | `DONE` | docs/Requirements/REQ-custom_numeric_keypad_phase3.md / FS-custom_numeric_keypad_phase3.md |
| T-190a | Phase3 実装 | flutter-dev | `DONE` | FS-custom_numeric_keypad_phase3.md 参照 |
| T-190b | Phase3 テストコード実装 | tester | `DONE` | TC-CNK-020〜024 実装済み |
| T-191a | Phase3 レビュー | reviewer | `DONE` | 承認・違反なし |
| T-192a | Phase3 テスト実行 | tester | `DONE` | 5PASS/0SKIP/0FAIL |

### R-1: メンバー未選択時の入力ガード

| ID | タスク | 役割 | status | notes |
|---|---|---|---|---|
| T-170 | メンバー未選択ガード 要件書 | product-manager | `DONE` | docs/Requirements/REQ-member_required_guard.md |
| T-171 | メンバー未選択ガード Spec作成 | architect | `DONE` | docs/Spec/Features/MemberRequiredGuard_Spec.md |
| T-172 | メンバー未選択ガード 実装 | flutter-dev | `DONE` | MemberRequiredGuard_Spec.md 参照 |
| T-172b | メンバー未選択ガード テストコード実装 | tester | `DONE` | TC-MRG-001〜006 実装済み |
| T-173 | メンバー未選択ガード レビュー | reviewer | `DONE` | 承認・違反なし |
| T-174 | メンバー未選択ガード テスト実行 | tester | `DONE` | 3PASS/3SKIP/0FAIL |

### R-2: イベント詳細画面 インライン選択UI（タグ・メンバー・Trans・支払者）

> 旧R-2（メンバー選択UIタグ式リニューアル）を廃止・統合。REQ-event_detail_inline_selection_ui 参照。

| ID | タスク | 役割 | status | notes |
|---|---|---|---|---|
| T-196 | Phase A 要件書作成 | product-manager | `DONE` | docs/Requirements/REQ-event_detail_inline_selection_ui.md |
| T-197 | Phase A Spec作成 | architect | `DONE` | docs/Spec/Features/FS-event_detail_inline_selection_ui_phaseA.md |
| T-198a | Phase A BasicInfo 実装（Trans・Members・Tags・GasPayMember インライン化） | flutter-dev | `DONE` | |
| T-198b | Phase A テストコード実装（TC-BII-001〜016） | tester | `DONE` | TC-BII-001〜016 実装済み |
| T-199 | Phase A レビュー | reviewer | `DONE` | 承認・違反なし |
| T-200 | Phase A テスト実行 | tester | `DONE` | 12PASS/0FAIL/4SKIP |
| T-201 | Phase B Spec作成 | architect | `DONE` | docs/Spec/Features/FS-event_detail_inline_selection_ui_phaseB.md |
| T-202a | Phase B MarkDetail・LinkDetail・PaymentDetail 実装 | flutter-dev | `DONE` | FS-event_detail_inline_selection_ui_phaseB.md 参照。dart analyze エラーゼロ確認済み |
| T-202b | Phase B テストコード実装 | tester | `DONE` | TC-PBM-001〜014b（22ケース）実装済み |
| T-203 | Phase B レビュー | reviewer | `DONE` | 承認・違反なし |
| T-204 | Phase B テスト実行 | tester | `DONE` | 22PASS/0FAIL/0SKIP |

### B-5: MichiInfo タブ切り替え時追加モード終了バグ修正

| ID | タスク | 役割 | status | notes |
|---|---|---|---|---|
| T-205 | タブ切り替え追加モード終了 実装 | flutter-dev | `DONE` | MichiInfoTabDeactivated イベント追加・_onTabDeactivated ハンドラ実装 |
| T-205b | タブ切り替え追加モード終了 テストコード実装 | tester | `DONE` | TC-B5-001〜002 実装済み |
| T-206 | タブ切り替え追加モード終了 レビュー | reviewer | `DONE` | 承認・違反なし |
| T-207 | タブ切り替え追加モード終了 テスト実行 | tester | `DONE` | 2PASS/0FAIL/0SKIP |
