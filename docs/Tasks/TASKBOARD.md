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
| T-155 | PaymentInfo カード削除 要件書作成 | product-manager | `TODO` | | 削除対象（payment_detail単体 or payment_info行）・確認ダイアログ要否を定義 |
| T-156 | PaymentInfo カード削除 Spec作成 | architect | `BLOCKED` | | T-155完了後 |
| T-157 | PaymentInfo カード削除 実装 | flutter-dev | `BLOCKED` | | T-156完了後 |
| T-158 | PaymentInfo カード削除 レビュー | reviewer | `BLOCKED` | | T-157完了後 |
| T-159 | PaymentInfo カード削除 テスト | tester | `BLOCKED` | | T-158完了後 |
