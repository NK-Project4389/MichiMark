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
| T-131 | イベント削除機能 Spec作成 | architect | `TODO` | | T-130完了後。flutter_slidable ^3.1.0 追加・deleteEvent(eventId)実装・スワイプUI |
| T-132 | イベント削除機能 実装 | flutter-dev | `BLOCKED` | | T-131完了後 |
| T-133 | イベント削除機能 レビュー | reviewer | `BLOCKED` | | T-132完了後 |
| T-134 | イベント削除機能 テスト | tester | `BLOCKED` | | T-133完了後 |

## Phase 15: バグ修正（B-1〜B-4）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-140 | B-1/B-2: BasicInfo燃費/ガソリン単価 単位表示・即時反映修正 | flutter-dev | `IN_PROGRESS` | `2026-04-11_bugfix_basic_michi` | _NumberInputField → NumericInputRow置き換え |
| T-141 | B-3: MichiInfo 0件時 追加ボタン修正 | flutter-dev | `IN_PROGRESS` | `2026-04-11_bugfix_basic_michi` | items.empty時 pendingInsertAfterSeq=-1設定 |
| T-142 | B-4: MichiInfo InsertMode時タイムライン座標ズレ修正 | flutter-dev | `IN_PROGRESS` | `2026-04-11_bugfix_basic_michi` | InsertMode時CustomPaint非表示 |
| T-143 | バグ修正 レビュー | reviewer | `BLOCKED` | | T-140〜142完了後 |
| T-144 | バグ修正 テスト | tester | `BLOCKED` | | T-143完了後 |
