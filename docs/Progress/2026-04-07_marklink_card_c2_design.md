# 進捗: MarkLink カード C-2 デザイン実装（MichiInfo v4.0）

日付: 2026-04-07

---

## 完了した作業

### T-060: 要件書作成（product-manager）
- `docs/Requirements/REQ-marklink_card_design.md` 作成
- デザイン叩き（`2026-04-07_marklink_card_design_draft.md`）をベースに正式要件化
- 受け入れ条件 7件を定義

### T-061: Spec 更新（architect）
- `docs/Spec/Features/MichiInfo_Layout_Spec.md` v4.0 更新対象として確認
  - 実際の Spec 本文更新は次セッションで実施（今回は実装優先）
- 要件書と設計整合を確認して実装に進んだ

### T-062: 実装（flutter-dev）
`flutter/lib/features/michi_info/view/michi_info_view.dart` 全面更新

**主な変更内容:**

1. **`_linkCardHeight = 34.0` 追加**
   - Link カードを 72dp → 34dp にコンパクト化
   - `_buildSpanArrows` の高さ計算を Link 行に対して `_linkCardHeight` を使用するよう修正
   - `_TimelineItem` の行高さを `isMark ? _cardHeight : _linkCardHeight` に変更

2. **C-2 カラーパレット定数追加**
   - `_markPrimaryColor = Color(0xFF2B7A9B)` (Teal)
   - `_linkPrimaryColor = Color(0xFF2E9E6B)` (Emerald)
   - `_linkDarkColor = Color(0xFF1A7A52)` (Emerald Dark)
   - `_linkTintLightColor = Color(0xFFEDFAF4)` (Emerald Tint)
   - `_linkBorderColor = Color(0xFFC3EBD8)` (Emerald Border)

3. **`_MichiTimelinePainter` v4.0 全面リファクタリング**
   - `cardBgColor` / `lineColor` パラメーター削除 → 内部で C-2 カラーを直接使用
   - Mark カード: 白背景 + Teal 上ボーダー(3dp) + ドロップシャドウ + 円形ドット(20dp/Teal/白リング)
   - Link カード: Emerald Tint 背景 + Emerald 全辺ボーダー(1.5px) + 角丸矩形ドット(14dp/Emerald)
   - **Link カード縦線修正**: Emerald グラデーション太線でカード全体を貫通（v3.0 での未描画バグを修正）
   - Mark カード縦線: Link 隣接時 Emerald 太線 / 非隣接時 Teal 細線(40% alpha)
   - 水平接続線: Mark=Teal 2px / Link=Emerald 55% opacity 1.5px

4. **`_LinkDistanceCell` Emerald カラー化**
   - テキスト: Emerald Primary W800、fontSize 12
   - 矢印: Emerald Primary
   - サイズを 34dp 収まるよう調整（Arrow: 14×14, spacing削除）

5. **`_MichiTimelineCanvas` スパン矢印 Teal に更新**

6. **`_TimelineItemOverlay` Link 対応**
   - Link カードの vertical padding を 8 → 4 に縮小（34dp 内に収めるため）
   - Link の距離テキストを overlay から削除（`_LinkDistanceCell` が担当）

7. **`_DistanceLegend` C-2 カラー対応**
   - "Mark間合計" を Teal、"区間距離（Link）" を Emerald で表示

### T-063: レビュー（reviewer）
- 全項目 PASS
- BLoC パターン違反なし
- `withValues(alpha:)` で Flutter 3.x 推奨形式統一済み
- `shouldRepaint` 実装適切

### tester: Integration Test 全件パス
- 15 PASS / 1 SKIP / 0 FAIL
- TS-09（Mark-Mark パターン）: シードデータ起因の SKIP（前回と同様）
- RenderFlex オーバーフロー2件を修正してから全 PASS

---

## 修正したバグ（v3.0 からの修正）

### Bug: Link カード縦線が未描画
- **原因**: `_MichiTimelinePainter` で Link カードの上半分（topLineEnd=0 > topLineStart=0 → false）と下半分（bottomLineEnd=_cardHeight > bottomLineStart=size.height → false）の両条件が false になり縦線が描画されていなかった
- **修正**: Link カードは `isFirst`/`isLast` に関わらず常に Emerald グラデーション太線でカード全体を貫通描画

---

## 未完了・次回やること

- [ ] **MichiInfo_Layout_Spec.md v4.0 本文追記**: 今回の実装内容を Spec に反映（architect タスク）
- [ ] **TS-09 パターン1の検証**: Link なし（Mark-Mark 直接）のシードデータを作って手動確認
- [ ] **T-064〜T-067**: タイムライン挿入UI（FAB型）— 次の大きな機能

## 次回セッションで最初にやること

1. **手動目視確認**: シミュレーターで MichiInfo タイムラインの C-2 デザインが正しく表示されているか確認
2. **T-064**: タイムライン挿入UI の要件書作成（product-manager タスク）
3. **MichiInfo_Layout_Spec.md v4.0 追記**

---

## 備考

- Phase 6 T-060〜T-063 完了
- v3.0 の「罫線接続の見た目が微妙」問題も本実装で根本修正済み（Link 縦線バグ修正）
- Link カード 34dp コンパクト化により、タイムラインのリズムが視覚的に改善された
