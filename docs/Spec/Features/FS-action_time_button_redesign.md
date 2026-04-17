# Feature Spec: UI-24 ActionTime アクションボタン大型化

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-17
Requirement: `docs/Requirements/REQ-action_time_button_redesign.md`

---

# 1. Feature Overview

## Feature Name

ActionTimeButtonRedesign

## Purpose

ActionTimeボトムシート内のアクションボタンを、現行の `ElevatedButton + Wrap` レイアウトから、等幅スクエア角丸の大型グリッドボタンへリデザインする。
各ボタンに「アクション名（上部）＋ 直近の押下時刻（下部・大きめ表示）」を表示し、モバイル操作性と状況把握の即時化を両立する。
あわせてボタン押下時にボトムシートを閉じない動作へ変更する。

## Scope

含むもの
- `ActionTimeView` のアクションボタン部分のレイアウト変更（Wrap → Row/GridView）
- `ActionButtonProjection` 新規追加（アクション名・直近押下時刻ラベル）
- `ActionTimeProjection` への `buttonItems: List<ActionButtonProjection>` 追加
- ActionTimeAdapterの `buttonItems` 算出ロジック追加（ログ一覧からアクションIDごとに最新タイムスタンプを逆引き）
- ボトムシート閉じない動作への変更（`ActionTimeNavigateBackDelegate` の発火タイミング変更）

含まないもの
- `ActionTimeLogRecorded` のdispatchロジックの変更
- 既存の状態遷移ロジック・ログ記録ロジックの変更
- ボタン数が5以上のデザイン対応（Phase 2以降）
- 長押しによる確認ダイアログ
- ダークテーマ対応

---

# 2. 設計判断

## 直近押下時刻（lastLoggedAt）の管理場所

**判断: Projectionに持たせる（`ActionButtonProjection`）**

- `ActionTimeDraft` は `List<ActionTimeLog> logs` を既に保持している
- Adapterがログ一覧をアクションIDでグループ化し、各アクションの最新タイムスタンプを算出して `ActionButtonProjection.lastLoggedTimeLabel` にセットする
- `ActionTimeDraft` / `ActionTimeState` への変更は不要
- BLoC State内で管理する場合、アクション数分の `Map<String, DateTime?>` を保持する必要があり複雑になるため不採用

## ボタン数による表示切り替え

- 4ボタン以下: `Row + Expanded` で等幅横並び
- 5ボタン以上: `Wrap` フォールバック（要件書REQ-ATB-01に従う）
- ボタン数の判定は `ActionButtonProjection` リストの件数で行う（Widget層）

## ボトムシートを閉じない動作変更

**判断: `ActionTimeNavigateBackDelegate` の発火をやめ、View側で閉じる処理を削除する**

- 現行: `ActionTimeLogRecorded` 処理後に `ActionTimeNavigateBackDelegate` を emit → `BlocListener` が `Navigator.of(context).pop()` を呼ぶ
- 変更後: `ActionTimeLogRecorded` 処理後に Delegate を emit しない（`ActionTimeNavigateBackDelegate` を使用しない）
- ボトムシートを閉じる操作はユーザーのスワイプ・閉じるボタンのみとする
- `ActionTimeNavigateBackDelegate` 自体は将来の他のユースケースのために定義は残す

---

# 3. Projection 変更

## ActionButtonProjection（新規追加）

**ファイル:** `flutter/lib/features/action_time/projection/action_time_projection.dart`

| フィールド名 | 型 | 説明 |
|---|---|---|
| `actionId` | `String` | アクションID |
| `actionName` | `String` | アクション名（表示用） |
| `lastLoggedTimeLabel` | `String?` | 直近の押下時刻（`HH:mm`形式）。履歴なし時は `null` |
| `isLastPressed` | `bool` | 最後に押したアクションかどうか（アクティブ状態の表示制御に使用） |

## ActionTimeProjection 変更

**既存フィールドはそのまま維持。** 以下のフィールドを追加する。

| フィールド名 | 型 | 説明 |
|---|---|---|
| `buttonItems` | `List<ActionButtonProjection>` | アクションボタン表示用Projection一覧。表示順はTopicConfig.markActions順に従う |

---

# 4. Adapter 変更

**ファイル:** `flutter/lib/features/action_time/adapter/action_time_adapter.dart`（既存Adapterまたは相当ファイル）

`buttonItems` の算出ロジック:
- `ActionTimeDraft.logs`（`List<ActionTimeLog>`）を `actionId` でグループ化する
- 各 `actionId` について `timestamp` が最大のログを特定し `lastLoggedAt: DateTime?` を取得する
- 全ログ中で `timestamp` が最大のログの `actionId` を `lastPressedActionId` とする
- `TopicConfig.markActions` のIDリスト順（または `availableActions` の順）に `ActionButtonProjection` を生成する
- `lastLoggedTimeLabel` は `lastLoggedAt` を `HH:mm` 形式の文字列に変換する。`null` の場合は `null` のまま

---

# 5. View 変更

**ファイル:** `flutter/lib/features/action_time/view/action_time_view.dart`

変更箇所:

1. **アクションボタン部分の置き換え:**
   - 既存の `Wrap + ElevatedButton` を `_ActionButtonGrid` ウィジェットに置き換える
   - `_ActionButtonGrid` は `buttonItems` を受け取り、件数に応じて `Row` または `Wrap` で描画する
   - 各ボタンは `_ActionButton` ウィジェット（新規）として実装する

2. **ボトムシートを閉じない動作変更:**
   - `BlocListener` 内の `ActionTimeNavigateBackDelegate` に対する `Navigator.of(context).pop()` 処理を削除する
   - `MichiInfoView._showActionTimeBottomSheet` における ActionTime Bloc の状態リスンロジックは変更しない

---

# 6. _ActionButton ビジュアル仕様

| 状態 | 背景色 | ボーダー色 | ボーダー幅 |
|---|---|---|---|
| 通常（未アクティブ） | `#FFFFFF` | `#E9ECEF` | 1.5px |
| アクティブ（最後に押したボタン） | `#F5F3FF` | `#7C3AED` | 1.5px |

ボタン内レイアウト（上→下）:
1. アクション名テキスト: fontSize 12 / fontWeight w700 / color `#1A1A2E`（最大2行折り返し可）
2. 区切り線: height 1px / color `#E9ECEF`（アクティブ時 `#C4B5FD`）/ margin 4px 8px
3. 直近の押下時刻: fontSize 18 / fontWeight w700 / color `#7C3AED` / HH:mm形式
   - 押下履歴なし時は「未記録」テキスト: fontSize 11 / italic / color `#ADB5BD`
4. 「直近の記録」ラベル: fontSize 9 / fontWeight Regular / color `#ADB5BD`（押下履歴ありのとき表示）

ボタンサイズ: 高さ 88px / 角丸 14px / 内側パディング top 12px / horizontal 4px / bottom 10px
ボタン間隔: 8px

---

# 7. Data Flow

- `ActionTimeLogRecorded` → Bloc がログを保存 → `ActionTimeDraft.logs` を更新する
- Adapter が `draft.logs` をスキャンしてアクションIDごとに最新タイムスタンプを逆引きし `ActionButtonProjection` を生成する
- `ActionTimeProjection.buttonItems` が更新される → `ActionTimeView` が再描画される
- ボタン押下後もボトムシートは閉じず、`buttonItems` の `lastLoggedTimeLabel` と `isLastPressed` が更新されてUIに反映される

---

# 8. State / Event 変更サマリー

| 種別 | 変更内容 |
|---|---|
| `ActionTimeProjection` | `buttonItems: List<ActionButtonProjection>` を追加 |
| `ActionButtonProjection` | 新規追加（上記フィールド定義参照） |
| `ActionTimeDraft` | 変更なし |
| `ActionTimeState` | 変更なし（Projectionのみ変更） |
| `ActionTimeEvent` | 変更なし |
| `ActionTimeDelegate` | `ActionTimeNavigateBackDelegate` は定義を残すが発火しない |

---

# 9. ファイル変更一覧

| ファイル | 変更種別 | 内容 |
|---|---|---|
| `flutter/lib/features/action_time/projection/action_time_projection.dart` | 変更 | `ActionButtonProjection` 追加、`ActionTimeProjection` に `buttonItems` 追加 |
| `flutter/lib/features/action_time/view/action_time_view.dart` | 変更 | `_ActionButtonGrid` / `_ActionButton` 追加、Wrap→Row切り替えロジック追加、BlocListenerからNavigateBack処理削除 |
| Adapter（`action_time_adapter.dart` 相当） | 変更 | `buttonItems` 算出ロジック追加 |

---

# 10. テストシナリオ

## 10.1 テストファイル

`flutter/integration_test/action_time_button_redesign_test.dart`

## 10.2 前提条件

- iOSシミュレーターが起動済みであること
- visitWorkトピックのイベントにMarkが存在すること（テスト内で作成）

## 10.3 テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-ATB-001 | アクションボタンが横一列・等幅で並んで表示される | High |
| TC-ATB-002 | 押下履歴がないアクションボタンに「未記録」テキストが表示される | High |
| TC-ATB-003 | アクションボタンを押しても ActionTimeボトムシートが閉じない | High |
| TC-ATB-004 | アクションボタンを押すとActionTimeLogが記録される | High |
| TC-ATB-005 | アクションボタンを押すと直近の押下時刻（HH:mm）が更新される | High |
| TC-ATB-006 | 最後に押したボタンがアクティブ状態（Violet背景・ボーダー）で表示される | Medium |
| TC-ATB-007 | アクションを連続して記録できる（ボトムシートが閉じないため） | Medium |

## 10.4 シナリオ詳細

### TC-ATB-001: アクションボタンが横一列・等幅で並んで表示される

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する
- ActionTimeボトムシートが表示されている

**操作手順:**
1. MichiInfoのMarkカード上の⚡ボタンをタップしてActionTimeボトムシートを開く

**期待結果:**
- アクションボタンが横一列に複数個並んで表示される
- 各ボタン内にアクション名テキストが表示される
- 各ボタン内に「未記録」テキストが表示される（押下履歴なし）

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_button_action_${actionId}')` — 各アクションボタン
- `Key('actionTime_label_noRecord_${actionId}')` — 「未記録」テキスト

---

### TC-ATB-002: 押下履歴がないアクションボタンに「未記録」テキストが表示される

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する
- ActionTimeLogが1件も存在しない

**操作手順:**
1. ActionTimeボトムシートを開く

**期待結果:**
- すべてのアクションボタンに「未記録」テキストが表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_label_noRecord_${actionId}')` — 「未記録」ラベル（アクションIDごと）

---

### TC-ATB-003: アクションボタンを押してもActionTimeボトムシートが閉じない

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する
- ActionTimeボトムシートが表示されている

**操作手順:**
1. ActionTimeボトムシートを開く
2. 「到着」アクションボタンをタップする

**期待結果:**
- ボトムシートが閉じずに表示されたままである
- `Key('actionTime_sheet_header')` が引き続き見つかる

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_sheet_header')` — ボトムシートのヘッダー部分
- `Key('actionTime_button_action_visit_work_arrive')` — 「到着」ボタン

---

### TC-ATB-004: アクションボタンを押すとActionTimeLogが記録される

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する

**操作手順:**
1. ActionTimeボトムシートを開く
2. 「到着」アクションボタンをタップする

**期待結果:**
- 現在状態ラベルが更新される（「到着」に対応する状態に変わる）
- ログセクションに「到着」ログが追加されて表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_button_action_visit_work_arrive')` — 「到着」ボタン
- `Key('actionTime_label_currentState')` — 現在状態ラベル
- `Key('actionTime_logItem_0')` — 最初のログアイテム

---

### TC-ATB-005: アクションボタンを押すと直近の押下時刻（HH:mm）が更新される

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する

**操作手順:**
1. ActionTimeボトムシートを開く
2. 「到着」アクションボタンをタップする

**期待結果:**
- 「到着」ボタン内の「未記録」テキストが消える
- 「到着」ボタン内に `HH:mm` 形式の時刻テキストが表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_button_action_visit_work_arrive')` — 「到着」ボタン
- `Key('actionTime_label_lastTime_visit_work_arrive')` — 直近時刻ラベル

---

### TC-ATB-006: 最後に押したボタンがアクティブ状態で表示される

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する

**操作手順:**
1. ActionTimeボトムシートを開く
2. 「到着」アクションボタンをタップする

**期待結果:**
- 「到着」ボタンがアクティブ状態（Violet系背景）で表示される
- 他のボタンは通常状態（白背景）で表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_button_action_visit_work_arrive')` — 「到着」ボタン（アクティブ状態検証）

---

### TC-ATB-007: アクションを連続して記録できる

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する

**操作手順:**
1. ActionTimeボトムシートを開く
2. 「到着」アクションボタンをタップする
3. ボトムシートが表示されたままであることを確認する
4. 「作業開始」アクションボタンをタップする

**期待結果:**
- ボトムシートが閉じずに2回のアクション記録が完了する
- ログセクションに「到着」「作業開始」の2件が表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_button_action_visit_work_arrive')` — 「到着」ボタン
- `Key('actionTime_button_action_visit_work_start')` — 「作業開始」ボタン
- `Key('actionTime_logItem_0')` / `Key('actionTime_logItem_1')` — ログアイテム

---

# 11. 依存関係・制約

- `ActionTimeNavigateBackDelegate` の定義は削除しない（将来のユースケース残置）
- ボトムシートを閉じない変更は `MichiInfoView` の `BlocListener` 内の削除のみ。`ActionTimeBloc` のDelegateロジックを変更する方法でも実現できるが、BlocはNavigationを知らない設計原則に従い、View側のみ変更する
- `buttonItems` の順序は `ActionTimeDraft.availableActions` の順（TopicConfigのmarkActions順）に準拠する
- 既存の `availableActions` フィールドは `ActionTimeDraft` に残す（互換性維持）
- `ActionTimeView` は `buttonItems` と `availableActions` の両方を参照できるが、ボタン描画は `buttonItems` を優先して使用する
