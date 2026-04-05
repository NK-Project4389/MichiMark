# デザイン叩き: トピックカラー設計

作成日: 2026-04-05
作成者: designer
ステータス: PM確認待ち

---

## 提案概要

MichiMarkロゴのメインカラー（スチールティールブルー `#2B7A9B`、H=200° S=56% L=39%）を起点として、
2つの TopicType（movingCost / travelExpense）に対し色彩理論に基づいた専用カラーを設計した。

**選定方針:**
- movingCost（通勤・日常移動）→ ロゴの同系色方向（H=155〜180°）の緑ティール系。「継続・安定・日常」の印象を持つ落ち着いた色。
- travelExpense（出張・旅行）→ ロゴの分割補色方向（H=25〜32°）のアンバーオレンジ系。「活動・旅情・特別感」の印象を持つ暖色系。

ロゴカラーとの調和（色相環上の同系色・補色関係）を保ちながら、2トピックが視覚的に明確に区別できることを優先した。

---

## 推奨パターン（採用候補）: Pattern A

### movingCost カラー
- カラーコード: `#2E9E6B`（緑ティール、H=155°）
- Dark（グラデーション起点）: `#1A7A52`
- Tint（背景薄色）: `#D4F0E4`
- 理由: ロゴのティールブルーから同系色方向（Hue -45°）に展開した緑ティール。通勤・通学など毎日の移動という「継続・安定・日常」のニュアンスを自然な緑系で表現。ロゴとの色相距離が近いため、アプリ全体の統一感を保てる。

### travelExpense カラー
- カラーコード: `#E07B39`（アンバーオレンジ、H=25°）
- Dark（グラデーション起点）: `#B85C20`
- Tint（背景薄色）: `#FDEBD4`
- 理由: ロゴティールブルーの分割補色（Hue +180°±15°）に当たるアンバーオレンジ。ティールと補色関係にあるため高いコントラストを持ちつつ、暖色系の「活動・旅情・非日常感」がtravelExpenseのユースケースと一致する。

---

## 代替パターン

### Pattern B: ブルー系統一 × パープル分岐
- movingCost: `#3B82C4`（ロイヤルブルー）/ `#2256A0`（Dark）/ `#D6E8F8`（Tint）
- travelExpense: `#9B5EA8`（パープル）/ `#6B3580`（Dark）/ `#EEE0F4`（Tint）
- 特徴: コーポレートライクで落ち着いた印象。全体が寒色でまとまる。2トピックの区別は明確だが、ロゴとの補色コントラストが弱くなる。

### Pattern C: ダブルティール × アンバーゴールド
- movingCost: `#1E8A8A`（純ティール）/ `#136868`（Dark）/ `#C8ECEC`（Tint）
- travelExpense: `#D4914A`（アンバーゴールド）/ `#9E6830`（Dark）/ `#F8E6CC`（Tint）
- 特徴: movingCostにロゴと直系のティールを使うためブランド一体感が最も高い。travelExpenseが落ち着いたアンバーゴールドで上品な仕上がり。Aより全体的に彩度が低くシックだが、活発さは減る。

---

## 実装メモ（architectへの引き継ぎ）

### TopicDomain.color フィールドに設定する値（Pattern A推奨）

```
movingCost.color    = 0xFF2E9E6B
travelExpense.color = 0xFFE07B39
```

### TopicConfig.themeColor の Flutter Color 値

```dart
// movingCost
const Color movingCostColor     = Color(0xFF2E9E6B);
const Color movingCostDark      = Color(0xFF1A7A52);
const Color movingCostTint      = Color(0xFFD4F0E4);

// travelExpense
const Color travelExpenseColor  = Color(0xFFE07B39);
const Color travelExpenseDark   = Color(0xFFB85C20);
const Color travelExpenseTint   = Color(0xFFFDEBD4);
```

### EventListカードへの適用方法

- 左ボーダーとして幅 4dp の縦線を使用（`Container(width: 4, color: topic.themeColor)`）
- 背景への Tint 適用は任意（`tintColor.withOpacity(0.3)` 程度を検討）

### EventDetailヘッダーへの適用方法

- ヘッダー全体に `LinearGradient(colors: [darkColor, primaryColor])` を適用
- テキスト・アイコンカラーはすべて `Colors.white`（白）
- グラデーション方向: `begin: Alignment.topLeft, end: Alignment.bottomRight`

### アーキテクチャ上の考慮

- `TopicType` enum に `themeColor` ゲッターを追加するか、TopicConfig クラスに color フィールドを持たせる設計を推奨
- Projection レイヤーで `TopicType` → `Color` のマッピングを行い、Widget は Projection から受け取る

---

## 参照

- HTMLデザインレポート: `docs/Design/2026-04-05_topic_color_proposal.html`
- 関連要件: REQ-007（EventListカードアクセントカラー）、REQ-008（EventDetailヘッダーテーマカラー）
