# Feature Spec: MichiInfo レイアウト変更

Feature: MichiInfo
Version: 1.0
作成日: 2026-04-04
要件書: docs/Requirements/REQ-michi_info_layout.md

---

## 1. Feature Overview

### Feature Name

MichiInfo レイアウト変更（タイムライン型）

### Purpose

MichiInfo Feature の一覧表示を `ListTile` ベースから「道」を視覚的に表現するタイムライン型レイアウトへ変更する。
縦罫線・ドット・太線・吹き出し型カードにより、ドライブルートの地点（Mark）と区間（Link）の構造を直感的に伝える。

### Scope

含むもの
- `_MichiInfoList` ウィジェットの全面置き換え（タイムライン型レイアウト）
- `MarkLinkItemProjection` への `displayMeterDiff` フィールド追加
- `EventDetailAdapter._toMichiInfo` でのメーター差分計算
- `MichiInfoBloc._applyMarkDraft` / `_applyLinkDraft` での差分再計算
- 距離凡例の常時表示

含まないもの
- MichiInfoBloc / Event / State の構造変更
- MichiInfoDelegate の変更
- ダークテーマ対応
- 縦線・ドット・カードのアニメーション
- 距離単位の切り替え

---

## 2. Feature Responsibility

変更対象の責務

- `EventDetailAdapter`（Adapter層）: メーター差分をリスト生成時に計算し Projection に格納する
- `MichiInfoBloc`（Bloc層）: Mark / Link Draft 適用後に差分を再計算した Projection を emit する
- `MarkLinkItemProjection`（Projection層）: `displayMeterDiff` フィールドを保持する
- `_MichiInfoList`（Widget層）: タイムライン型レイアウトでアイテムを描画する

BLoC の Event / State 定義、Delegate 定義、Repository 呼び出しは変更しない。

---

## 3. Projection 変更

### MarkLinkItemProjection への追加フィールド

| フィールド名 | 型 | 説明 |
|---|---|---|
| `displayMeterDiff` | `String?` | 前の Mark との累積メーター差分の表示文字列（例: "+150 km"）。Mark アイテムのみ設定。リスト先頭の Mark や前後に Mark が存在しない場合は `null` |

計算定義:
- 対象: `MarkOrLink.mark` かつ `meterValue != null` のアイテム
- 計算式: 当該 Mark の `meterValue` - 直前の Mark の `meterValue`
- 直前の Mark が存在しない場合（リスト先頭の Mark）: `null`
- 差分がマイナスの場合も表示する（符号付き）
- 単位: "km"、数値はカンマ区切り（例: "+1,234 km"、"-50 km"）

### MichiInfoListProjection

変更なし。`items: List<MarkLinkItemProjection>` のまま。

---

## 4. 設計判断

### 4-1. メーター差分の計算場所: 案A（Adapter）を採用

採用理由:
- `EventDetailAdapter._toMichiInfo` はすでにソート済みリストをイテレートしており、連続する Mark 間の差分を一括計算できる
- BLoC に計算ロジックを持たせると State 変換の責務を超える
- View 側での計算は設計憲章で禁止されているアンチパターン（Widget は Projection を表示するだけ）
- Projection は「表示に必要なデータをすべて保持する」という原則に合致する

補足（Draft 適用後の再計算）:
- `MichiInfoBloc._applyMarkDraft` / `_applyLinkDraft` は Projection を直接操作している
- Draft 適用後も差分を正確に保つため、これらのメソッドで差分を再計算して `displayMeterDiff` を更新すること
- 再計算ロジックは `MarkLinkDraftAdapter` または `MichiInfoBloc` 内のプライベートメソッドとして実装する

### 4-2. 縦ライン・ドット・太線の実装方法: `CustomPaint` を採用

採用理由:
- Link が存在する区間（複数アイテムにまたがる）で太線に切り替える必要があり、`Container + BoxDecoration` では行ごとに独立した描画になるため連続性を制御できない
- `CustomPaint` を使用することで、アイテム1行分の縦線を「上半分 / 下半分 / ドット」に分割して描画でき、隣接行との整合性を確保できる

### 4-3. 吹き出しカード（Mark 用）の実装方法: `CustomPaint` を採用

採用理由:
- 三角ポインターのサイズ・頂点位置・カード境界のアンチエイリアス処理が `ClipPath + Stack` より正確かつ安定する
- `CustomPaint` で外形パスを1つ描画するシンプルな構成になる

### 4-4. 距離表示の配置: 各アイテム行の右カラム

各 `_TimelineItem` の右側カラム内に距離情報を縦に配置する。
行間に独立ウィジェットとして挟む設計は採用しない（Mark アイテム自体が高さを持ち、右カラムに距離を収めることで見通しが良い）。

距離表示の構成（右カラム内）:
- メーター差分（Mark が設定されている場合）: 大・太字・`colorScheme.onSurface`
- 区間距離（当該 Mark に対応する Link が存在する場合）: 小・`colorScheme.outline`（グレー）
- 矢印アイコン（`Icons.swap_vert` 等）で距離範囲を視覚的に示す

### 4-5. 距離凡例の配置: `Stack` でリスト上に重ねる

採用理由:
- MichiInfo は EventDetail のタブとして埋め込まれており、独自の AppBar を持たない
- `Scaffold.body` 内で `Stack` を使用し、リストの右上に凡例ウィジェットを重ねて固定表示する

---

## 5. Widget 構造

### ウィジェット分割

```
_MichiInfoList                         // Scaffold 全体。Stack で凡例を重ねる
  ├── ListView.builder                 // タイムラインアイテムのスクロールリスト
  │     └── _TimelineItem              // 1アイテム分の行（Mark / Link 両対応）
  │           ├── _TimelineConnector   // 縦ライン・ドット・太線（CustomPaint）
  │           ├── _MarkCard            // 吹き出し型カード（Mark 用、CustomPaint）
  │           ├── _LinkCard            // 角丸カード（Link 用）
  │           └── _DistanceColumn      // 右側の距離表示（差分 + 区間距離）
  └── _DistanceLegend                  // 右上固定の凡例
```

### 各ウィジェットの責務と引数

#### `_MichiInfoList`
- 責務: `Stack` で `ListView.builder` と `_DistanceLegend` を重ねる。空リスト時のメッセージ表示。FAB 表示。
- 引数: `MichiInfoListProjection projection`

#### `_TimelineItem`
- 責務: 縦方向に `_TimelineConnector`・カード（`_MarkCard` or `_LinkCard`）・`_DistanceColumn` を横並びで構成する
- 引数: `MarkLinkItemProjection item`、`bool isLinkActive`（この行の縦線区間が Link に含まれるか）、`bool isFirst`、`bool isLast`

#### `_TimelineConnector`
- 責務: `CustomPaint` で縦ライン・ドット・太線を描画する
- 引数: `bool showDot`（Mark の場合 true）、`bool isUpperThick`（上半分が太線か）、`bool isLowerThick`（下半分が太線か）、`bool isFirst`、`bool isLast`
- カラー: `colorScheme.onSurface` を使用。カスタムカラーは定義しない
- ドットサイズ: 縦線幅の 3 倍以上
- 通常線幅: 2.0、太線幅: 4.0

#### `_MarkCard`
- 責務: `CustomPaint` で三角ポインター付き吹き出し形カードを描画し、内部に名称・メーター値・isFuel アイコンを表示する
- 引数: `MarkLinkItemProjection item`、`VoidCallback onTap`
- 三角ポインター: カード左側・縦線ドットと同じ高さに配置

#### `_LinkCard`
- 責務: 角丸 `Card` で名称・区間距離・isFuel アイコンを表示する
- 引数: `MarkLinkItemProjection item`、`VoidCallback onTap`

#### `_DistanceColumn`
- 責務: メーター差分と区間距離を縦に並べる。`displayMeterDiff` が null の場合は何も表示しない
- 引数: `String? displayMeterDiff`、`String? displayDistanceValue`

#### `_DistanceLegend`
- 責務: メーター差分（黒）と区間距離（グレー）の凡例を小さなインジケーターとテキストで表示する
- 引数: なし（固定文言）
- 配置: `Stack` の `Positioned(top, right)` で固定

---

## 6. 太線区間の判定ロジック

Link アイテムが存在する場合、その Link に対応する「前後の Mark の区間」で縦線を太線にする。

`MichiInfoListProjection.items` はソート済みであるため、次のルールで判定する:

- 各 Mark について、その Mark から次の Mark の間に1つ以上の Link が存在する場合、以下を太線とする
  - 当該 Mark 行の「縦線下半分」
  - 区間内の Link 行の「縦線全体」
  - 次の Mark 行の「縦線上半分」
- 太線判定は Widget 層で `MichiInfoListProjection.items` の順序から導出する（Projection への事前計算は不要）

---

## 7. Data Flow（変更部分）

```
EventDomain
  ↓
EventDetailAdapter._toMichiInfo
  ├── items をソート
  ├── 連続する Mark 間の displayMeterDiff を計算
  └── MarkLinkItemProjection（displayMeterDiff 付き）を生成
  ↓
MichiInfoListProjection
  ↓
MichiInfoBloc（_onStarted で emit）
  ↓
MichiInfoLoaded.projection
  ↓
_MichiInfoList
  ↓
_TimelineItem（各アイテム）
  ├── _TimelineConnector（CustomPaint）
  ├── _MarkCard / _LinkCard
  └── _DistanceColumn
```

Draft 適用後（`_applyMarkDraft` / `_applyLinkDraft`）:
```
MarkDetailDraft / LinkDetailDraft
  ↓
MarkLinkDraftAdapter.fromMarkDraft / fromLinkDraft
  ↓
差分再計算（新しい items リスト全体を走査）
  ↓
MichiInfoListProjection（displayMeterDiff 更新済み）
  ↓
emit（MichiInfoLoaded）
```

---

## 8. 変更対象ファイル

| ファイルパス | 変更種別 | 内容 |
|---|---|---|
| `lib/features/shared/projection/mark_link_item_projection.dart` | 変更 | `displayMeterDiff: String?` フィールドを追加 |
| `lib/adapter/event_detail_adapter.dart` | 変更 | `_toMichiInfo` でメーター差分を計算して Projection に格納 |
| `lib/features/michi_info/bloc/michi_info_bloc.dart` | 変更 | `_applyMarkDraft` / `_applyLinkDraft` で差分を再計算 |
| `lib/features/michi_info/view/michi_info_view.dart` | 変更 | `_MichiInfoList` 以下のウィジェット全面置き換え |

既存ファイルで変更しないもの:
- `MichiInfoBloc` の Event / State / Delegate クラス定義
- `MichiInfoListProjection` クラス定義
- `EventDetailAdapter.toProjection` のシグネチャ
- Router 定義

---

## 9. SwiftUI 版との対応

SwiftUI 版に本レイアウトの実装は存在しない。Flutter 版の新規デザインとして実装する。

---

## 10. 受け入れ条件

- 縦線が画面左側に表示され、各 Mark の位置にドットが重なって表示される
- Link が存在する区間の縦線が他の区間より太く表示される（線幅変更のみ、色変更なし）
- Mark カードが三角ポインター付き吹き出し形で表示される
- Link カードが角丸の通常カードで表示される
- 地点カード右側にメーター差分（大・太字・黒）が表示される
- Link が存在する区間では区間距離（小・グレー）がメーター差分の下に表示される
- 画面右上に凡例（黒 = メーター差分、グレー = 区間距離）がスクロールに関わらず常時表示される
- 既存の Mark / Link タップ操作（詳細画面への遷移）が引き続き動作する
- カラーは `colorScheme` の範囲内のみ使用（カスタムカラーなし）
