---
date: 2026-04-07
title: MarkLink カードデザイン提案・タイムライン挿入UI設計
---

# 完了した作業

## デザイン提案（designer）

### 1. MarkLink カード 初回提案
- `docs/Design/2026-04-07_marklink_card_design_proposal.html`
- A（ミニマル）/ B（ビジュアル重視）/ C（タイムライン連結）/ D（ダークモード）4パターン提案
- カラー設計: Mark=Teal `#2B7A9B` / Link=Emerald `#2E9E6B`

### 2. C案バリエーション（距離カード外表示）
- `docs/Design/2026-04-07_marklink_card_c_variants.html`
- C-1〜C-4の4バリエーション
- フィードバック反映: 距離情報はカードの外（タイムライン線上）に配置する制約を適用

### 3. Linkカード短縮＋余白に距離表示（v2）
- `docs/Design/2026-04-07_marklink_card_c_v2.html`
- V1（コンパクト中・上余白バッジ）/ V2（超コンパクト・右端距離数値）/ V3（バーライン・縦線沿いテキスト）
- フィードバック: 「Linkカードだけ短くして、余白に距離を持ってくる」

### 4. タイムライン挿入UI（FAB型）提案
- `docs/Design/2026-04-07_marklink_insert_button_proposal.html`
- P1（常時表示型）/ P2（タップ展開型）/ P3（FAB型）の3パターン
- 推奨: P3 FAB型（閲覧と編集モードの明確な分離）
- 挿入ボタンカラー: Amber `#F59E0B`

### 5. 要件の叩き（v4.0まで累積更新）
- `docs/Design/draft/2026-04-07_marklink_card_design_draft.md`

## タスクボード更新

- Phase 6「MichiInfo タイムライン UI リニューアル」を新設
- T-060〜T-067 を `BLOCKED` で追加
- 関連作業（Phase 2動作確認）完了後に着手予定

---

# 未完了・継続事項

- Phase 2 動作確認（T-010〜012）: IN_PROGRESS のまま（別セッション）
- デザイン方針の最終確認: C-2ベースでユーザー合意済み、FAB型（P3）も合意済み

---

# 次回セッションで最初にやること

1. **Phase 2動作確認（T-010〜012）の状況確認** → 完了していれば T-060（MarkLinkカード要件書作成）に着手
2. T-060: product-manager が要件書を作成（叩きMD v4.0 を元に）
3. T-064: タイムライン挿入UI 要件書作成（T-060と並行可）
