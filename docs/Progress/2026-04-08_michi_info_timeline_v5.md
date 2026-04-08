# 進捗: MichiInfo タイムライン UI v5.0（縦線分離・矢印位置・距離右配置・Mark-Mark間隔）

日付: 2026-04-08

---

## 完了した作業
- fix: MichiInfo タイムライン 区間距離未表示・縦線タブはみ出し・距離テキスト中央揃え修正 (79b3677)
- feat: MichiInfo タイムライン UI v5.0（縦線分離・矢印位置・距離右配置・Mark-Mark間隔） (78aa044)

### Round 2 UI フィードバック 4件を実装

`flutter/lib/features/michi_info/view/michi_info_view.dart` を全面更新。

#### 1. タイムライン縦線の分離描画

- **旧**: 各カードの `_MichiTimelinePainter` が自分のカード内だけ縦線を描画 → カード間の隙間で途切れる
- **新**: `_MichiTimelineCanvas` が全体を担当
  - 細い Teal 線（40% alpha）をリスト先頭〜末尾まで途切れなく描画
  - Link カード区間のみ Emerald グラデーション太線をオーバーレイ
  - `_MichiTimelinePainter` から縦線描画ロジックを完全削除

#### 2. スパン矢印の始終点変更

- **旧**: 上 Mark 中心 Y → 下 Mark 中心 Y
- **新**: 上 Mark 底辺 Y → 下 Mark 上辺 Y
- `SpanArrowData.startY = yOffsets[i] + cardHeightList[i]`
- `SpanArrowData.endY = yOffsets[j]`

#### 3. Mark カード幅の拡張

- `_MichiTimelinePainter` の Mark カード右余白を `_cardRight: 8 → _markCardRight: 0` に変更
- Mark カードが Expanded エリア右端まで延伸（距離表示エリアの手前まで）
- Link カードは従来通り `_linkCardRight: 8`

#### 4. 距離表示の右側集約

- **旧**: 区間距離が左列（`_LinkDistanceCell`）、メーター差分が右列（スパン矢印と同一）
- **新**: 両方ともスパン列（右側）に配置
  - メーター差分テキスト: 矢印上端の右側（上）
  - 区間距離テキスト: Link カード中心 Y の右側（下）
- `_LinkDistanceCell` Widget を廃止
- `_linkDistanceColumnWidth` 定数を廃止
- Row レイアウト: Mark・Link 両行とも `[Expanded card] [SizedBox(width: 72)]`

#### 5. Mark-Mark 直接隣接時の間隔拡大

- 新定数 `_markMarkGap = 50.0` 追加
- `_buildTimelineData()` で Mark→Mark 直接隣接を検出し、`_markMarkGap` を適用
- `_TimelineItem` に `gapAfter` パラメーターを追加（`_itemGap` の定数を直接使わない設計）

### アーキテクチャ改善

- `_buildSpanArrows()` → `_buildTimelineData()` にリネーム・機能拡張
- 戻り値を `_TimelineData` クラスにまとめ（spans / linkSegments / linkDistances / gapAfterItem / totalContentHeight）
- `_buildIsSpanLink()` を廃止（縦線描画不要になったため）
- `_MichiTimelinePainter` から `isFirst`, `isLast`, `isLinkActive` パラメーターを削除

### テスト結果

- **15 PASS / 1 SKIP / 0 FAIL**
- TS-09（Mark-Mark パターン）: シードデータ起因の SKIP（前回と同様）
- `dart analyze`: 0 issues

---

## 追加修正（Round 3・同日）

1. **縦線範囲制限**: 始点ドット中心〜終点ドット中心のみ描画
2. **Mark カード幅を右端まで拡張**: Mark 行の SizedBox を削除
3. **距離テキスト縦中央揃え + 1 テキストボックス統合**: `linkDistanceTexts` を `SpanArrowData` に内包し、スパン矢印の縦中央に 1 つの TextPainter でまとめて表示
4. **区間距離未表示バグ修正**: スパン外 Link の距離を `standaloneLinkDistances` で表示
5. **縦線タブはみ出し修正**: `Positioned.fill(top: 48)` + `ClipRect` でクリップ

テスト: 15 PASS / 1 SKIP / 0 FAIL

---

## 未完了・次回やること

- [ ] **MichiInfo_Layout_Spec.md v5.0 追記**: v4→v5 変更内容の Spec 反映（architect タスク）
- [ ] **TS-09 パターン1の検証**: Mark-Mark 直接のシードデータを作って手動確認
- [ ] **T-064〜T-067**: タイムライン挿入UI（FAB型）— 次の大きな機能

## 次回セッションで最初にやること

1. **手動目視確認**: シミュレーターで縦線・矢印位置・距離表示が意図通りか確認
2. **T-064**: タイムライン挿入UI の要件書作成（product-manager タスク）
3. **MichiInfo_Layout_Spec.md v5.0 追記**

---

## 備考

- v4.0（C-2 デザイン）の上に Round 2 UI フィードバックを重ねて v5.0 として完成
- カード間隙間による縦線途切れ問題を根本解決（分離描画）
- メーター差分・区間距離を右側に集約してレイアウトをシンプル化
