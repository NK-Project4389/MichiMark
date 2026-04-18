# Feature Spec: UI-19 訪問作業 Mark カード UI 改善

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-18
Requirement: `docs/Requirements/REQ-visit_work_action_ui.md`
Design Reference: `docs/Design/draft/visit_work_action_button_center_design.html`

---

# 1. Feature Overview

## Feature Name

VisitWorkActionUI

## Purpose

MichiInfo 訪問作業（visitWork）トピックの Mark カードレイアウトを改善する。
現状のカードはアクションボタン（28x28dp）と削除ボタン（36x36dp）がカード右端に密集しており誤タップリスクが高い。
左: 日付+状態バッジ / 中央: 地点名+アクションボタン / 右: 削除ボタン の3カラムレイアウトへ変更し、操作性と視認性を向上させる。
合わせて `visitWork` の「休憩」アクション削除とアクション表示順の修正も行う。

## Scope

含むもの
- `visitWork` トピック（`topicConfig.showActionTimeButton == true`）の Mark カードのみ対象とした3カラムレイアウトの実装
- `_ActionTimeButton`（⚡ボタン）のリデザイン: アイコン+「アクション」テキスト付き大型ボタンへ変更
- 削除ボタンの仕様変更: サイズ縮小・opacity 0.6・グレー系カラーへ変更
- `_ActionStateBadge` の仕様変更: 11px / semibold・padding 3px 8px・角丸 6dp・左カラムへ移動
- `TopicConfig.visitWork.markActions` から `toggleBreak` を除去し表示順を修正
- Integration Test シナリオ（TC-VWA-001〜TC-VWA-006）の定義

含まないもの
- `movingCost` / `movingCostEstimated` / `travelExpense` トピックのカードレイアウト変更
- Link（区間）カードの変更
- 状態バッジのタップ機能（アクションボタンと同機能）: 将来検討
- ダークテーマ対応
- スワイプ削除・長押しコンテキストメニューの導入
- 既存の ActionTime Bloc・状態遷移ロジックの変更

---

# 2. 設計判断

## カードレイアウト変更方針

現行の `_TimelineItemOverlay._buildMarkCardContent()` は単一の `Column` でコンテンツを積み上げる構造。
visitWork トピック（`showActionTimeButton == true`）のみ、以下の3カラム `Row` に切り替える。

| カラム | 内容 | 幅 |
|---|---|---|
| 左カラム | 日付テキスト（上）+ 状態バッジ（下） | 54dp 固定幅 |
| 中央カラム | 地点名テキスト（上）+ アクションボタン（下） | `Expanded`（残り全幅） |
| 右カラム | 削除ボタン | 28dp 固定幅 |

- `showActionTimeButton == false` のトピックは従来の `_buildMarkCardContent()` をそのまま維持する。
- タイムラインドット（紫色 10dp 円）は既存の `_MichiTimelinePainter` が担当するため変更しない。
- 削除ボタンは中央カラムに含めず右カラムに配置することで、アクションボタンとの物理的距離を確保する。

## アクションボタン（⚡ ボタン）変更方針

既存の `_ActionTimeButton`（28x28dp・アイコンのみ）を廃止し、テキスト「アクション」+ アイコンの横並びレイアウトに変更する。
新しいボタンは `_VisitWorkActionButton` として実装し、中央カラムの下部に配置する。

- タップ領域: 高さ 36dp・横方向 padding 16dp（WCAG 44dp 以上を満たすよう `InkWell` + `ConstrainedBox` で対応）
- 角丸: 10dp
- 背景色・文字色・アイコン色: `#7C3AED`（Violet）・白
- フォントサイズ: 13px / bold
- Widget キー: `Key('michiInfo_button_actionTime_${item.id}')` （マークIDを含む、既存の `Key('mark_action_button')` から変更）

## 削除ボタン変更方針

既存の削除ボタン（赤系・目立つ）をグレー系・目立たない配置に変更する。
実装上は `_TimelineItemOverlay` の右カラムに配置する。

- サイズ: 28x28dp（縮小）
- 不透明度: `Opacity(opacity: 0.6, ...)` でラップ
- アイコンサイズ: 14dp
- 背景色: `#F3F4F6`（Gray 100）
- アイコン色: `#9CA3AF`（Gray 400）
- 角丸: 6dp
- Widget キー: `Key('michiInfo_button_delete_${item.id}')` を継続使用（既存の Integration Test との互換性維持）

## 状態バッジ変更方針

既存の `_ActionStateBadge` は `_buildMarkCardContent` 内 Column の末尾に配置されている。
3カラム化後は左カラムの日付テキストの下に配置する。

- フォントサイズ: 11px（10px から変更）
- フォントウェイト: `FontWeight.w600`（`normal` から変更）
- padding: `3px 8px`（`2px 6px` から変更）
- 角丸: 6dp（4dp から変更）
- Widget キー: `Key('michiInfo_badge_actionState_${item.id}')` （マークIDを含む形式へ変更。既存の `Key('mark_action_state_badge')` から変更）

## TopicConfig 変更方針（markActions）

`TopicConfig.fromTopicType` の `visitWork` ケースで、`markActions` の内容を変更する。

| Before | After |
|---|---|
| `['visit_work_arrive', 'visit_work_depart', 'visit_work_start', 'visit_work_end']` | `['visit_work_arrive', 'visit_work_start', 'visit_work_end', 'visit_work_depart']` |

- `toggleBreak` は既存の `markActions` に含まれておらず、除去操作は不要（要件書 REQ-VWA-05 の前提確認済み）
- 変更は表示順のみ（到着→作業開始→作業終了→出発）

---

# 3. Projection 変更

このFeatureでは新規 Projection クラスの追加は不要。
`MichiInfoState.markActionStateLabels` の既存フィールドをそのまま利用する。
`MarkLinkItemProjection` への変更もなし。

---

# 4. View 変更

## 変更ファイル: `flutter/lib/features/michi_info/view/michi_info_view.dart`

### 4.1 `_TimelineItemOverlay._buildMarkCardContent` の変更

`showActionTimeButton == true`（visitWork）のとき、以下の3カラム Row を返す分岐を追加する。

**左カラム（54dp 固定幅）:**
- 日付テキスト: 既存スタイルを維持（11px・`#6B7280`・w500）
- 状態バッジ（`_ActionStateBadge`）: 日付の下に配置

**中央カラム（Expanded）:**
- 地点名テキスト: 既存スタイルを維持（13px・`#1A1A2E`・w700）
- `_VisitWorkActionButton`: 地点名の下に配置

**右カラム（28dp 固定幅）:**
- 削除ボタン: `Opacity` でラップしたグレー系ボタン

`showActionTimeButton == false` の場合は従来の Column レイアウトを維持する。

### 4.2 既存ウィジェットの変更

| ウィジェット | 変更内容 |
|---|---|
| `_ActionTimeButton` | `_VisitWorkActionButton` に置き換え（クラス名変更・サイズ・ラベル追加） |
| `_ActionStateBadge` | フォント・padding・角丸・Widget キーの更新 |
| 削除ボタン部分 | `_TimelineItemOverlay` 内の削除ボタン実装をグレー系仕様に変更 |

### 4.3 カード高さ定数

visitWork の Mark カードは3カラム構造になるが、カード高さ（`_cardHeight = 72.0`）は変更しない。
アクションボタンは中央カラム内に収まるため `_actionButtonsHeight` の加算も不要になる。

ただし、3カラムレイアウト時は `_MarkActionButtons` ウィジェット（カード下部の地点アクションボタン群）を表示しない。
`_TimelineItem.build()` 内の `hasActionButtons` フラグの判定に `showActionTimeButton` を組み合わせて制御する。

---

# 5. TopicConfig 変更

## 変更ファイル: `flutter/lib/domain/topic/topic_config.dart`

`TopicConfig.fromTopicType` の `TopicType.visitWork` ケース:

| フィールド | Before | After |
|---|---|---|
| `markActions[0]` | `'visit_work_arrive'` | `'visit_work_arrive'`（変更なし） |
| `markActions[1]` | `'visit_work_depart'` | `'visit_work_start'`（変更） |
| `markActions[2]` | `'visit_work_start'` | `'visit_work_end'`（変更） |
| `markActions[3]` | `'visit_work_end'` | `'visit_work_depart'`（変更） |

---

# 6. BLoC / State / Event 変更サマリー

| 種別 | 変更内容 |
|---|---|
| `MichiInfoBloc` | 変更なし |
| `MichiInfoState` | 変更なし |
| `MichiInfoEvent` | 変更なし |
| `MichiInfoDelegate` | 変更なし |
| `ActionTimeBloc` / `ActionTimeState` | 変更なし |

---

# 7. Data Flow

- `MichiInfoLoaded` State の `topicConfig.showActionTimeButton` が `true` のとき、View が3カラムレイアウトを描画する
- 左カラムの状態バッジは `markActionStateLabels[item.id]` を参照する（既存フロー）
- 中央カラムのアクションボタンタップ → `MichiInfoActionButtonPressed` を dispatch → `MichiInfoOpenActionTimeDelegate` → ActionTimeボトムシート表示（既存フロー）
- 右カラムの削除ボタンタップ → 確認ダイアログ → `MichiInfoCardDeleteRequested` を dispatch（既存フロー）

---

# 8. Widget キー一覧

Integration Test で使用するウィジェットキーをすべて列挙する。

| キー | 場所 | 説明 |
|---|---|---|
| `Key('michiInfo_item_mark_${markId}')` | `_TimelineItem` | Mark カード全体（既存・変更なし） |
| `Key('michiInfo_button_actionTime_${markId}')` | `_VisitWorkActionButton` | アクションボタン（⚡+テキスト）。既存 `mark_action_button` から変更 |
| `Key('michiInfo_badge_actionState_${markId}')` | `_ActionStateBadge` | 状態バッジ。既存 `mark_action_state_badge` から変更 |
| `Key('michiInfo_button_delete_${markId}')` | 削除ボタン | 削除ボタン（既存・変更なし） |
| `Key('michiInfo_text_markDate_${markId}')` | 日付テキスト | 左カラムの日付テキスト（既存・変更なし） |
| `Key('deleteConfirmDialog_dialog_confirm')` | 削除確認ダイアログ | 確認ダイアログ（既存・変更なし） |
| `Key('deleteConfirmDialog_button_cancel')` | ダイアログキャンセルボタン | （既存・変更なし） |
| `Key('deleteConfirmDialog_button_delete')` | ダイアログ削除ボタン | （既存・変更なし） |
| `Key('actionTime_sheet_header')` | ActionTimeボトムシートヘッダー | （既存・変更なし） |
| `Key('michiInfo_fab_add')` | FAB ボタン | （既存・変更なし） |

---

# 9. ファイル変更一覧

| ファイル | 変更種別 | 内容 |
|---|---|---|
| `flutter/lib/domain/topic/topic_config.dart` | 変更 | `visitWork.markActions` の表示順修正（到着→作業開始→作業終了→出発） |
| `flutter/lib/features/michi_info/view/michi_info_view.dart` | 変更 | 3カラムレイアウト実装・`_VisitWorkActionButton` 追加・`_ActionStateBadge` 仕様更新・削除ボタン仕様更新 |

---

# 10. テストシナリオ

## 10.1 テストファイル

`flutter/integration_test/visit_work_action_ui_test.dart`

## 10.2 前提条件

- iOSシミュレーター（UDID: `DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6`）が起動済みであること
- `FLAVOR=test` を指定して実行する（`--dart-define=FLAVOR=test`）
- テスト内で visitWork トピックのイベントと Mark を作成する

## 10.3 テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-VWA-001 | visitWork Mark カードが3カラムレイアウトで表示される | High |
| TC-VWA-002 | アクションボタンが中央カラムに「アクション」テキスト付きで表示される | High |
| TC-VWA-003 | 削除ボタンが右カラムに小さく・薄く表示される | High |
| TC-VWA-004 | 状態バッジが左カラムに配置される | High |
| TC-VWA-005 | アクションボタンタップでActionTimeボトムシートが開く | High |
| TC-VWA-006 | アクション表示順が「到着→作業開始→作業終了→出発」になっている | Medium |

## 10.4 シナリオ詳細

---

### TC-VWA-001: visitWork Mark カードが3カラムレイアウトで表示される

**前提:**
- visitWork トピックのイベントが存在する
- MichiInfo 画面に Mark が1件以上存在する

**操作手順:**
1. visitWork トピックのイベントを開く
2. MichiInfo タブを表示する

**期待結果:**
- Mark カードが表示される
- アクションボタン（`Key('michiInfo_button_actionTime_${markId}')`）がカード内に表示される
- 削除ボタン（`Key('michiInfo_button_delete_${markId}')`）がカード内に表示される
- 状態バッジ（`Key('michiInfo_badge_actionState_${markId}')`）がカード内に表示される

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_item_mark_${markId}')` — Mark カード全体
- `Key('michiInfo_button_actionTime_${markId}')` — アクションボタン
- `Key('michiInfo_button_delete_${markId}')` — 削除ボタン
- `Key('michiInfo_badge_actionState_${markId}')` — 状態バッジ

---

### TC-VWA-002: アクションボタンが中央カラムに「アクション」テキスト付きで表示される

**前提:**
- visitWork トピックのイベントが存在する
- MichiInfo 画面に Mark が1件以上存在する

**操作手順:**
1. visitWork トピックのイベントを開く
2. MichiInfo タブを表示する

**期待結果:**
- `Key('michiInfo_button_actionTime_${markId}')` のウィジェットが見つかる
- ウィジェット内に「アクション」テキストが表示されている（`find.text('アクション')` でヒット）

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_button_actionTime_${markId}')` — アクションボタン（⚡+テキスト）

---

### TC-VWA-003: 削除ボタンが右カラムに小さく・薄く表示される

**前提:**
- visitWork トピックのイベントが存在する
- MichiInfo 画面に Mark が1件以上存在する

**操作手順:**
1. visitWork トピックのイベントを開く
2. MichiInfo タブを表示する

**期待結果:**
- `Key('michiInfo_button_delete_${markId}')` のウィジェットが見つかる
- 削除ボタンをタップすると確認ダイアログが表示される（誤タップ防止のダイアログ動作が維持されていること）

**操作手順（削除ダイアログ確認）:**
1. 削除ボタン（`Key('michiInfo_button_delete_${markId}')`）をタップする
2. 確認ダイアログ（`Key('deleteConfirmDialog_dialog_confirm')`）が表示されることを確認する
3. キャンセルボタン（`Key('deleteConfirmDialog_button_cancel')`）をタップして戻る

**期待結果:**
- 確認ダイアログが表示される
- キャンセル後も Mark カードが残っている

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_button_delete_${markId}')` — 削除ボタン
- `Key('deleteConfirmDialog_dialog_confirm')` — 確認ダイアログ
- `Key('deleteConfirmDialog_button_cancel')` — キャンセルボタン

---

### TC-VWA-004: 状態バッジが左カラムに配置される

**前提:**
- visitWork トピックのイベントが存在する
- MichiInfo 画面に Mark が1件以上存在する（ActionTime 記録なし・初期状態）

**操作手順:**
1. visitWork トピックのイベントを開く
2. MichiInfo タブを表示する

**期待結果:**
- `Key('michiInfo_badge_actionState_${markId}')` のウィジェットが見つかる
- バッジに「滞留中」テキストが表示される（初期状態）

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_badge_actionState_${markId}')` — 状態バッジ

---

### TC-VWA-005: アクションボタンタップで ActionTime ボトムシートが開く

**前提:**
- visitWork トピックのイベントが存在する
- MichiInfo 画面に Mark が1件以上存在する

**操作手順:**
1. visitWork トピックのイベントを開く
2. MichiInfo タブを表示する
3. アクションボタン（`Key('michiInfo_button_actionTime_${markId}')`）をタップする

**期待結果:**
- ActionTime ボトムシートが開く
- ボトムシートのヘッダー（`Key('actionTime_sheet_header')`）が表示される

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_button_actionTime_${markId}')` — アクションボタン
- `Key('actionTime_sheet_header')` — ActionTime ボトムシートヘッダー

---

### TC-VWA-006: アクション表示順が「到着→作業開始→作業終了→出発」になっている

**前提:**
- visitWork トピックのイベントが存在する
- MichiInfo 画面に Mark が1件以上存在する
- ActionTime ボトムシートが表示されている

**操作手順:**
1. visitWork トピックのイベントを開く
2. MichiInfo タブを表示する
3. アクションボタン（`Key('michiInfo_button_actionTime_${markId}')`）をタップして ActionTime ボトムシートを開く

**期待結果:**
- ActionTime ボトムシート内のアクションボタンが「到着」「作業開始」「作業終了」「出発」の順に表示される
- 「休憩」ボタンが表示されない

**実装ノート（ウィジェットキー）:**
- `Key('actionTime_button_action_visit_work_arrive')` — 到着ボタン
- `Key('actionTime_button_action_visit_work_start')` — 作業開始ボタン
- `Key('actionTime_button_action_visit_work_end')` — 作業終了ボタン
- `Key('actionTime_button_action_visit_work_depart')` — 出発ボタン
- `Key('actionTime_sheet_header')` — ActionTime ボトムシートヘッダー

---

# 11. 依存関係・制約

- `_cardHeight = 72.0` は変更しない。3カラムレイアウトは既存のカード高さ内に収まるよう設計する
- `_actionButtonsHeight`（48dp）の加算はvisitWorkカードでは不要になる。`_buildTimelineData` の `hasActions` フラグ評価の際に `topicConfig.showActionTimeButton` との組み合わせで制御する
  - visitWork（`showActionTimeButton == true`）: `hasActions` を `false` として扱い `_actionButtonsHeight` を加算しない
  - 他トピック（`showActionTimeButton == false`）: 従来通り `markActionItems.isNotEmpty` で判定
- `ActionTimeBloc` / `ActionTimeState` / `ActionTimeProjection` は変更しない
- 既存の `Key('michiInfo_button_delete_${item.id}')` は変更しない（UI-23 等の既存 Integration Test との互換性維持）
- `Key('mark_action_button')` （旧アクションボタンキー）は `Key('michiInfo_button_actionTime_${markId}')` に変更される。既存テストで `mark_action_button` を参照している場合は合わせて更新が必要
- `Key('mark_action_state_badge')` （旧バッジキー）は `Key('michiInfo_badge_actionState_${markId}')` に変更される。同上
- `dart analyze` エラー・警告 0 を維持すること

---

# End of Feature Spec
