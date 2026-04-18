# Feature Spec: F-9 ActionTimeLog 時間変更（後から修正）

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-18
Requirement: `docs/Requirements/REQ-action_log_time_edit.md`

---

# 1. Feature Overview

## Feature Name

ActionLogTimeEdit

## Purpose

ActionTimeLogに `adjustedAt`（変更後の時間）フィールドをDomainレベルで追加し、ユーザーがUI上で記録した時刻を事後変更できるようにする。
ログ一覧は「有効時間」（`adjustedAt ?? timestamp`）でソートし、変更後の時刻が登録時間と一致した場合は `adjustedAt` を NULL に正規化する。
ボタン内の「直近の押下時刻」も有効時間を反映する。

## Scope

含むもの
- `ActionTimeLog` Domain への `adjustedAt: DateTime?` フィールド追加
- 有効時間（`adjustedAt ?? timestamp`）ベースのソート変更
- ログ一覧の時間表示をタップで開く CupertinoDatePicker（timeモード）ボトムシート
- `adjustedAt` 設定ログへの視覚的区別（編集アイコン表示）
- `ActionTimeAdapter` の `lastLoggedTimeLabel` 算出を有効時間ベースに変更
- DBスキーマ変更（`action_time_logs` テーブルに `adjusted_at` カラム追加、schemaVersion 7）
- `EventRepository` への `updateActionTimeLogAdjustedAt` メソッド追加
- drift実装（`DriftEventRepository`）における `saveActionTimeLog`・`deleteActionTimeLog`・`fetchActionTimeLogs` の実装（現在 `UnimplementedError`）
- `ActionTimeLogs` drift Table定義への `mark_link_id` カラム追加（現在未追加・F-10との整合修正）

含まないもの
- 日付をまたぐ時刻変更（Phase 2以降）
- 複数ログの一括時刻変更
- 時刻変更の履歴管理（Undo/Redo）
- ダークテーマ対応
- `ActionTimeLogRecorded` のdispatchロジック変更
- 既存の状態遷移ロジック変更

---

# 2. Feature Responsibility

このFeatureの責務

- `ActionTimeLog` Domain 拡張（`adjustedAt` フィールド追加）
- 有効時間定義の導入（`adjustedAt ?? timestamp`）
- `adjustedAt` の NULL 正規化ロジック（Bloc）
- `ActionTimeAdapter` の有効時間ベースへの変更
- `ActionTimeBloc` への新規Event追加（`ActionTimeLogAdjustedAtUpdated`）
- `ActionTimeView` への時刻変更UI追加（`_LogItem` の時間表示タップ → ボトムシート）
- drift Repository実装の完成（未実装メソッドの実装）

RootはこのFeatureの内部状態を変更しない。

---

# 3. 設計判断

## 3.1 adjustedAt の NULL 正規化ルール

`adjustedAt` が `timestamp` と同一の時刻（秒単位で一致）の場合、保存前に `null` に戻す。
これにより不要なデータ保持を防ぎ、「変更あり」の判定を `adjustedAt != null` で一意に行える。

**実装場所**: `ActionTimeBloc._onAdjustedAtUpdated` が Adapter の `normalizeAdjustedAt` を呼び、正規化済みの値でRepositoryに保存する。

## 3.2 有効時間の定義

```
有効時間 = adjustedAt ?? timestamp
```

この定義はアプリ全体で統一する。Adapterで計算し、Projectionに変換後はWidgetが直接扱わない。

## 3.3 ソート変更

`ActionTimeAdapter.buildDraftAndProjection` のソートキーを `timestamp` から有効時間（`effectiveTime`）に変更する。
ソート方向は現行と同じ昇順を維持する。

## 3.4 DatePicker UI方針

- **方式**: CupertinoDatePicker（mode: time）をボトムシートとして表示する
- **理由**: iOSネイティブに馴染みのあるスクロール式ピッカーで、時・分の選択が直感的。日付変更はPhase 1スコープ外のため timeモードが適切
- **表示トリガー**: ログ一覧の時刻ラベルをタップ
- **確定**: 「確定」ボタンタップで `ActionTimeLogAdjustedAtUpdated` イベントをdispatch
- **キャンセル**: 「キャンセル」ボタンタップでボトムシートを閉じる（変更なし）
- **初期値**: タップしたログの有効時間（`adjustedAt ?? timestamp`）をピッカーの初期値とする

## 3.5 adjustedAt 設定時の視覚的区別

`adjustedAt != null` のログに対して、時刻ラベルの末尾に編集アイコン（`Icons.edit` サイズ12）を表示する。
色は `Theme.of(context).colorScheme.primary` に準拠する。

## 3.6 DriftEventRepository 未実装メソッドの対応

現時点で `saveActionTimeLog`・`deleteActionTimeLog`・`fetchActionTimeLogs` が `UnimplementedError` であり、本Featureの実装に必須。
本Specで実装対象に含める。

## 3.7 ActionTimeLogs Table の mark_link_id 未追加問題

`domain/action_time/action_time_log.dart` には `markLinkId: String?` が存在するが、drift Table定義（`event_tables.dart`）および `database.g.dart` には未追加。
本Featureで `adjusted_at` を追加する際に `mark_link_id` も同時にTable定義へ追加し、schemaVersion 7 のマイグレーションで両カラムを追加する。

---

# 4. Domain 変更

## ActionTimeLog（変更）

**ファイル**: `flutter/lib/domain/action_time/action_time_log.dart`

| フィールド名 | 型 | 変更 | 説明 |
|---|---|---|---|
| `id` | `String` | 変更なし | PK（UUID） |
| `eventId` | `String` | 変更なし | FK → EventDomain.id |
| `actionId` | `String` | 変更なし | FK → ActionDomain.id |
| `timestamp` | `DateTime` | 変更なし | 登録時のAction発生日時 |
| `adjustedAt` | `DateTime?` | **新規追加** | ユーザーが変更した時刻。null = 未変更 |
| `isDeleted` | `bool` | 変更なし | 論理削除フラグ |
| `createdAt` | `DateTime` | 変更なし | 登録日時 |
| `updatedAt` | `DateTime` | 変更なし | 更新日時 |
| `markLinkId` | `String?` | 変更なし | 操作対象MarkLinkID（F-10） |

**有効時間の定義**: `adjustedAt ?? timestamp`（Domainは計算メソッドを持たない。Adapterで計算する）

---

# 5. Projection 変更

## ActionTimeLogProjection（変更）

**ファイル**: `flutter/lib/features/action_time/projection/action_time_projection.dart`

| フィールド名 | 型 | 変更 | 説明 |
|---|---|---|---|
| `id` | `String` | 変更なし | ログID |
| `actionName` | `String` | 変更なし | アクション名 |
| `timestampLabel` | `String` | **意味変更** | 有効時間（`adjustedAt ?? timestamp`）の `HH:mm` 表示 |
| `transitionLabel` | `String` | 変更なし | 状態遷移ラベル |
| `isAdjusted` | `bool` | **新規追加** | `adjustedAt != null` の場合 `true`。編集アイコン表示に使用 |

## ActionButtonProjection（変更）

| フィールド名 | 型 | 変更 | 説明 |
|---|---|---|---|
| `actionId` | `String` | 変更なし | アクションID |
| `actionName` | `String` | 変更なし | アクション名（表示用） |
| `lastLoggedTimeLabel` | `String?` | **算出基準変更** | 有効時間（`adjustedAt ?? timestamp`）の `HH:mm` 表示 |
| `isLastPressed` | `bool` | **算出基準変更** | 有効時間で最大のログのアクションIDと一致するかどうか |

## ActionTimeProjection（変更なし）

フィールド構造は変更なし。`logItems` と `buttonItems` の内容がAdapter変更により更新される。

---

# 6. Adapter 変更

**ファイル**: `flutter/lib/adapter/action_time_adapter.dart`

## 変更点

### ソートキーの変更

`buildDraftAndProjection` 内のソートを `timestamp` から有効時間（`effectiveTime = adjustedAt ?? timestamp`）に変更する。

### logItems 生成変更

- `timestampLabel`: 有効時間（`adjustedAt ?? timestamp`）を `HH:mm` 形式でフォーマットする
- `isAdjusted`: `adjustedAt != null` の場合 `true`

### buttonItems 生成変更

- `lastLoggedAtMap`: アクションIDごとに「有効時間」の最大値を算出する（`timestamp` ではなく有効時間を比較）
- `lastPressedActionId`: 全ログ中で有効時間が最大のログの `actionId`

### normalizeAdjustedAt（新規追加）

`adjustedAt` と `timestamp` の時刻部分（時・分）が一致するかを判定し、一致する場合は `null` を返す静的メソッド。

---

# 7. Bloc 変更

## 新規Event

**ファイル**: `flutter/lib/features/action_time/bloc/action_time_event.dart`

| Event名 | 発火タイミング | フィールド |
|---|---|---|
| `ActionTimeLogAdjustedAtUpdated` | ユーザーが時刻ピッカーで「確定」をタップしたとき | `logId: String`, `adjustedAt: DateTime` |

## 変更Event

既存Eventの変更なし。`ActionTimeLogRecorded` のdispatchロジックは変更しない。

## 新規ハンドラ

`ActionTimeBloc._onAdjustedAtUpdated`:

- `adjustedAt` を NULL 正規化（`ActionTimeAdapter.normalizeAdjustedAt` 呼び出し）
- 正規化済み値で `EventRepository.updateActionTimeLogAdjustedAt(logId, normalizedAdjustedAt)` を呼ぶ
- `_refreshState` を呼んでProjectionを再構築する

---

# 8. State 変更

**ファイル**: `flutter/lib/features/action_time/bloc/action_time_state.dart`

変更なし。Projectionのみ変更されるため、既存の `ActionTimeState` 構造を維持する。

| フィールド名 | 型 | 説明 |
|---|---|---|
| `draft` | `ActionTimeDraft` | 変更なし |
| `projection` | `ActionTimeProjection` | 内容（logItemsのisAdjusted等）が変わる |
| `delegate` | `ActionTimeDelegate?` | 変更なし |
| `isLoading` | `bool` | 変更なし |
| `errorMessage` | `String?` | 変更なし |

## Delegate 変更なし

新規Delegateの追加なし。時刻変更はボトムシート内で完結する。

---

# 9. View 変更

**ファイル**: `flutter/lib/features/action_time/view/action_time_view.dart`

## 変更箇所

### _LogItem への時刻タップ機能追加

- `_LogItem` ウィジェットの時刻ラベル（`timestampLabel`）をタップ可能にする
- タップ時に `_showTimePickerBottomSheet` を呼び出す
- `isAdjusted == true` の場合、時刻ラベルの末尾に `Icons.edit`（サイズ12）を表示する

### _showTimePickerBottomSheet（新規プライベートメソッド/ウィジェット）

- `showModalBottomSheet` で `_TimePickerSheet` を表示する
- `isDismissible: true`（スワイプで閉じられる）

### _TimePickerSheet（新規プライベートウィジェット）

- `CupertinoDatePicker` を `mode: CupertinoDatePickerMode.time` で表示する
- 初期値: ログの有効時間（`adjustedAt ?? timestamp`）
- 「確定」ボタン: `ActionTimeLogAdjustedAtUpdated` をdispatchしてボトムシートを閉じる
- 「キャンセル」ボタン: ボトムシートを閉じる（変更なし）
- ボトムシートはgo_routerを使用せずネイティブな `showModalBottomSheet` で実装する（ActionTime自体がボトムシートのため入れ子になるが、Flutterでは許容される）

---

# 10. Repository 変更

## EventRepository インターフェース（変更）

**ファイル**: `flutter/lib/repository/event_repository.dart`

新規追加メソッド:

| メソッド名 | 引数 | 戻り値 | 説明 |
|---|---|---|---|
| `updateActionTimeLogAdjustedAt` | `String logId, DateTime? adjustedAt` | `Future<void>` | 指定ログの `adjustedAt` を更新する |

## DriftEventRepository（実装追加）

**ファイル**: `flutter/lib/repository/impl/drift/repository/drift_event_repository.dart`

現在 `UnimplementedError` のメソッドを実装する:

| メソッド名 | 実装内容 |
|---|---|
| `saveActionTimeLog` | `EventDao` 経由で `action_time_logs` に upsert |
| `deleteActionTimeLog` | `EventDao` 経由で論理削除（`isDeleted = true`） |
| `fetchActionTimeLogs` | 有効時間 ASC でソートして取得（`adjusted_at ?? timestamp` の SQL表現） |
| `updateActionTimeLogAdjustedAt` | 指定 `logId` の `adjusted_at` を更新 |

## EventDao 変更

**ファイル**: `flutter/lib/repository/impl/drift/dao/event_dao.dart`

- `saveActionTimeLog`・`deleteActionTimeLog`・`fetchActionTimeLogs`・`updateActionTimeLogAdjustedAt` の実装を追加する
- Domain → drift DataClass の変換時に `adjustedAt` と `markLinkId` を含める

---

# 11. DBスキーマ変更

## 対象テーブル: action_time_logs

**ファイル**: `flutter/lib/repository/impl/drift/tables/event_tables.dart`

追加カラム:

| カラム名 | 型 | NULL許容 | デフォルト値 | 説明 |
|---|---|---|---|---|
| `adjusted_at` | `DateTimeColumn` | nullable | NULL | ユーザーが変更した時刻 |
| `mark_link_id` | `TextColumn` | nullable | NULL | 操作対象MarkLinkID（F-10で必要だが未追加だったため同時追加） |

## ActionTimeLogs Table定義（変更後）

```
action_time_logs テーブル構造:
  id TEXT NOT NULL PRIMARY KEY
  event_id TEXT NOT NULL REFERENCES events(id)
  action_id TEXT NOT NULL REFERENCES actions(id)
  timestamp INTEGER NOT NULL
  adjusted_at INTEGER          ← 新規追加
  is_deleted INTEGER NOT NULL DEFAULT 0
  created_at INTEGER NOT NULL
  updated_at INTEGER NOT NULL
  mark_link_id TEXT            ← 同時追加（F-10整合修正）
```

## マイグレーション

**ファイル**: `flutter/lib/repository/impl/drift/database.dart`

- `schemaVersion: 6` → **`schemaVersion: 7`** に変更する
- `onUpgrade` に `if (from < 7)` ブロックを追加する

マイグレーション内容:

```
if (from < 7):
  ALTER TABLE action_time_logs ADD COLUMN adjusted_at INTEGER
  ALTER TABLE action_time_logs ADD COLUMN mark_link_id TEXT
```

既存レコードの `adjusted_at` は `NULL`（変更なし扱い）。
既存レコードの `mark_link_id` は `NULL`（F-10以前の旧データ扱い）。

---

# 12. Data Flow

- ユーザーがログ一覧の時刻ラベルをタップする
- `_showTimePickerBottomSheet` が呼ばれ、CupertinoDatePicker（timeモード）がボトムシートで開く
- ユーザーが時刻を選択し「確定」をタップする
- `ActionTimeLogAdjustedAtUpdated(logId, adjustedAt)` イベントが `ActionTimeBloc` にdispatchされる
- Bloc が `ActionTimeAdapter.normalizeAdjustedAt(timestamp, adjustedAt)` を呼んで正規化する
- `EventRepository.updateActionTimeLogAdjustedAt(logId, normalizedAdjustedAt)` で永続化する
- `_refreshState` が呼ばれる
- `EventRepository.fetchActionTimeLogs(eventId)` でログを再取得する
- `ActionTimeAdapter.buildDraftAndProjection` がログを有効時間ASCでソートし、Projectionを再構築する
- `ActionTimeState` が更新され、`ActionTimeView` が再描画される
- ログ一覧は有効時間順に並び替えられ、`adjustedAt` 設定ログには編集アイコンが表示される
- アクションボタンの `lastLoggedTimeLabel` も有効時間ベースに更新される

---

# 13. ファイル変更一覧

| ファイル | 変更種別 | 内容 |
|---|---|---|
| `flutter/lib/domain/action_time/action_time_log.dart` | 変更 | `adjustedAt: DateTime?` フィールド追加・`copyWith` 更新・`props` 更新 |
| `flutter/lib/adapter/action_time_adapter.dart` | 変更 | ソートキーを有効時間に変更・`timestampLabel` 生成変更・`isAdjusted` 追加・`buttonItems` 算出変更・`normalizeAdjustedAt` 追加 |
| `flutter/lib/features/action_time/projection/action_time_projection.dart` | 変更 | `ActionTimeLogProjection` に `isAdjusted: bool` 追加 |
| `flutter/lib/features/action_time/bloc/action_time_event.dart` | 変更 | `ActionTimeLogAdjustedAtUpdated` 追加 |
| `flutter/lib/features/action_time/bloc/action_time_bloc.dart` | 変更 | `_onAdjustedAtUpdated` ハンドラ追加・`on<ActionTimeLogAdjustedAtUpdated>` 登録 |
| `flutter/lib/features/action_time/view/action_time_view.dart` | 変更 | `_LogItem` に時刻タップ機能追加・`_TimePickerSheet` 追加・編集アイコン表示追加 |
| `flutter/lib/repository/event_repository.dart` | 変更 | `updateActionTimeLogAdjustedAt` メソッド追加 |
| `flutter/lib/repository/impl/drift/tables/event_tables.dart` | 変更 | `ActionTimeLogs` に `adjusted_at`・`mark_link_id` カラム追加 |
| `flutter/lib/repository/impl/drift/database.dart` | 変更 | `schemaVersion: 7` に変更・`if (from < 7)` マイグレーション追加 |
| `flutter/lib/repository/impl/drift/dao/event_dao.dart` | 変更 | `saveActionTimeLog`・`deleteActionTimeLog`・`fetchActionTimeLogs`・`updateActionTimeLogAdjustedAt` 実装追加 |
| `flutter/lib/repository/impl/drift/repository/drift_event_repository.dart` | 変更 | 上記4メソッドの `UnimplementedError` を実際の実装に置き換え |
| `flutter/lib/repository/impl/drift/database.g.dart` | 自動生成 | `build_runner` で再生成（手動編集禁止） |
| `flutter/lib/repository/impl/drift/dao/event_dao.g.dart` | 自動生成 | `build_runner` で再生成（手動編集禁止） |

---

# 14. Widget キー一覧（Integration Test用）

命名規則: `Key('${画面名}_${要素種別}_${要素名}')` — snake_case、画面名は lowerCamelCase

| キー | ウィジェット種別 | 説明 |
|---|---|---|
| `Key('actionTime_sheet_header')` | Text | ボトムシートのヘッダー（既存） |
| `Key('actionTime_label_currentState')` | Text | 現在状態ラベル（既存） |
| `Key('actionTime_button_action_${actionId}')` | GestureDetector | アクションボタン（既存） |
| `Key('actionTime_label_lastTime_${actionId}')` | Text | ボタン内直近時刻ラベル（既存） |
| `Key('actionTime_label_noRecord_${actionId}')` | Text | ボタン内「未記録」ラベル（既存） |
| `Key('actionTime_logItem_${index}')` | ListTile | ログ一覧アイテム（既存） |
| `Key('actionTime_timeLabel_${logId}')` | GestureDetector | タップ可能な時刻ラベル（新規） |
| `Key('actionTime_icon_adjusted_${logId}')` | Icon | 時刻変更済みアイコン（新規） |
| `Key('actionTime_timePicker_sheet')` | Container | 時刻ピッカーボトムシート（新規） |
| `Key('actionTime_timePicker_confirm')` | TextButton | 「確定」ボタン（新規） |
| `Key('actionTime_timePicker_cancel')` | TextButton | 「キャンセル」ボタン（新規） |

---

# 15. テストシナリオ

## テストファイル

`flutter/integration_test/action_log_time_edit_test.dart`

## 前提条件

- iOSシミュレーターが起動済みであること
- visitWorkトピックのイベントにMarkが1件存在すること（テスト内で作成）
- ActionTimeボトムシートが開けること

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-ALTE-001 | ログの時刻ラベルをタップすると時刻ピッカーが表示される | High |
| TC-ALTE-002 | 時刻ピッカーで「キャンセル」をタップするとボトムシートが閉じて変更されない | High |
| TC-ALTE-003 | 時刻ピッカーで時刻を変更して「確定」をタップするとログの時刻が更新される | High |
| TC-ALTE-004 | 時刻変更済みのログに編集アイコンが表示される | High |
| TC-ALTE-005 | 時刻変更後のログ一覧が有効時間でソートされる | High |
| TC-ALTE-006 | 有効時間が登録時間と同じになる変更後にAdjustedAtがNULLに戻る（編集アイコン消滅） | Medium |
| TC-ALTE-007 | アクションボタンの「直近の記録」時刻が有効時間を反映する | Medium |
| TC-ALTE-008 | 時刻変更後にアプリを再起動しても変更が保持されている | High |

## シナリオ詳細

---

### TC-ALTE-001: ログの時刻ラベルをタップすると時刻ピッカーが表示される

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する
- ActionTimeボトムシートが表示されている
- アクションボタンを1回タップしてログが1件存在する

**操作手順:**
1. アクションボタン（例: 「到着」）をタップしてActionTimeLogを1件記録する
2. ログ一覧に表示された時刻ラベルをタップする

**期待結果:**
- 時刻ピッカーボトムシートが表示される（`Key('actionTime_timePicker_sheet')` が見つかる）
- ピッカー内に「確定」ボタンと「キャンセル」ボタンが表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_timeLabel_${logId}')` — タップ対象の時刻ラベル
- `Key('actionTime_timePicker_sheet')` — ピッカーボトムシート
- `Key('actionTime_timePicker_confirm')` — 「確定」ボタン
- `Key('actionTime_timePicker_cancel')` — 「キャンセル」ボタン

---

### TC-ALTE-002: 時刻ピッカーで「キャンセル」をタップするとボトムシートが閉じて変更されない

**前提:**
- ログが1件存在し、時刻ピッカーが表示されている

**操作手順:**
1. 時刻ピッカーを開く
2. 「キャンセル」ボタン（`Key('actionTime_timePicker_cancel')`）をタップする

**期待結果:**
- 時刻ピッカーボトムシートが閉じる
- ログの時刻ラベルは変更前と同じ値が表示される
- 編集アイコン（`Key('actionTime_icon_adjusted_${logId}')`）が表示されていない

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_timePicker_cancel')` — キャンセルボタン
- `Key('actionTime_logItem_0')` — ログアイテム（タイトルで時刻を確認）

---

### TC-ALTE-003: 時刻ピッカーで時刻を変更して「確定」をタップするとログの時刻が更新される

**前提:**
- ログが1件存在し、時刻ピッカーが表示されている

**操作手順:**
1. 時刻ピッカーを開く
2. CupertinoDatePicker のスクロールで時刻を変更する（元の時刻と異なる値に変更）
3. 「確定」ボタン（`Key('actionTime_timePicker_confirm')`）をタップする

**期待結果:**
- 時刻ピッカーボトムシートが閉じる
- ログ一覧の時刻ラベルが変更後の時刻（HH:mm形式）に更新される

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_timePicker_confirm')` — 確定ボタン
- `Key('actionTime_timeLabel_${logId}')` — 更新後の時刻ラベル

---

### TC-ALTE-004: 時刻変更済みのログに編集アイコンが表示される

**前提:**
- ログが1件存在し、時刻を変更済みである（TC-ALTE-003実施後の状態）

**操作手順:**
1. ログ一覧を確認する

**期待結果:**
- 時刻変更済みのログに編集アイコン（`Key('actionTime_icon_adjusted_${logId}')`）が表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_icon_adjusted_${logId}')` — 編集済みアイコン

---

### TC-ALTE-005: 時刻変更後のログ一覧が有効時間でソートされる

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する

**操作手順:**
1. ActionTimeボトムシートを開く
2. 「到着」アクションボタンをタップして1件目のログ（時刻: 現在時刻）を記録する
3. 「作業開始」アクションボタンをタップして2件目のログ（時刻: 現在時刻+数秒）を記録する
4. 1件目のログの時刻ラベルをタップして、2件目のログより後の時刻に変更して「確定」をタップする

**期待結果:**
- ログ一覧で1件目（時刻変更済み）が2件目より後に表示される（有効時間ASCソート）
- `Key('actionTime_logItem_0')` に「作業開始」のアクション名が表示される
- `Key('actionTime_logItem_1')` に「到着」のアクション名が表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_logItem_0')` — ソート後1番目のログ
- `Key('actionTime_logItem_1')` — ソート後2番目のログ

---

### TC-ALTE-006: 有効時間が登録時間と同じになる変更後にAdjustedAtがNULLに戻る（編集アイコン消滅）

**前提:**
- ログが1件存在し、時刻を変更済みである（`adjustedAt != null`）

**操作手順:**
1. 時刻変更済みのログの時刻ラベルをタップして時刻ピッカーを開く
2. 元の登録時間（`timestamp`）と同じ時刻（時・分）に戻して「確定」をタップする

**期待結果:**
- 編集アイコン（`Key('actionTime_icon_adjusted_${logId}')`）が消える
- 時刻ラベルが元の登録時間と同じ値で表示される（`adjustedAt = null` の正規化が成立）

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_icon_adjusted_${logId}')` — 消えることを確認する対象

---

### TC-ALTE-007: アクションボタンの「直近の記録」時刻が有効時間を反映する

**前提:**
- ログが1件存在し、時刻を変更済みである

**操作手順:**
1. アクションボタン（例: 「到着」）をタップして記録する
2. ログ一覧の時刻ラベルをタップして時刻を変更し「確定」する

**期待結果:**
- アクションボタン内の「直近の記録」時刻ラベル（`Key('actionTime_label_lastTime_${actionId}')`）が変更後の有効時間（HH:mm）を表示している

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_label_lastTime_${actionId}')` — ボタン内直近時刻ラベル

---

### TC-ALTE-008: 時刻変更後にアプリを再起動しても変更が保持されている

**前提:**
- ログが1件存在し、時刻を変更済みである

**操作手順:**
1. アクションボタンをタップしてログを1件記録する
2. ログ一覧の時刻ラベルをタップして時刻を変更し「確定」する
3. アプリを再起動する（`GetIt.I.reset()` → `router.go('/')` → `app.main()`）
4. 同じイベントのActionTimeボトムシートを開く

**期待結果:**
- ログ一覧に変更後の時刻が表示される
- 編集アイコン（`Key('actionTime_icon_adjusted_${logId}')`）が表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_icon_adjusted_${logId}')` — 再起動後も表示されることを確認

---

# 16. 依存関係・制約

- `ActionTimeLogRecorded` のdispatchロジック（ログ記録処理）は変更しない
- 既存の `ActionTimeBreakToggled` / `ActionTimeLogDeleted` ハンドラは変更しない
- `ActionTimeNavigateBackDelegate` の定義は変更しない（将来のユースケース残置）
- drift の `database.g.dart` および `event_dao.g.dart` は `build_runner` で自動再生成する（手動編集禁止）
- `flutter pub run build_runner build` を Table定義変更後に必ず実行する
- InMemoryEventRepository にも `updateActionTimeLogAdjustedAt` を実装する（テスト用）
- CupertinoDatePicker はmaterial widgetと混在可能。`import 'package:flutter/cupertino.dart'` を追加する

---

# 17. 備考

## DriftEventRepository の ActionTimeLog 実装について

現在 `saveActionTimeLog`・`deleteActionTimeLog`・`fetchActionTimeLogs` が `UnimplementedError` のため、本Featureで初めてdrift側のActionTimeLog永続化が動作可能になる。
本Feature実装前は InMemoryEventRepository のみが ActionTimeLog の永続化を行っている。

## fetchActionTimeLogs のソートについて

`fetchActionTimeLogs` は有効時間ASCでソートした結果を返す。
SQLiteでは `adjusted_at IS NULL` の場合に `timestamp` を使用するCASE式でソートする:
```
ORDER BY COALESCE(adjusted_at, timestamp) ASC
```
ただし実装コードの詳細はflutter-devが決定する。

## schemaVersion管理

schemaVersion の変遷:

| バージョン | 変更内容 |
|---|---|
| 1 | 初期スキーマ |
| 2 | actions テーブルにActionState関連カラム追加 / action_time_logs テーブル新規作成 |
| 3 | actions テーブルに needs_transition 追加 / topics テーブルに color 追加 |
| 4 | mark_links テーブルに gas_payer_id 追加 |
| 5 | payments テーブルに mark_link_id 追加 |
| 6 | （F-8）PaymentDetail 売上フィールド追加 |
| **7** | **action_time_logs テーブルに adjusted_at・mark_link_id 追加** |

---

# End of Feature Spec: F-9 ActionLogTimeEdit
