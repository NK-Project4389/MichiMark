# Feature Spec: MichiInfoカード トピック別表示切り替え

Feature: MichiInfo（カード部品拡張）
Version: 1.0
作成日: 2026-04-13
要件書: docs/Requirements/REQ-michi_info_card_topic_view.md

---

## 1. Feature Overview

### Feature Name

MichiInfoカード トピック別表示切り替え（F-4）

### Purpose

MichiInfo（ミチタブ）一覧に表示されるMark（地点）カード・Link（区間）カードの表示内容を、イベントに設定されたトピック種別に応じて動的に切り替える。

- movingCost / movingCostEstimated: 日付・累積メーター・区間距離を重視した表示
- travelExpense: 名称・日付・参加メンバーを重視した表示

### Scope

含むもの
- `TopicConfig` への新規フラグ追加（`showMarkDate`、`showMarkMembers`、`showLinkDate`）
- Mark（地点）カードへの日付表示追加（全トピック）
- Mark（地点）カードへのメンバー表示追加（travelExpenseのみ）
- Link（区間）カードへの日付・区間距離表示追加（movingCost / movingCostEstimatedのみ）
- `_TimelineItemOverlay`（Widgetレイヤー）の表示ロジック変更
- テストシナリオ（TC-MCV-001〜007）

含まないもの
- MichiInfoBloc / Event / State / Delegate の構造変更
- Projection層・Domain層・Repository層の変更
- `MarkLinkItemProjection` フィールドの追加・変更
- カード高さ（`_cardHeight`・`_linkCardHeight`）の変更
- タイムラインキャンバス（`_MichiTimelinePainter`・`_MichiTimelineCanvas`）の変更
- メンバーアイコン（アバター）表示
- 給油情報の詳細数値（給油量・金額）のカード内表示

---

## 2. Feature Responsibility

- `TopicConfig`（Domain層）: 新規フラグ3件を追加する
- `_TimelineItemOverlay`（Widget層）: TopicConfigの新規フラグを参照して表示内容を切り替える
- BLoC・Projection・Repository の変更なし

---

## 3. TopicConfig 変更

### 追加フラグ

| フラグ名 | 型 | 説明 |
|---|---|---|
| `showMarkDate` | `bool` | Markカードに日付を表示するか |
| `showMarkMembers` | `bool` | Markカードに参加メンバー名を表示するか |
| `showLinkDate` | `bool` | Linkカードに日付を表示するか |

### TopicType別の設定値

| フラグ | movingCost | movingCostEstimated | travelExpense |
|---|---|---|---|
| `showMarkDate` | `true` | `true` | `true` |
| `showMarkMembers` | `false` | `false` | `true` |
| `showLinkDate` | `true` | `true` | `false` |

### 既存フラグとの対応関係（参考）

以下の既存フラグは今回のカード表示変更でも引き続き参照する。

| フラグ | Mark表示制御 | Link表示制御 |
|---|---|---|
| `showNameField` | 名称の表示/非表示 | 名称の表示/非表示 |
| `showMeterValue` | 累積メーターの表示/非表示 | - |
| `showLinkDistance` | - | 区間距離の表示/非表示 |
| `showFuelDetail` | isFuel時の給油ドット演出制御 | - |

---

## 4. Projection 定義（変更なし）

`MarkLinkItemProjection` のフィールドは変更しない。カード内で新規表示する項目は以下の既存フィールドを使用する。

| 使用フィールド | 型 | 用途 |
|---|---|---|
| `displayDate` | `String` | Markカード・Linkカードの日付表示 |
| `members` | `List<MemberItemProjection>` | Markカードのメンバー名表示 |
| `displayDistanceValue` | `String?` | Linkカードの区間距離表示 |
| `displayMeterValue` | `String?` | Markカードの累積メーター表示（既存） |
| `markLinkName` | `String` | 名称表示（既存） |
| `isFuel` | `bool` | 給油ドット演出制御（既存） |

---

## 5. Widgetレイヤー変更: `_TimelineItemOverlay`

### Mark（地点）カード 表示レイアウト

```
[カード内 Column]
  Row（最上段）
    - 日付テキスト（showMarkDate = true の場合）
  Row（次段）
    - 名称テキスト（showNameField = true の場合）
  Row（次段）
    - 累積メーターテキスト（showMeterValue = true の場合）
    - メンバーテキスト（showMarkMembers = true の場合）
  状態バッジ（showActionTimeButton = true の場合）
```

**重複表示の排除ルール:**
- showNameField = false（movingCost / movingCostEstimated）の場合: 日付を主表示として最上段に置く
- showNameField = true（travelExpense）の場合: 名称を主表示として最上段に置き、日付はその下に置く

### Link（区間）カード 表示レイアウト

```
[カード内 Row]
  Expanded（左側テキストエリア）
    - 日付テキスト（showLinkDate = true の場合）
    - 名称テキスト（showNameField = true の場合）
    - 区間距離テキスト（showLinkDistance = true かつ displayDistanceValue != null の場合）
  削除ボタン（挿入モード外）
```

### メンバー表示フォーマット（`showMarkMembers = true` のとき）

| メンバー数 | 表示形式 |
|---|---|
| 0名 | 非表示 |
| 1名 | 「田中」 |
| 2名 | 「田中・鈴木」 |
| 3名以上 | 「田中・鈴木 +2人」（先頭2名 + 残数） |

---

## 6. Widget Key 一覧

| Key | 要素 | 説明 |
|---|---|---|
| `Key('michiInfo_text_markDate_${item.id}')` | テキスト | Markカードの日付テキスト |
| `Key('michiInfo_text_markMembers_${item.id}')` | テキスト | Markカードのメンバー名テキスト |
| `Key('michiInfo_text_linkDate_${item.id}')` | テキスト | Linkカードの日付テキスト |
| `Key('michiInfo_text_linkDistance_${item.id}')` | テキスト | Linkカードの区間距離テキスト |

---

## 7. Data Flow

- MichiInfoBlocは変更なし
- `MichiInfoLoaded.topicConfig` に新規フラグ3件が追加された `TopicConfig` が格納される
- `_TimelineItemOverlay` は `topicConfig` の各フラグを参照して表示を切り替える
- `MarkLinkItemProjection` の既存フィールド（`displayDate`、`members`、`displayDistanceValue`）を参照する

---

## 8. 影響範囲まとめ

| 変更対象 | 変更種別 | 詳細 |
|---|---|---|
| `TopicConfig` | 拡張 | `showMarkDate`・`showMarkMembers`・`showLinkDate` フラグ追加 |
| `_TimelineItemOverlay` | 変更 | Mark/Linkカードの表示内容をTopicConfigフラグで制御 |
| `MichiInfoLoaded`（`michi_info_state.dart`） | 軽微な変更 | デフォルト`TopicConfig`コンストラクタ呼び出し箇所に新規フラグのデフォルト値を追加 |

---

## 9. Test Scenarios

### 前提条件

- iOSシミュレーターが起動済みであること
- テスト用イベントが登録済みであること
- トピック・Mark・Linkのシードデータが投入済みであること

### テストシナリオ一覧

| ID | シナリオ名 | 対象トピック | 優先度 |
|---|---|---|---|
| TC-MCV-001 | movingCostのMarkカードに日付が表示される | movingCost | High |
| TC-MCV-002 | movingCostのMarkカードにメンバーが表示されない | movingCost | High |
| TC-MCV-003 | movingCostのMarkカードに累積メーターが表示される | movingCost | High |
| TC-MCV-004 | movingCostのLinkカードに日付が表示される | movingCost | High |
| TC-MCV-005 | travelExpenseのMarkカードに名称が表示される | travelExpense | High |
| TC-MCV-006 | travelExpenseのMarkカードにメンバーが表示される | travelExpense | High |
| TC-MCV-007 | travelExpenseのLinkカードに日付が表示されない | travelExpense | High |

---

### TC-MCV-001: movingCostのMarkカードに日付が表示される

**前提:**
- movingCostトピックのイベントが存在する
- そのイベントにMarkが1件以上登録されている

**操作手順:**
1. movingCostトピックのイベント詳細画面を開く
2. 「ミチ」タブを表示する
3. Markカードを確認する

**期待結果:**
- `Key('michiInfo_text_markDate_${markId}')` の要素が表示されている
- 表示される日付文字列が空でない

**実装ノート:**
- Widget Key: `michiInfo_text_markDate_${markId}`

---

### TC-MCV-002: movingCostのMarkカードにメンバーが表示されない

**前提:**
- movingCostトピックのイベントが存在する
- そのイベントにメンバーが設定されたMarkが1件以上登録されている

**操作手順:**
1. movingCostトピックのイベント詳細画面を開く
2. 「ミチ」タブを表示する
3. Markカードを確認する

**期待結果:**
- `Key('michiInfo_text_markMembers_${markId}')` の要素が表示されていない（`findsNothing`）

**実装ノート:**
- Widget Key: `michiInfo_text_markMembers_${markId}`

---

### TC-MCV-003: movingCostのMarkカードに累積メーターが表示される

**前提:**
- movingCostトピックのイベントが存在する
- 累積メーター値が設定されたMarkが1件以上登録されている

**操作手順:**
1. movingCostトピックのイベント詳細画面を開く
2. 「ミチ」タブを表示する
3. Markカードを確認する

**期待結果:**
- Markカードに「〇〇 km」形式のメーター値テキストが表示されている
- （メーターテキストはProjectionの`displayMeterValue`を表示する既存要素）

**実装ノート:**
- 累積メーター表示は既存実装。本TCでは退行チェックとして確認する
- 既存の累積メーターテキストは `displayMeterValue` の内容を表示する

---

### TC-MCV-004: movingCostのLinkカードに日付が表示される

**前提:**
- movingCostトピックのイベントが存在する
- そのイベントにLinkが1件以上登録されている

**操作手順:**
1. movingCostトピックのイベント詳細画面を開く
2. 「ミチ」タブを表示する
3. Linkカードを確認する

**期待結果:**
- `Key('michiInfo_text_linkDate_${linkId}')` の要素が表示されている
- 表示される日付文字列が空でない

**実装ノート:**
- Widget Key: `michiInfo_text_linkDate_${linkId}`

---

### TC-MCV-005: travelExpenseのMarkカードに名称が表示される

**前提:**
- travelExpenseトピックのイベントが存在する
- 名称が設定されたMarkが1件以上登録されている

**操作手順:**
1. travelExpenseトピックのイベント詳細画面を開く
2. 「ミチ」タブを表示する
3. Markカードを確認する

**期待結果:**
- Markカードに登録した名称テキストが表示されている（既存の名称表示要素）
- Markカードに `Key('michiInfo_text_markDate_${markId}')` の日付も表示されている

**実装ノート:**
- 名称表示は既存実装。本TCでは日付と同時表示の確認を行う
- Widget Key: `michiInfo_text_markDate_${markId}`

---

### TC-MCV-006: travelExpenseのMarkカードにメンバーが表示される

**前提:**
- travelExpenseトピックのイベントが存在する
- 参加メンバーが1名以上設定されたMarkが1件以上登録されている

**操作手順:**
1. travelExpenseトピックのイベント詳細画面を開く
2. 「ミチ」タブを表示する
3. Markカードを確認する

**期待結果:**
- `Key('michiInfo_text_markMembers_${markId}')` の要素が表示されている
- 表示されるテキストにメンバー名が含まれている

**実装ノート:**
- Widget Key: `michiInfo_text_markMembers_${markId}`

---

### TC-MCV-007: travelExpenseのLinkカードに日付が表示されない

**前提:**
- travelExpenseトピックのイベントが存在する
- そのイベントにLinkが1件以上登録されている

**操作手順:**
1. travelExpenseトピックのイベント詳細画面を開く
2. 「ミチ」タブを表示する
3. Linkカードを確認する

**期待結果:**
- `Key('michiInfo_text_linkDate_${linkId}')` の要素が表示されていない（`findsNothing`）

**実装ノート:**
- Widget Key: `michiInfo_text_linkDate_${linkId}`

---

## 10. SwiftUI版との対応

| Flutter Feature | 対応SwiftUI実装 |
|---|---|
| MichiInfo カード部品 | SwiftUI版 MarkLinkCardView（トピック別表示切り替えロジック） |

SwiftUI版では各カードがトピックに応じた表示を持つ実装がReducer内に組み込まれていた。Flutter版では `TopicConfig` フラグによる制御に統一し、Widgetはフラグのみ参照する。

---

# End of Feature Spec
