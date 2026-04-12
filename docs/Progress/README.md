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
| [2026-04-08_seed_topic_payer_filter.md](./2026-04-08_seed_topic_payer_filter.md) | シードデータトピック追加・支払者参加者制限・イベント一覧トピック名表示 |
| [2026-04-08_michi_info_action_button.md](./2026-04-08_michi_info_action_button.md) | Phase 10完了：MichiInfoアクションボタンUI（⚡ボタン・状態バッジ・ボトムシート）8PASS/1SKIP |
- [2026-04-09](./2026-04-09_feat__MichiInfoアクションボタンUI実装完了_.md)
| [2026-04-09_payment_info_redesign.md](./2026-04-09_payment_info_redesign.md) | PaymentInfo UI 改善 + 支払いごとの精算セクション追加（TC-PIR-001〜014 全件PASS）|
| [2026-04-09_testflight_upload.md](./2026-04-09_testflight_upload.md) | TestFlight アップロード（1.0.0 (3)）・Podfile simulator スライス除去フック追加 |
| [2026-04-09_ui_fixes_and_refactor.md](./2026-04-09_ui_fixes_and_refactor.md) | 給油集計バグ修正・UI整理・NumericInputRow共通ウィジェット追加 |
| [2026-04-09_michi_info_add_button_test.md](./2026-04-09_michi_info_add_button_test.md) | MichiInfo追加ボタン改善・集計ページ整理 Integration Test 全3件PASS |
| [2026-04-09_michi_info_add_button_and_aggregation.md](./2026-04-09_michi_info_add_button_and_aggregation.md) | MichiInfo追加FABカラー・addMenuItems配列制御・集計時間セクション削除・TF 1.0.0(5) |
| [2026-04-09_payment_info_fab_fix.md](./2026-04-09_payment_info_fab_fix.md) | PaymentInfo追加ボタンテーマカラー修正・走行コスト割り勘タスクボード追加 |
| [2026-04-09_basic_info_trans_fuel_fix_test.md](./2026-04-09_basic_info_trans_fuel_fix_test.md) | BasicInfo燃費変換バグ修正 Integration Test 全2件PASS（TC-BTF-001〜002） |
| [2026-04-09_moving_cost_fuel_mode_req.md](./2026-04-09_moving_cost_fuel_mode_req.md) | movingCost燃費モード分離 要件書作成・仕様調査ルール追加 |
| [2026-04-09_moving_cost_fuel_mode_impl.md](./2026-04-09_moving_cost_fuel_mode_impl.md) | MovingCostFuelMode 実装・全8件PASS・TF 1.0.0(6) |
| [2026-04-09_permission_settings.md](./2026-04-09_permission_settings.md) | MichiMark・NomikaiShare 操作許可設定追加 |
| [2026-04-09_moving_cost_fuel_mode_test.md](./2026-04-09_moving_cost_fuel_mode_test.md) | MovingCostFuelMode Integration Test 全8件PASS（TC-FCM-001〜008） |
- [2026-04-10](./2026-04-10_test__TC_BTF_001_002_全件PASS確認_.md)
| [2026-04-10_michi_info_card_insert_test.md](./2026-04-10_michi_info_card_insert_test.md) | MichiInfoカード間挿入機能 Integration Test 全10件PASS（TC-MCI-001〜010） |
| [2026-04-10_overview_bugfix_basic_info_reorder.md](./2026-04-10_overview_bugfix_basic_info_reorder.md) | 概要集計バグ修正（movingCostEstimated discriminator修正・推計ガソリン代算出）・BasicInfo項目並び替え |
| [2026-04-10_fuel_efficiency_update_req.md](./2026-04-10_fuel_efficiency_update_req.md) | 燃費更新機能 要件書作成（REQ-fuel_efficiency_update） |
| [2026-04-10_integration_test_spec.md](./2026-04-10_integration_test_spec.md) | Integration Test 設計書整理・tester/workflowルール更新（41件・10グループ） |
| [2026-04-10_integration_test_fixes.md](./2026-04-10_integration_test_fixes.md) | Integration Test 修正（TC-MCI挿入モード対応・TS-03/04/05・TC-MAD-001〜008） |
- [2026-04-11](./2026-04-11_docs__pumpAndSettle__禁止ルールをCLA.md)
| [2026-04-11_session_progress.md](./2026-04-11_session_progress.md) | Phase11カード挿入・Phase13燃費更新 全完了・許可設定追加 |
| [2026-04-11_roadmap_renewal_and_cleanup.md](./2026-04-11_roadmap_renewal_and_cleanup.md) | SwiftUI資材削除・Roadmap再設計（Phase A〜E）・タスク追加（Phase 16・17） |
| [2026-04-11_fix__B1-B4バグ修正_IntTest全件PASS_TF予定.md](./2026-04-11_fix__B1-B4バグ修正_IntTest全件PASS_TF予定.md) | B-1〜B-4バグ修正・Integration Test 84PASS/0FAIL・TestFlight予定 |
| [2026-04-11_chore__テスト許可設定整理・ログ保存.md](./2026-04-11_chore__テスト許可設定整理・ログ保存.md) | テスト許可設定整理・TestLogsログ保存機能追加（MichiMark/NomikaiShare） |
| [2026-04-11_test__TC-MIB-001-005_InsertIndicator全件PASS.md](./2026-04-11_test__TC-MIB-001-005_InsertIndicator全件PASS.md) | MichiInfo InsertIndicator改善 TC-MIB-001〜005 全件PASS |
| [2026-04-11_feat__イベント削除機能.md](./2026-04-11_feat__イベント削除機能.md) | Phase 14完了：イベント削除機能（スワイプ削除・カスケード削除）3PASS/0FAIL |
| [2026-04-11_workflow__並行テスト実装フロー導入.md](./2026-04-11_workflow__並行テスト実装フロー導入.md) | 並行テストフロー導入・T-131 Spec作成・T-132〜134完了・エージェント強化 |
| [2026-04-11_test__TC-MCD-001-010_MichiInfoCard削除全件PASS.md](./2026-04-11_test__TC-MCD-001-010_MichiInfoCard削除全件PASS.md) | MichiInfo カード削除機能 TC-MCD-001〜010 9PASS/1SKIP/0FAIL |
| [2026-04-11_feat__PaymentInfo伝票削除機能.md](./2026-04-11_feat__PaymentInfo伝票削除機能.md) | Phase 17 PaymentInfo 伝票削除機能 実装・テスト完了（4PASS/1SKIP/0FAIL） |
| [2026-04-11_feat__Phase16_17_削除機能完了.md](./2026-04-11_feat__Phase16_17_削除機能完了.md) | Phase 16・17 削除機能完了セッションサマリー・次回やること |
| [2026-04-11_feat__R-1_メンバー未選択ガード完了.md](./2026-04-11_feat__R-1_メンバー未選択ガード完了.md) | R-1 メンバー未選択ガード・Slidable排他制御修正 完了 |
| [2026-04-11_feat__CustomNumericKeypad実装完了.md](./2026-04-11_feat__CustomNumericKeypad実装完了.md) | F-1 Phase 1 カスタム数値キーパッド実装・テスト全件PASS |
| [2026-04-11_feat__CustomNumericKeypad_Phase2_四則演算完了.md](./2026-04-11_feat__CustomNumericKeypad_Phase2_四則演算完了.md) | F-1 Phase 2 四則演算 19PASS/0FAIL 完了 |
| [2026-04-11_feat__CustomNumericKeypad_Phase3_完了.md](./2026-04-11_feat__CustomNumericKeypad_Phase3_完了.md) | F-1 Phase 3 確定ボタンラベル変更 5PASS/0FAIL 完了 |
| [2026-04-12_testflight__1_0_0_9_アップロード完了.md](./2026-04-12_testflight__1_0_0_9_アップロード完了.md) | TestFlight 1.0.0(9) アップロード完了（F-1 Phase1-3・R-1・Phase16/17含む） |
| [2026-04-12_fix__プラスボタンデザイン統一_TF10.md](./2026-04-12_fix__プラスボタンデザイン統一_TF10.md) | プラスボタンデザイン統一（オレンジ色・追加テキスト削除）+ TestFlight 1.0.0(10) |
| [2026-04-12_chore__タスクボード追加・要件書下書き作成.md](./2026-04-12_chore__タスクボード追加・要件書下書き作成.md) | B-5/UI-1〜5/REL-1 タスクボード追加・要件書下書き7件作成 |
| [2026-04-12_feat__R2-PhaseA-BasicInfo-インライン選択UI完了.md](./2026-04-12_feat__R2-PhaseA-BasicInfo-インライン選択UI完了.md) | R-2 Phase A BasicInfo インライン選択UI完了（TC-BII 12PASS/4SKIP） |
| [2026-04-12_feat__T201-PhaseB-Spec_B5-タブ切替追加モード修正.md](./2026-04-12_feat__T201-PhaseB-Spec_B5-タブ切替追加モード修正.md) | T-201 Phase B Spec作成・B-5 タブ切替追加モード修正（2PASS/0FAIL） |
| [2026-04-12_feat__R2-PhaseB-Detail画面メンバー選択インライン化.md](./2026-04-12_feat__R2-PhaseB-Detail画面メンバー選択インライン化.md) | R-2 Phase B MarkDetail・LinkDetail・PaymentDetail メンバー選択インライン化（T-202a完了） |
| [2026-04-12_feat__R2-PhaseB-全Detail画面メンバー選択インライン化完了.md](./2026-04-12_feat__R2-PhaseB-全Detail画面メンバー選択インライン化完了.md) | R-2 Phase B 全完了（22PASS/0FAIL/0SKIP） |
| [2026-04-12_testflight__1_0_0_11_R2-PhaseB完了アップロード.md](./2026-04-12_testflight__1_0_0_11_R2-PhaseB完了アップロード.md) | TestFlight 1.0.0(11) アップロード完了（R-2 Phase B・B-5含む） |
| [2026-04-12_chore__タスクボード追加_B6_UI6.md](./2026-04-12_chore__タスクボード追加_B6_UI6.md) | B-6 ガソリン支払い者チップ選択バグ・UI-6 概要タブセクション名タスク追加 |
| [2026-04-12_docs__UI1-UI5-要件書-Spec作成完了.md](./2026-04-12_docs__UI1-UI5-要件書-Spec作成完了.md) | UI-1〜UI-5 要件書・デザイン提案・Spec 全作成完了 |
| [2026-04-12_feat__T252a-UI5-Detail画面UI改善実装完了.md](./2026-04-12_feat__T252a-UI5-Detail画面UI改善実装完了.md) | T-252a UI-5 MarkDetail/LinkDetail/PaymentDetail UI改善 実装完了 |
| [2026-04-12_test__T261b-B6-ガソリン支払者チップ選択テストコード実装.md](./2026-04-12_test__T261b-B6-ガソリン支払者チップ選択テストコード実装.md) | T-261b B-6 ガソリン支払い者チップ選択 テストコード実装（TC-GPS-001〜008） |
| [2026-04-12_feat__T232a-UI3-MichiInfo削除UIアイコン常時表示実装.md](./2026-04-12_feat__T232a-UI3-MichiInfo削除UIアイコン常時表示実装.md) | T-232a UI-3 MichiInfo削除UI変更（スワイプ廃止・削除アイコン常時表示・給油ドット統合） |
| [2026-04-12_architect__T269-B6-PhaseC-Spec作成完了.md](./2026-04-12_architect__T269-B6-PhaseC-Spec作成完了.md) | T-269 B-6 Phase C Spec作成完了（ガソリン支払者インラインチップ選択） |
| [2026-04-12_test__T234-UI3-MichiInfo削除UIアイコンテスト全件PASS.md](./2026-04-12_test__T234-UI3-MichiInfo削除UIアイコンテスト全件PASS.md) | T-234 UI-3 MichiInfo削除UIアイコン Integration Test 5PASS/2SKIP/0FAIL |
| [2026-04-12_test__T244-UI4-PaymentInfo削除UIアイコンテスト全件PASS.md](./2026-04-12_test__T244-UI4-PaymentInfo削除UIアイコンテスト全件PASS.md) | T-244 UI-4 PaymentInfo削除UI変更 Integration Test 3PASS/0FAIL/0SKIP |
