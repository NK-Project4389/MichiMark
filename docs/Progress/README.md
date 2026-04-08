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
| [2026-04-05_requirements_topic_actiontime_aggregation.md](./2026-04-05_requirements_topic_actiontime_aggregation.md) | 要件書作成：Topic / ActionTime / Aggregation |
| [2026-04-05_topic_actiontime_aggregation_impl.md](./2026-04-05_topic_actiontime_aggregation_impl.md) | Topic / ActionTime / Aggregation / EventDetailOverview 実装・レビュー完了 |
| [2026-04-05_topic_action_redesign_requirements.md](./2026-04-05_topic_action_redesign_requirements.md) | Topic・Action設計再定義 要件書作成（REQ-topic_action_redesign） |
| [2026-04-05_claudecode_statusbar.md](./2026-04-05_claudecode_statusbar.md) | ClaudeCode ステータスバー修正（週次プログレスバー・リセット時間表示） |
| [2026-04-05_topic_color_impl.md](./2026-04-05_topic_color_impl.md) | REQ-007/008 トピックテーマカラー実装（EventListカード左ボーダー・EventDetailヘッダーグラデーション） |
| [2026-04-05_phase5_topic_action_redesign.md](./2026-04-05_phase5_topic_action_redesign.md) | Phase 5完了：Topic・Action再定義・10色パレット・カラー実装・全レビューPASS |
| [2026-04-05_event_create_topic_impl.md](./2026-04-05_event_create_topic_impl.md) | EventCreateWithTopic実装：Topic選択BottomSheet・BasicInfoBloc初期化・ルーター対応 |
| [2026-04-05_event_create_with_topic.md](./2026-04-05_event_create_with_topic.md) | イベント新規作成時のトピック選択フロー 完全完了（要件書・Spec・実装・レビュー） |
- [2026-04-06](./2026-04-06_docs__進捗ファイルにバグ修正内容を追記.md)
- [2026-04-07](./2026-04-07_fix__基本画面のトピック項目を非表示に変更.md)
| [2026-04-07_event_detail_save_bugfix.md](./2026-04-07_event_detail_save_bugfix.md) | イベント詳細画面 保存バグ修正（タグハンドラ未登録・actionTimeLogs消失） |
| [2026-04-07_michi_canvas_layout.md](./2026-04-07_michi_canvas_layout.md) | MichiInfo タイムラインUI Canvas/Path 全面再設計 |
| [2026-04-07_payment_payer_fixed_selection.md](./2026-04-07_payment_payer_fixed_selection.md) | 割り勘メンバー選択で支払者を常にON固定・非活性化 |
| [2026-04-07_tester_agent_setup.md](./2026-04-07_tester_agent_setup.md) | testerエージェント追加・Integration Test基盤整備 |
| [2026-04-07_michi_info_stack_layout.md](./2026-04-07_michi_info_stack_layout.md) | MichiInfo Flutter Stack+統合CustomPainter実装・TestFlight初回アップロード |
| [2026-04-07_xcode_build_fix.md](./2026-04-07_xcode_build_fix.md) | Xcode ビルドエラー調査（integration_test 削除・xcscheme 修正） |
| [2026-04-07_marklink_card_design.md](./2026-04-07_marklink_card_design.md) | MarkLink カードデザイン提案（C-2採用・FAB型挿入UI）・タスクボードPhase 6追加 |
| [2026-04-07_michi_info_timeline_redesign.md](./2026-04-07_michi_info_timeline_redesign.md) | MichiInfo タイムライン UI 再設計 v3.0（罫線接続・スパン矢印距離表示・B案 CustomScrollView 採用） |
| [2026-04-07_marklink_card_c2_design.md](./2026-04-07_marklink_card_c2_design.md) | MarkLink カード C-2 デザイン実装（MichiInfo v4.0: Teal/Emerald カラー・Link 34dp コンパクト） |
- [2026-04-08](./2026-04-08_feat__MichiInfo_v4_0_C_2_デザイン実.md)
| [2026-04-08_michi_info_timeline_v5.md](./2026-04-08_michi_info_timeline_v5.md) | MichiInfo タイムライン UI v5.0（縦線分離・矢印位置・距離右配置・Mark-Mark間隔） |
| [2026-04-08_michi_info_date_separator_design.md](./2026-04-08_michi_info_date_separator_design.md) | MichiInfo 日付セパレーター デザイン提案・要件書作成（T-068〜069完了） |
| [2026-04-08_settings_bugfix_and_visibility.md](./2026-04-08_settings_bugfix_and_visibility.md) | 設定ページ戻るバグ修正・非表示セクションヘッダー・選択リスト非表示フィルター |
| [2026-04-08_mark_addition_defaults_test.md](./2026-04-08_mark_addition_defaults_test.md) | T-076完了：地点追加初期値・引き継ぎ Integration Test 全8件PASS |
| [2026-04-08_event_detail_overview_redesign.md](./2026-04-08_event_detail_overview_redesign.md) | EventDetail 概要タブ再設計（タブ3つ・インライン編集・即DB保存・テスト12 PASS）|
