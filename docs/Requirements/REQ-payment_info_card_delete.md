# 要件書: PaymentInfo 伝票削除機能

- **要件ID**: REQ-payment_info_card_delete
- **作成日**: 2026-04-11
- **担当**: product-manager
- **ステータス**: 確定

---

## 1. 背景・目的

PaymentInfo（支払タブ）に表示されている伝票行（payment 単体）を削除できるようにする。
現状、伝票の追加・編集は可能だが削除手段がなく、誤って追加した伝票を取り除けない。

---

## 2. 要件一覧

| 項目 | 内容 |
|---|---|
| 削除対象 | 伝票行（payment_info 1件 = PaymentItemProjection 1行）単体 |
| 操作 | 伝票行を左スワイプ → 赤い削除ボタンが出現 |
| UIライブラリ | `flutter_slidable ^3.1.0`（既に依存済み） |
| 確認ダイアログ | **なし**（タップ即削除） |
| 削除方式 | 論理削除（`is_deleted = true`） |
| カスケード削除 | **あり**（payment_detail 行も同時に論理削除） |
| 削除後の再描画 | 合計金額・リストを即時再計算して表示更新 |

---

## 3. カスケード削除仕様

伝票（payment）を削除する際、その伝票に紐づく割り勘メンバー行（payment_split_members）も削除する。

| テーブル | 操作 | 条件 |
|---|---|---|
| `payments` | `is_deleted = true` に更新（論理削除） | `id = 削除対象の paymentId` |
| `payment_split_members` | 物理削除（`is_deleted` カラムなし） | `payment_id = 削除対象の paymentId` |

---

## 4. 削除後の表示更新

- 合計金額（`displayTotalAmount`）が削除後に再計算されること
- リストから削除した行が即座に消えること
- 0 件になった場合は「支払情報がありません」の空状態 UI を表示すること

---

## 5. 対象外

- 削除取り消し（Undo）
- 物理削除
- payment_detail 単体の削除（伝票ごと削除のみ）
