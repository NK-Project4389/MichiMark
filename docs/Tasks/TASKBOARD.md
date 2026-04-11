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

## Phase 14: イベント削除機能 + スワイプ削除UI

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-130 | イベント削除機能 要件書作成 | product-manager | `DONE` | | 要件書: ユーザー提示仕様（カスケード削除・確認ダイアログなし・flutter_slidable使用） |
| T-131 | イベント削除機能 Spec作成 | architect | `DONE` | | docs/Spec/Features/EventDelete_Spec.md |
| T-132 | イベント削除機能 実装 | flutter-dev | `DONE` | | EventDelete_Spec.md 参照 |
| T-133 | イベント削除機能 レビュー | reviewer | `DONE` | | 承認・違反なし |
| T-134 | イベント削除機能 テスト | tester | `DONE` | | 3PASS/0FAIL |

## Phase 15: バグ修正（B-1〜B-4）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-140 | B-1/B-2: BasicInfo燃費/ガソリン単価 単位表示・即時反映修正 | flutter-dev | `DONE` | | _NumberInputField → NumericInputRow置き換え |
| T-141 | B-3: MichiInfo 0件時 追加ボタン修正 | flutter-dev | `DONE` | | items.empty時 pendingInsertAfterSeq=-1設定 |
| T-142 | B-4: MichiInfo InsertMode時タイムライン座標ズレ修正 | flutter-dev | `DONE` | | InsertMode時CustomPaint非表示 |
| T-143 | バグ修正 レビュー | reviewer | `DONE` | | |
| T-144 | バグ修正 テスト | tester | `DONE` | | 84PASS/19SKIP/0FAIL |

## Phase 16: MichiInfo カード削除機能

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-150 | MichiInfo カード削除 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-michi_info_card_delete.md |
| T-151 | MichiInfo カード削除 Spec作成 | architect | `DONE` | | docs/Spec/Features/MichiInfoCardDelete_Spec.md |
| T-152 | MichiInfo カード削除 実装 | flutter-dev | `DONE` | | MichiInfoCardDelete_Spec.md 参照 |
| T-152b | MichiInfo カード削除 テストコード実装（Phase1） | tester | `DONE` | | TC-MCD-001〜010 実装済み |
| T-153 | MichiInfo カード削除 レビュー | reviewer | `DONE` | | 承認・違反なし |
| T-154 | MichiInfo カード削除 テスト実行（Phase2） | tester | `DONE` | | 9PASS/1SKIP/0FAIL |

## Phase 18: MichiInfo 挿入ボタン改善

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-160 | MIB-001+003統合/002: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-michi_info_insert_button_size.md (v2.0) |
| T-161 | MIB-001+003統合/002: 実装 | flutter-dev | `DONE` | | |
| T-162 | MIB-001+003統合/002: レビュー | reviewer | `DONE` | | 承認・違反なし |
| T-163 | MIB-001+003統合/002: テスト | tester | `DONE` | | 5PASS/0FAIL |
| T-164 | MIB-003: デザイン提案（「＋」アイコンのみ変更） | designer | `DONE` | | docs/Design/draft/michi_info_insert_icon_design.html |
| T-165 | MIB-003: デザインレビュー・ユーザー確認 | product-manager | `DONE` | | C案採用・MIB-001と統合。負のmargin不採用 |

## Phase 17: PaymentInfo カード削除機能

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-155 | PaymentInfo カード削除 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-payment_info_card_delete.md |
| T-156 | PaymentInfo カード削除 Spec作成 | architect | `DONE` | | docs/Spec/Features/PaymentInfoCardDelete_Spec.md |
| T-157 | PaymentInfo カード削除 実装 | flutter-dev | `DONE` | | PaymentInfoCardDelete_Spec.md 参照 |
| T-157b | PaymentInfo カード削除 テストコード実装（Phase1） | tester | `DONE` | | TC-PID-001〜005 実装済み |
| T-158 | PaymentInfo カード削除 レビュー | reviewer | `DONE` | | 承認・違反なし |
| T-159 | PaymentInfo カード削除 テスト実行（Phase2） | tester | `DONE` | | 4PASS/1SKIP/0FAIL |

## F-1: カスタム数値キーパッド

### Phase 1（基本キーパッド）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-180 | カスタムキーパッド 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-custom_numeric_keypad.md |
| T-181 | カスタムキーパッド Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-custom_numeric_keypad.md |
| T-182 | カスタムキーパッド 実装 | flutter-dev | `DONE` | | |
| T-182b | カスタムキーパッド テストコード実装 | tester | `DONE` | | TC-CNK-001〜009 実装済み |
| T-183 | カスタムキーパッド レビュー | reviewer | `DONE` | | 承認・違反なし |
| T-184 | カスタムキーパッド テスト実行 | tester | `DONE` | | 9PASS/0SKIP/0FAIL |

### Phase 2（四則演算・中間式表示）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-185 | 四則演算 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-custom_numeric_keypad_phase2.md |
| T-186 | 四則演算 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-custom_numeric_keypad_phase2.md |
| T-187 | 四則演算 実装 | flutter-dev | `DONE` | | |
| T-187b | 四則演算 テストコード実装 | tester | `DONE` | | TC-CNK-010〜019 実装済み |
| T-188 | 四則演算 レビュー | reviewer | `DONE` | | 承認・違反なし |
| T-189b | 四則演算 テスト実行 | tester | `DONE` | | 19PASS/0SKIP/0FAIL |

### Phase 3（確定ボタンラベル変更 + label 表示）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-189 | Phase3 要件書・Spec作成 | product-manager / architect | `DONE` | | docs/Requirements/REQ-custom_numeric_keypad_phase3.md / FS-custom_numeric_keypad_phase3.md |
| T-190a | Phase3 実装 | flutter-dev | `DONE` | | FS-custom_numeric_keypad_phase3.md 参照 |
| T-190b | Phase3 テストコード実装 | tester | `DONE` | | TC-CNK-020〜024 実装済み |
| T-191a | Phase3 レビュー | reviewer | `DONE` | | 承認・違反なし |
| T-192a | Phase3 テスト実行 | tester | `DONE` | | 5PASS/0SKIP/0FAIL |

---

## R-2: メンバー選択UI タグ式リニューアル

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-190 | メンバー選択UIタグ式リニューアル 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-member_selection_tag_style.md |
| T-191 | メンバー選択UIタグ式リニューアル Spec作成 | architect | `TODO` | | REQ-member_selection_tag_style.md 参照 |
| T-192 | モード1: BasicInfo `_MemberInputSection` 実装 | flutter-dev | `BLOCKED` | | T-191 完了待ち |
| T-193 | モード2: SelectionPage メンバー系UI改善 実装 | flutter-dev | `BLOCKED` | | T-191 完了待ち |
| T-194 | メンバー選択UIタグ式リニューアル レビュー | reviewer | `BLOCKED` | | T-192/T-193 完了後に着手 |
| T-195 | メンバー選択UIタグ式リニューアル テスト | tester | `BLOCKED` | | T-194 承認後に着手 |

---

## R-1: メンバー未選択時の入力ガード

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-170 | メンバー未選択ガード 要件書 | product-manager | `DONE` | | docs/Requirements/REQ-member_required_guard.md |
| T-171 | メンバー未選択ガード Spec作成 | architect | `DONE` | | docs/Spec/Features/MemberRequiredGuard_Spec.md |
| T-172 | メンバー未選択ガード 実装 | flutter-dev | `DONE` | | MemberRequiredGuard_Spec.md 参照 |
| T-172b | メンバー未選択ガード テストコード実装 | tester | `DONE` | | TC-MRG-001〜006 実装済み |
| T-173 | メンバー未選択ガード レビュー | reviewer | `DONE` | | 承認・違反なし |
| T-174 | メンバー未選択ガード テスト実行 | tester | `DONE` | | 3PASS/3SKIP/0FAIL |
