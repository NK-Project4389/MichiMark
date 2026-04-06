# Feature Spec: MichiInfo Canvas/Path カスタム描画レイアウト

Feature: MichiInfo（SwiftUI Canvas/Path 再設計）
Version: 1.0
作成日: 2026-04-07
要件書: docs/Requirements/REQ-michi_canvas_layout.md

---

## 1. Feature Overview

### Feature Name

MichiInfo Canvas/Path カスタム描画レイアウト

### Purpose

MichiInfo タブの一覧表示UIを HStack/VStack の並列構成から SwiftUI Canvas/Path ベースのカスタム描画に全面再設計する。
各行のビジュアル要素（線・ドット・三角形・カード背景）を定数 `cardHeight` から算出した座標で直接描画し、位置合わせの安定性を確保する。

### Scope

含むもの
- `MichiTimelineRowView.swift` の全面変更（Canvas/Path ベースの描画実装）
- `MichiMarkCardView.swift` の高さ調整（`cardHeight` 定数への統一）
- `MichiLinkCardView.swift` の高さ調整（`cardHeight` 定数への統一）
- `cardHeight: CGFloat = 72` の定数定義と全描画座標への適用
- Canvas 上に SwiftUI View をオーバーレイする構造の設計

含まないもの
- MichiInfoReducer / State / Action の構造変更
- ナビゲーション・データバインディングの変更
- `MarkLinkItemProjection` 等のドメイン層・Projection 層の変更
- ダークテーマ対応
- アニメーション

---

## 2. Feature Responsibility

変更対象の責務

- `MichiTimelineRowView`（View 層）: 各ビジュアル要素を Canvas/Path で描画し、インタラクティブ要素を SwiftUI View としてオーバーレイする
- `MichiMarkCardView`（View 層）: `cardHeight` に準拠した高さでカードを表示する
- `MichiLinkCardView`（View 層）: `cardHeight` に準拠した高さでカードを表示する

データ層（Reducer / State / Projection）は変更しない。

---

## 3. 定数定義

| 定数名 | 型 | 値 | 説明 |
|---|---|---|---|
| `cardHeight` | `CGFloat` | `72` | 1カードの固定高さ。全描画座標の基準値 |

- `cardHeight` はファイルスコープまたは View スコープの `let` 定数として定義する
- `MichiMarkCardView`・`MichiLinkCardView` の `minHeight` も `cardHeight` に合わせる

---

## 4. View 構造

### ビュー分割

```
MichiTimelineRowView              // 1行全体の構成
  ├── Canvas（背面）               // 全ビジュアル要素の描画
  │     ├── カード背景（矩形）
  │     ├── リンク太線（区間線）
  │     ├── 太線とカードの接続線（細線）
  │     ├── ドット（円）
  │     ├── 三角形（地点マーカー）
  │     ├── 距離線（地点あり）
  │     └── 距離線（地点なし）
  └── SwiftUI View オーバーレイ（前面）
        ├── テキスト（タイトル・メーター値・距離等）
        └── ボタン（onMarkTap / onLinkTap）

MichiMarkCardView                 // Mark カード（高さ調整のみ）
MichiLinkCardView                 // Link カード（高さ調整のみ）
```

### 各ビューの責務と引数

#### `MichiTimelineRowView`

- 責務: Canvas で背面の全ビジュアル要素を描画し、前面にテキスト・ボタンを重ねる
- 既存の引数を維持する:
  - `item: MarkLinkItemProjection`
  - `isFirst: Bool`
  - `isLast: Bool`
  - `onMarkTap: () -> Void`
  - `onLinkTap: () -> Void`

#### `MichiMarkCardView`

- 責務: Mark カードの内容表示（タイトル・メーター値・メモ）
- 高さを `cardHeight` に合わせた `minHeight` で定義する
- 既存の引数を維持する:
  - `title: String`
  - `displayMeter: String?`
  - `memo: String`

#### `MichiLinkCardView`

- 責務: Link カードの内容表示（タイトル・距離）
- 高さを `cardHeight` に合わせた `minHeight` で定義する
- 既存の引数を維持する:
  - `title: String`
  - `displayDistance: String?`

---

## 5. 描画パーツ仕様

各パーツは `Canvas { context, size in }` 内で `Path` を使って描画する。
全座標は `cardHeight` を基準として算出する。

### 5-1. カード背景

| 項目 | 定義 |
|---|---|
| 形状 | 矩形（RoundedRectangle または Rectangle） |
| 高さ | `cardHeight` |
| 対象 | Mark アイテム / Link アイテム 両方 |
| 塗り色 | Mark: `systemGray5`、Link: `green.opacity(0.15)` に準ずる色 |

### 5-2. リンクの太線（区間線）

| 項目 | 定義 |
|---|---|
| 形状 | 縦方向の太い線（Path stroke） |
| 長さ | `cardHeight`（カードの高さと同一） |
| 対象 | Link アイテムのみ |
| 線幅 | 通常線より太い値（実装時に確定。目安 4.0pt） |

### 5-3. 太線とカードの接続線

| 項目 | 定義 |
|---|---|
| 形状 | 細い水平線または斜め線（Path stroke） |
| 役割 | 太線（区間線）とカード背景を視覚的に繋ぐ |
| 線幅 | 通常線（目安 1.0〜2.0pt） |

### 5-4. ドット（地点マーカー）

| 項目 | 定義 |
|---|---|
| 形状 | 円（Path ellipse） |
| 位置 | 三角形と接する位置（三角形の頂点に隣接） |
| 対象 | Mark アイテムのみ |
| 塗り色 | `colorScheme.onSurface` に準ずる色 |

### 5-5. 三角形（地点マーカー）

| 項目 | 定義 |
|---|---|
| 形状 | 三角形（Path move/addLine） |
| 底辺 | カードの高さ（`cardHeight`）に揃える |
| 位置 | ドットに接する位置（ドットの右隣） |
| 対象 | Mark アイテムのみ |
| 塗り色 | カード背景と同系色またはアクセントカラー |

### 5-6. 距離線（地点あり）

| 項目 | 定義 |
|---|---|
| 形状 | 縦方向の線（Path stroke） |
| 接続 | 上の Mark ドット位置から下の Mark ドット位置まで |
| 対象 | 前後に Mark が存在する区間 |

### 5-7. 距離線（地点なし）

| 項目 | 定義 |
|---|---|
| 形状 | 縦方向の線（Path stroke） |
| 接続 | リンク区間線の上辺から下辺まで |
| 対象 | Mark が存在しない区間（Link のみの区間） |

---

## 6. GeometryReader の使用方針

- GeometryReader は Canvas 外での使用を最小限にとどめる
- Canvas 内の描画座標は `size`（Canvas に渡される CGSize）と `cardHeight` 定数から算出する
- 行全体の幅取得が必要な場合のみ GeometryReader を Canvas の親 View として使用する

---

## 7. インタラクティブ要素のオーバーレイ方針

- Canvas は `allowsHitTesting(false)` として、タップイベントを通過させる
- テキスト・ボタン等のインタラクティブ要素は `ZStack` または `.overlay` で Canvas の前面に配置する
- `onMarkTap` / `onLinkTap` の発火はオーバーレイ側の `Button` または `onTapGesture` で行う

---

## 8. データフロー（変更なし）

```
MichiInfoReducer
  ↓ State（items: [MarkLinkItemProjection]）
MichiTimelineRowView
  ├── Canvas 描画（item の markLinkType に基づく）
  └── SwiftUI View オーバーレイ（item のテキスト・ボタン）
```

- Reducer / Action / State は変更しない
- `MarkLinkItemProjection` のフィールドは変更しない
- 表示データは既存の `item` プロパティをそのまま参照する

---

## 9. 変更対象ファイル

| ファイルパス | 変更種別 | 変更内容 |
|---|---|---|
| `MichiMark/Feature/EventDetail/MichiInfo/MichiTimelineRowView.swift` | 全面変更 | Canvas/Path ベースの描画実装・インタラクティブ要素のオーバーレイ構造 |
| `MichiMark/Feature/EventDetail/MichiInfo/MichiMarkCardView.swift` | 部分変更 | `minHeight` を `cardHeight` 定数に統一 |
| `MichiMark/Feature/EventDetail/MichiInfo/MichiLinkCardView.swift` | 部分変更 | `minHeight` を `cardHeight` 定数に統一 |

変更しないファイル:
- MichiInfoReducer / State / Action 定義
- `MarkLinkItemProjection` 等の Projection・Domain 定義
- MichiInfoView / AddSheetFeature
- ナビゲーション定義

---

## 10. SwiftUI 版との対応

本 Spec は SwiftUI 版（`MichiMark/` ディレクトリ）への変更である。Flutter 版（`lib/` ディレクトリ）の MichiInfo_Layout_Spec.md（Flutter CustomPaint タイムライン）とは独立した変更。

| 変更対象 | 対応 |
|---|---|
| `MichiTimelineRowView.swift` | HStack/VStack 構成 → Canvas/Path 構成 |
| `MichiMarkCardView.swift` | `minHeight: 80` → `cardHeight: 72` に統一 |
| `MichiLinkCardView.swift` | `minHeight: 60` → `cardHeight: 72` に統一 |

---

## 11. 受け入れ条件

- 各行の線・ドット・三角形・カード背景が Canvas/Path で描画され、位置ずれが発生しない
- `cardHeight = 72` を起点として全描画座標が算出されている
- 太線（Link区間線）がカードの高さに合わせた長さで描画される
- ドットが三角形と接する位置に描画される
- 三角形の底辺がカードの高さ（`cardHeight`）に揃って描画される
- 距離線が上下の地点（Mark）を繋いで描画される
- 地点なし区間の距離線がリンク区間線の上辺・下辺に接して描画される
- テキスト等インタラクティブ要素が Canvas の前面に SwiftUI View として重なっている
- GeometryReader の使用が Canvas 外で最小限にとどまっている
- 既存の Mark / Link タップ操作（詳細画面への遷移）が引き続き動作する
- `MarkLinkItemProjection` 等のドメイン層に変更が加えられていない
