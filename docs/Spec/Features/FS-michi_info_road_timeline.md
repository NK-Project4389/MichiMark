# Feature Spec: MichiInfo タイムライン 道路イメージ背景

- **Spec ID**: FS-michi_info_road_timeline
- **Feature ID**: UI-14
- **要件書**: `docs/Requirements/REQ-michi_info_road_timeline.md`
- **作成日**: 2026-04-15
- **担当**: architect
- **ステータス**: 確定

---

# 1. Feature Overview

## Feature Name

MichiInfo タイムライン 道路イメージ背景

## Purpose

MichiInfo タイムラインの縦軸をグレーの道路帯（`drawRRect`）＋白破線センターライン（`drawLine` ループ）に差し替え、ドライブ記録アプリらしいビジュアルを追加する。

## Scope

**含むもの**
- `_MichiTimelineCanvas.paint()` の縦線描画（ステップ1）を道路帯描画に差し替える
- 道路帯（グレー角丸帯）の描画
- 白破線センターラインの描画

**含まないもの**
- Mark / Link カードのデザイン変更
- ドット・水平接続線・スパン矢印・区間接続線・距離テキストの変更
- 挿入モーション（InsertMode）の変更
- Link 区間の道路帯カラーリング（将来の拡張候補）
- `_MichiTimelinePainter`（カード・ドット描画 CustomPainter）の変更
- BLoC・State・Draft・Projection・Adapter・Repository の変更

---

# 2. 変更対象

## 変更対象ファイル

`flutter/lib/features/michi_info/view/michi_info_view.dart`

## 変更対象クラス・メソッド

| クラス | メソッド | 変更内容 |
|---|---|---|
| `_MichiTimelineCanvas` | `paint(Canvas canvas, Size size)` | ステップ1の縦線 `drawLine` を道路帯描画（`drawRRect` + 破線ループ）に差し替える |

## 変更しないもの（対象外）

| クラス / 要素 | 理由 |
|---|---|
| `_MichiTimelineCanvas.paint()` ステップ2〜（Link グラデーション縦線・スパン矢印・距離テキスト） | 既存ロジックに影響しない |
| `_MichiTimelinePainter` | カード・ドット・水平接続線の描画担当。変更不要 |
| `_MichiTimelineCanvasData`（データクラス） | フィールド追加なし |
| BLoC / State / Draft / Projection / Adapter / Repository | このFeatureはView層の描画変更のみ |

---

# 3. 道路帯 デザイン仕様

## レイヤー構成（描画順）

```
背面 ──────────────────── 前面

1. 道路帯（新規・最背面）
   └ グレー角丸帯（drawRRect）
   └ 白破線センターライン（drawLine ループ）

2. Emerald グラデーション縦線（Link 区間）← 変更なし
3. スパン矢印・距離テキスト              ← 変更なし
4. _MichiTimelinePainter（カード・ドット）← 変更なし
```

## パラメーター一覧

| 項目 | 値 |
|---|---|
| 描画条件 | `verticalLineEndRelY > verticalLineStartRelY` の場合のみ描画（アイテム1件のとき非表示） |
| 帯の左端 X | `_axisX - 9.0`（= `11.0`） |
| 帯の右端 X | `_axisX + 9.0`（= `29.0`） |
| 帯幅 | 18px（軸中心 `_axisX = 20.0` を基準に ±9px） |
| 帯色 | `#888888`（`Color(0xFF888888)`） |
| 上下端の丸み | `radius = 4.0px`（`drawRRect` の `Radius.circular(4.0)`） |
| センターライン色 | `#FFFFFF`（白） |
| センターライン幅 | 1.5px |
| センターライン破線 on | 6px |
| センターライン破線 off | 4px |

---

# 4. 描画ロジック（疑似コード）

`_MichiTimelineCanvas.paint()` の**最初**（既存ステップ1の直前・または差し替え）に実行する。

```
// 条件：アイテムが2件以上のときのみ描画
if (verticalLineEndRelY > verticalLineStartRelY) {

  // Canvas Y 座標への変換（scrollOffset を考慮）
  roadStartY = _topPadding + verticalLineStartRelY - scrollOffset
  roadEndY   = _topPadding + verticalLineEndRelY   - scrollOffset

  // ── 1. グレー道路帯（drawRRect）────────────────────
  roadRect = Rect.fromLTRB(
    left  = _axisX - 9.0,   // 11.0
    top   = roadStartY,
    right = _axisX + 9.0,   // 29.0
    bottom= roadEndY,
  )
  canvas.drawRRect(
    RRect.fromRectAndRadius(roadRect, Radius.circular(4.0)),
    Paint()..color = Color(0xFF888888),
  )

  // ── 2. 白破線センターライン（drawLine ループ）────────
  dashPaint = Paint()
    ..color       = Color(0xFFFFFFFF)
    ..strokeWidth = 1.5
    ..strokeCap   = StrokeCap.butt

  dashOn  = 6.0  // 実線部分の長さ
  dashOff = 4.0  // 空白部分の長さ
  y = roadStartY

  while y < roadEndY:
    segEnd = min(y + dashOn, roadEndY)
    canvas.drawLine(
      Offset(_axisX, y),
      Offset(_axisX, segEnd),
      dashPaint,
    )
    y += dashOn + dashOff
}
```

---

# 5. Data Flow

このFeatureは描画ロジックのみの変更であり、BLoC / State / Draft / Projection / Domain に変更はない。

```
（変更なし）
MichiInfoBloc
  ↓ MichiInfoState
_MichiTimelineCanvasData（計算済みデータ）
  ↓ verticalLineStartRelY / verticalLineEndRelY（既存フィールドをそのまま使用）
_MichiTimelineCanvas.paint()
  ↓ ★ 道路帯描画（新規）→ 既存描画（変更なし）
Canvas
```

---

# 6. 定数追加

`michi_info_view.dart` の定数ブロックに以下を追加する。

| 定数名 | 値 | 説明 |
|---|---|---|
| `_roadBandWidth` | `18.0` | 道路帯の全幅 |
| `_roadBandHalfWidth` | `9.0` | 軸中心からの片側幅 |
| `_roadBandRadius` | `4.0` | 帯上下端の丸みRadius |
| `_roadBandColor` | `Color(0xFF888888)` | 道路帯のグレー色 |
| `_centerLineColor` | `Color(0xFFFFFFFF)` | 白破線センターラインの色 |
| `_centerLineWidth` | `1.5` | センターライン幅 |
| `_dashOn` | `6.0` | 破線の実線部分の長さ |
| `_dashOff` | `4.0` | 破線の空白部分の長さ |

---

# 7. Test Scenarios

## 前提条件

- iOS シミュレーターが起動済みであること
- テスト用のイベントデータが存在すること
- `GetIt.I.reset()` → `router.go('/...')` → `app.main()` の順で起動すること
- Integration Test 内では `pumpAndSettle()` を使用しないこと（CustomPainter が常時再描画するため無限ハングになる）

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-RDT-001 | 道路帯が表示される（Mark・Link 複数件） | High |
| TC-RDT-002 | 白破線センターラインが表示される | High |
| TC-RDT-003 | カード・ドットが道路帯の前面に表示される | High |
| TC-RDT-004 | Mark が1件のみのとき道路帯が表示されない | Medium |
| TC-RDT-005 | 地点・区間を追加後も道路帯が正常に表示される | High |

---

## TC-RDT-001: 道路帯が表示される（Mark・Link 複数件）

**前提:**
- Mark が2件以上、または Mark と Link が1件ずつ以上存在するイベントを表示する

**操作手順:**
1. MichiInfo 画面を開く
2. タイムラインが表示されるまで待機する（最大15秒）

**期待結果:**
- タイムライン軸にグレー（`#888888`）の道路帯が表示される
- 道路帯は `Key('michiInfo_canvas_timeline')` を持つ `CustomPaint` ウィジェット上に描画されている

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 説明 |
|---|---|---|
| `Key('michiInfo_canvas_timeline')` | CustomPaint | `_MichiTimelineCanvas` を内包する CustomPaint ウィジェット |

---

## TC-RDT-002: 白破線センターラインが表示される

**前提:**
- TC-RDT-001 と同じ。Mark が2件以上存在するイベントを表示する

**操作手順:**
1. MichiInfo 画面を開く
2. タイムラインが表示されるまで待機する（最大15秒）

**期待結果:**
- `Key('michiInfo_canvas_timeline')` の CustomPaint ウィジェットが画面上に存在する
- `_MichiTimelineCanvas` の `shouldRepaint` が正しく動作し、スクロール後も再描画される

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 説明 |
|---|---|---|
| `Key('michiInfo_canvas_timeline')` | CustomPaint | 道路帯・センターラインを描画する CustomPaint |

> 注意: Integration Test では Canvas の描画内容をピクセル単位で直接検証できない。センターラインの存在確認は「CustomPaint ウィジェットが描画エラーなく存在すること」をもって代替する。

---

## TC-RDT-003: カード・ドットが道路帯の前面に表示される

**前提:**
- Mark と Link が各1件以上存在するイベントを表示する

**操作手順:**
1. MichiInfo 画面を開く
2. タイムラインが表示されるまで待機する（最大15秒）

**期待結果:**
- `Key('michiInfo_item_mark_{id}')` を持つ Mark カードウィジェットが画面上に存在する
- `Key('michiInfo_item_link_{id}')` を持つ Link カードウィジェットが画面上に存在する
- 両カードがヒットテストを通過する（タップ可能な状態にある）

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 説明 |
|---|---|---|
| `Key('michiInfo_item_mark_{id}')` | カードウィジェット | Mark カード（id は MarkLinkId の先頭8文字など一意な部分） |
| `Key('michiInfo_item_link_{id}')` | カードウィジェット | Link カード |

---

## TC-RDT-004: Mark が1件のみのとき道路帯が表示されない

**前提:**
- Mark が1件のみ、Link が0件のイベントを表示する
- `verticalLineStartRelY == verticalLineEndRelY` になる状態

**操作手順:**
1. MichiInfo 画面を開く
2. タイムラインが表示されるまで待機する（最大15秒）

**期待結果:**
- `Key('michiInfo_canvas_timeline')` の CustomPaint ウィジェットが画面上に存在する
- 道路帯描画が実行されないこと（描画エラーが発生しないことをもって確認）

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 説明 |
|---|---|---|
| `Key('michiInfo_canvas_timeline')` | CustomPaint | 道路帯なし状態の CustomPaint |
| `Key('michiInfo_item_mark_{id}')` | カードウィジェット | 1件のみの Mark カード |

---

## TC-RDT-005: 地点・区間を追加後も道路帯が正常に表示される

**前提:**
- 既存のイベントに Mark が2件以上存在する状態から開始する

**操作手順:**
1. MichiInfo 画面を開く
2. タイムラインが表示されるまで待機する（最大15秒）
3. 地点追加ボタン（`Key('michiInfo_button_addMark')`）をタップする
4. Mark 作成画面で保存して MichiInfo に戻る
5. タイムライン更新を待機する（最大10秒）

**期待結果:**
- 追加後の MichiInfo 画面で `Key('michiInfo_canvas_timeline')` の CustomPaint が描画エラーなく存在する
- 新しく追加した Mark カードが画面に表示される
- 挿入モーション終了後も道路帯の描画が崩れない

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 説明 |
|---|---|---|
| `Key('michiInfo_button_addMark')` | ボタン | 地点追加ボタン |
| `Key('michiInfo_canvas_timeline')` | CustomPaint | 追加後の道路帯 CustomPaint |
| `Key('michiInfo_item_mark_{id}')` | カードウィジェット | 追加された新しい Mark カード |

---

# End of Feature Spec
