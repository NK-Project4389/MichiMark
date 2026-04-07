# Feature Spec: MichiInfo レイアウト変更

Feature: MichiInfo
Version: 2.0
作成日: 2026-04-04
更新日: 2026-04-07
要件書: docs/Requirements/REQ-michi_info_layout.md

---

## 変更履歴

| Version | 日付 | 変更内容 |
|---|---|---|
| 1.0 | 2026-04-04 | 初版。CustomPaint 分散型タイムラインレイアウトを定義 |
| 2.0 | 2026-04-07 | Widget 構造を統合 CustomPainter + Stack overlay に変更。`cardHeight` 定数導入。テストシナリオ追加 |

---

## 1. Feature Overview

### Feature Name

MichiInfo レイアウト変更（統合 CustomPainter タイムライン型）

### Purpose

MichiInfo Feature の一覧表示を、複数 Widget に分散した CustomPainter 構成から、
1行分のビジュアル要素をすべて1つの `CustomPainter` で描画し、テキスト・タップ領域を
Stack overlay として重ねる統合型アーキテクチャに変更する。

SwiftUI の Canvas + ZStack 相当の構造に対応し、各パーツ（コネクター・バブルカード・リンクカード）
の位置合わせ精度を定数 `cardHeight` から算出された座標で統一することで表示の一貫性を向上させる。

### Scope

含むもの
- `_MichiInfoList` ウィジェット以下の全面置き換え（統合 CustomPainter + Stack overlay 型）
- `cardHeight` 定数の導入（全描画座標の基準値）
- `_TimelineItem` の構造を `Stack( CustomPaint, overlay )` に変更
- 1行ぶんの全ビジュアル要素（カード背景・縦線・ドット・三角ポインター・接続線）を
  1つの `_MichiTimelinePainter` に統合
- テストシナリオ（Integration Test 用）の定義

含まないもの
- MichiInfoBloc / Event / State / Delegate の構造変更
- Projection 層・Domain 層・Repository 層の変更
- `MarkLinkItemProjection.displayMeterDiff` フィールドの定義（v1.0 から維持）
- `EventDetailAdapter._toMichiInfo` のメーター差分計算ロジック（v1.0 から維持）
- ダークテーマ対応
- 縦線・ドット・カードのアニメーション
- 距離単位の切り替え

---

## 2. Feature Responsibility

変更対象の責務

- `_MichiInfoList`（Widget層）: `Stack` で `ListView.builder` と `_DistanceLegend` を重ねる。空リスト時メッセージ・FAB を表示する
- `_TimelineItem`（Widget層）: `Stack( CustomPaint, overlay )` 構造で1行分を構成する
- `_MichiTimelinePainter`（Widget層内 CustomPainter）: 1行分の全ビジュアル要素を `cardHeight` 基準の座標で描画する
- テキスト・タップ領域（Widget層 overlay）: `_TimelineItem` の Stack 前面に配置し、インタラクションを担当する

BLoC の Event / State 定義、Delegate 定義、Projection 層、Repository 呼び出しは変更しない。

---

## 3. 定数定義

| 定数名 | 型 | 値 | 説明 |
|---|---|---|---|
| `_cardHeight` | `double` | `72.0` | 1カードの固定高さ。全描画座標の基準値 |

- `_cardHeight` はファイルスコープまたはクラス定数として定義する
- Mark カード・Link カードの `minHeight` はいずれも `_cardHeight` に統一する
- 縦線・ドット・三角ポインター等の全描画 Y 座標は `_cardHeight` から算出する

---

## 4. Projection 定義（変更なし）

v1.0 からの変更なし。以下は参照用に維持する。

### MarkLinkItemProjection（既存フィールド維持）

| フィールド名 | 型 | 説明 |
|---|---|---|
| `displayMeterDiff` | `String?` | 前の Mark との累積メーター差分の表示文字列（例: "+150 km"）。Mark アイテムのみ設定。リスト先頭の Mark や前後に Mark が存在しない場合は `null` |

計算定義（変更なし）:
- 対象: `MarkOrLink.mark` かつ `meterValue != null` のアイテム
- 計算式: 当該 Mark の `meterValue` - 直前の Mark の `meterValue`
- 直前の Mark が存在しない場合（リスト先頭の Mark）: `null`
- 差分がマイナスの場合も表示する（符号付き）
- 単位: "km"、数値はカンマ区切り（例: "+1,234 km"、"-50 km"）

---

## 5. 設計判断

### 5-1. CustomPainter の統合方針

v1.0 では `_TimelineGroupConnector`・`_BubbleCardPainter` が Widget ごとに独立した CustomPainter を持っていた。
v2.0 では1行分（`_TimelineItem`）の全ビジュアル要素を1つの `_MichiTimelinePainter` で描画する。

採用理由:
- 描画座標を `_cardHeight` 定数から一元的に算出できる
- 縦線・ドット・三角ポインター・カード背景の位置合わせが1つの paint コンテキストで完結する
- SwiftUI Canvas + ZStack の構造に対応する Flutter イディオムとして整合性が高い

### 5-2. Stack overlay の分離方針

- `_MichiTimelinePainter` はビジュアル要素のみ描画し、タップイベントは受け付けない
- テキスト・`GestureDetector`・アクションボタン等のインタラクティブ要素は Stack 前面の overlay Widget として配置する
- overlay 側の Widget の高さも `_cardHeight` に揃えることで CustomPainter の描画座標と整合させる

### 5-3. _MarkGroup の廃止

v1.0 の `_MarkGroup`（Mark + 後続 Links をグループ化した Widget）は廃止する。
v2.0 では `_TimelineItem` が Mark / Link を問わず1行単位で処理し、
太線判定フラグ（`isLinkActive`）を ListView.builder の index から導出する。

採用理由:
- `_cardHeight` 固定高さを前提とした座標計算では、グループ単位ではなく行単位の方が座標が単純になる
- SwiftUI の `ForEach` + 1行単位描画モデルに対応する

### 5-4. メーター差分計算場所（v1.0 から維持）

v1.0 の設計判断 4-1（Adapter 層で計算）を維持する。

### 5-5. 距離凡例の配置（v1.0 から維持）

v1.0 の設計判断 4-5（`Stack` でリスト上に重ねる）を維持する。

---

## 6. Widget 構造

### ウィジェット分割

```
_MichiInfoList                              // Scaffold 全体。Stack で凡例を重ねる
  ├── ListView.builder                      // タイムラインアイテムのスクロールリスト
  │     └── _TimelineItem                   // 1行（Mark または Link）の統合ウィジェット
  │           ├── CustomPaint               // 全ビジュアル要素を描画（_MichiTimelinePainter）
  │           └── overlay（Column / Row）   // テキスト・タップ領域・アクションボタン
  └── _DistanceLegend                       // 右上固定の凡例
```

### _MichiTimelinePainter が描画するビジュアル要素

1行分のすべてのビジュアル要素を1つの `CustomPainter` で描画する:

| 要素 | 対象 | 説明 |
|---|---|---|
| カード背景（角丸矩形） | Mark / Link 両方 | `_cardHeight` を高さとする角丸矩形 |
| タイムライン縦線（上半分） | Mark / Link 両方 | 行上端からドット/カード上端まで。`isFirst` の場合は省略 |
| タイムライン縦線（下半分） | Mark / Link 両方 | ドット/カード下端から行下端まで。`isLast` の場合は省略 |
| ドット（円） | Mark のみ | 縦線上に重なるドット。タイムライン軸の中心に配置 |
| 三角ポインター | Mark のみ | カード左端から縦線ドットに向かう三角形 |
| 接続線（水平線） | Link のみ | タイムライン軸からカード左端をつなぐ細い水平線 |
| 縦線の太線切り替え | Link を含む区間 | `isLinkActive: true` の行では縦線を太線で描画 |

### 各ウィジェットの責務と引数

#### `_MichiInfoList`
- 責務: `Stack` で `ListView.builder` と `_DistanceLegend` を重ねる。空リスト時のメッセージ表示。FAB 表示
- 引数: `MichiInfoListProjection projection`、`TopicConfig topicConfig`、`List<ActionItemProjection> markActionItems`

#### `_TimelineItem`
- 責務: `Stack( children: [ CustomPaint(_MichiTimelinePainter), overlay ] )` を構成する
- 引数:
  - `MarkLinkItemProjection item`
  - `bool isFirst`（リスト先頭か）
  - `bool isLast`（リスト末尾か）
  - `bool isLinkActive`（この行の縦線区間が Link に含まれるか）
  - `VoidCallback onTap`
  - `List<ActionItemProjection> markActionItems`（Mark の場合のみ使用）
- 高さ: `_cardHeight` を基準とした固定高さ（アクションボタンがある場合は追加分を加算）

#### `_MichiTimelinePainter`（CustomPainter）
- 責務: 1行分の全ビジュアル要素を `_cardHeight` 基準の座標で描画する
- フィールド:
  - `MarkOrLink markLinkType`（Mark / Link の種別）
  - `bool isFirst`
  - `bool isLast`
  - `bool isLinkActive`（太線区間か）
  - `Color cardBgColor`（カード背景色）
  - `Color lineColor`（縦線・ドット色）
- カラー: `colorScheme` の値を外部から受け取る。`_MichiTimelinePainter` 内でテーマを参照しない
- 線幅定数: 通常線 `1.5`、太線 `6.0`
- ドットサイズ: 通常線幅の 4 倍以上（目安 `_dotRadius = 6.0`）

#### overlay（_TimelineItem 内）
- 責務: テキスト（名称・メーター値・距離値・isFuel アイコン）・タップ領域・アクションボタンを表示する
- `GestureDetector` または `InkWell` で `onTap` を受け付ける
- overlay 要素の高さは `_cardHeight` に揃える

#### `_DistanceLegend`
- 責務: メーター差分（onSurface色）と区間距離（outline色）の凡例を表示する
- 引数: なし（固定文言）
- 配置: `Stack` の `Positioned(top, right)` で固定

---

## 7. 太線区間の判定ロジック

`MichiInfoListProjection.items` はソート済みであるため、次のルールで判定する:

- 各アイテムについて、`MarkOrLink.link` アイテムの行は `isLinkActive = true`
- Mark アイテムについては、次のアイテムが Link の場合は「下半分を太線」として `isLinkActive = true`
- Mark アイテムについては、前のアイテムが Link の場合は「上半分を太線」として `isLinkActive = true`
- 先頭 Mark・末尾 Mark の判定は `isFirst` / `isLast` で制御する
- 太線判定は Widget 層で `items` の順序から導出する（Projection への事前計算は不要）

`_MichiTimelinePainter` は `isLinkActive` フラグと `isFirst` / `isLast` を受け取り、
上下の半分ごとに線幅を切り替えて描画する。

---

## 8. Data Flow（変更部分）

Projection・BLoC 層のデータフローは v1.0 から変更なし。Widget 層のフローのみ変更する。

```
MichiInfoLoaded.projection（MichiInfoListProjection）
  ↓
_MichiInfoList
  ↓
ListView.builder（items を index ベースでイテレート）
  ├── 太線判定（index から isLinkActive を導出）
  └── _TimelineItem
        ├── CustomPaint（_MichiTimelinePainter）
        │     ← cardBgColor / lineColor / isLinkActive / isFirst / isLast / markLinkType
        └── overlay
              ← テキスト / onTap / markActionItems
```

---

## 9. 変更対象ファイル

| ファイルパス | 変更種別 | 内容 |
|---|---|---|
| `lib/features/michi_info/view/michi_info_view.dart` | 変更 | `_MichiInfoList` 以下のウィジェット全面置き換え。`_MichiTimelinePainter` 追加。`_MarkGroup` / `_TimelineGroupConnector` / `_BubbleCardPainter` を廃止し `_TimelineItem` + `_MichiTimelinePainter` に統合 |

既存ファイルで変更しないもの:
- `MichiInfoBloc` の Event / State / Delegate クラス定義
- `MarkLinkItemProjection` / `MichiInfoListProjection` クラス定義
- `EventDetailAdapter.toProjection` のシグネチャ
- Router 定義

---

## 10. SwiftUI 版との対応

| SwiftUI 構造 | Flutter 対応構造 |
|---|---|
| `Canvas { context, size in }` | `CustomPaint(painter: _MichiTimelinePainter(...))` |
| `ZStack { Canvas; SwiftUI View }` | `Stack( children: [ CustomPaint, overlay Widget ] )` |
| `cardHeight: CGFloat = 72` | `_cardHeight: double = 72.0` |
| `allowsHitTesting(false)` （Canvas） | `CustomPaint` はタップを透過（overlay 側が担当） |

---

## 11. テストシナリオ

tester が Integration Test で検証する粒度でシナリオを定義する。

### TS-01: タイムラインの基本表示

- 前提: Mark と Link を含むイベントの MichiInfo タブを開く
- 検証:
  - Mark 行が表示され、名称テキストが見える
  - Link 行が表示され、名称テキストが見える
  - 画面右上に凡例（`_DistanceLegend`）が表示されている

### TS-02: メーター差分の表示

- 前提: メーター値が設定された Mark が2件以上あるイベントの MichiInfo タブを開く
- 検証:
  - 2件目以降の Mark 行にメーター差分テキスト（例: "+150 km"）が表示されている
  - 先頭 Mark 行にはメーター差分が表示されない

### TS-03: Mark タップで詳細画面に遷移

- 前提: Mark が1件以上あるイベントの MichiInfo タブを開く
- 操作: 表示されている Mark 行をタップする
- 検証: MarkDetail 画面に遷移する

### TS-04: Link タップで詳細画面に遷移

- 前提: Link が1件以上あるイベントの MichiInfo タブを開く
- 操作: 表示されている Link 行をタップする
- 検証: LinkDetail 画面に遷移する

### TS-05: 地点追加フローの動作

- 前提: MichiInfo タブを開く
- 操作: FAB をタップし「地点を追加」を選択する
- 検証: MarkDetail 画面（新規追加）に遷移する

### TS-06: 空リスト時のメッセージ表示

- 前提: Mark / Link が0件のイベントの MichiInfo タブを開く
- 検証: 「地点/区間がありません」のメッセージが表示されている

### TS-07: MarkDetail 保存後に一覧が更新される

- 前提: MichiInfo タブを開く
- 操作: Mark 行をタップし MarkDetail 画面を開く → 名称を変更して保存する
- 検証: MichiInfo タブに戻り、変更後の名称が表示されている

---

## 12. 受け入れ条件

- 各行のビジュアル要素（縦線・ドット・三角ポインター・カード背景・接続線）が1つの `CustomPainter` で描画されている
- `_cardHeight = 72.0` を基準として全描画座標が算出されている
- `Stack( CustomPaint, overlay )` 構造で1行が構成されており、タップ操作は overlay 側で処理されている
- Link が存在する区間の縦線が他の区間より太く表示される（線幅変更のみ、色変更なし）
- Mark 行に三角ポインター付き吹き出し形カード背景が表示される
- Link 行に角丸カード背景と水平接続線が表示される
- 2件目以降の Mark 行右側にメーター差分（大・太字・onSurface色）が表示される
- Link が存在する区間では区間距離（小・outline色）がメーター差分の下に表示される
- 画面右上に凡例（onSurface = メーター差分、outline = 区間距離）がスクロールに関わらず常時表示される
- 既存の Mark / Link タップ操作（詳細画面への遷移）が引き続き動作する
- MarkDetail / LinkDetail 保存後に一覧の表示が更新される
- カラーは `colorScheme` の範囲内のみ使用（カスタムカラーなし）
- `_MichiTimelinePainter` 内でテーマ参照を行わない（色は外部から引数で受け取る）
