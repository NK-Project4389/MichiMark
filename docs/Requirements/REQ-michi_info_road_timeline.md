# 要件書: MichiInfo タイムライン 道路イメージ背景

- **要件ID**: REQ-michi_info_road_timeline
- **作成日**: 2026-04-15
- **担当**: product-manager
- **ステータス**: 確定
- **種別**: UI改善（UI-14）
- **デザイン参照**: docs/Design/draft/michi_info_road_timeline_design.html

---

## 1. 背景・目的

MichiInfoのタイムライン縦線を「道路イメージの背景帯」に変更し、ドライブ記録アプリらしいビジュアルを追加する。

既存のドット・カード・スパン矢印・挿入モーションは一切変更しない。
道路帯は最背面レイヤーとして追加するだけのシンプルな変更とする。

---

## 2. レイヤー構成

```
背面 ──────────────────── 前面

1️⃣ 道路帯（新規追加）
   └ グレー帯 + 白破線センターライン
   └ タイムライン軸（x=20）に沿って縦に固定描画

2️⃣ 既存描画（変更なし）
   └ スパン矢印・区間接続線・距離テキスト
   └ Mark●ドット（Teal）/ Link■ドット（Emerald）
   └ 水平接続線（軸→カード）

3️⃣ カード（変更なし）
   └ Mark / Linkカード
```

---

## 3. 道路帯 デザイン仕様

| 項目 | 仕様 |
|---|---|
| 描画範囲 | `verticalLineStartRelY`〜`verticalLineEndRelY`（現行の縦線と同じ範囲） |
| 帯幅 | 18px（軸中心 x=20 を基準に ±9px） |
| 帯色 | `#888888` |
| 端処理 | 上下端を radius=4px の丸みで描画 |
| センターライン | 白（`#FFFFFF`）・破線（on=6px / off=4px） |
| センターライン幅 | 1.5px |
| Link区間オーバーレイ | なし（グレー帯のまま。既存のEmeraldグラデーション矩形が前面で重なる） |

---

## 4. 実装方針

- `_MichiTimelineCanvas`（CustomPainter）内の**縦線 `drawLine` を道路帯描画に差し替える**だけ
- 道路帯は `_MichiTimelineCanvas` の `paint()` の**最初に描画**（最背面）
- 既存のスパン矢印・Linkセグメント・距離テキスト描画は**変更なし**
- `_MichiTimelinePainter`（カード・ドット描画）は**変更なし**
- 挿入モーション（InsertMode）は**変更なし**

---

## 5. 影響範囲

| 対象 | 変更内容 |
|---|---|
| `_MichiTimelineCanvas.paint()` | 縦線 `drawLine` → 道路帯描画（`drawRRect` + 破線ループ） |
| その他すべて | 変更なし |

---

## 6. 対象外

- Mark / Linkカードのデザイン
- ドット・水平接続線・スパン矢印
- 挿入モーション（InsertMode）
- Link区間の道路帯カラーリング（将来の拡張候補）

---

## 7. テストシナリオ

| TC-ID | シナリオ | 期待結果 |
|---|---|---|
| TC-RDT-001 | MichiInfo画面を開く（Mark・Linkが存在する） | タイムライン軸にグレーの道路帯が表示される |
| TC-RDT-002 | MichiInfo画面を開く（Mark・Linkが存在する） | 道路帯の上にセンターライン（白破線）が表示される |
| TC-RDT-003 | MichiInfo画面を開く | Markカード・Linkカード・ドットが道路帯の前面に表示される |
| TC-RDT-004 | MichiInfo画面を開く（Markが1件のみ） | 道路帯が表示されない（verticalLineStartRelY == verticalLineEndRelY の場合） |
| TC-RDT-005 | 追加ボタンから地点/区間を追加する | 道路帯が新しい範囲に延長される（挿入モーション後も崩れない） |
