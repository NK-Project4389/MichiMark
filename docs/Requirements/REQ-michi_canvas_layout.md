# 要件書: MichiInfo Canvas/Path カスタム描画レイアウト

REQ-ID: REQ-michi_canvas_layout
作成日: 2026-04-07
対象プラットフォーム: SwiftUI (iOS)

---

## 概要

MichiInfo タブの一覧表示UIを、HStack/VStackによる並列構成から SwiftUI Canvas/Path ベースのカスタム描画に全面再設計する。
各行のビジュアル要素（線・ドット・三角形・カード背景等）を直接描画することで、位置合わせの精度と表示の一貫性を向上させる。

---

## 背景・現状の問題

現行の `MichiTimelineRowView` は HStack/VStack の並列構成で各要素（線・ドット・カード）を配置している。

- 線・ドット・三角形・カード背景の位置合わせが行ごとにずれやすい
- SwiftUI の Auto Layout 制約によって描画座標が揺れる
- 各パーツが独立した View として管理されており、隣接行との整合性を制御しにくい

---

## ユーザーストーリー

- ユーザーとして、線・ドット・三角形・カードが正確に位置揃えされた状態でタイムラインを閲覧したい
- ユーザーとして、スクロール中も各パーツのずれが発生しない安定したUIで操作したい

---

## 機能要件

### FR-01: カード高さの定数化

- 1カードの高さを定数 `cardHeight: CGFloat = 72` で定義する
- 全ての描画座標（線の長さ・ドットの位置・三角形の頂点等）はこの値から算出する

### FR-02: カード背景の描画

- カード背景を固定高さ（`cardHeight`）の矩形として Canvas/Path で直接描画する
- Mark カード・Link カードでそれぞれ背景色を使い分ける

### FR-03: リンクの太線（区間線）の描画

- Link アイテムに対応する縦方向の太線を Canvas/Path で描画する
- 太線の長さはカードの高さ（`cardHeight`）に合わせる

### FR-04: 太線とカードの接続線の描画

- 太線（リンク区間線）と各カードを繋ぐ細い接続線を Canvas/Path で描画する

### FR-05: ドット（地点マーカー）の描画

- Mark の地点を示すドット（円）を Canvas/Path で描画する
- ドットは三角形と接する位置に配置する

### FR-06: 三角形（地点マーカー）の描画

- Mark の地点を示す三角形を Canvas/Path で描画する
- 三角形の底辺をカードの高さに揃える
- 三角形はドットに接する位置に配置する

### FR-07: 距離線の描画

- 上の地点（Mark）と下の地点（Mark）を繋ぐ距離線を Canvas/Path で描画する

### FR-08: 地点なし時の距離線の描画

- Mark が存在しない区間（Link のみの区間）の距離線は、リンク区間線の上辺・下辺に接するよう描画する

### FR-09: テキスト等インタラクティブ要素のオーバーレイ

- テキスト・ボタン等のインタラクティブ要素は Canvas の上に SwiftUI View として重ねる
- Canvas/Path で描画する要素とインタラクティブ要素は明確に分離する

---

## 非機能要件

- GeometryReader は Canvas 外での使用を最小限にとどめる
- 既存のデータバインディング・ナビゲーションは変更しない
- `MarkLinkItemProjection` 等のドメイン層は変更しない

---

## スコープ外

- MichiInfoReducer / State / Action の構造変更
- ナビゲーション構造の変更
- `MarkLinkItemProjection` 等 Projection 層の変更
- ダークテーマ対応
- アニメーション

---

## 実装対象ファイル

| ファイルパス | 変更種別 |
|---|---|
| `MichiMark/Feature/EventDetail/MichiInfo/MichiTimelineRowView.swift` | 全面変更（主要変更） |
| `MichiMark/Feature/EventDetail/MichiInfo/MichiMarkCardView.swift` | 高さ調整 |
| `MichiMark/Feature/EventDetail/MichiInfo/MichiLinkCardView.swift` | 高さ調整 |

---

## 受け入れ条件

- [ ] 各行の線・ドット・三角形・カード背景が Canvas/Path で描画され、位置ずれが発生しない
- [ ] `cardHeight = 72` を起点として全描画座標が算出されている
- [ ] 太線（Link区間線）がカードの高さに合わせた長さで描画される
- [ ] ドットが三角形と接する位置に描画される
- [ ] 三角形の底辺がカードの高さに揃って描画される
- [ ] 距離線が上下の地点（Mark）を繋いで描画される
- [ ] 地点なし区間の距離線がリンク区間線の上辺・下辺に接して描画される
- [ ] テキスト等インタラクティブ要素は Canvas の上に SwiftUI View として重なっている
- [ ] GeometryReader の使用が Canvas 外で最小限にとどまっている
- [ ] 既存の Mark / Link タップ操作（詳細画面への遷移）が引き続き動作する
- [ ] `MarkLinkItemProjection` 等のドメイン層に変更が加えられていない
