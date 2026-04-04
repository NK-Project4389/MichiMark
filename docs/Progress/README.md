# 進捗記録ディレクトリ

## 目的

- 作業ログをセッションごとに記録する
- 次回の会話開始時に読み込むことでコンテキスト消費を抑える

## 運用ルール

- ファイル名: `YYYY-MM-DD_[作業内容].md`
- 新しいセッション開始時に最新のログを参照してから作業開始する
- 完了した作業・未完了の作業・次回やること を必ず記載する

## ファイル一覧

| ファイル | 内容 |
|---|---|
| [2026-03-24_initial_setup.md](./2026-03-24_initial_setup.md) | リポジトリClone・CLAUDE.md整備・進捗記録ディレクトリ作成 |
| [2026-03-26_flutter_setup.md](./2026-03-26_flutter_setup.md) | Flutterプロジェクト初期セットアップ・フォルダ構造作成 |
| [2026-03-27_basic_info_feature.md](./2026-03-27_basic_info_feature.md) | basic_info Feature実装・EventDetail全タブ一括保存仕様の記録 |
| [2026-03-27_selection_feature.md](./2026-03-27_selection_feature.md) | selection Feature実装・InMemoryスタブ・go vs push 憲章追記 |
| [2026-03-27_mark_detail_feature.md](./2026-03-27_mark_detail_feature.md) | mark_detail Feature実装・michi_info eventId対応・router追加 |
| [2026-03-28_spec_and_role_rules.md](./2026-03-28_spec_and_role_rules.md) | SwiftUI Spec確認・TCA→Flutter用語課題整理・CLAUDE.md役割ルール更新 |
| [2026-03-29_link_detail_feature.md](./2026-03-29_link_detail_feature.md) | link_detail Feature実装・router追加 |
| [2026-03-29_fuel_detail_feature.md](./2026-03-29_fuel_detail_feature.md) | fuel_detail Feature実装・product-managerロール追加・MarkDetail/LinkDetail更新 |
| [2026-03-29_payment_detail_feature.md](./2026-03-29_payment_detail_feature.md) | payment_detail Feature実装・Spec Delegate追加・router更新 |
| [2026-03-29_payment_info_feature.md](./2026-03-29_payment_info_feature.md) | payment_info Feature実装・EventDetailPage組み込み |
| [2026-03-29_new_mark_link_routes.md](./2026-03-29_new_mark_link_routes.md) | マーク/リンク新規作成ルート追加・MichiInfoView TODO解消 |
| [2026-03-29_settings_features.md](./2026-03-29_settings_features.md) | 設定系Feature（Trans/Member/Tag/Action）Spec作成・実装・router追加 |
| [2026-03-30_event_detail_save.md](./2026-03-30_event_detail_save.md) | EventDetail全タブ一括保存（§17）実装 |
| [2026-03-30_uuid_new_entity_spec.md](./2026-03-30_uuid_new_entity_spec.md) | UUID化・新規エンティティ作成フロー Spec設計（方針A採用） |
| [2026-03-29_roadmap_planning.md](./2026-03-29_roadmap_planning.md) | ロードマップ策定・マネタイズ戦略・法人対応設計考慮事項 |
| [2026-03-31_react_discussion_uuid_check.md](./2026-03-31_react_discussion_uuid_check.md) | React換装検討（Flutter継続決定）・UUID実装確認（未完了確認） |
| [2026-04-01_uuid_implementation.md](./2026-04-01_uuid_implementation.md) | UUID化・新規エンティティ作成フロー実装・レビュー修正完了 |
| [2026-04-02_mark_link_draft_apply.md](./2026-04-02_mark_link_draft_apply.md) | MarkDetail/LinkDetail Draft反映フロー・MichiInfoView接続・MarkLinkDraftAdapter |
| [2026-04-03_phase1_completion.md](./2026-04-03_phase1_completion.md) | Phase 1完了：InMemory seed data・drift Repository・get_it DI |
| [2026-04-03_phase2_verification.md](./2026-04-03_phase2_verification.md) | Phase 2動作確認・GoRouterルート順序バグ修正 |
- [2026-04-04_chore](./2026-04-04_chore__要件vsバグ判断ルール_push時自動進捗登録.md) | CLAUDE.mdルール追加・push時自動進捗hook
- [2026-04-04_michi_info_layout](./2026-04-04_michi_info_layout.md) | MichiInfoタイムライン型レイアウト実装完了
