# 2026-04-08 MichiInfo 日付セパレーター デザイン提案・要件書作成

## 完了した作業

### デザイン提案（designer）
- MichiInfo 一覧画面に日付を表示する配置案を4候補で比較
- **候補B「日付セパレーター方式」** を推奨・採用決定
  - 日付が変わるタイミングにセパレーター行を挿入
  - 背景: `#EAF5F4`、テキスト: `#2D6A6A`、区切り線: `#B2DFDB`
  - Markカードの高さは変えない（情報密度維持）
- HTMLレポート: `docs/Design/draft/2026-04-08_michi_info_date_placement.html`

### 要件書作成（architect）
- `docs/Requirements/REQ-michi_info_date_separator.md` 作成
- 日付フォーマット: `4月6日（土）`（複数年またぎ時は `2026年4月6日（土）`）
- `Day N` 表示は Phase 2 拡張としてスコープ外

### タスクボード更新
- T-068〜T-072 を Phase 6 に追加（T-068/069 は DONE、T-070 は TODO）

## 未完了

- T-070: MichiInfo 日付セパレーター Spec 作成（architect、`TODO`）
- T-071: 実装（`BLOCKED`）
- T-072: レビュー（`BLOCKED`）

## 次回セッションで最初にやること

1. **architect に T-070 の Spec 作成を依頼**
   - `MarkLinkItemProjection` に日付フィールドが存在するか確認
   - なければ Projection への追加を Spec に含める
2. Spec 確認後 → flutter-dev で実装（T-071）
