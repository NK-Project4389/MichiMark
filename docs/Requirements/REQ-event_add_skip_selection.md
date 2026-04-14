# 要件書: イベント追加ボタン 選択肢スキップ遷移

**ID**: REQ-event_add_skip_selection
**日付**: 2026-04-13
**ステータス**: 確定
**対応タスク**: UI-8（T-285 要件書作成、T-286 Spec作成）

---

## 1. 概要

MichiInfo 画面の FAB（追加ボタン）をタップしたとき、トピック設定によって追加できる項目が「地点のみ」または「区間のみ」に限定されている場合に、選択肢ボトムシートを表示せず直接登録画面へ遷移する。

現在は `addMenuItems` が 1 件のみであっても、挿入ポイント選択後にボトムシートが表示されてしまう（1 項目しかない選択肢を選ばせる手順が発生する）。この不要なステップを排除してユーザー操作を簡略化する。

---

## 2. 背景

`TopicConfig.addMenuItems` は `AddMenuItemType` のリストで管理されており、トピック種別ごとに以下の設定が存在する。

| TopicType | addMenuItems | 現在の挙動 |
|---|---|---|
| movingCost | [mark, link] | 挿入ポイント選択 → ボトムシート（地点・区間の 2 択）|
| movingCostEstimated | [mark, link] | 挿入ポイント選択 → ボトムシート（地点・区間の 2 択）|
| travelExpense | [mark] | 挿入ポイント選択 → ボトムシート（地点のみ 1 択）|

`travelExpense` の場合、ボトムシートに選択肢が 1 件しかないにもかかわらずユーザーに選択を強制している。

---

## 3. ユーザーストーリー

「旅費可視化トピックのイベントで地点を追加しようとしたとき、追加ボタンを押すたびにわざわざボトムシートで『地点を追加』を選ばされる。1 択しかないのに選ばせるのは手間だ。直接地点登録画面に行ってほしい。」

---

## 4. 機能要件

### 4-1. スキップ条件

以下の条件をすべて満たす場合に選択肢ボトムシートを表示せず直接遷移する。

- `TopicConfig.addMenuItems.length == 1`（追加できる項目が 1 種類のみ）

スキップ判定は **挿入ポイント確定後（`pendingInsertAfterSeq` が確定したタイミング）** に適用する。

### 4-2. スキップ時の遷移先

| addMenuItems の唯一の要素 | 遷移先 |
|---|---|
| `AddMenuItemType.mark` | MarkDetail（地点登録）画面へ直接遷移 |
| `AddMenuItemType.link` | LinkDetail（区間登録）画面へ直接遷移 |

### 4-3. 非スキップ条件（従来通りの挙動を維持）

- `addMenuItems.length == 2`（mark と link の両方）: 挿入ポイント選択後にボトムシートを表示する
- `addMenuItems.isEmpty`: FAB 非表示のため到達しない

### 4-4. 0 件時（リスト空）の挿入モード

0 件時も同じスキップ判定を適用する。`pendingInsertAfterSeq = -1`（0 件シグナル値）が確定した時点でスキップ判定を実行する。

---

## 5. 非機能要件

- 既存の 2 択（movingCost / movingCostEstimated）の挙動は変更しない
- 実装変更は `michi_info_view.dart` の BlocListener（`_showInsertBottomSheet` の呼び出し判定）に限定する
- Bloc・State・Delegate・TopicConfig の構造変更は不要

---

## 6. 制約・前提条件

- `AddMenuItemType` enum および `TopicConfig.addMenuItems` フィールドは実装済みのため変更不要
- `MichiInfoInsertMarkPressed` / `MichiInfoInsertLinkPressed` Event は実装済みのため変更不要
- 将来的に `addMenuItems` に 3 種類以上の項目が追加された場合は本仕様の更新が必要（現時点では対象外）

---

## 7. 対象ファイル

| ファイル | 変更種別 |
|---|---|
| `flutter/lib/features/michi_info/view/michi_info_view.dart` | BlocListener の挿入ボトムシート表示判定変更 |

---

## 8. 対象外

- TopicConfig の構造変更
- Bloc / State / Delegate の変更
- 挿入モードのインジケーター UI の変更
- AddMenuItemType の追加・削除

---

# End of Requirements
