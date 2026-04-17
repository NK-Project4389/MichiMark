# Feature Spec: UI-23 MichiInfo 日付区切り表示

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-17
Requirement: `docs/Requirements/REQ-michi_info_date_separator.md`

---

# 1. Feature Overview

## Feature Name

MichiInfoDateSeparator

## Purpose

MichiInfoタイムラインのMarkiLinkカード間に日付区切り行を挿入する。
日付が変わるタイミング（前カードと異なる日付になる直前）、およびリスト先頭カードの直前に区切りウィジェットを表示し、ユーザーが旅程・作業の節目を一目でスキャンできるようにする。

## Scope

含むもの
- タイムラインリストへの日付区切りウィジェット挿入ロジック
- 日付区切りウィジェット（DateSeparatorWidget）の新規作成
- `MarkLinkItemProjection` への `dateKey` フィールド追加
- `_buildTimelineData` のY座標計算への区切り高さ加算

含まないもの
- MichiInfoBloc / Event / State / Repository の構造変更
- 曜日付きフォーマット（Phase 2以降）
- Day N 表記（Phase 2以降）
- ダークテーマ対応
- 区切りのアニメーション

---

# 2. 設計判断

## 日付情報の持ち方

`MarkLinkItemProjection` に既に `displayDate: String`（例: `"2026/03/26"`）が存在する。
この値から日付比較用キー `dateKey: String`（`yyyy/MM/dd` 形式）を導出できる。

**判断: `MarkLinkItemProjection` にフィールド追加する**

- `displayDate` は将来的にフォーマットが変わりうるため、比較専用フィールド `dateKey: String` を別途追加する
- `dateKey` は `yyyy/MM/dd` 固定フォーマットの文字列（例: `"2024/08/11"`）
- Adapterがdomain.dateから`yyyy/MM/dd`形式で算出してProjectionにセットする
- Bloc / State への変更は不要

## 区切りの挿入方式

- SliverListのアイテムリストを構築する際に、`MarkLinkItemProjection` のリストをスキャンして区切りアイテムを差し込んだ**表示用アイテムリスト**を生成する
- 表示用アイテムは sealed class `TimelineListItem` として定義し、`CardItem` と `DateSeparatorItem` の2種を持つ
- `_buildTimelineData` の Y座標計算は表示用アイテムリストを入力とし、`DateSeparatorItem` の高さ（48px）を加算する
- InsertMode（`isInsertMode == true`）のときは区切りを挿入しない（Y座標ずれ防止）

## Canvas（道路帯）との関係

- 道路帯Canvasは全体を通して描画するため、区切りウィジェットの高さをY座標計算に含める必要がある
- 区切りウィジェットはSliverListアイテムとして既存カードと同列に配置し、Canvasレイヤーは変更しない

---

# 3. 新規型定義

## TimelineListItem（表示用アイテム識別）

SliverList構築時に使用する sealed class。Widgetファイル内のローカル定義。

| バリアント | フィールド | 説明 |
|---|---|---|
| `CardItem` | `projection: MarkLinkItemProjection` | 既存のMarkまたはLinkカード |
| `DateSeparatorItem` | `dateLabel: String` | 日付区切り行（`yyyy/MM/dd`形式） |

## DateSeparatorWidget（新規ウィジェット）

| プロパティ | 型 | 説明 |
|---|---|---|
| `dateLabel` | `String` | 表示する日付テキスト（`yyyy/MM/dd`形式） |

ビジュアル仕様:
- レイアウト: `横線 ─── 日付バッジ ─── 横線`（Row構成）
- コンポーネント全高: 48px（バッジ32px + 上下余白各8px）
- 横線色: `#CBD5E1`
- バッジ背景色: `#F1F5F9`
- バッジボーダー色: `#CBD5E1`
- 日付テキスト色: `#64748B`
- 日付テキスト: fontSize 12 / fontWeight w600 / textAlign center
- バッジ角丸: 16px（pill型）、バッジ高さ: 32px

---

# 4. MarkLinkItemProjection 変更

**ファイル:** `flutter/lib/features/shared/projection/mark_link_item_projection.dart`

追加フィールド:

| フィールド名 | 型 | 説明 |
|---|---|---|
| `dateKey` | `String` | 日付比較用キー。`yyyy/MM/dd` 固定フォーマット（例: `"2024/08/11"`）。Adapterが算出してセットする |

- 既存の `displayDate` は変更しない
- `dateKey` はEquatableの `props` に追加する

---

# 5. Data Flow

- `MarkLinkDomain.date`（`DateTime`）をAdapterが `yyyy/MM/dd` 形式の文字列 `dateKey` に変換してProjectionにセットする
- `MichiInfoBloc` が `MichiInfoListProjection` を構築するとき、Projectionリストをそのまま保持する（区切り挿入ロジックはWidget層で行う）
- `_MichiInfoListState` の表示構築ロジックが `MarkLinkItemProjection` リストをスキャンし、`TimelineListItem` リスト（CardItem / DateSeparatorItem 混在）を生成する
- `isInsertMode == true` の場合は `DateSeparatorItem` を一切挿入しない
- `_buildTimelineData` は `TimelineListItem` リストを入力とし、`DateSeparatorItem` の高さ（`_dateSeparatorHeight = 48.0`）をY座標計算に加算する
- `DateSeparatorWidget` は `DateSeparatorItem` に対応するWidgetとしてSliverListで描画される

---

# 6. 区切り挿入アルゴリズム

1. `MarkLinkItemProjection` リストを上から走査する
2. 最初のアイテムの直前に必ず `DateSeparatorItem(dateLabel: items[0].dateKey)` を挿入する
3. 2番目以降のアイテムについて、直前のカードの `dateKey` と比較する
4. `dateKey` が異なる場合、そのアイテムの直前に `DateSeparatorItem` を挿入する
5. `dateKey` が同じ場合は挿入しない

---

# 7. State / Event 変更

**なし。** MichiInfoBloc / MichiInfoState / MichiInfoEvent への変更は行わない。

---

# 8. ファイル変更一覧

| ファイル | 変更種別 | 内容 |
|---|---|---|
| `flutter/lib/features/shared/projection/mark_link_item_projection.dart` | 変更 | `dateKey: String` フィールド追加 |
| `flutter/lib/features/michi_info/view/michi_info_view.dart` | 変更 | `TimelineListItem` sealed class追加、区切り挿入ロジック追加、`_buildTimelineData` Y座標計算修正、`DateSeparatorWidget` 追加 |
| Adapterファイル（MarkLinkItemProjectionを生成している箇所） | 変更 | `dateKey` の算出・セット追加 |

---

# 9. テストシナリオ

## 9.1 テストファイル

`flutter/integration_test/michi_info_date_separator_test.dart`

## 9.2 前提条件

- iOSシミュレーターが起動済みであること
- テスト用イベント・Markデータはテスト内で作成する

## 9.3 テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-DS-001 | 単一日付のMarkが1件のみのとき、先頭に区切りが表示される | High |
| TC-DS-002 | 同一日付のMarkが複数あるとき、先頭のみ区切りが表示され中間に区切りは表示されない | High |
| TC-DS-003 | 日付が変わるMarkの直前に区切りが挿入される（2日分のMarkがある場合） | High |
| TC-DS-004 | 区切りの日付テキストが `yyyy/MM/dd` 形式（例: `2024/08/11`）で表示される | High |
| TC-DS-005 | InsertMode中に区切りが非表示になる | Medium |
| TC-DS-006 | Markカード（72dp）・Linkカード（34dp）の縦幅が変化しない | Medium |
| TC-DS-007 | 道路帯Canvas（グレー帯・白破線）が区切り位置で切断されない | Medium |

## 9.4 シナリオ詳細

### TC-DS-001: 単一日付のMarkが1件のみのとき、先頭に区切りが表示される

**前提:**
- visitWorkトピックのイベントに同一日付のMarkが1件存在する

**操作手順:**
1. イベント詳細画面のミチタブを表示する

**期待結果:**
- Markカードの直上に日付区切りが1件表示される
- 区切りの日付テキストが正しい `yyyy/MM/dd` 形式で表示される

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_dateSeparator_0')` — 先頭区切り

---

### TC-DS-002: 同一日付のMarkが複数あるとき、先頭のみ区切りが表示され中間に区切りは表示されない

**前提:**
- visitWorkトピックのイベントに同一日付のMarkが2件存在する

**操作手順:**
1. イベント詳細画面のミチタブを表示する

**期待結果:**
- 先頭Markカードの直上に区切りが1件表示される
- 2件目のMarkカードの直上に区切りは表示されない
- 区切りの合計件数は1件である

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_dateSeparator_0')` — 先頭区切り

---

### TC-DS-003: 日付が変わるMarkの直前に区切りが挿入される（2日分のMarkがある場合）

**前提:**
- visitWorkトピックのイベントに日付A（1件）と日付B（1件）のMarkが存在する（日付A < 日付B）

**操作手順:**
1. イベント詳細画面のミチタブを表示する

**期待結果:**
- 日付Aのカード直上に区切りが1件表示される
- 日付Bのカード直上に区切りが1件表示される
- 区切りの合計件数は2件である

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_dateSeparator_0')` — 日付Aの区切り
- `Key('michiInfo_dateSeparator_1')` — 日付Bの区切り

---

### TC-DS-004: 区切りの日付テキストが `yyyy/MM/dd` 形式で表示される

**前提:**
- Mark日付が `2024/08/11`

**操作手順:**
1. イベント詳細画面のミチタブを表示する

**期待結果:**
- 区切りウィジェットに `2024/08/11` というテキストが表示される

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_dateSeparator_0')` — 区切りウィジェット内のテキストを `find.text('2024/08/11')` で検証する

---

### TC-DS-005: InsertMode中に区切りが非表示になる

**前提:**
- visitWorkトピックのイベントにMarkが1件以上存在する
- InsertMode（FABタップ後の状態）を有効にする

**操作手順:**
1. イベント詳細画面のミチタブを表示する
2. FABボタンをタップしてInsertModeを有効にする

**期待結果:**
- InsertMode有効中、日付区切りウィジェットが画面から消える
- `Key('michiInfo_dateSeparator_0')` が見つからない

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_button_insertModeFab')` — FABボタン
- `Key('michiInfo_dateSeparator_0')` — 区切りウィジェット

---

### TC-DS-006: Markカード・Linkカードの縦幅が変化しない

**前提:**
- visitWorkトピックのイベントにMarkが1件存在する

**操作手順:**
1. イベント詳細画面のミチタブを表示する

**期待結果:**
- Markカードが表示される
- 区切りウィジェットが表示される
- 既存のMark/Linkタップ操作（詳細画面への遷移）が正常に動作する

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_item_${markLinkId}')` — Markカード
- `Key('michiInfo_dateSeparator_0')` — 区切りウィジェット

---

### TC-DS-007: 道路帯Canvasが区切り位置で切断されない

**前提:**
- visitWorkトピックのイベントに異なる日付のMarkが2件存在する

**操作手順:**
1. イベント詳細画面のミチタブを表示する

**期待結果:**
- 日付区切りウィジェットが2件のMarkカードの間に表示される
- 道路帯（グレー帯）が区切りウィジェットを貫通して連続して表示される
- タイムライン縦線がMarkカード間で途切れない

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_dateSeparator_1')` — 2番目の区切りウィジェット
- Canvas切断の有無はスクリーンショット目視またはWidget構造確認で検証する

---

# 10. 依存関係・制約

- `MarkLinkItemProjection` の `dateKey` フィールドを既存Adapterすべてで追加する必要がある（実装時に影響範囲を確認すること）
- `isInsertMode` フラグは `MichiInfoLoaded.isInsertMode` から取得する（既存フィールド）
- `_buildTimelineData` のY座標計算は `TimelineListItem` リストを入力とするよう変更するため、既存スパン矢印・Link縦線の位置計算に影響しないことを確認すること
- 区切りウィジェットキーはリスト内のインデックス（DateSeparatorItemの出現順）で採番する: `Key('michiInfo_dateSeparator_$index')`
