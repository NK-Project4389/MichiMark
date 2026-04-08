# Feature Spec: EventDetail 概要タブ再設計

**Spec ID**: EventDetailOverviewRedesign_Spec
**要件書**: `docs/Requirements/REQ-event_detail_overview_redesign.md`
**作成日**: 2026-04-08
**ステータス**: Draft

---

## 1. 概要

### Purpose

EventDetail の UX を統一する。現状は「基本」タブ（AppBar チェックボタン保存）・「振り返り」タブ（単独タブ）・MichiInfo/PaymentInfo（ネスト先保存）と保存操作が不揃いである。これを解消するため：

- 「基本」「振り返り」タブを廃止し「概要」タブに統合する
- 概要タブ内の基本情報セクションをインライン編集（セクション内保存ボタン）に変更する
- AppBar のチェックボタン（全体保存）を廃止する
- MarkDetail / LinkDetail / PaymentDetail の保存時に即 DB 保存を行い、MichiInfo / PaymentInfo の即時更新を保証する

### Scope

含むもの

- `event_detail`: タブ構成変更（4タブ → 3タブ）、AppBar チェックボタン廃止、タブ切り替えアラート
- `basic_info`: 独立タブ廃止、概要タブ内インライン編集セクションへ変更、保存フロー変更
- `overview`: 概要タブ下部セクションとして再利用（OverviewBloc は変更なし）
- `mark_detail`: `_onSaveTapped` に DB 保存追加、`_eventId` 保持
- `link_detail`: `_onSaveTapped` に DB 保存追加、`_eventId` 保持
- `payment_detail`: `_onSaveTapped` に DB 保存追加、`_eventId` 保持
- `payment_info`: PaymentDetailPage を `await context.push` で呼び出しに変更（保存後の一覧即時更新）
- `michi_info`: DB 保存後も in-memory 更新（Draft 返却パターン）を継続

含まないもの

- 「戻る」ボタンで EventDetail を閉じる際の未保存アラート
- 概要タブのデザイン詳細（デザイナー委任）
- 新規作成フローの変更

---

## 2. タブ構成変更

### 変更前

| タブ | 内容 |
|---|---|
| 基本 | BasicInfoView（イベント基本情報編集） |
| ミチ | MichiInfoView |
| 支払 | PaymentInfoView |
| 振り返り | EventDetailOverviewPage |

### 変更後

| タブ | 内容 |
|---|---|
| 概要 | BasicInfoSection（上部・インライン編集） + OverviewSection（下部・集計） |
| ミチ | MichiInfoView（変更なし） |
| 支払 | PaymentInfoView（変更なし） |

### EventDetailTab enum の変更

変更前:
- `basicInfo`
- `michiInfo`
- `paymentInfo`
- `overview`

変更後:
- `overview`（概要タブ。旧 basicInfo + 旧 overview の統合）
- `michiInfo`
- `paymentInfo`

---

## 3. 概要タブ設計

### 3-1. BasicInfoSection（インライン編集）

概要タブの上部に配置するセクション。BasicInfoBloc を使用する（既存 Bloc の継続利用）。

#### 表示モード（参照モード）

- `BasicInfoLoaded.isEditing == false` のとき表示
- イベント名・交通手段・燃費・ガソリン単価・メンバー・タグ・ガソリン支払者を読み取り専用で表示
- セクション右上に「編集」ボタン（`BasicInfoEditModeEntered` を発火）

#### 編集モード

- `BasicInfoLoaded.isEditing == true` のとき表示
- 既存 `_BasicInfoForm` と同等の入力フォームを表示
- 「編集」ボタンの代わりに「保存」ボタンと保存中インジケーターを表示
- 「保存」ボタン押下 → `BasicInfoSavePressed` を発火 → DB 保存 → `isEditing = false` に戻る
- 保存中（`isSaving == true`）はボタンを非活性

### 3-2. BasicInfoDraft への isEditing 追加

`BasicInfoDraft` に `isEditing: bool` フィールドを追加する。

| フィールド | 型 | 説明 |
|---|---|---|
| isEditing | bool | 編集モード中かどうか。デフォルト false |
| （既存フィールドはすべて維持） | | |

### 3-3. BasicInfoState への isSaving 追加

`BasicInfoLoaded` に `isSaving: bool` フィールドを追加する。

| フィールド | 型 | 説明 |
|---|---|---|
| isSaving | bool | 保存処理中フラグ。デフォルト false |
| （既存フィールドはすべて維持） | | |

### 3-4. OverviewSection（集計情報）

概要タブの下部に配置するセクション。

- `EventDetailOverviewBloc` を再利用する（変更なし）
- `EventDetailOverviewPage` の Widget を概要タブ内に埋め込む
- OverviewStarted の発火タイミング: 概要タブが表示されたとき（現行 overview タブ選択時の発火ロジックを概要タブに転用）

---

## 4. BasicInfoBloc の変更

### 新規 Event

| Event 名 | 発火タイミング | 説明 |
|---|---|---|
| `BasicInfoEditModeEntered` | 「編集」ボタン押下 | isEditing を true に切り替える |
| `BasicInfoSavePressed` | 「保存」ボタン押下 | DB 保存 → isEditing を false に切り替える |
| `BasicInfoEditCancelled` | 「破棄して移動」選択時または編集キャンセル | Draft を元の値に戻し isEditing を false にする |

### 既存 Event の変更

既存の Draft 更新 Event（`BasicInfoEventNameChanged` など）はすべてそのまま維持する。

### 新規 Delegate

| Delegate 名 | 説明 |
|---|---|
| `BasicInfoSavedDelegate` | DB 保存完了を親（EventDetailPage）に通知する |

### BasicInfoBloc の DB 保存責務

- 現行では EventDetailBloc の `_onSaveRequested` が DB 保存を担っていた
- 変更後は BasicInfoBloc の `_onSavePressed` が直接 EventRepository を呼び出して保存する
- 保存ロジック（kmPerGas の変換・pricePerGas の変換・既存 markLinks/payments の引き継ぎ）は現行 `EventDetailBloc._onSaveRequested` の実装をそのまま移植する
- Trans の最大メーター値更新（`_updateTransMaxMeterValue`）も同様に BasicInfoBloc に移植する
- 保存後に `BasicInfoSavedDelegate` を emit し、EventDetailPage の BlocListener が AppBar タイトルを更新する

### BasicInfoBloc の `_eventId` 保持

- `BasicInfoStarted(eventId)` を受け取った時点で `_eventId` を保持する
- `_onSavePressed` で `_eventId` を使用して `_eventRepository.fetch()` および `_eventRepository.save()` を呼び出す

---

## 5. EventDetailBloc の変更

### 削除する Event

| Event 名 | 理由 |
|---|---|
| `EventDetailSaveRequested` | 保存責務を BasicInfoBloc に移管するため削除 |

### 変更する Event

| Event 名 | 変更内容 |
|---|---|
| `EventDetailTabSelected` | 編集中チェック付きに変更（後述のアラート制御）|

### 新規 Event

| Event 名 | 発火タイミング | 説明 |
|---|---|---|
| `EventDetailTabChangeRequested` | タブボタン押下（編集中の場合） | isEditing チェックを行い、アラート表示か即切り替えかを判断する |
| `EventDetailDelegateConsumed` | Delegate 処理後 | delegate を null にリセットする |

### 削除する Delegate

| Delegate 名 | 理由 |
|---|---|
| `EventDetailSavedDelegate` | AppBar チェックボタン保存フローが廃止されるため削除 |

### 変更する State

`EventDetailLoaded` の変更:

| フィールド | 変更内容 |
|---|---|
| `isSaving` | 削除（BasicInfoBloc に移管） |
| `saveErrorMessage` | 削除（BasicInfoBloc に移管） |

`EventDetailTab` enum の変更（上述 2 節のとおり）

---

## 6. タブ切り替えアラート

### 対象条件

`BasicInfoLoaded.isEditing == true` の状態でユーザーが「ミチ」または「支払」タブをタップした場合。

### アラート表示フロー

1. Widget 側がタブ押下を検知する
2. `BasicInfoLoaded.isEditing` を確認する
3. `true` の場合: アラートダイアログを表示する（Widget 側で表示。Bloc に持たせない）
4. `false` の場合: 即座に `EventDetailTabSelected` を発火してタブ切り替える

### アラートの選択肢

| ボタン | 処理 |
|---|---|
| 「保存して移動」 | `BasicInfoSavePressed` → 保存完了後 → `EventDetailTabSelected(targetTab)` |
| 「破棄して移動」 | `BasicInfoEditCancelled` → `EventDetailTabSelected(targetTab)` |
| 「キャンセル」 | 概要タブに留まる（編集モード継続） |

### 実装方針

- アラートダイアログは `EventDetailPage`（または概要タブ Widget）の BlocListener 外で Widget ローカルに表示する
- Bloc はアラートの表示自体を知らない
- 「保存して移動」選択後は、`BasicInfoSavedDelegate` を受け取ってからタブ切り替えを発火する
- `context.pop()` を `await` した後に Bloc に Event を追加するため、呼び出し元 Widget は `StatefulWidget` とする

---

## 7. MarkDetail / LinkDetail の即 DB 保存

### 変更方針

現行の `_onSaveTapped` は `MarkDetailSaveDraftDelegate(draft)` を emit してMichiInfoBloc側で in-memory 更新するだけだった。これを変更し、Bloc 自身が DB 保存を行う。

### MarkDetailBloc の変更

#### `_eventId` 保持

- `MarkDetailStarted(eventId, markLinkId, ...)` 受け取り時に `_eventId = event.eventId` を保持する

#### `_onSaveTapped` 変更

変更前: `MarkDetailSaveDraftDelegate(draft)` を emit するのみ
変更後:
1. `_eventRepository.fetch(_eventId)` で現在の EventDomain を取得
2. Draft を MarkLinkDomain に変換して EventDomain を更新
3. `_eventRepository.save(updatedDomain)` で DB 保存
4. `MarkDetailSavedDelegate(markLinkId, draft)` を emit
5. エラー時は `MarkDetailSaveErrorDelegate(message)` を emit

#### 新規 Delegate

| Delegate 名 | フィールド | 説明 |
|---|---|---|
| `MarkDetailSavedDelegate` | `markLinkId: String`, `draft: MarkDetailDraft` | DB 保存完了。MichiInfoBloc の in-memory 更新に使用 |
| `MarkDetailSaveErrorDelegate` | `message: String` | DB 保存エラー通知 |

既存の `MarkDetailSaveDraftDelegate` は `MarkDetailSavedDelegate` に置き換える。

#### `isSaving` フラグ追加

`MarkDetailLoaded` に `isSaving: bool` フィールドを追加する。保存中は保存ボタンを非活性にする。

### LinkDetailBloc の変更

MarkDetailBloc と同様の変更を適用する。

#### `_eventId` 保持

- `LinkDetailStarted(eventId, markLinkId, ...)` 受け取り時に `_eventId = event.eventId` を保持する

#### `_onSaveTapped` 変更

変更前: `LinkDetailSaveDraftDelegate(draft)` を emit するのみ
変更後: MarkDetailBloc と同様に DB 保存 → `LinkDetailSavedDelegate(markLinkId, draft)` を emit

#### 新規 Delegate

| Delegate 名 | フィールド | 説明 |
|---|---|---|
| `LinkDetailSavedDelegate` | `markLinkId: String`, `draft: LinkDetailDraft` | DB 保存完了。MichiInfoBloc の in-memory 更新に使用 |
| `LinkDetailSaveErrorDelegate` | `message: String` | DB 保存エラー通知 |

既存の `LinkDetailSaveDraftDelegate` は `LinkDetailSavedDelegate` に置き換える。

### MichiInfoBloc の変更

#### `_onMarkDraftApplied` / `_onLinkDraftApplied` の維持

- これらのハンドラは引き続き in-memory 更新のために使用する
- DB 保存は MarkDetailBloc / LinkDetailBloc 側で完結するため、MichiInfoBloc は DB 保存を行わない

#### Event 名の変更

| 変更前 | 変更後 | 理由 |
|---|---|---|
| `MichiInfoMarkDraftApplied` | `MichiInfoMarkSaved` | DB 保存後の通知に意味が変わるため |
| `MichiInfoLinkDraftApplied` | `MichiInfoLinkSaved` | 同上 |

---

## 8. PaymentDetail の即 DB 保存

### 変更方針

現行の `_onSaveTapped` は `PaymentDetailSaveDraftDelegate(draft)` を emit して呼び出し元（PaymentInfoView）が `context.pop(draft)` で Draft を返す方式だった。これを変更し、Bloc 自身が DB 保存を行う。

### PaymentDetailBloc の変更

#### `_eventId` 保持

- `PaymentDetailStarted(eventId, paymentId)` 受け取り時に `_eventId = event.eventId` を保持する

#### `_onSaveTapped` 変更

変更前: `PaymentDetailSaveDraftDelegate(draft)` を emit するのみ
変更後:
1. `_eventRepository.fetch(_eventId)` で現在の EventDomain を取得
2. Draft を PaymentDomain に変換して EventDomain を更新
3. `_eventRepository.save(updatedDomain)` で DB 保存
4. `PaymentDetailSavedDelegate(draft)` を emit → Page が `context.pop()` する
5. エラー時は `PaymentDetailSaveErrorDelegate(message)` を emit

#### 新規 Delegate

| Delegate 名 | フィールド | 説明 |
|---|---|---|
| `PaymentDetailSavedDelegate` | `draft: PaymentDetailDraft` | DB 保存完了。呼び出し元が pop に使う |
| `PaymentDetailSaveErrorDelegate` | `message: String` | DB 保存エラー通知 |

既存の `PaymentDetailSaveDraftDelegate` は `PaymentDetailSavedDelegate` に置き換える。

#### `isSaving` フラグ追加

`PaymentDetailLoaded` に `isSaving: bool` フィールドを追加する。保存中は「反映」ボタンを非活性にする。

### PaymentInfoView の変更

- `_handleDelegate` における PaymentDetail 遷移を `await context.push<PaymentDetailDraft>()` に変更する（現行は `await` なし）
- `await context.push()` 後に `mounted` チェックを行い、`PaymentInfoReloadRequested` を PaymentInfoBloc に追加する
- PaymentInfoView は `StatefulWidget` に変更する

### PaymentInfoBloc の変更

#### 新規 Event

| Event 名 | 発火タイミング | 説明 |
|---|---|---|
| `PaymentInfoReloadRequested` | PaymentDetail から戻ったとき | EventRepository から最新データを取得して一覧を更新する |

#### `_onReloadRequested` の設計

- `_eventRepository.fetch(_eventId)` で最新 EventDomain を取得
- Projection を再計算して emit する

#### `_eventId` 保持

- `PaymentInfoStarted(eventId, ...)` 受け取り時に `_eventId` を保持する

---

## 9. EventDetailBloc の既存保存フロー廃止後の整理

### 廃止するもの

- `EventDetailSaveRequested` Event
- `EventDetailBloc._onSaveRequested` ハンドラ
- `EventDetailLoaded.isSaving` フィールド
- `EventDetailLoaded.saveErrorMessage` フィールド
- AppBar の `saveAction` IconButton
- `EventDetailScaffoldInner._buildAppBar` の BasicInfoBloc への依存（saveAction が BasicInfoLoaded を参照していた）

### cachedEvent の更新

- BasicInfoBloc が保存完了したとき（`BasicInfoSavedDelegate` 受信時）、EventDetailBloc は最新 EventDomain を再取得して `cachedEvent` を更新する
- 更新後に OverviewBloc へ `OverviewTopicConfigUpdated` を再発火して集計を最新化する

---

## 10. Data Flow

### 概要タブ表示フロー

```
EventDetail 起動
  → EventDetailStarted → EventDetailBloc → EventDetailLoaded(cachedEvent)
  → BasicInfoStarted → BasicInfoBloc → BasicInfoLoaded(draft, isEditing=false)
  → OverviewStarted（概要タブ表示時） → EventDetailOverviewBloc → 集計結果 emit
  → 概要タブに BasicInfoSection（参照モード）+ OverviewSection を表示
```

### 基本情報インライン編集・保存フロー

```
「編集」ボタン押下
  → BasicInfoEditModeEntered → BasicInfoBloc → BasicInfoLoaded(isEditing=true)
  → 編集フォームに切り替わる

「保存」ボタン押下
  → BasicInfoSavePressed → BasicInfoBloc
    → isSaving=true emit
    → EventRepository.fetch / save
    → isSaving=false, isEditing=false emit
    → BasicInfoSavedDelegate emit
  → EventDetailPage BlocListener: cachedEvent 更新 → OverviewBloc へ再発火
```

### タブ切り替えアラートフロー（編集中）

```
isEditing=true の状態でタブ押下
  → Widget がアラートダイアログを表示
  → 「保存して移動」: BasicInfoSavePressed → 保存完了 → EventDetailTabSelected(targetTab)
  → 「破棄して移動」: BasicInfoEditCancelled → EventDetailTabSelected(targetTab)
  → 「キャンセル」: 概要タブ留まり
```

### MarkDetail / LinkDetail 保存フロー

```
「保存」ボタン押下
  → MarkDetailSaveTapped → MarkDetailBloc
    → isSaving=true emit
    → EventRepository.fetch / save（DB 保存）
    → MarkDetailSavedDelegate(markLinkId, draft) emit
  → MarkDetailPage BlocListener:
    → MichiInfoBloc に MichiInfoMarkSaved(markLinkId, draft) を発火（in-memory 更新）
    → context.pop()
```

### PaymentDetail 保存フロー

```
「反映」ボタン押下
  → PaymentDetailSaveTapped → PaymentDetailBloc
    → isSaving=true emit
    → EventRepository.fetch / save（DB 保存）
    → PaymentDetailSavedDelegate(draft) emit
  → PaymentDetailPage BlocListener: context.pop(draft)

PaymentInfoView（await context.push の戻り）
  → mounted チェック
  → PaymentInfoReloadRequested → PaymentInfoBloc → 一覧を最新化
```

---

## 11. 変更対象ファイル一覧

| ファイル | 変更種別 | 主な変更内容 |
|---|---|---|
| `event_detail/draft/event_detail_draft.dart` | 変更 | `EventDetailTab` enum を 3値に変更 |
| `event_detail/bloc/event_detail_event.dart` | 変更 | `EventDetailSaveRequested` 削除、`EventDetailDelegateConsumed` 追加 |
| `event_detail/bloc/event_detail_state.dart` | 変更 | `isSaving` / `saveErrorMessage` / `EventDetailSavedDelegate` 削除 |
| `event_detail/bloc/event_detail_bloc.dart` | 変更 | `_onSaveRequested` 削除、`cachedEvent` 更新処理追加、`_onDelegateConsumed` 追加 |
| `event_detail/view/event_detail_page.dart` | 変更 | タブ構成変更、AppBar チェックボタン削除、タブ切り替えアラート追加 |
| `basic_info/draft/basic_info_draft.dart` | 変更 | `isEditing: bool` フィールド追加 |
| `basic_info/bloc/basic_info_event.dart` | 変更 | `BasicInfoEditModeEntered` / `BasicInfoSavePressed` / `BasicInfoEditCancelled` 追加 |
| `basic_info/bloc/basic_info_state.dart` | 変更 | `BasicInfoLoaded.isSaving` 追加、`BasicInfoSavedDelegate` 追加 |
| `basic_info/bloc/basic_info_bloc.dart` | 変更 | `_onEditModeEntered` / `_onSavePressed` / `_onEditCancelled` 追加、DB 保存ロジック追加 |
| `basic_info/view/basic_info_view.dart` | 変更 | 参照モード / 編集モード切り替え UI 追加 |
| `overview/view/event_detail_overview_page.dart` | 変更なし | そのまま概要タブ内に埋め込む |
| `mark_detail/bloc/mark_detail_bloc.dart` | 変更 | `_eventId` 保持、`_onSaveTapped` に DB 保存追加 |
| `mark_detail/bloc/mark_detail_state.dart` | 変更 | `isSaving` 追加、`MarkDetailSavedDelegate` / `MarkDetailSaveErrorDelegate` 追加 |
| `link_detail/bloc/link_detail_bloc.dart` | 変更 | `_eventId` 保持、`_onSaveTapped` に DB 保存追加 |
| `link_detail/bloc/link_detail_state.dart` | 変更 | `isSaving` 追加、`LinkDetailSavedDelegate` / `LinkDetailSaveErrorDelegate` 追加 |
| `michi_info/bloc/michi_info_event.dart` | 変更 | `MichiInfoMarkDraftApplied` → `MichiInfoMarkSaved`、`MichiInfoLinkDraftApplied` → `MichiInfoLinkSaved` |
| `payment_detail/bloc/payment_detail_bloc.dart` | 変更 | `_eventId` 保持、`_onSaveTapped` に DB 保存追加 |
| `payment_detail/bloc/payment_detail_state.dart` | 変更 | `isSaving` 追加、`PaymentDetailSavedDelegate` / `PaymentDetailSaveErrorDelegate` 追加 |
| `payment_info/view/payment_info_view.dart` | 変更 | `StatefulWidget` 化、`await context.push` + `mounted` チェック + `PaymentInfoReloadRequested` 追加 |
| `payment_info/bloc/payment_info_event.dart` | 変更 | `PaymentInfoReloadRequested` 追加 |
| `payment_info/bloc/payment_info_bloc.dart` | 変更 | `_eventId` 保持、`_onReloadRequested` 追加 |

---

## 12. テストシナリオ

### 前提条件

- iOS シミュレーターが起動済みであること
- テスト用イベントが 1 件以上存在すること
- テスト用イベントに交通手段・メンバーが設定済みであること（一部テスト）

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-EOD-001 | 概要タブが先頭タブとして表示される | High |
| TC-EOD-002 | 概要タブ: 参照モードで基本情報が表示される | High |
| TC-EOD-003 | 概要タブ: 「編集」押下で編集モードに切り替わる | High |
| TC-EOD-004 | 概要タブ: 編集後「保存」押下で DB 保存され参照モードに戻る | High |
| TC-EOD-005 | AppBar にチェックボタン（保存アイコン）が表示されない | High |
| TC-EOD-006 | 編集中に「ミチ」タブを押すとアラートが表示される | High |
| TC-EOD-007 | アラートで「保存して移動」を選ぶと保存後ミチタブに移動する | High |
| TC-EOD-008 | アラートで「破棄して移動」を選ぶと変更が破棄されミチタブに移動する | High |
| TC-EOD-009 | アラートで「キャンセル」を選ぶと概要タブの編集モードに留まる | Medium |
| TC-EOD-010 | MarkDetail 保存後にミチ一覧が即時更新される | High |
| TC-EOD-011 | LinkDetail 保存後にミチ一覧が即時更新される | High |
| TC-EOD-012 | PaymentDetail 保存後に支払一覧が即時更新される | High |
| TC-EOD-013 | 「振り返り」タブが表示されない | High |
| TC-EOD-014 | 「基本」タブが表示されない | High |
| TC-EOD-015 | 概要タブ下部に集計情報が表示される | Medium |

### シナリオ詳細

#### TC-EOD-001: 概要タブが先頭タブとして表示される

**操作手順:**
1. イベント一覧からイベントをタップする
2. EventDetail 画面が開く

**期待結果:**
- タブが「概要」「ミチ」「支払」の 3 つだけ表示される
- 「概要」タブが選択状態である

---

#### TC-EOD-002: 概要タブ: 参照モードで基本情報が表示される

**操作手順:**
1. EventDetail を開く（概要タブ）

**期待結果:**
- イベント名が読み取り専用テキストで表示される
- 「編集」ボタンが表示される
- テキストフィールド（入力欄）が表示されない

---

#### TC-EOD-003: 概要タブ: 「編集」押下で編集モードに切り替わる

**操作手順:**
1. EventDetail を開く（概要タブ）
2. 「編集」ボタンをタップする

**期待結果:**
- 入力フォームが表示される
- 「編集」ボタンが「保存」ボタンに変わる

---

#### TC-EOD-004: 概要タブ: 編集後「保存」押下で DB 保存され参照モードに戻る

**操作手順:**
1. EventDetail を開く（概要タブ）
2. 「編集」ボタンをタップする
3. イベント名を変更する
4. 「保存」ボタンをタップする

**期待結果:**
- 参照モードに戻る
- 変更後のイベント名が読み取り専用テキストで表示される
- EventDetail を閉じて再度開いても変更後のイベント名が表示される（DB に保存されている）

---

#### TC-EOD-005: AppBar にチェックボタン（保存アイコン）が表示されない

**操作手順:**
1. EventDetail を開く

**期待結果:**
- AppBar の右端にチェックアイコン（保存ボタン）が表示されない

---

#### TC-EOD-006: 編集中に「ミチ」タブを押すとアラートが表示される

**操作手順:**
1. EventDetail を開く（概要タブ）
2. 「編集」ボタンをタップする
3. 「ミチ」タブをタップする

**期待結果:**
- アラートダイアログが表示される
- タイトルに「保存していません」が表示される
- 「保存して移動」「破棄して移動」「キャンセル」の 3 ボタンが表示される

---

#### TC-EOD-007: アラートで「保存して移動」を選ぶと保存後ミチタブに移動する

**操作手順:**
1. TC-EOD-006 の続き
2. アラートの「保存して移動」ボタンをタップする

**期待結果:**
- 「ミチ」タブが表示される
- 編集前後の変更が保存されている（再度 EventDetail を開いて確認）

---

#### TC-EOD-008: アラートで「破棄して移動」を選ぶと変更が破棄されミチタブに移動する

**操作手順:**
1. EventDetail を開く
2. 「編集」ボタンをタップして編集モードにする
3. イベント名を変更する（保存はしない）
4. 「ミチ」タブをタップする
5. アラートの「破棄して移動」をタップする

**期待結果:**
- 「ミチ」タブが表示される
- 概要タブに戻るとイベント名が変更前の値に戻っている

---

#### TC-EOD-009: アラートで「キャンセル」を選ぶと概要タブの編集モードに留まる

**操作手順:**
1. TC-EOD-006 の続き
2. アラートの「キャンセル」ボタンをタップする

**期待結果:**
- アラートが閉じる
- 概要タブの編集モードのまま表示される

---

#### TC-EOD-010: MarkDetail 保存後にミチ一覧が即時更新される

**操作手順:**
1. EventDetail を開いて「ミチ」タブを表示する
2. 地点をタップして MarkDetail を開く
3. 地点名を変更して「保存」ボタンをタップする

**期待結果:**
- MarkDetail が閉じてミチ一覧に戻る
- 一覧に変更後の地点名が表示される

---

#### TC-EOD-011: LinkDetail 保存後にミチ一覧が即時更新される

**操作手順:**
1. EventDetail を開いて「ミチ」タブを表示する
2. リンクをタップして LinkDetail を開く
3. リンク名を変更して「保存」ボタンをタップする

**期待結果:**
- LinkDetail が閉じてミチ一覧に戻る
- 一覧に変更後のリンク名が表示される

---

#### TC-EOD-012: PaymentDetail 保存後に支払一覧が即時更新される

**操作手順:**
1. EventDetail を開いて「支払」タブを表示する
2. 「+」ボタンをタップして PaymentDetail を開く
3. 金額を入力して「反映」ボタンをタップする

**期待結果:**
- PaymentDetail が閉じて支払一覧に戻る
- 一覧に新しい支払が表示される

---

#### TC-EOD-013: 「振り返り」タブが表示されない

**操作手順:**
1. EventDetail を開く

**期待結果:**
- タブバーに「振り返り」のラベルが存在しない

---

#### TC-EOD-014: 「基本」タブが表示されない

**操作手順:**
1. EventDetail を開く

**期待結果:**
- タブバーに「基本」のラベルが存在しない

---

#### TC-EOD-015: 概要タブ下部に集計情報が表示される

**操作手順:**
1. マーク・支払が登録済みのイベントの EventDetail を開く
2. 概要タブが表示される

**期待結果:**
- 概要タブの下部（基本情報セクションより下）に集計情報（走行距離、燃費など）が表示される

---

## End of Spec
