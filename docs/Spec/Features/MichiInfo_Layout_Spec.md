# Feature Spec: MichiInfo レイアウト変更

Feature: MichiInfo
Version: 3.0
作成日: 2026-04-04
更新日: 2026-04-07
要件書: docs/Requirements/REQ-michi_info_layout.md / REQ-michi_info_timeline_redesign.md

---

## 変更履歴

| Version | 日付 | 変更内容 |
|---|---|---|
| 1.0 | 2026-04-04 | 初版。CustomPaint 分散型タイムラインレイアウトを定義 |
| 2.0 | 2026-04-07 | Widget 構造を統合 CustomPainter + Stack overlay に変更。`cardHeight` 定数導入。テストシナリオ追加 |
| 3.0 | 2026-04-07 | タイムライン UI 再設計。三角ポインター廃止・罫線接続に変更。縦線をカード高さ範囲内に短縮。距離表示をマーク間スパン矢印形式に変更。距離エリア2段構造（Link距離列 + スパン矢印列）を新設。C案（Stack + GlobalKey）からB案（CustomScrollView + SliverList）に実装方針を変更 |

---

## 1. Feature Overview

### Feature Name

MichiInfo タイムライン UI 再設計（マーク間スパン矢印・罫線接続型）

### Purpose

MichiInfo「ミチ」タブのタイムライン表示を以下の3点で改善する。

1. Mark カードとドットの接続を三角ポインター（吹き出し）から水平罫線に変更し、視覚的にシンプルかつ整合感のある表示にする
2. タイムライン縦線をカード高さ範囲内に短縮し、行間の余白感を改善する
3. 距離表示をマーク間スパン矢印形式に変更し、Mark 間・区間間・混在パターンの距離を直感的に把握できるようにする

### Scope

含むもの
- `_MichiTimelinePainter` の変更（三角ポインター廃止、罫線接続に変更、縦線短縮）
- `_MichiInfoList` の `ListView.builder` を `CustomScrollView` + `SliverList` に置き換え
- `_MichiTimelineCanvas`（新設）: `CustomScrollView` の背景レイヤーとして配置する全体 CustomPainter。Mark 間スパン矢印を描画する
- `_TimelineItem` の幅レイアウト変更（Mark カードと Link カードで幅を分ける）
- 距離表示エリアの2段構造化（Link 個別距離列 + スパン矢印列）
- `_LinkDistanceCell`（新設）: Link 行右側の個別区間距離表示 Widget
- `_SpanArrowOverlay`（廃止）: B案では `_MichiTimelineCanvas` に統合するため不要
- `_DistanceLegend` の凡例文言更新
- テストシナリオ追加（TS-08 〜 TS-16）

含まないもの
- MichiInfoBloc / Event / State / Delegate の構造変更
- Projection 層・Domain 層・Repository 層の変更
- `MarkLinkItemProjection` フィールドの追加・変更
- Mark / Link タップ操作（詳細画面への遷移）
- `_MarkActionButtons` の変更
- FAB の変更
- ダークテーマ対応
- アニメーション
- 距離単位の切り替え

---

## 2. Feature Responsibility（v3.0 変更分）

- `_MichiInfoList`（Widget層）: `CustomScrollView` + `SliverList` 構成に変更。`Stack` で `_MichiTimelineCanvas`・`SliverList`・`_DistanceLegend` を重ねる
- `_MichiTimelineCanvas`（新設 Widget層 CustomPainter）: `CustomScrollView` の背景レイヤーとして `Positioned.fill` で配置。タイムライン全体のスパン矢印を単一描画コンテキストで描画する
- `_TimelineItem`（Widget層）: Mark / Link の幅差異に対応した Row 構成に変更する
- `_MichiTimelinePainter`（Widget層内 CustomPainter）: 三角ポインターを廃止し、Mark の接続を水平罫線に変更する。縦線描画範囲をカード高さ内に限定する
- `_LinkDistanceCell`（新設 Widget層）: Link 行の右側距離エリア（Link 個別距離列）に区間距離と矢印を表示する

BLoC・Projection・Repository の変更なし。

---

## 3. 定数定義（v3.0 追加・変更）

v2.0 の `_cardHeight` を維持し、以下を追加する。

| 定数名 | 型 | 値 | 説明 |
|---|---|---|---|
| `_cardHeight` | `double` | `72.0` | 1カードの固定高さ（v2.0 から維持） |
| `_markCardRightInset` | `double` | `80.0` | Mark カード右端の内側余白。スパン矢印列幅分を確保する |
| `_linkDistanceColumnWidth` | `double` | `64.0` | Link 個別距離列の固定幅 |
| `_spanArrowColumnWidth` | `double` | `72.0` | Mark 間スパン矢印列の固定幅 |
| `_distanceAreaTotalWidth` | `double` | `136.0` | 距離表示エリア合計幅（`_linkDistanceColumnWidth` + `_spanArrowColumnWidth`） |

### カード幅の設計

- Mark カード: 画面幅 - タイムライン軸幅 - `_spanArrowColumnWidth`（スパン矢印列のみ右に確保）
- Link カード: 画面幅 - タイムライン軸幅 - `_distanceAreaTotalWidth`（Link距離列 + スパン矢印列を右に確保）
- Mark カードは Link カードより横幅が広くなる

### アイテム高さの事前計算

`_MarkActionButtons` が存在する Mark アイテムはカード本体（`_cardHeight`）にボタン領域の高さが加算される。`_MichiTimelineCanvas` がスパン矢印の Y 座標を算出する際に、各アイテムの実際の高さを事前に積算してオフセットを導出する。

- `_MarkActionButtons` なし: アイテム高さ = `_cardHeight`
- `_MarkActionButtons` あり: アイテム高さ = `_cardHeight` + ボタン領域高さ（定数 `_actionButtonsHeight` で管理）

---

## 4. Projection 定義（変更なし）

v2.0 からの変更なし。以下のフィールドをそのまま利用する。

### MarkLinkItemProjection（利用フィールド）

| フィールド名 | 型 | 利用箇所 |
|---|---|---|
| `displayMeterDiff` | `String?` | スパン矢印列に表示する Mark 間合計距離。Mark アイテムのみ設定される |
| `displayDistanceValue` | `String?` | Link 個別距離列に表示する区間距離。Link アイテムのみ設定される |

Projection への新フィールド追加は不要。

---

## 5. 設計判断

### 5-1. 三角ポインターから罫線接続への変更

v2.0 では Mark カードの接続に `_pointerWidth = 20.0` の三角形を描画していた。
v3.0 では三角形を廃止し、タイムライン軸（`_axisX`）からカード左端まで水平罫線を描画する。

採用理由:
- 三角形が不要になることでカード内テキストの左余白を削減できる
- Link の接続線（水平線）と同じ描画パターンに統一でき、`_MichiTimelinePainter` の分岐が減る

### 5-2. 縦線のカード高さ内への短縮

v2.0 では縦線が行全体の高さ（0 〜 `size.height`）で描画されていた。
v3.0 では縦線をカード高さ範囲内（行の上端〜カード上端、カード下端〜行の下端）に限定し、`SliverList` のアイテム間スペースには縦線を描画しない。

実現方法:
- `SliverList` の各アイテム高さは `_cardHeight`（+ `_MarkActionButtons` 分）で管理する
- 縦線の描画範囲は上端 `0` 〜 `centerY - _dotRadius`（Mark 上半分）、`centerY + _dotRadius` 〜 `_cardHeight`（Mark 下半分）に限定する
- Link の場合も縦線を `0` 〜 `cardTop`、`cardBottom` 〜 `_cardHeight` の範囲のみに制限する

### 5-3. Mark 間スパン矢印の描画方針（B案採用）

採用方針: **B案（CustomScrollView + SliverList + `_MichiTimelineCanvas`）**

#### 候補と比較

| 案 | 概要 | 採用可否 | 理由 |
|---|---|---|---|
| A案 | 各 Mark 行が高さ×行数で矢印を自前描画 | 不採用 | `_cardHeight` 固定の前提が `_MarkActionButtons` の存在で崩れる。行数×固定高さでの座標計算に誤差リスクがある |
| B案 | `CustomScrollView` + `SliverList` + 全体 Canvas | **採用** | 単一描画コンテキストで全行の Y 座標を管理できる。`GlobalKey` + スクロール追従実装が不要。`_MarkActionButtons` の高さも事前計算でオフセット導出できる |
| C案 | Stack オーバーレイ CustomPainter + `GlobalKey` | 不採用 | `GlobalKey` + `NotificationListener<ScrollNotification>` によるスクロール追従実装が複雑。描画タイミングのズレが生じやすい |

#### B案の実装概要

- `MichiInfoView` は `EventDetailPage` の `Expanded` 内に配置されており、`CustomScrollView` への変更は `michi_info_view.dart` 内に完全に閉じる（他 Widget への影響ゼロ）
- `ListView.builder` を `CustomScrollView` + `SliverList` に置き換える
- タイムライン全体を描画する `_MichiTimelineCanvas`（CustomPainter）を `CustomScrollView` の背景レイヤーとして配置し、スパン矢印をここで描画する
- 各アイテムの `_TimelineItem` は引き続き個別の Widget として構成する
- スパン矢印の描画座標は各アイテムの高さを積算して算出する（`_cardHeight` × index ベース + `_MarkActionButtons` 補正）
- `_MichiTimelineCanvas` はスクロール位置を受け取り、スパン矢印の描画 Y 座標をオフセット補正する

### 5-4. パターン判定ロジックの配置（課題2）

採用方針: **Widget 層（`SliverList` の index ベースで導出）**

設計憲章は Projection を「表示整形専用・ロジックを持たない」と定義している。
「次の Mark まで何件 Link があるか」の計算はリスト構造を走査するロジックであり、Projection への追加は憲章違反となる。

Widget 層の `SliverList` において `items` を先読みし、各アイテムに以下を渡す:
- `spanLinkCount`: この Mark から次の Mark まで連続する Link の件数（Mark アイテムのみ。0 の場合はパターン1）
- パターン判定は `spanLinkCount` と `item.markLinkType` の組み合わせで決定する

### 5-5. 距離表示エリアの幅構造（課題3）

採用方針: **固定幅2段構造**（Link 個別距離列 64px + スパン矢印列 72px）

- Link 個別距離列（`_linkDistanceColumnWidth = 64.0`）: パターン2・3・4の Link 行に区間距離と小矢印を表示する。Mark 行では空欄とする
- スパン矢印列（`_spanArrowColumnWidth = 72.0`）: パターン1・3・4で Mark 間スパン矢印と合計距離を表示する。`_MichiTimelineCanvas` が描画する

この2段構造により:
- パターン1（Mark-Mark）: スパン矢印列のみ使用。Link 個別距離列は空欄
- パターン2（Link-Link）: Link 個別距離列のみ使用。スパン矢印列は空欄
- パターン3（Mark-Link-Mark）: Link 行は Link 個別距離列を使用。スパン矢印列に複数行スパンの矢印を描画
- パターン4（Mark-Link-Link-Mark）: パターン3と同様。Link が複数行でもスパン矢印列は1本の矢印で表現する

### 5-6. v2.0 から維持する設計判断

- 5-1（CustomPainter 統合方針）: 維持
- 5-2（Stack overlay 分離方針）: 維持（ただし Stack の重ね対象が変わる）
- 5-3（`_MarkGroup` の廃止）: 維持
- 5-4（メーター差分計算場所 = Adapter 層）: 維持
- 5-5（距離凡例の配置 = Stack Positioned）: 維持

---

## 6. 距離表示パターン定義

### パターン1：Mark 間（Link なし）

```
[Mark カード（幅広）           ]          ↕ 80 km
[Mark カード（幅広）           ]
```

- Mark 行の右側スパン矢印列に両方向矢印と `displayMeterDiff` を表示
- Link 個別距離列は空欄
- `spanLinkCount = 0` の Mark で適用

### パターン2：Link 行のみ連続（Mark 間に Link が来る区間外）

```
[Link カード（短め）   ] ↕ 80 km |
[Link カード（短め）   ] ↕ 80 km |
```

- 各 Link 行の Link 個別距離列に `displayDistanceValue` と小矢印を表示
- スパン矢印列は空欄
- 直前 / 直後に Mark がない Link 行、またはスパン矢印が必要ない Link 行で適用

### パターン3：Mark - Link×1 - Mark

```
[Mark カード（幅広）           ]        ↑
[Link カード（短め）   ] ↕ 79km |  80 km
[Mark カード（幅広）           ]        ↓
```

- 最右スパン矢印列: 開始 Mark 行から終了 Mark 行までまたがる矢印と `displayMeterDiff`（開始 Mark の値）
- Link 行の Link 個別距離列: `displayDistanceValue` と小矢印
- `spanLinkCount = 1` の Mark で適用

### パターン4：Mark - Link×2以上 - Mark

```
[Mark カード（幅広）           ]             ↑
[Link カード（短め）   ] ↕ 79km |       160 km
[Link カード（短め）   ] ↕ 81km |
[Mark カード（幅広）           ]             ↓
```

- 最右スパン矢印列: 開始 Mark 行から終了 Mark 行までまたがる矢印と `displayMeterDiff`（開始 Mark の値）
- 各 Link 行の Link 個別距離列: `displayDistanceValue` と小矢印
- `spanLinkCount >= 2` の Mark で適用

---

## 7. Widget 構造（v3.0 B案）

### ウィジェット分割

```
_MichiInfoList                              // Scaffold 全体
  ├── Stack
  │     ├── CustomScrollView                // タイムライン全体のスクロール
  │     │     └── SliverList               // タイムラインアイテムのリスト
  │     │           └── _TimelineItem      // 1行（Mark または Link）の統合ウィジェット
  │     │                 ├── CustomPaint  // 全ビジュアル要素（_MichiTimelinePainter v3.0）
  │     │                 └── overlay（Row）// テキスト・距離列・タップ領域
  │     │                       ├── _TimelineItemOverlay  // カード内テキスト・タップ
  │     │                       └── _LinkDistanceCell     // Link行のみ: 区間距離表示
  │     ├── _MichiTimelineCanvas            // CustomScrollView の背景レイヤー（Positioned.fill）
  │     │     （Mark間スパン矢印を全体 CustomPainter で描画）
  │     └── _DistanceLegend                // 右上固定の凡例
```

> 注: `_MichiTimelineCanvas` は `Stack` 内で `CustomScrollView` の背後（下層）に配置し、スパン矢印のみを描画する。スクロール位置は `ScrollController` 経由で受け取る。

### 各 Widget の責務と引数（v3.0 変更・追加分）

#### `_MichiInfoList`（変更）

- 責務: `CustomScrollView` + `SliverList` 構成への変更。`Stack` で `_MichiTimelineCanvas`・`CustomScrollView`・`_DistanceLegend` を重ねる。`ScrollController` を管理し `_MichiTimelineCanvas` にスクロール位置を渡す。空リスト時のメッセージ表示。FAB 表示
- 引数: `MichiInfoListProjection projection`、`TopicConfig topicConfig`、`List<ActionItemProjection> markActionItems`
- `ScrollController` は `_MichiInfoList` が所有し、`CustomScrollView` と `_MichiTimelineCanvas` の両方に渡す

#### `_TimelineItem`（変更）

- 責務: Mark / Link の幅差異に対応した `Row` 構成
- 引数:
  - `MarkLinkItemProjection item`
  - `bool isFirst`、`bool isLast`
  - `bool isLinkActive`（縦線太線判定）
  - `bool isSpanLink`（この Link がスパン区間内かどうか。パターン3・4に該当する Link 行で `true`）
  - `VoidCallback onTap`
  - `List<ActionItemProjection> markActionItems`
- `GlobalKey` は不要（B案では `_MichiTimelineCanvas` が高さ積算で座標を算出するため）

#### `_MichiTimelinePainter`（変更）

- 責務: 三角ポインターを廃止し、Mark の接続を水平罫線で描画する。縦線描画範囲をカード高さ内に限定する
- フィールド（v2.0 から変更なし）:
  - `MarkOrLink markLinkType`
  - `bool isFirst`、`bool isLast`
  - `bool isLinkActive`
  - `Color cardBgColor`、`Color lineColor`
- 変更点:
  - `_pointerWidth`・`_pointerHeight` を廃止する（三角ポインター廃止）
  - Mark・Link ともに `_axisX` からカード左端まで水平罫線を描画する（`_connectorLineLength` で統一）
  - 縦線の描画 Y 範囲を 0 〜 `_cardHeight` 内に限定する（行間スペースには描画しない）
  - `_cardLeft` を統一値に変更する（三角ポインター分の余白が不要になるため）
- カード幅: Mark は `size.width - _cardLeft - _spanArrowColumnWidth`、Link は `size.width - _cardLeft - _distanceAreaTotalWidth`

#### `_MichiTimelineCanvas`（新設）

- 責務: `CustomScrollView` の背景レイヤーとして配置し、Mark 間スパン矢印を単一描画コンテキストで描画する CustomPainter
- フィールド:
  - `List<SpanArrowData> spans`: スパン矢印の描画データリスト
  - `double scrollOffset`: `ScrollController` から受け取る現在のスクロールオフセット
  - `Color arrowColor`
  - `Color textColor`
- `SpanArrowData` は以下のフィールドを持つ値オブジェクト:
  - `double startY`: スパン開始 Mark のリスト内 Y 座標（スクロールオフセット前の絶対位置）
  - `double endY`: スパン終了 Mark のリスト内 Y 座標（スクロールオフセット前の絶対位置）
  - `String distanceText`: 表示する距離文字列（`displayMeterDiff`）
- 座標算出: 各アイテムの高さ（`_cardHeight` または `_cardHeight + _actionButtonsHeight`）を積算してオフセットを導出する
- スクロール更新: `ScrollController` のリスナーから `scrollOffset` を更新し `setState` で再描画する
- `_SpanArrowOverlay`（C案の Widget）は廃止。本 Widget がその役割を担う

#### `_LinkDistanceCell`（新設）

- 責務: Link 行の Link 個別距離列（幅 `_linkDistanceColumnWidth = 64.0`）に `displayDistanceValue` と小矢印を表示する
- 引数:
  - `MarkLinkItemProjection item`（Link アイテムのみ）
- 表示: 中央配置。`_VerticalArrowPainter` と `displayDistanceValue` テキスト（`bodySmall`・`outline` 色）

#### `_DistanceLegend`（変更）

- 責務: 新しい距離表示形式に合わせた凡例を表示する
- 変更点: 「メーター差分」を「Mark間合計」に、「区間距離」を「区間距離（Link）」に更新する

---

## 8. `_MichiTimelinePainter` 変更仕様（v2.0 との差分）

### 廃止する定数

- `_pointerWidth`: 三角ポインターの幅（廃止）
- `_pointerHeight`: 三角ポインターの高さ（廃止）

### 変更する定数

- `_cardLeft`: Mark・Link ともに同一の値に統一する（三角ポインター分の余白が不要になるため値が変わる）

### 縦線の描画範囲変更

v2.0 では縦線を `Offset(_axisX, 0)` から `Offset(_axisX, size.height)` まで描画していた。
v3.0 では以下に変更する:

- 上半分: `Offset(_axisX, 0)` 〜 `Offset(_axisX, dotTop または cardTop)` のみ描画
- 下半分: `Offset(_axisX, dotBottom または cardBottom)` 〜 `Offset(_axisX, _cardHeight)` のみ描画
- `size.height` ではなく `_cardHeight` を使用する（`SliverList` のアイテム間スペースが縦線に含まれない）

### Mark 接続の変更

v2.0: 三角ポインターパス（`_pointerWidth`・`_pointerHeight` を使用）
v3.0: `_axisX` からカード左端まで水平罫線（Link の接続線と同じ描画パターン）

---

## 9. パターン判定ロジック（Widget 層）

`SliverList` の `itemBuilder` 内で以下の計算を行う。

`_buildSpanLinkCount(items, index)`:
- `items[index].markLinkType` が `MarkOrLink.mark` の場合のみ計算する
- `index + 1` から順に `MarkOrLink.link` が連続する件数を数える
- 次の `MarkOrLink.mark` または末尾に達したら停止する
- Link の件数を `spanLinkCount` として保持する（スパン矢印の行数計算に使用）

`_buildIsSpanLink(items, index)`:
- `items[index].markLinkType` が `MarkOrLink.link` の場合のみ計算する
- `index - 1` を遡り、直近の `MarkOrLink.mark` を探す
- その Mark の `spanLinkCount > 0`（= 次に Mark が存在する）であれば `true` を返す

### SpanArrowData の生成

`_MichiInfoList` の build 時点（またはデータ更新時）に全アイテムを走査し、`List<SpanArrowData>` を事前計算して `_MichiTimelineCanvas` に渡す。

各 `SpanArrowData.startY` / `endY` は以下で算出する:
- アイテム i の累積 Y オフセット = `items[0..i-1]` の各アイテム高さの合計
- アイテム高さ = `_cardHeight`（`_MarkActionButtons` なし）または `_cardHeight + _actionButtonsHeight`（あり）
- Mark アイテムの場合は累積オフセット + `_cardHeight / 2` を中心 Y とする

---

## 10. Data Flow（v3.0 B案）

```
MichiInfoLoaded.projection（MichiInfoListProjection）
  ↓
_MichiInfoList
  ├── ScrollController（スクロールオフセット管理）
  ├── CustomScrollView + SliverList
  │     ├── spanLinkCount / isSpanLink / SpanArrowData の計算（Widget層・index ベース）
  │     └── _TimelineItem
  │           ├── CustomPaint（_MichiTimelinePainter v3.0）
  │           │     ← cardBgColor / lineColor / isLinkActive / isFirst / isLast /
  │           │       markLinkType（カード幅決定用）
  │           └── overlay（Row）
  │                 ├── _TimelineItemOverlay（テキスト・onTap）
  │                 └── _LinkDistanceCell（Link行のみ: displayDistanceValue）
  └── _MichiTimelineCanvas（Positioned.fill・背景レイヤー）
        ← List<SpanArrowData>（高さ積算で算出した Y 座標 + displayMeterDiff）
        ← scrollOffset（ScrollController から）
```

Projection・BLoC 層のデータフローは v2.0 から変更なし。

---

## 11. 変更対象ファイル

| ファイルパス | 変更種別 | 内容 |
|---|---|---|
| `lib/features/michi_info/view/michi_info_view.dart` | 変更 | `_MichiTimelinePainter` の三角ポインター廃止・縦線短縮。`ListView.builder` を `CustomScrollView` + `SliverList` に置き換え。`_MichiTimelineCanvas` 新設（Mark 間スパン矢印の全体 CustomPainter）。`_LinkDistanceCell` 新設。`_DistanceLegend` 文言更新。距離エリア幅定数追加。`_SpanArrowOverlay` 廃止 |

変更しないファイル:
- `MichiInfoBloc` / Event / State / Delegate クラス定義
- `MarkLinkItemProjection` / `MichiInfoListProjection` クラス定義
- `EventDetailAdapter.toProjection` のシグネチャ
- Router 定義

---

## 12. SwiftUI 版との対応（v3.0 B案）

| SwiftUI 構造 | Flutter 対応構造 |
|---|---|
| `Canvas { context, size in }` | `CustomPaint(painter: _MichiTimelinePainter(...))` |
| `ZStack { Canvas; SwiftUI View }` | `Stack( children: [ CustomPaint, overlay Widget ] )` |
| `cardHeight: CGFloat = 72` | `_cardHeight: double = 72.0` |
| スパン矢印を ZStack オーバーレイで描画 | `_MichiTimelineCanvas` を `Positioned.fill` で配置 |
| `GeometryReader` で Y 座標取得 | 高さ積算（`_cardHeight` × index + `_actionButtonsHeight` 補正）で Y 座標算出 |

---

## 13. テストシナリオ

v2.0 の TS-01 〜 TS-07 を維持し、v3.0 で以下を追加する。

### TS-01: タイムラインの基本表示（v2.0 から維持）

- 前提: Mark と Link を含むイベントの MichiInfo タブを開く
- 検証:
  - Mark 行が表示され、名称テキストが見える
  - Link 行が表示され、名称テキストが見える
  - 画面右上に凡例（`_DistanceLegend`）が表示されている

### TS-02: メーター差分の表示（v2.0 から維持）

- 前提: メーター値が設定された Mark が2件以上あるイベントの MichiInfo タブを開く
- 検証:
  - 2件目以降の Mark 行にメーター差分テキスト（例: "+150 km"）が表示されている
  - 先頭 Mark 行にはメーター差分が表示されない

### TS-03: Mark タップで詳細画面に遷移（v2.0 から維持）

- 前提: Mark が1件以上あるイベントの MichiInfo タブを開く
- 操作: 表示されている Mark 行をタップする
- 検証: MarkDetail 画面に遷移する

### TS-04: Link タップで詳細画面に遷移（v2.0 から維持）

- 前提: Link が1件以上あるイベントの MichiInfo タブを開く
- 操作: 表示されている Link 行をタップする
- 検証: LinkDetail 画面に遷移する

### TS-05: 地点追加フローの動作（v2.0 から維持）

- 前提: MichiInfo タブを開く
- 操作: FAB をタップし「地点を追加」を選択する
- 検証: MarkDetail 画面（新規追加）に遷移する

### TS-06: 空リスト時のメッセージ表示（v2.0 から維持）

- 前提: Mark / Link が0件のイベントの MichiInfo タブを開く
- 検証: 「地点/区間がありません」のメッセージが表示されている

### TS-07: MarkDetail 保存後に一覧が更新される（v2.0 から維持）

- 前提: MichiInfo タブを開く
- 操作: Mark 行をタップし MarkDetail 画面を開く → 名称を変更して保存する
- 検証: MichiInfo タブに戻り、変更後の名称が表示されている

### TS-08: Mark カードが Link カードより横幅が広い

- 前提: Mark と Link を含むイベントの MichiInfo タブを開く
- 検証: Mark カードの右端と Link カードの右端が異なる位置にある（Mark カードが右まで広がっている）

### TS-09: パターン1（Mark - Mark）のスパン矢印と距離表示

- 前提: Mark が2件連続し、その間に Link が存在せず、両 Mark にメーター値が設定されているイベントの MichiInfo タブを開く
- 検証:
  - 2件目の Mark 行の右側スパン矢印列にメーター差分テキストが表示されている
  - Link 個別距離列の位置には何も表示されていない
  - スパン矢印（両方向矢印）がスパン矢印列に描画されている

### TS-10: パターン2（Link 行の個別距離表示）

- 前提: `displayDistanceValue` が設定された Link が1件以上あるイベントの MichiInfo タブを開く
- 検証:
  - Link 行の右側 Link 個別距離列に区間距離テキストが表示されている
  - スパン矢印列には何も表示されていない

### TS-11: パターン3（Mark - Link×1 - Mark）のスパン矢印と距離表示

- 前提: Mark、Link×1、Mark の順に並び、両 Mark にメーター値が設定されているイベントの MichiInfo タブを開く
- 検証:
  - Link 行の右側 Link 個別距離列に区間距離テキストが表示されている
  - スパン矢印列に Mark 間スパン矢印と `displayMeterDiff` テキストが表示されている
  - スパン矢印が開始 Mark 行から終了 Mark 行までの高さにまたがって描画されている

### TS-12: パターン4（Mark - Link×2 - Mark）のスパン矢印と距離表示

- 前提: Mark、Link×2、Mark の順に並び、両 Mark にメーター値が設定されているイベントの MichiInfo タブを開く
- 検証:
  - 各 Link 行の右側にそれぞれ区間距離テキストが表示されている
  - スパン矢印列に Mark 間スパン矢印と `displayMeterDiff` テキスト（合計）が表示されている
  - スパン矢印が開始 Mark 行から終了 Mark 行までの高さにまたがって描画されている

### TS-13: Mark カードの接続が罫線になっている（視覚確認）

- 前提: Mark が1件以上あるイベントの MichiInfo タブを開く
- 検証: Mark 行に三角形のポインターが表示されていない（ビジュアル的確認は手動）

### TS-14: スクロール後もスパン矢印の表示が崩れない

- 前提: Mark、Link×3、Mark の順で並ぶイベントの MichiInfo タブを開く（スクロールが必要なアイテム数）
- 操作: リストを下方向にスクロールする
- 検証:
  - スクロール後もスパン矢印列が正しい位置に描画されている
  - スパン矢印の開始 Y・終了 Y がアイテムの描画位置と一致している（ズレがない）
  - 距離テキストがスパン矢印の中間位置に表示されている

### TS-15: `_MarkActionButtons` があるアイテムを含む場合のスパン矢印座標

- 前提: `markActionItems` が1件以上存在する設定で、Mark（アクションボタンあり）、Link×1、Mark の順に並ぶイベントの MichiInfo タブを開く
- 検証:
  - アクションボタン付き Mark のカード下にボタンが表示されている
  - スパン矢印の開始 Y 座標がアクションボタン領域の高さを含む正しい位置にある（開始 Mark の中央 Y が正しい）
  - スパン矢印の終了 Y 座標が終了 Mark の中央 Y に一致している

### TS-16: 罫線接続の視覚確認（Mark と Link が同じ接続パターン）

- 前提: Mark と Link を含むイベントの MichiInfo タブを開く
- 検証: Mark 行・Link 行ともにタイムライン軸からカードへ水平罫線で接続されている（三角形ポインターなし。ビジュアル確認は手動）

---

## 14. 受け入れ条件（v3.0 B案 更新）

### v2.0 から変更する条件

- Mark カードの左端とドットが **三角形ポインターではなく水平罫線** で接続されている
- タイムライン縦線が **カード高さ（`_cardHeight`）の範囲内** に収まっており、行間スペースには縦線が描画されない
- Mark カードが Link カードより **横幅が広い**
- 距離表示エリアが **Link 個別距離列（64px）+ スパン矢印列（72px）** の2段構造になっている

### v3.0 で追加する条件

- `ListView.builder` が `CustomScrollView` + `SliverList` に置き換えられている
- `_MichiTimelineCanvas` が `CustomScrollView` の背景レイヤーとして配置されている（`Positioned.fill`）
- `_SpanArrowOverlay`・`GlobalKey` によるスクロール追従実装が存在しない
- パターン1（Mark-Mark 間に Link なし）: Mark 行右側のスパン矢印列にスパン矢印と `displayMeterDiff` が表示される
- パターン2（Link 行）: Link 行右側の Link 個別距離列に区間距離と矢印が表示される
- パターン3（Mark-Link×1-Mark）: スパン矢印列に Mark 間スパン矢印と `displayMeterDiff` が表示され、Link 行右に区間距離が表示される
- パターン4（Mark-Link×2以上-Mark）: スパン矢印列に Mark 間スパン矢印と `displayMeterDiff` が表示され、各 Link 行右にそれぞれの区間距離が表示される
- スパン矢印はスクロール後も正しい Y 座標に描画される（`scrollOffset` 補正済み）
- `_MarkActionButtons` を持つ Mark を含む場合でも、スパン矢印の開始 Y 座標が正しい（アクションボタン高さを含むオフセット計算済み）

### v2.0 から維持する条件

- 各行のビジュアル要素が1つの `CustomPainter`（`_MichiTimelinePainter`）で描画されている
- `_cardHeight = 72.0` を基準として全描画座標が算出されている
- `Stack( CustomPaint, overlay )` 構造でタップ操作は overlay 側で処理されている
- Link が存在する区間の縦線が他の区間より太く表示される（線幅変更のみ）
- 画面右上に凡例がスクロールに関わらず常時表示される
- 既存の Mark / Link タップ操作（詳細画面への遷移）が引き続き動作する
- MarkDetail / LinkDetail 保存後に一覧の表示が更新される
- カラーは `colorScheme` の範囲内のみ使用（カスタムカラーなし）
- `_MichiTimelinePainter` 内でテーマ参照を行わない（色は外部から引数で受け取る）
