# デザイン叩き: トピックテーマカラー 10色パレット

作成日: 2026-04-05
作成者: designer
ステータス: PM確認待ち
バージョン: v2.0（10色パレット版）

---

## 提案概要

MichiMarkロゴのメインカラー（スチールティールブルー `#2B7A9B`、H=200° S=56% L=39%）を起点として、
ユーザーがトピックごとにテーマカラーを選択できる仕様に対応した **10色パレット** を設計した。

**設計方針:**
- 色相環（360°）を10分割（約36°間隔）して色相を均等分散
- ロゴカラー H=200° は No.7 「ブランドティール」としてパレットに含む（ブランドカラー兼用）
- すべての色が彩度 S=45〜65%・明度 L=36〜55% の範囲でモバイルUIのアクセントカラーとして適切な深みを持つ
- Material 3 のPrimaryカラーとして使用できる輝度レベルを維持

**現在の2トピックへの推奨:**
- movingCost → No.5 エメラルドグリーン `#2E9E6B`（H=155°、ロゴから-45°の同系色展開）
- travelExpense → No.2 アンバーオレンジ `#E07B39`（H=30°、ロゴの分割補色方向）

---

## 10色パレット定義

| No | 色名（日本語） | HEX (Primary) | HEX (Dark) | HEX (Tint) | Flutter Color | 推奨トピック用途 |
|---|---|---|---|---|---|---|
| 1 | コーラルレッド | #D94F4F | #A83030 | #FADADD | Color(0xFFD94F4F) | 緊急・警告・重要費目 |
| 2 | アンバーオレンジ | #E07B39 | #B85C20 | #FDEBD4 | Color(0xFFE07B39) | 出張・旅行・活動系 |
| 3 | ゴールデンイエロー | #C4A43A | #9A7C22 | #F5ECC8 | Color(0xFFC4A43A) | 食費・エンタメ・プレミアム |
| 4 | フレッシュグリーン | #4DB36B | #2D8A4C | #D2F0DC | Color(0xFF4DB36B) | 健康・環境・節約 |
| 5 | エメラルドグリーン | #2E9E6B | #1A7A52 | #D4F0E4 | Color(0xFF2E9E6B) | 通勤・日常移動・継続費目 |
| 6 | ティールグリーン | #1E8A8A | #136868 | #C8ECEC | Color(0xFF1E8A8A) | 公共交通・水・インフラ |
| 7 | ブランドティール | #2B7A9B | #1A4A5E | #D0EBF5 | Color(0xFF2B7A9B) | ロゴカラー・汎用デフォルト |
| 8 | インディゴブルー | #3D65C4 | #2245A0 | #D3DCF5 | Color(0xFF3D65C4) | 業務・コーポレート・IT |
| 9 | バイオレットパープル | #7B5CC4 | #5A3EA0 | #E2D8F5 | Color(0xFF7B5CC4) | 趣味・エンタメ・特別用途 |
| 10 | ローズピンク | #C4497A | #9E2A58 | #F5D2E0 | Color(0xFFC4497A) | 個人・ライフスタイル・プライベート |

---

## 色相環上の配置

```
色相  0°: No.1  コーラルレッド      #D94F4F
色相 30°: No.2  アンバーオレンジ    #E07B39  ← travelExpense 推奨
色相 60°: No.3  ゴールデンイエロー  #C4A43A
色相 90°: No.4  フレッシュグリーン  #4DB36B
色相155°: No.5  エメラルドグリーン  #2E9E6B  ← movingCost 推奨
色相180°: No.6  ティールグリーン    #1E8A8A
色相200°: No.7  ブランドティール    #2B7A9B  ← ロゴカラー
色相225°: No.8  インディゴブルー    #3D65C4
色相260°: No.9  バイオレットパープル #7B5CC4
色相330°: No.10 ローズピンク        #C4497A
```

---

## 現在のトピックへの推奨割り当て

### movingCost → No.5 エメラルドグリーン
- Primary: `#2E9E6B`
- Dark: `#1A7A52`
- Tint: `#D4F0E4`
- 理由: ロゴのティールブルー（H=200°）から色相-45°に位置するエメラルドグリーン（H=155°）。同系色の展開でアプリ全体の統一感を保ちながら、緑の「継続・安定・日常」のニュアンスが通勤・通学など毎日の移動費という用途と一致する。ロゴとの色相差が45°で近すぎず遠すぎないバランスを保てる。

### travelExpense → No.2 アンバーオレンジ
- Primary: `#E07B39`
- Dark: `#B85C20`
- Tint: `#FDEBD4`
- 理由: ロゴのティールブルーの分割補色（H=200° + 190° = H=30°）に当たるアンバーオレンジ。寒色のティールと暖色のオレンジは高いコントラストを持ち、movingCostとの識別も明確。オレンジの「活動・旅情・エネルギー」が出張・旅行という非日常感と直感的に一致する。

---

## 将来トピック追加時の色選択ガイドライン

| トピックの性質 | 推奨カラーNo | 色名 | 理由 |
|---|---|---|---|
| 日常系（通勤・通学） | No.5 | エメラルドグリーン | 継続・安定・日常の緑。毎日の移動費に自然なイメージ |
| 旅行系（旅行・出張） | No.2 | アンバーオレンジ | 活動・旅情・非日常感。travelExpenseの直感的イメージ |
| 業務系（経費・精算・IT） | No.8 | インディゴブルー | コーポレート・信頼・プロフェッショナルの青 |
| 健康系（医療・運動） | No.4 | フレッシュグリーン | 健康・自然・活力を表す明るいグリーン |
| 食費系（飲食・グルメ） | No.3 | ゴールデンイエロー | 食欲・プレミアム感を演出するゴールド |
| 趣味系（エンタメ・娯楽） | No.9 | バイオレットパープル | 創造性・非日常・特別感のパープル |
| 個人系（プライベート） | No.10 | ローズピンク | 個人・親密さ・ライフスタイルのピンク |
| 緊急系（修理・緊急出費） | No.1 | コーラルレッド | 注意・緊急・重要性を伝える赤系 |
| 公共系（インフラ・交通） | No.6 | ティールグリーン | 公共性・信頼感を表すティール系 |
| ブランド汎用（デフォルト） | No.7 | ブランドティール | ロゴカラー本人。未分類・汎用デフォルト色 |

---

## 実装メモ（architectへの引き継ぎ）

### TopicThemeColor 列挙型の定義（Dart）

```dart
/// MichiMark トピックテーマカラー 10色パレット
enum TopicThemeColor {
  // No.1 コーラルレッド (H=0°)
  coralRed(
    primary: Color(0xFFD94F4F),
    dark:    Color(0xFFA83030),
    tint:    Color(0xFFFADADD),
  ),
  // No.2 アンバーオレンジ (H=30°) ← travelExpense 推奨
  amberOrange(
    primary: Color(0xFFE07B39),
    dark:    Color(0xFFB85C20),
    tint:    Color(0xFFFDEBD4),
  ),
  // No.3 ゴールデンイエロー (H=60°)
  goldenYellow(
    primary: Color(0xFFC4A43A),
    dark:    Color(0xFF9A7C22),
    tint:    Color(0xFFF5ECC8),
  ),
  // No.4 フレッシュグリーン (H=90°)
  freshGreen(
    primary: Color(0xFF4DB36B),
    dark:    Color(0xFF2D8A4C),
    tint:    Color(0xFFD2F0DC),
  ),
  // No.5 エメラルドグリーン (H=155°) ← movingCost 推奨
  emeraldGreen(
    primary: Color(0xFF2E9E6B),
    dark:    Color(0xFF1A7A52),
    tint:    Color(0xFFD4F0E4),
  ),
  // No.6 ティールグリーン (H=180°)
  tealGreen(
    primary: Color(0xFF1E8A8A),
    dark:    Color(0xFF136868),
    tint:    Color(0xFFC8ECEC),
  ),
  // No.7 ブランドティール (H=200°) ← ロゴカラー
  brandTeal(
    primary: Color(0xFF2B7A9B),
    dark:    Color(0xFF1A4A5E),
    tint:    Color(0xFFD0EBF5),
  ),
  // No.8 インディゴブルー (H=225°)
  indigoBlue(
    primary: Color(0xFF3D65C4),
    dark:    Color(0xFF2245A0),
    tint:    Color(0xFFD3DCF5),
  ),
  // No.9 バイオレットパープル (H=260°)
  violetPurple(
    primary: Color(0xFF7B5CC4),
    dark:    Color(0xFF5A3EA0),
    tint:    Color(0xFFE2D8F5),
  ),
  // No.10 ローズピンク (H=330°)
  rosePink(
    primary: Color(0xFFC4497A),
    dark:    Color(0xFF9E2A58),
    tint:    Color(0xFFF5D2E0),
  );

  const TopicThemeColor({
    required this.primary,
    required this.dark,
    required this.tint,
  });

  final Color primary;
  final Color dark;
  final Color tint;
}
```

### SeedData割り当て
- movingCost: `TopicThemeColor.emeraldGreen`
- travelExpense: `TopicThemeColor.amberOrange`

### UI実装方針
- 選択UIはColorPicker風のグリッド（2×5 または 5×2）
- 選択中の色は白枠線（width: 3dp）でハイライト + チェックマークアイコン表示
- TopicDomain.color フィールドに `TopicThemeColor` の `name`（String）を保存
- WidgetはProjectionレイヤー経由でColor値を受け取る（Widgetから直接enumを参照しない）

### EventListカードへの適用方法
- 左ボーダー: `Container(width: 4, color: themeColor.primary)`
- 金額テキスト: `themeColor.primary` を適用
- 背景Tint: オプション（`themeColor.tint.withOpacity(0.3)` 程度）

### EventDetailヘッダーへの適用方法
- `LinearGradient(colors: [themeColor.dark, themeColor.primary])`
- グラデーション方向: `begin: Alignment.topLeft, end: Alignment.bottomRight`
- テキスト・アイコン: すべて `Colors.white`

---

## 参照

- HTMLデザインレポート: `docs/Design/2026-04-05_topic_color_proposal.html`
- 関連要件: REQ-007（EventListカードアクセントカラー）、REQ-008（EventDetailヘッダーテーマカラー）
