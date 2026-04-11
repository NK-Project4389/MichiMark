# 要件書: MichiInfo カード削除機能

- **要件ID**: REQ-michi_info_card_delete
- **作成日**: 2026-04-11
- **担当**: product-manager
- **ステータス**: 確定

---

## 1. 背景・目的

MichiInfo（ミチタブ）に表示されている Mark（地点）・Link（区間）カードを個別に削除できるようにする。
現状、カードの追加・編集は可能だが削除手段がなく、誤って追加したカードを取り除けない。

---

## 2. 要件一覧

| 項目 | 内容 |
|---|---|
| 削除対象 | Mark カード・Link カード 両方 |
| 操作 | カードを左スワイプ → 赤い削除ボタンが出現 |
| UIライブラリ | `flutter_slidable ^3.1.0`（既に依存済み） |
| 確認ダイアログ | **なし**（タップ即削除） |
| 削除方式 | 論理削除（`is_deleted = true`） |
| カスケード削除 | **なし**（Mark と Link に関係性はなく、独立して削除する） |
| 削除後の再描画 | 残存カードで距離表現・タイムラインを即時再構築する |

---

## 3. 削除後の再描画仕様

Mark と Link は独立しており、カスケード削除は行わない。
ただし削除後のカード構成によって距離表現ロジックが変化するため、再描画時に以下を正しく処理すること。

### 距離表現の変化パターン

| 削除前の構成 | 削除操作 | 削除後の構成 | 期待される表示 |
|---|---|---|---|
| Mark → Link → Mark | Link を削除 | Mark → Mark | スパン矢印なし・2 Mark 間の距離表示なし |
| Mark → Link → Mark | 先頭 Mark を削除 | Link → Mark | 孤立 Link のまま表示（距離・方向の起点なし） |
| Mark → Link → Mark | 末尾 Mark を削除 | Mark → Link | 孤立 Link のまま表示 |
| Mark → Mark | いずれかの Mark を削除 | Mark のみ | 縦線 1 本・スパン矢印なし |
| カード 1 件のみ | そのカードを削除 | 空リスト | 「まだ地点がありません」等の空状態 UI を表示 |

### 注意事項

- `_MichiTimelineCanvas`（CustomPainter）はリスト変更後に**必ず再描画**すること
- `seq` の再採番は行わない（削除後も既存カードの seq はそのまま維持）
- 挿入モード中に削除操作は行えない（挿入モード中はスワイプを無効化する）

---

## 4. DB 変更

### 4.1 変更対象テーブル

| テーブル | 操作 | 条件 |
|---|---|---|
| `mark_links` | `is_deleted = true` に更新 | `id = 削除対象のmarkLinkId` |

### 4.2 対象外

- `payments`・`event_members`・`event_tags` などへのカスケード削除は **不要**
- `seq` の再採番は **不要**

---

## 5. Bloc への変更

`MichiInfoBloc` に以下を追加する。

| 追加要素 | 内容 |
|---|---|
| Event | `MichiInfoCardDeleteRequested(String markLinkId)` |
| Handler | `_onCardDeleteRequested`: Repository の `deleteMarkLink(id)` を呼び出し → リスト再読み込み |

Repository に `deleteMarkLink(String id)` メソッドが未実装の場合は追加する。

---

## 6. UI 変更

### 6.1 MichiInfoView（`michi_info_view.dart`）

各カード（Mark・Link）を `Slidable` でラップする。

**Key 命名規則（設計憲章 §Widget Key 命名規則に準拠）**:
- Slidable: `Key('michi_info_card_slidable_${item.id}')`
- 削除アクション: `Key('michi_info_card_delete_action_${item.id}')`

**挿入モード中のスワイプ無効化**:
- `MichiInfoState.isInsertMode == true` のとき `Slidable` を無効化する

---

## 7. 対象外

- 削除取り消し（Undo）
- 物理削除
- カード並び替え（別 Phase）
- 挿入モード中の削除

---

## 8. テストシナリオ概要

Integration Test グループ `TC-MCD`（MichiInfo Card Delete）として実装する。

優先度 High のカバーパターン：

1. Mark カードをスワイプすると削除ボタンが表示される
2. Link カードをスワイプすると削除ボタンが表示される
3. Mark を削除すると一覧から消え、タイムラインが再描画される
4. Link を削除すると一覧から消え、タイムラインが再描画される
5. **Mark → Link → Mark の Link を削除 → 残存 Mark 2件が崩れずに表示される**
6. **Mark → Link → Mark の先頭 Mark を削除 → Link → Mark が崩れずに表示される**
7. **Mark → Link → Mark の末尾 Mark を削除 → Mark → Link が崩れずに表示される**
8. カード 1 件のみ削除 → 空状態 UI が表示される
9. 確認ダイアログが表示されない（即削除）
10. 挿入モード中はスワイプが無効になる
