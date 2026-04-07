# 進捗記録: MichiInfo Flutter Stack + 統合 CustomPainter レイアウト実装

- 作成日: 2026-04-07
- セッション: MichiInfo Flutter ZStack 相当実装・TestFlight 初回アップロード

---

## 背景

SwiftUI 側では Canvas + ZStack 構成で MichiInfo タイムラインを再設計済み（68af4a1）。
ユーザーから「Flutter 側も同じ ZStack 相当の構造にしてほしい」との要望があり対応。

---

## 実施内容

### Spec 更新（architect）

- `docs/Spec/Features/MichiInfo_Layout_Spec.md` を v1.0 → **v2.0** に更新
- Widget 構造を「統合 CustomPainter + Stack overlay」構成に変更
- `_cardHeight = 72.0` 定数の導入
- テストシナリオ（TS-01〜07）を追加

### 実装（flutter-dev）

コミット: `746e82c`

**廃止したクラス:**
- `_GroupData` / `_buildGroups()`
- `_MarkGroup` / `_TimelineGroupConnector` / `_TimelineGroupConnectorPainter`
- `_BubbleCardPainter` / `_MarkCard` / `_LinkCard`
- `_GroupDistanceArrows` / `_ArrowWithText`

**新規追加クラス:**
- `_cardHeight = 72.0`（ファイルスコープ定数）
- `_TimelineItem` — `Stack( CustomPaint, overlay )` 構造で1行を構成
- `_MichiTimelinePainter` — カード背景・縦線・ドット・三角ポインター・水平接続線を1つの CustomPainter で描画
- `_TimelineItemOverlay` — テキスト・タップ領域を overlay として配置
- `_DistanceColumn` — メーター差分・区間距離の表示

**維持したクラス:**
- `_MarkActionButtons` / `_DistanceLegend` / `_VerticalArrowPainter`

### レビュー（reviewer）

- 結果: **PASS**
- 設計憲章・Spec v2.0 に完全準拠

### Integration Test（tester）

コミット: `425a8a8`

- テストファイル: `flutter/integration_test/michi_info_layout_test.dart`
- 全7シナリオ PASS（TS-01〜07）
- iOS シミュレーター対応: `SUPPORTED_PLATFORMS` に `iphonesimulator` を追加

---

## TestFlight 初回アップロード

- `flutter build ipa` でビルド成功（21.7MB）
- App Store Connect にアプリレコードを新規作成
- Transporter 経由でアップロード成功

---

## 手動確認が必要な項目（目視確認）

| 確認項目 |
|---|
| 縦線・ドット・三角ポインター・カード背景が1つの CustomPainter で描画されている |
| Link 区間の縦線が太く表示される（色変更なし） |
| Mark 行に三角ポインター付き吹き出しカード |
| Link 行に角丸カード＋水平接続線 |
| 画面右上の凡例がスクロールしても固定表示される |

---

## 未完了

- 手動確認（TestFlight 実機での目視確認）
- ローンチ画像がデフォルトのまま（審査提出前に要差し替え）

---

## 次回セッションで最初にやること

1. TestFlight 実機インストール → MichiInfo タブの目視確認
2. T-010 Phase2 動作確認の継続
3. ローンチ画像の作成・設定（審査提出前）
