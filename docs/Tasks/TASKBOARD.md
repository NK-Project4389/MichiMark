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
| T-214 | イベント削除UI変更 テスト実行 | tester | `IN_PROGRESS` | 2026-04-12_自走 | T-213 承認後 |

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
| T-224 | BasicInfo参照タップ編集 テスト実行 | tester | `IN_PROGRESS` | 2026-04-12_自走 | T-223 承認後 |

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
| T-234 | MichiInfo削除UI変更 テスト実行 | tester | `IN_PROGRESS` | 2026-04-12_自走 | T-233 承認後 |

---

## UI-4: PaymentInfo カード削除UI変更

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-240 | PaymentInfo削除UI変更 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-payment_info_delete_icon.md |
| T-241 | PaymentInfo削除UI変更 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-payment_info_delete_icon.md |
| T-242a | PaymentInfo削除UI変更 実装 | flutter-dev | `DONE` | | FS-payment_info_delete_icon.md 参照 |
| T-242b | PaymentInfo削除UI変更 テストコード実装 | tester | `DONE` | | TC-PID2-001〜003 実装済み |
| T-243 | PaymentInfo削除UI変更 レビュー | reviewer | `DONE` | | 合格 |
| T-244 | PaymentInfo削除UI変更 テスト実行 | tester | `IN_PROGRESS` | 2026-04-12_自走 | T-243 承認後 |

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
| T-272 | B-6: テスト実行 | tester | `IN_PROGRESS` | 2026-04-12_自走 | T-271 承認後 |

---

## UI-6: 概要タブ セクション名追加（基本情報・集計）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-264 | 概要タブセクション名 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-overview_tab_section_labels.md |
| T-265 | 概要タブセクション名 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-overview_tab_section_labels.md |
| T-266a | 概要タブセクション名 実装 | flutter-dev | `DONE` | | FS-overview_tab_section_labels.md 参照 |
| T-266b | 概要タブセクション名 テストコード実装 | tester | `DONE` | | TC-OSL-001〜002 実装済み |
| T-267 | 概要タブセクション名 レビュー | reviewer | `DONE` | | 合格 |
| T-268 | 概要タブセクション名 テスト実行 | tester | `IN_PROGRESS` | 2026-04-12_自走 | T-267 承認後 |

---

## REL-1: AppStore無料版リリース準備

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-260 | AppStore無料版リリース準備 | orchestrator | `TODO` | | 下書き: docs/Requirements/REQ-DRAFT-appstore_free_release.md |

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
