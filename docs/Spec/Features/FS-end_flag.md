# Feature Spec: F-10 EndFlag機能（訪問作業 出発=完了）

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-17
Requirement: `docs/Requirements/REQ-end_flag.md`

---

# 1. Feature Overview

## Feature Name

EndFlag

## Purpose

`ActionDomain` に `endFlag: bool` フィールドを追加し、EndFlag=trueのアクションが記録されたMarkカードをMichiInfo上で「完了」ビジュアルに切り替える機能を実装する。
訪問作業トピック（visitWork）では「出発」アクションをEndFlag=trueとして定義し、「出発」が記録されたMarkを完了状態（グレーアウト＋「✓ 完了」バッジ）で表示する。

## Scope

含むもの
- `ActionDomain` への `endFlag: bool` フィールド追加
- Driftテーブル `actions` への `end_flag` カラム追加（DBマイグレーション: schemaVersion 6）
- `ActionTimeLog` への `markLinkId: String?` フィールド追加（DBマイグレーション: schemaVersion 6）
- `action_time_logs` テーブルへの `mark_link_id` カラム追加（同上）
- visitWork シードデータ「出発」アクションの `endFlag: true` 定義
- `MarkLinkItemProjection` への `isDone: bool` フィールド追加
- MichiInfoBlocの `projection` 生成時に `isDone` を算出するロジック追加
- MichiInfoViewの完了ビジュアル切り替え実装
- `_MichiTimelinePainter`（Canvas）への `isDone` フラグ渡しとドット色・接続線色分岐

含まないもの
- EndFlag設定UI（Phase 2以降）
- 完了状態の取り消し（undone）操作
- 訪問作業以外のトピックでのEndFlag定義
- ダークテーマ対応
- 完了アニメーション

---

# 2. 設計判断

## ActionTimeLog への markLinkId 追加の必要性

**現状の問題:**
`ActionTimeLog` は `eventId` のみを持ち、どのMarkLinkカードに対するアクション記録かの情報がない。
複数のMarkカードが存在するイベントで、各Markの「出発」完了状態を個別に判定できない。

**判断: `ActionTimeLog` に `markLinkId: String?` を追加する**

- `action_time_logs` テーブルに `mark_link_id TEXT` カラムを追加（nullable。既存ログとの後方互換性確保）
- `ActionTimeLog` ドメインクラスに `markLinkId: String?` を追加する
- `ActionTimeBloc._onLogRecorded` が ActionTimeLog を保存するとき、現在操作対象の `markLinkId` を `ActionTimeDraft` から取得してセットする
- 既存ログ（`markLinkId == null`）は `isDone` 判定の対象外とする

## markLinkId を ActionTimeDraft に持たせる

- `ActionTimeDraft` に `markLinkId: String?` フィールドを追加する
- `ActionTimeStarted` Eventに `markLinkId: String?` を追加し、BlocがDraftに保持する
- `MichiInfoOpenActionTimeDelegate` は既に `markLinkId` を持っているため、ボトムシート起動時にActionTimeBlocへ渡せる

## isDone の算出ロジック

判定ロジック（Adapterで実装）:
1. 対象MarkLinkId（`markLinkId`）を持つ `ActionTimeLog` のうち、`isDeleted == false` のものを抽出する
2. それらのログに紐づく `ActionDomain`（`actionId` で引く）の中に `endFlag: true` のものが1件以上存在すれば `isDone: true`
3. いずれも `endFlag: false` ならば `isDone: false`
4. EndFlagアクションが複数種類定義された場合も「いずれかが存在すれば完了」とする

## DBマイグレーション判断

以下の2カラム追加が必要であるため、`schemaVersion` を 5 → 6 に上げる。

| テーブル | カラム | 型 | 説明 |
|---|---|---|---|
| `actions` | `end_flag` | `BOOLEAN NOT NULL DEFAULT 0` | EndFlagフラグ |
| `action_time_logs` | `mark_link_id` | `TEXT` (nullable) | 操作対象MarkLinkのID |

## visitWork シードデータのEndFlag定義

「出発」アクションID `visit_work_depart` の `endFlag: true` を定義する。
既存データへの反映: `onUpgrade`（from < 6）で `UPDATE actions SET end_flag = 1 WHERE id = 'visit_work_depart'` を実行する。

---

# 3. Domain 変更

## ActionDomain 変更

**ファイル:** `flutter/lib/domain/master/action/action_domain.dart`

追加フィールド:

| フィールド名 | 型 | デフォルト | 説明 |
|---|---|---|---|
| `endFlag` | `bool` | `false` | trueのとき、このアクションが記録されたMarkを「完了」とみなす |

- `copyWith` に `endFlag` パラメータを追加する
- `Equatable.props` に `endFlag` を追加する

## ActionTimeLog 変更

**ファイル:** `flutter/lib/domain/action_time/action_time_log.dart`

追加フィールド:

| フィールド名 | 型 | デフォルト | 説明 |
|---|---|---|---|
| `markLinkId` | `String?` | `null` | 操作対象のMarkLinkID。null=既存ログ（完了判定対象外） |

- `copyWith` に `markLinkId` パラメータを追加する
- `Equatable.props` に `markLinkId` を追加する

---

# 4. DBスキーマ変更

## actions テーブル

| カラム | 型 | デフォルト | 説明 |
|---|---|---|---|
| `end_flag` | `BOOLEAN NOT NULL DEFAULT 0` | `false` | EndFlagフラグ |

Driftクラス変更:
```
// Actions テーブルに追加
BoolColumn get endFlag => boolean().withDefault(const Constant(false))();
```

## action_time_logs テーブル

| カラム | 型 | デフォルト | 説明 |
|---|---|---|---|
| `mark_link_id` | `TEXT` (nullable) | `null` | 操作対象のMarkLinkID |

Driftクラス変更:
```
// ActionTimeLogs テーブルに追加
TextColumn get markLinkId => text().nullable()();
```

## マイグレーション (onUpgrade from < 6)

1. `ALTER TABLE actions ADD COLUMN end_flag INTEGER NOT NULL DEFAULT 0`
2. `ALTER TABLE action_time_logs ADD COLUMN mark_link_id TEXT`
3. `UPDATE actions SET end_flag = 1 WHERE id = 'visit_work_depart'`

---

# 5. ActionTimeDraft 変更

**ファイル:** `flutter/lib/features/action_time/draft/action_time_draft.dart`

追加フィールド:

| フィールド名 | 型 | デフォルト | 説明 |
|---|---|---|---|
| `markLinkId` | `String?` | `null` | ボトムシートを開いた対象MarkLinkのID。ログ保存時にActionTimeLogにセットする |

---

# 6. ActionTimeEvent 変更

`ActionTimeStarted` Event に `markLinkId: String?` フィールドを追加する。

| フィールド名 | 型 | 説明 |
|---|---|---|
| `markLinkId` | `String?` | 操作対象のMarkLinkID（visitWorkトピックで使用） |

`MichiInfoOpenActionTimeDelegate` は既に `markLinkId: String` を保持しているため、ボトムシート起動時に `ActionTimeStarted` にそのまま渡す。

---

# 7. MarkLinkItemProjection 変更

**ファイル:** `flutter/lib/features/shared/projection/mark_link_item_projection.dart`

追加フィールド:

| フィールド名 | 型 | デフォルト | 説明 |
|---|---|---|---|
| `isDone` | `bool` | `false` | trueのとき完了ビジュアルを適用する |

- `copyWithMeterDiff` メソッドに `isDone` を引き継ぐよう変更する
- `Equatable.props` に `isDone` を追加する

---

# 8. isDone 算出フロー

`MichiInfoBloc` は `_onStarted` および `_onReloadRequested` でデータをロードする際に以下の情報を取得済みである:
- `EventDomain.markLinks`（各MarkLinkのID一覧）
- `ActionTimeLog`（イベントのログ一覧、`markLinkId` つき）
- `ActionDomain`（全アクション、`endFlag` つき）

Adapter（`EventDetailAdapter` または新規メソッド）で以下を算出する:
1. `endFlag: true` のアクションIDセットを生成する
2. `ActionTimeLog` リストを `markLinkId` でグループ化する
3. 各 `MarkLinkId` について、`endFlagActionIdSet` に含まれる `actionId` を持つログが1件以上あれば `isDone: true`

---

# 9. MichiInfoView 完了ビジュアル

`MarkLinkItemProjection.isDone == true` のMarkカードに以下のビジュアルを適用する。
Widgetレイヤーの変更のみで実現する。

## カード本体

| 要素 | 通常 | 完了（isDone=true） |
|---|---|---|
| カード背景色 | `#FFFFFF` | `#F9FAFB`（Gray 50） |
| カードボーダー色 | `#E9ECEF` | `#D1D5DB` |
| 上辺カラーライン色 | `#2B7A9B`（Teal） | `#9CA3AF`（Gray 400） |
| 地点名テキスト色 | `#1A1A2E` | `#9CA3AF` + lineThrough |
| 日時・その他テキスト色 | `#6C757D` | `#ADB5BD` |

## 完了バッジ（カード右上）

- テキスト: `✓ 完了`
- バッジ背景色: `#F3F4F6`（Gray 100）
- バッジボーダー色: `#D1D5DB`
- テキスト: fontSize 10 / fontWeight w700 / color `#6B7280`（Gray 500）
- `isDone == false` のときは非表示

## タイムラインドット（Canvas）

`_MichiTimelinePainter`（または相当するCanvasクラス）に `isDone` フラグを渡し、以下を分岐する:

| 要素 | 通常 | 完了（isDone=true） |
|---|---|---|
| ドット色 | `#2B7A9B` | `#9CA3AF` |
| ドット内チェックマーク | なし | 白色 `✓` |
| 接続線色 | `#2B7A9B` | `#D1D5DB` |

実装方針: 既存の `isFuel` フラグと同様の追加方法でCanvasの描画パラメータを拡張する。

---

# 10. Data Flow

- `ActionTimeStarted(eventId, markLinkId: ...)` → BlocがDraftに `markLinkId` を保持する
- `ActionTimeLogRecorded(actionId)` → BlocがActionTimeLogを生成するとき `draft.markLinkId` をセットして保存する
- `MichiInfoReloadRequested` / `MichiInfoStarted` → BlocがActionTimeLogs+ActionDomainsを取得する
- Adapter が各 MarkLinkId について `isDone` を算出して `MarkLinkItemProjection` にセットする
- `MichiInfoLoaded` の `projection.items` に `isDone: true` のアイテムが含まれる
- `_MichiInfoList` が各カードの `isDone` を参照してビジュアルを分岐する

---

# 11. State / Event 変更サマリー

| 種別 | 変更内容 |
|---|---|
| `ActionDomain` | `endFlag: bool`（デフォルト: false）追加 |
| `ActionTimeLog` | `markLinkId: String?` 追加 |
| `ActionTimeDraft` | `markLinkId: String?` 追加 |
| `ActionTimeStarted` | `markLinkId: String?` フィールド追加 |
| `MarkLinkItemProjection` | `isDone: bool`（デフォルト: false）追加 |
| `ActionTimeState` | 変更なし |
| `MichiInfoState` | 変更なし（Projectionの中身が変わる） |
| `MichiInfoEvent` | 変更なし |
| DBスキーマ | `actions.end_flag`、`action_time_logs.mark_link_id` カラム追加（schemaVersion 6） |

---

# 12. ファイル変更一覧

| ファイル | 変更種別 | 内容 |
|---|---|---|
| `flutter/lib/domain/master/action/action_domain.dart` | 変更 | `endFlag: bool` 追加 |
| `flutter/lib/domain/action_time/action_time_log.dart` | 変更 | `markLinkId: String?` 追加 |
| `flutter/lib/features/action_time/draft/action_time_draft.dart` | 変更 | `markLinkId: String?` 追加 |
| `flutter/lib/features/action_time/bloc/action_time_event.dart` | 変更 | `ActionTimeStarted` に `markLinkId: String?` 追加 |
| `flutter/lib/features/action_time/bloc/action_time_bloc.dart` | 変更 | ログ保存時に `markLinkId` をセット |
| `flutter/lib/features/shared/projection/mark_link_item_projection.dart` | 変更 | `isDone: bool` 追加 |
| `flutter/lib/adapter/event_detail_adapter.dart` | 変更 | `isDone` 算出ロジック追加 |
| `flutter/lib/features/michi_info/view/michi_info_view.dart` | 変更 | 完了ビジュアル分岐、Canvas `isDone` フラグ追加 |
| `flutter/lib/repository/impl/drift/tables/master_tables.dart` | 変更 | `Actions` に `endFlag` カラム追加 |
| `flutter/lib/repository/impl/drift/tables/event_tables.dart` | 変更 | `ActionTimeLogs` に `markLinkId` カラム追加 |
| `flutter/lib/repository/impl/drift/database.dart` | 変更 | `schemaVersion: 6`、`onUpgrade (from < 6)` 追加、シードデータ更新 |
| `flutter/lib/repository/impl/drift/dao/event_dao.dart` | 変更 | `markLinkId` を含むActionTimeLog保存・読み込みに対応 |
| `flutter/lib/repository/impl/drift/repository/drift_action_repository.dart` | 変更 | `endFlag` を含むActionDomain変換に対応 |
| `flutter/lib/features/michi_info/view/michi_info_view.dart` | 変更 | `_showActionTimeBottomSheet` で `markLinkId` を `ActionTimeStarted` に渡す |

---

# 13. テストシナリオ

## 13.1 テストファイル

`flutter/integration_test/end_flag_test.dart`

## 13.2 Unit Test

`flutter/test/domain/end_flag/end_flag_isDone_test.dart`

### Unit テストシナリオ

| ID | シナリオ | 検証内容 |
|---|---|---|
| TC-EF-U001 | endFlagアクション（出発）のログがあるとき isDone == true | `isDone` 算出ロジックが正しく true を返す |
| TC-EF-U002 | endFlagアクションのログがないとき isDone == false | `isDone` 算出ロジックが正しく false を返す |
| TC-EF-U003 | ログの `markLinkId` が null（既存ログ）のとき isDone == false | nullログを判定対象外にする |
| TC-EF-U004 | 複数MarkLink の中で、endFlagログを持つMarkLinkだけ isDone == true | 他のMarkLinkに影響しない |

## 13.3 Integration Testシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-EF-I001 | 「出発」アクションを記録するとMarkカードが完了ビジュアル（グレーアウト）に変わる | High |
| TC-EF-I002 | 完了カードの右上に「✓ 完了」バッジが表示される | High |
| TC-EF-I003 | 完了カードのタップ操作（詳細画面遷移）が引き続き動作する | High |
| TC-EF-I004 | 「出発」を記録していないMarkカードは通常のTeal系ビジュアルのまま | High |
| TC-EF-I005 | 複数Markがあるとき、「出発」を記録したMarkのみ完了ビジュアルになる | High |
| TC-EF-I006 | 「出発」以外のアクション（到着・作業開始等）を記録してもカードが完了ビジュアルにならない | Medium |

## 13.4 シナリオ詳細

### TC-EF-I001: 「出発」アクションを記録するとMarkカードが完了ビジュアルに変わる

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する
- 当該Markに対するActionTimeLogが存在しない（未完了状態）

**操作手順:**
1. イベント詳細画面のミチタブを表示する
2. Markカードの⚡ボタンをタップしてActionTimeボトムシートを開く
3. 「出発」アクションボタンをタップする
4. ボトムシートを閉じる
5. ミチタブを確認する

**期待結果:**
- Markカードの背景が `#F9FAFB`（グレー）に変化している
- Markカードの上辺カラーラインが `#9CA3AF`（グレー）に変化している
- Markカードの地点名テキストに打ち消し線が表示されている

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_button_actionTime_${markLinkId}')` — ⚡ボタン
- `Key('actionTime_button_action_visit_work_depart')` — 「出発」ボタン
- `Key('michiInfo_item_${markLinkId}')` — Markカード
- `Key('actionTime_sheet_close')` — ボトムシート閉じるボタン

---

### TC-EF-I002: 完了カードの右上に「✓ 完了」バッジが表示される

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する
- 当該Markの「出発」ActionTimeLogが既に記録されている（TC-EF-I001の続き、またはデータ準備）

**操作手順:**
1. イベント詳細画面のミチタブを表示する

**期待結果:**
- Markカードの右上に「✓ 完了」バッジが表示される
- バッジテキストが確認できる

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_badge_done_${markLinkId}')` — 「✓ 完了」バッジ

---

### TC-EF-I003: 完了カードのタップ操作が引き続き動作する

**前提:**
- visitWorkトピックのイベントにMarkが1件存在し、「出発」が記録されている（完了状態）

**操作手順:**
1. イベント詳細画面のミチタブを表示する
2. 完了状態のMarkカードをタップする

**期待結果:**
- MarkDetail画面に遷移する
- MarkDetail画面のコンテンツが表示される

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_item_${markLinkId}')` — 完了状態のMarkカード
- `Key('markDetail_field_name')` — MarkDetail画面の名称フィールド（遷移確認用）

---

### TC-EF-I004: 「出発」を記録していないMarkカードは通常のTeal系ビジュアルのまま

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する
- ActionTimeLogが存在しない（または「出発」以外のログのみ存在する）

**操作手順:**
1. イベント詳細画面のミチタブを表示する

**期待結果:**
- 「✓ 完了」バッジが表示されない
- Markカードの背景が白色で表示される

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_badge_done_${markLinkId}')` — 存在しないことを確認（findsNothing）

---

### TC-EF-I005: 複数Markがあるとき、「出発」を記録したMarkのみ完了ビジュアルになる

**前提:**
- visitWorkトピックのイベントにMarkが2件存在する（markA / markB）
- markAの「出発」ActionTimeLogが記録されている
- markBのActionTimeLogは存在しない

**操作手順:**
1. イベント詳細画面のミチタブを表示する

**期待結果:**
- markAカードが完了ビジュアル（グレーアウト + 「✓ 完了」バッジ）で表示される
- markBカードが通常ビジュアル（Teal系）で表示される

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_badge_done_${markAId}')` — markAの完了バッジ（存在する）
- `Key('michiInfo_badge_done_${markBId}')` — markBの完了バッジ（存在しない: findsNothing）

---

### TC-EF-I006: 「出発」以外のアクションを記録してもカードが完了ビジュアルにならない

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する

**操作手順:**
1. ActionTimeボトムシートを開く
2. 「到着」アクションボタンをタップする
3. ボトムシートを閉じる
4. ミチタブを確認する

**期待結果:**
- 「✓ 完了」バッジが表示されない
- Markカードが通常ビジュアルのまま

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_button_action_visit_work_arrive')` — 「到着」ボタン
- `Key('michiInfo_badge_done_${markLinkId}')` — バッジ（findsNothing）

---

# 14. 依存関係・制約

- DB schemaVersion を 5 → 6 に変更する。`onUpgrade (from < 6)` で2つのALTER TABLE + 1つのUPDATE文を実行する
- `ActionTimeStarted` の `markLinkId` 追加により、呼び出し側（`MichiInfoView._showActionTimeBottomSheet`）を更新する必要がある
- `ActionTimeDraft.markLinkId` が `null` のまま（旧コード経路やlink操作）でも `ActionTimeLog.markLinkId = null` として保存され、isDone判定では無視される設計にする
- `MarkLinkItemProjection.isDone` はMarkタイプ（`MarkOrLink.mark`）のみに意味を持つ。Linkカードは常に `isDone: false` とする
- Canvas（`_MichiTimelinePainter`）への `isDone` フラグ追加は既存の `isFuel` フラグ追加パターンに準拠する
