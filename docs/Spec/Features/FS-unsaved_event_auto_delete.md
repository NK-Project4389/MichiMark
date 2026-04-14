# Feature Spec: 未保存新規イベント自動削除

**Feature ID**: UI-12
**要件書**: docs/Requirements/REQ-unsaved_event_auto_delete.md
**作成日**: 2026-04-14
**ステータス**: Draft

---

## 1. Feature Overview

### Feature Name

UnsavedEventAutoDelete（未保存新規イベント自動削除）

### Purpose

新規イベント作成後、何も保存せずにイベント一覧へ戻った場合、DBに残った空イベントを自動削除する。ユーザーが「やっぱりやめた」という操作に対してリストをクリーンな状態に保つ。

### Scope

**含むもの**
- EventDetailPage のバックボタン押下時の未保存判定
- 「未保存の新規イベント」と判定した場合の EventRepository.deleteEvent 呼び出し
- 判定ロジック（BasicInfo・MichiInfo・PaymentInfo すべてが保存なし状態かどうか）

**含まないもの**
- 既存イベント編集時の操作（対象外）
- システムのスワイプバック（REQ-UIE-002 では「戻るボタン」のみ対象）
- 削除確認ダイアログの表示（サイレント削除）

---

## 2. Feature Responsibility

EventDetailBloc が以下を担当する。

- 新規作成フラグの保持（isNewEvent）
- 未保存判定ロジック（isSavedAtLeastOnce フラグの管理）
- 戻るボタン押下時に未保存の場合は deleteEvent を呼び出してから Dismiss

子 Bloc（BasicInfoBloc・MichiInfoBloc・PaymentInfoBloc）は保存完了時に EventDetailBloc へ保存完了通知を送る。EventDetailBloc は通知を受けて isSavedAtLeastOnce を true にする。

---

## 3. State Structure

### EventDetailLoaded への追加フィールド

| フィールド | 型 | 説明 |
|---|---|---|
| `isNewEvent` | `bool` | 新規作成モードで開かれた場合 true。既存編集は false |
| `isSavedAtLeastOnce` | `bool` | BasicInfo・MichiInfo・PaymentInfo のいずれかを1件以上保存したら true |

> 既存の `EventDetailLoaded` に追加する。デフォルト値はそれぞれ `false`。

---

## 4. Domain Model

新規フィールドなし。既存の `EventDomain` を使用する。

---

## 5. Projection Model

新規フィールドなし。既存の `EventDetailProjection` を使用する。

---

## 6. Adapter

変更なし。既存の `EventDetailAdapter` を使用する。

---

## 7. Events

### 既存 Event の変更

| Event名 | 変更内容 |
|---|---|
| `EventDetailStarted` | `isNewEvent` フラグを Bloc が判定して State に設定する（新規作成時 `NotFoundError` → `isNewEvent = true`） |
| `EventDetailDismissPressed` | 未保存判定を追加。`isNewEvent == true && isSavedAtLeastOnce == false` の場合、deleteEvent を呼んでから Dismiss |

### 追加 Event

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `EventDetailChildSaved` | BasicInfoBloc・MichiInfoBloc・PaymentInfoBloc が保存完了したとき | EventDetailBloc の `isSavedAtLeastOnce` を true にする |

> `EventDetailChildSaved` は EventDetailPage の BlocListener（BasicInfo/MichiInfo/PaymentInfo の SavedDelegate 受信時）から EventDetailBloc に追加する。

---

## 8. Delegate Contract

既存の `EventDetailDismissDelegate` をそのまま使用する。削除処理は Bloc 内で完了させてから Delegate を emit する。

---

## 9. Data Flow

1. EventDetailPage が新規 eventId で起動 → EventDetailBloc が `NotFoundError` を検知して空 EventDomain を保存 → `isNewEvent = true` で State を emit
2. ユーザーが何も操作せずにバックボタンをタップ → `EventDetailDismissPressed` が発火
3. Bloc は `isNewEvent == true && isSavedAtLeastOnce == false` を確認
4. 条件を満たす場合 → `EventRepository.deleteEvent(eventId)` を非同期呼び出し（完了を待つ）
5. 削除完了後 → `EventDetailDismissDelegate` を emit
6. EventDetailPage の BlocListener が `context.pop()` を実行

**通常パス（保存済みの場合）**
- BasicInfoBloc / MichiInfoBloc / PaymentInfoBloc が保存成功 → EventDetailPage の BlocListener が `EventDetailChildSaved` を EventDetailBloc に add → `isSavedAtLeastOnce = true`
- バックボタン押下時は `isSavedAtLeastOnce == true` のため削除せずそのまま Dismiss

---

## 10. Bloc Responsibility

`EventDetailBloc` が以下を追加担当する。

- `EventDetailStarted` ハンドラ: 新規作成時（NotFoundError パス）に `isNewEvent = true` を State に追加
- `EventDetailDismissPressed` ハンドラ: 未保存判定 + 条件付き deleteEvent 呼び出し
- `EventDetailChildSaved` ハンドラ: `isSavedAtLeastOnce = true` に更新

---

## 11. Navigation

変更なし。既存の `EventDetailDismissDelegate` → `context.pop()` のフローを使用する。

---

## 12. Persistence

`EventRepository` の既存 `deleteEvent(String eventId)` を使用する。

---

## 13. Validation

未保存判定条件（すべて満たす場合「未保存」）：

- `isNewEvent == true`
- `isSavedAtLeastOnce == false`

---

## 14. Widget Key 一覧

| キー | 説明 |
|---|---|
| `Key('eventDetail_button_back')` | EventDetailPage のバックボタン |

> EventDetail の戻るボタンに Key を付与する必要がある（現状 AppBar の leading に自動生成の BackButton がある場合はカスタム BackButton に置き換える）。

---

## 15. Test Scenarios

### 前提条件

- アプリ起動済み（`startApp` ヘルパー使用）
- seed データにイベントが0件、またはテスト内で新規作成する
- 新規イベントを作成したあとの EventDetail 画面を起点とする

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-UAE-001 | 新規イベント: 何も保存せずに戻るとイベントが消える | High |
| TC-UAE-002 | 新規イベント: BasicInfo（名前）を保存して戻るとイベントが残る | High |
| TC-UAE-003 | 新規イベント: Mark を1件保存して戻るとイベントが残る | High |
| TC-UAE-004 | 新規イベント: Payment を1件保存して戻るとイベントが残る | High |
| TC-UAE-005 | 既存イベント: 何も操作せずに戻ってもイベントが消えない | High |

---

### TC-UAE-001: 新規イベント — 何も保存せずに戻るとイベントが消える

**前提**
- イベント一覧画面が表示されており、イベントが0件またはN件

**手順**
1. イベント追加ボタン（`Key('eventList_button_create')`）をタップする
2. EventDetail 画面が表示されることを確認する
3. 何も操作せずにバックボタン（`Key('eventDetail_button_back')`）をタップする
4. イベント一覧画面へ戻ることを確認する

**期待結果**
- イベント一覧のカード数が操作前と同じ（0件 → 0件 / N件 → N件）
- 空のイベントカードが表示されない

**実装ノート（ウィジェットキー一覧）**
- `Key('eventList_button_create')` — イベント追加ボタン（EventListPage）
- `Key('eventDetail_button_back')` — EventDetail バックボタン
- `Key('eventList_item_${index}')` — イベントリストアイテム

---

### TC-UAE-002: 新規イベント — BasicInfo（名前）を保存して戻るとイベントが残る

**前提**
- イベント一覧画面が表示されており、イベントが0件またはN件

**手順**
1. イベント追加ボタンをタップして EventDetail を開く
2. 概要タブの名前フィールド（`Key('basicInfo_field_name')`）に「テストイベント」と入力する
3. 名前フィールドの保存操作（フォーカスアウトまたは保存ボタン）を行う
4. バックボタン（`Key('eventDetail_button_back')`）をタップする
5. イベント一覧画面へ戻ることを確認する

**期待結果**
- イベント一覧にイベントが残っている（N件 → N+1件）
- 「テストイベント」と表示されたカードが確認できる

**実装ノート（ウィジェットキー一覧）**
- `Key('basicInfo_field_name')` — BasicInfo の名前入力フィールド
- `Key('eventDetail_button_back')` — バックボタン

---

### TC-UAE-003: 新規イベント — Mark を1件保存して戻るとイベントが残る

**前提**
- イベント一覧画面が表示されており、イベントが0件またはN件

**手順**
1. イベント追加ボタンをタップして EventDetail を開く
2. MichiInfoタブに切り替える
3. マーク追加ボタンをタップして MarkDetail を開く
4. MarkDetail で保存ボタン（`Key('markDetail_button_save')`）をタップする
5. EventDetail へ戻り、さらにバックボタンをタップする

**期待結果**
- イベント一覧にイベントが残っている（N件 → N+1件）

**実装ノート（ウィジェットキー一覧）**
- `Key('markDetail_button_save')` — MarkDetail 保存ボタン
- `Key('eventDetail_button_back')` — バックボタン

---

### TC-UAE-004: 新規イベント — Payment を1件保存して戻るとイベントが残る

**前提**
- イベント一覧画面が表示されており、イベントが0件またはN件

**手順**
1. イベント追加ボタンをタップして EventDetail を開く
2. 支払いタブに切り替える
3. 支払い追加ボタンをタップして PaymentDetail を開く
4. PaymentDetail で保存ボタン（`Key('paymentDetail_button_save')`）をタップする
5. EventDetail へ戻り、さらにバックボタンをタップする

**期待結果**
- イベント一覧にイベントが残っている（N件 → N+1件）

**実装ノート（ウィジェットキー一覧）**
- `Key('paymentDetail_button_save')` — PaymentDetail 保存ボタン
- `Key('eventDetail_button_back')` — バックボタン

---

### TC-UAE-005: 既存イベント — 何も操作せずに戻ってもイベントが消えない

**前提**
- seed データまたは事前作成済みのイベントが1件以上存在する

**手順**
1. イベント一覧から既存イベントをタップして EventDetail を開く
2. 何も操作せずにバックボタン（`Key('eventDetail_button_back')`）をタップする
3. イベント一覧へ戻る

**期待結果**
- イベント一覧のカード数が変わらない（既存イベントが削除されない）

**実装ノート（ウィジェットキー一覧）**
- `Key('eventList_item_${index}')` — イベントリストアイテム
- `Key('eventDetail_button_back')` — バックボタン

---

## 16. 備考

- 削除処理は非同期・UI ブロックなし（REQ-UIE-003 非機能要件）
- EventDetail の AppBar leading に `Key('eventDetail_button_back')` を持つカスタム BackButton が必要。flutter-dev は既存の自動 BackButton をカスタム実装に置き換えること
- `EventDetailChildSaved` の発火タイミング: EventDetailPage の BlocListener が各子 Bloc の SavedDelegate を検知したタイミングで EventDetailBloc.add(EventDetailChildSaved()) を呼ぶ
