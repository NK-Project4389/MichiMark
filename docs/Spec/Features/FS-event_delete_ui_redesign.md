# Feature Spec: イベント削除UI変更

- **Spec ID**: FS-event_delete_ui_redesign
- **要件ID**: REQ-event_delete_ui_redesign
- **作成日**: 2026-04-12
- **担当**: architect
- **ステータス**: 確定

---

## 1. Feature Overview

### Feature Name

EventDeleteUIRedesign（UI改善 UI-1）

### Purpose

イベント一覧画面のスワイプ削除UIを廃止し、イベント詳細画面のヘッダ右側に削除アイコンを移動する。
誤削除防止と操作の一貫性向上が目的。

### Scope

含むもの
- `event_list` feature の `flutter_slidable` スワイプ削除UI撤去（Widgetのみ）
- `event_list` Bloc の `EventListDeleteRequested` ハンドラ撤去
- `event_list` feature の `flutter_slidable` import除去
- `event_detail` feature のヘッダAppBar右側への削除アイコン＋「イベント削除」ラベル追加
- `event_detail` feature の削除確認ダイアログ追加
- `event_detail` Bloc への削除処理追加（`EventRepository.delete()` の呼び出し）
- 削除完了後のイベント一覧への遷移

含まないもの
- 削除ロジック（カスケード削除仕様）の変更
- 削除取り消し（Undo）
- `flutter_slidable` ライブラリ自体の削除（`payment_info` / `michi_info` で引き続き使用中）

---

## 2. Feature Responsibility

### event_list feature の変更

- スワイプ削除ウィジェット（`Slidable` / `SlidableAutoCloseBehavior` / `ActionPane` / `SlidableAction`）を除去する
- `EventListDeleteRequested` Eventおよびそのハンドラを撤去する
- `event_list_page.dart` の `flutter_slidable` import を除去する

### event_detail feature の変更

- ヘッダAppBar右側に削除アイコン＋「イベント削除」ラベルを追加する
- 削除アイコンタップ時に確認ダイアログを表示する
- 確認ダイアログで「削除」を選択した場合のみ削除処理を実行する
- 削除処理は `EventDetailBloc` が `EventRepository.delete()` を呼び出す
- 削除完了後は `EventDetailDeletedDelegate` を発火して一覧画面へ戻る

---

## 3. State Structure

### EventDetailLoaded（既存 State への追加）

変更はない。`EventDetailDeletedDelegate` を既存の `EventDetailDelegate` sealed class に追加する。

### EventDetailDelegate（追加）

| Delegate名 | 説明 |
|---|---|
| `EventDetailDeletedDelegate` | イベント削除完了後に一覧へ戻る遷移意図の通知 |

既存の `EventDetailDelegate` sealed class に `EventDetailDeletedDelegate` を追加する。

---

## 4. Draft Model

変更なし。`EventDetailDraft` に追加フィールドは不要。

---

## 5. Domain Model

変更なし。削除ロジックはすでに `EventRepository.delete()` として存在する。

---

## 6. Projection Model

変更なし。

---

## 7. Adapter

変更なし。

---

## 8. Events

### event_detail feature に追加するEvent

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `EventDetailDeleteButtonPressed` | 削除アイコンがタップされたとき | Blocは確認ダイアログ表示をStateに通知する |
| `EventDetailDeleteConfirmed` | 確認ダイアログで「削除」がタップされたとき | Blocが削除処理を実行する |

### event_detail feature から既存Eventへの変更はなし

### event_list feature から撤去するEvent

| Event名 | 説明 |
|---|---|
| `EventListDeleteRequested` | スワイプ削除起点のEventのため撤去する |

---

## 9. Delegate

### EventDetailDelegate（event_detail feature に追加）

| Delegate名 | 説明 | 遷移先 |
|---|---|---|
| `EventDetailDeletedDelegate` | 削除完了を通知 | `EventDetailPage` の BlocListener が `context.pop()` で一覧へ戻る |

`EventDetailDeletedDelegate` 受信後の遷移は `EventDetailPage`（`_handleDelegate`）で処理する。
遷移方法は `context.pop()` とする（`event_detail` は `context.push()` でスタックされているため）。

---

## 10. Bloc Responsibility

### EventDetailBloc に追加するハンドラ

- `EventDetailDeleteButtonPressed` を受け取ったとき
  - `EventDetailLoaded.showDeleteConfirmDialog` フラグを `true` にして emit する
  - Widgetはこのフラグを検知して確認ダイアログを表示する
- `EventDetailDeleteConfirmed` を受け取ったとき
  - `EventRepository.delete(eventId)` を呼び出す
  - 成功時は `EventDetailDeletedDelegate` を emit する
  - 失敗時はエラー状態（`EventDetailError`）を emit する

### EventListBloc から撤去するハンドラ

- `EventListDeleteRequested` のハンドラを除去する

---

## 11. State への showDeleteConfirmDialog フラグ追加

### EventDetailLoaded（既存 State の変更）

`showDeleteConfirmDialog` フィールド（`bool`）を追加する。

| フィールド名 | 型 | 説明 |
|---|---|---|
| `showDeleteConfirmDialog` | `bool` | 削除確認ダイアログの表示フラグ。trueのとき Page が確認ダイアログを表示する |

- デフォルト値: `false`
- ダイアログ表示後（キャンセル・削除どちらでも）は `false` にリセットする
- `EventDetailDeleteButtonPressed` で `true` になる
- `EventDetailDeleteConfirmed` または キャンセル（Widget側で `false` にリセット）で `false` になる

**実装ノート**: キャンセルタップ時の `false` リセットは Widget（BlocListener or showDialog の then コールバック）で `EventDetailDelegateConsumed` に相当するEventを発火してBlocがリセットする方針とする。あるいはWidget側の `showDialog` で `showDeleteConfirmDialog` フラグを直接参照して表示し、ダイアログを閉じた後に `EventDetailDeleteDialogDismissed` Eventを発火してBlocがリセットしてもよい。詳細はflutter-devが既存の unsavedChangesDialog パターン（`showDialog` をWidget内で直接呼ぶ）に合わせて判断すること。

---

## 12. Navigation

### 削除完了後の遷移

- `EventDetailPage` の `_handleDelegate` に `EventDetailDeletedDelegate` の case を追加する
- `context.pop()` で呼び出し元の `EventListPage` に戻る

```
EventDetailDeletedDelegate → EventDetailPage._handleDelegate → context.pop()
```

---

## 13. UI仕様

### event_list（EventListPage）

- `_EventListItem` から `Slidable` ウィジェットを除去する
- カードをタップしたとき `EventListItemTapped` を発火する動作は維持する
- `SlidableAutoCloseBehavior` を除去し `ListView.separated` を直接 return する

### event_detail（EventDetailPage / _EventDetailScaffoldInner）

#### AppBar 変更

- 既存の AppBar 右側（`actions`）に削除アイコンボタンを追加する
- Topic設定済み（グラデーションAppBar）・Topic未設定（デフォルトAppBar）いずれのケースも同様に追加する

#### 削除アイコンボタン仕様

| 項目 | 内容 |
|---|---|
| アイコン | `Icons.delete_outline`（または `Icons.delete`） |
| ラベル | 「イベント削除」 |
| 配置 | AppBar `actions` の末尾 |
| Widget種別 | `IconButton` または縦並びの `Column`（アイコン＋テキスト） |
| キー | `Key('eventDetail_button_delete')` |

#### 確認ダイアログ仕様

| 項目 | 内容 |
|---|---|
| タイトル | 「イベントを削除しますか？」 |
| メッセージ | 「このイベントに関連するすべての情報が削除されます。」 |
| ボタン（キャンセル） | 「キャンセル」（TextButton） |
| ボタン（削除） | 「削除」（TextButton、破壊的アクション色） |
| ダイアログキー | `Key('eventDetail_dialog_deleteConfirm')` |
| 削除ボタンキー | `Key('eventDetail_button_deleteConfirm')` |
| キャンセルボタンキー | `Key('eventDetail_button_deleteCancel')` |

---

## 14. Data Flow

### 削除フロー（event_detail）

1. ユーザーが AppBar の削除アイコンをタップする
2. Widget が `EventDetailDeleteButtonPressed` を EventDetailBloc に追加する
3. EventDetailBloc が `showDeleteConfirmDialog: true` の State を emit する
4. Widget（BlocListener）が `showDeleteConfirmDialog == true` を検知して `showDialog` を呼び出す
5. ユーザーが確認ダイアログで「削除」をタップする
6. Widget が `EventDetailDeleteConfirmed` を EventDetailBloc に追加する
7. EventDetailBloc が `EventRepository.delete(eventId)` を呼び出す
8. 削除成功 → `EventDetailDeletedDelegate` を emit する
9. `EventDetailPage._handleDelegate` が `EventDetailDeletedDelegate` を受け取り `context.pop()` する

### スワイプ削除撤去フロー

- `_EventListItem` から `Slidable` を除去する
- `EventListDeleteRequested` イベントとそのBlocハンドラを除去する

---

## 15. SwiftUI版との対応

| Flutter Feature | 対応SwiftUI Reducer |
|---|---|
| event_list | EventListReducer |
| event_detail | EventDetailReducer |

- SwiftUI版では削除UIの配置については参照しない
- 削除ロジック（カスケード削除）は既存実装に準拠する

---

## 16. Test Scenarios

### 前提条件

- iOSシミュレーターが起動済みであること
- テスト用イベントが1件以上登録されていること

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-EDR-001 | イベント一覧でスワイプ削除UIが表示されないこと | High |
| TC-EDR-002 | イベント詳細ヘッダに削除アイコンが表示されること | High |
| TC-EDR-003 | 削除アイコン付近に「イベント削除」ラベルが表示されること | High |
| TC-EDR-004 | 削除アイコンタップで確認ダイアログが表示されること | High |
| TC-EDR-005 | 確認ダイアログで「キャンセル」をタップするとダイアログが閉じイベントが残ること | High |
| TC-EDR-006 | 確認ダイアログで「削除」をタップするとイベントが削除されて一覧に戻ること | High |

---

### TC-EDR-001: イベント一覧でスワイプ削除UIが表示されないこと

**前提**: テスト用イベントが1件以上存在する

**操作手順:**
1. イベント一覧画面を表示する
2. イベントカードを左スワイプする

**期待結果:**
- スワイプしても削除ボタンが表示されない
- カードが通常表示のまま維持される

**実装ノート（ウィジェットキー）:**
- `Key('eventList_item_${eventId}')` — イベントカード（スワイプ先のキー不存在を確認）

---

### TC-EDR-002: イベント詳細ヘッダに削除アイコンが表示されること

**前提**: テスト用イベントが1件以上存在する

**操作手順:**
1. イベント一覧画面を表示する
2. イベントカードをタップしてイベント詳細画面に遷移する
3. AppBarの右側を確認する

**期待結果:**
- AppBar右側に削除アイコンボタンが表示されている

**実装ノート（ウィジェットキー）:**
- `Key('eventDetail_button_delete')` — AppBar内削除アイコンボタン

---

### TC-EDR-003: 削除アイコン付近に「イベント削除」ラベルが表示されること

**前提**: テスト用イベントが1件以上存在する

**操作手順:**
1. イベント詳細画面を表示する
2. AppBar右側の削除ボタン周辺を確認する

**期待結果:**
- 削除アイコンの付近（アイコン下部または tooltip）に「イベント削除」の文字が表示されている

**実装ノート（ウィジェットキー）:**
- `Key('eventDetail_button_delete')` — 削除アイコンボタン（ラベルテキストの find.text('イベント削除') で確認）

---

### TC-EDR-004: 削除アイコンタップで確認ダイアログが表示されること

**前提**: テスト用イベントが1件以上存在する

**操作手順:**
1. イベント詳細画面を表示する
2. AppBar右側の削除アイコンをタップする

**期待結果:**
- 確認ダイアログが表示される
- タイトル「イベントを削除しますか？」が表示されている
- メッセージ「このイベントに関連するすべての情報が削除されます。」が表示されている
- 「削除」ボタンと「キャンセル」ボタンが表示されている

**実装ノート（ウィジェットキー）:**
- `Key('eventDetail_button_delete')` — 削除アイコンボタン
- `Key('eventDetail_dialog_deleteConfirm')` — 確認ダイアログ
- `Key('eventDetail_button_deleteConfirm')` — 削除確認ボタン
- `Key('eventDetail_button_deleteCancel')` — キャンセルボタン

---

### TC-EDR-005: 確認ダイアログで「キャンセル」をタップするとダイアログが閉じイベントが残ること

**前提**: テスト用イベントが1件以上存在し、イベント詳細画面が表示されている

**操作手順:**
1. AppBar右側の削除アイコンをタップする
2. 確認ダイアログが表示されたら「キャンセル」をタップする

**期待結果:**
- 確認ダイアログが閉じる
- イベント詳細画面がそのまま表示されている
- イベントは削除されていない

**実装ノート（ウィジェットキー）:**
- `Key('eventDetail_button_delete')` — 削除アイコンボタン
- `Key('eventDetail_button_deleteCancel')` — キャンセルボタン
- `Key('eventDetail_dialog_deleteConfirm')` — ダイアログ（閉じた後は存在しないことを確認）

---

### TC-EDR-006: 確認ダイアログで「削除」をタップするとイベントが削除されて一覧に戻ること

**前提**: テスト用イベントが1件以上存在し、イベント詳細画面が表示されている。削除前のイベント名を記録しておく

**操作手順:**
1. AppBar右側の削除アイコンをタップする
2. 確認ダイアログが表示されたら「削除」をタップする

**期待結果:**
- イベント詳細画面が閉じてイベント一覧画面に戻る
- 削除したイベントがイベント一覧に表示されない

**実装ノート（ウィジェットキー）:**
- `Key('eventDetail_button_delete')` — 削除アイコンボタン
- `Key('eventDetail_button_deleteConfirm')` — 削除確認ボタン
- `Key('eventList_item_${eventId}')` — 削除後のイベント一覧アイテム（存在しないことを確認）

---

## End of Feature Spec
