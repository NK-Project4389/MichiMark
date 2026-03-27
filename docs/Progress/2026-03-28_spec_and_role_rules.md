# 2026-03-28 Spec確認・役割ルール更新

## 完了した作業

### SwiftUI Spec → Flutter 解釈確認

以下のSpecファイルを確認した。

- `docs/Spec/Features/EventDetail/EventDetail_Spec.md`
- `docs/Spec/Features/EventDetail/MarkDetail/MarkDetailFeature_Spec.md`
- `docs/Spec/Features/EventDetail/LinkDetail/LinkDetailFeature_Spec.md`
- `docs/Spec/Features/EventDetail/PaymentDetail/PaymentDetailFeature_Spec.md`
- `docs/Spec/Features/EventDetail/PaymentInfo/PaymentInfoFeature_Spec.md`

### 確認で判明したSpec課題（未修正・architect対応待ち）

#### 全Specに共通：TCA用語がそのまま残っている

| TCA/SwiftUI用語 | Flutter BLoC正しい用語 |
|---|---|
| `XxxReducer.Action` | `XxxEvent`（sealed class） |
| `appeared`（Action） | `Started`（Event） |
| `delegate`（Action列挙の一員） | `XxxDelegate`（Stateのフィールド、Eventではない） |
| `XxxReducer.State` | `XxxState` |
| `XxxReducer.Delegate` | `XxxDelegate`（sealed class、Stateに内包） |

#### EventDetail Spec 固有

- `CoreReducer` という概念 → Flutter BLocに直接対応する構造なし。設計方針の確定が必要
- `OverviewFeature` → 設計憲章のFeature一覧に未記載。実装スコープ外かどうか要確認

#### PaymentInfo Spec

- `"\\(total) 円"` → Swift文字列補完がそのまま。Dartでは `'$total 円'` に修正が必要

### CLAUDE.md 役割ルール更新

- **Spec駆動開発ルール** セクションを新設
  - `architect` がSpecを作成・更新する責務を明記
  - `flutter-dev` はSpec参照を義務化、Spec不足・曖昧時はarchitectに差し戻しを義務化
- **実装・レビューサイクルルール** を更新
  - フローに `architect（Spec作成）` を追加
  - 役割の侵食禁止テーブルに `architect` を追加
- **reviewerのレビュー観点** を強化
  - カテゴリ別に整理（アーキテクチャ違反 / 型安全・Null安全 / 非同期・ビジネスロジック / **Spec整合性**）
  - Spec整合性チェック（フィールド名・型・Delegate構造の一致）を追加
- **役割一覧テーブル** を説明更新
- **ドキュメント参照テーブル** に `docs/Spec/Features/` を追加

---

## 未完了の作業 / 次回やること

### Spec修正（architect担当）

1. 全SpecのTCA用語 → Flutter BLoC用語へ書き換え
2. EventDetail Spec の `CoreReducer` → Flutter設計方針確定・記述更新
3. EventDetail Spec の `OverviewFeature` → スコープ判断・記述調整
4. PaymentInfo Spec の Swift文字列補完を Dart記法に修正

### 実装タスク（優先順・flutter-dev担当）

1. link_detail Feature 実装（Spec修正後）
2. fuel_detail Feature（mark_detail のサブ機能）
3. payment_detail Feature
4. payment_info タブ（EventDetail）
5. マーク/リンク新規作成ルート（`/event/mark/new`, `/event/link/new`）
6. EventDetail 全タブ一括保存（§17）
7. InMemory スタブへのテストデータ投入（seed data）
8. drift Repository 実装（永続化）
9. get_it DI セットアップ
10. 設定系 Feature（trans_setting, member_setting, tag_setting, action_setting）
