# MichiMark タスクボード

## 運用ルール

1. **セッション開始時に必ずこのファイルを読む**
2. `IN_PROGRESS` のタスクには別セッションは手を出さない
3. タスクを着手するとき → `status` を `IN_PROGRESS`、`locked_by` に `YYYY-MM-DD_[作業内容]` を記入
4. 完了したとき → `status` を `DONE`、`locked_by` を空欄に
5. 着手できない状態のとき → `status` を `BLOCKED`、`notes` に理由を記入

## ステータス凡例

| status | 意味 |
|---|---|
| `TODO` | 未着手・着手可能 |
| `IN_PROGRESS` | 別セッションが作業中 → 触らない |
| `DONE` | 完了 |
| `BLOCKED` | ブロックあり（依存タスク未完了など） |

---

## Phase 1: データ永続化（drift + get_it）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-001 | drift Repository 実装（テーブル定義・DAO・Repository impl） | flutter-dev | `DONE` | | Spec: `docs/Spec/Features/DriftRepository_Spec.md` |
| T-002 | drift Repository レビュー | reviewer | `DONE` | | レビュー指摘修正済み |
| T-003 | get_it DI セットアップ（InMemory → drift 切り替え） | flutter-dev | `DONE` | | |
| T-004 | get_it DI レビュー | reviewer | `DONE` | | レビュー指摘修正済み |

## Phase 2: 動作確認

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-010 | `flutter run` で全Feature動作確認（イベント一覧・詳細・マーク・リンク・支払） | flutter-dev | `DONE` | | Phase 3〜10 の開発・テストを通じて確認済み |
| T-011 | 設定Feature動作確認（Trans/Member/Tag/Action） | flutter-dev | `DONE` | | Phase 3〜10 の開発・テストを通じて確認済み |
| T-012 | drift データ保存・再起動後の永続化確認 | flutter-dev | `DONE` | | Phase 3〜10 の開発・テストを通じて確認済み |

## Phase 4: Topic / ActionTime / Aggregation / EventDetailOverview 実装

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-040 | Topic Feature 実装 | flutter-dev | `DONE` | | Spec: `docs/Spec/Features/Topic_Spec.md` |
| T-041 | ActionTime Feature 実装 | flutter-dev | `DONE` | | Spec: `docs/Spec/Features/ActionTime_Spec.md` |
| T-042 | Aggregation Feature 実装 | flutter-dev | `DONE` | | Spec: `docs/Spec/Features/Aggregation_Spec.md` |
| T-043 | EventDetailOverview Feature 実装 | flutter-dev | `DONE` | | Spec: `docs/Spec/Features/EventDetailOverview_Spec.md` |
| T-044 | Topic / ActionTime / Aggregation / EventDetailOverview レビュー | reviewer | `DONE` | | レビュー指摘4件修正済み（2026-04-05）|
| T-045 | OverviewBloc OverviewStarted 発火問題解決 | flutter-dev | `DONE` | | EventDetailStateにcachedEventを追加・EventDetailPageのBlocListenerでOverviewStarted発火 |

## Phase 5: Topic・Action 設計再定義

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-050 | Topic・Action再定義 Spec作成 | architect | `DONE` | | REQ-001〜006対応済み。REQ-007/008カラー枠のみ確保 |
| T-051 | Topic・Action再定義 実装 | flutter-dev | `DONE` | | REQ-001〜006完了。REQ-007/008はデザイン確定後 |
| T-052 | Topic・Action再定義 レビュー | reviewer | `DONE` | | 全項目PASS。アーキテクチャ違反なし |
| T-053 | EventListカード色・EventDetailテーマカラー デザイン提案 | designer | `DONE` | | HTMLレポート・叩きMD作成済み。ユーザー確認待ち |
| T-054 | EventListカード色・EventDetailテーマカラー Spec作成 | architect | `DONE` | | v2.1更新済み。TopicThemeColor enum・EventList/EventDetail適用Spec追加 |
| T-055 | EventListカード色・EventDetailテーマカラー 実装 | flutter-dev | `DONE` | | REQ-007/008完了。TopicThemeColor enum・カード左ボーダー・AppBarグラデーション |

## Phase 6: MichiInfo タイムライン UI リニューアル

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-060 | MarkLink カードデザイン要件書作成（C-2スタイル・距離カード外表示） | product-manager | `DONE` | | 要件書: `docs/Requirements/REQ-marklink_card_design.md` |
| T-061 | MarkLink カードデザイン Spec 作成 | architect | `DONE` | | MichiInfo_Layout_Spec.md v4.0 更新対象（Spec追記は次セッションで実施） |
| T-062 | MarkLink カードデザイン 実装 | flutter-dev | `DONE` | | C-2カラー・Link 34dp・縦線修正・ドット変更 |
| T-063 | MarkLink カードデザイン レビュー | reviewer | `DONE` | | 全項目PASS。アーキテクチャ違反なし |
| T-064 | タイムライン挿入UI（FAB型）要件書作成 | product-manager | `DONE` | | デザイン提案: `docs/Design/2026-04-07_marklink_insert_button_proposal.html`。T-060と並行可 |
| T-065 | タイムライン挿入UI（FAB型）Spec 作成 | architect | `DONE` | | T-064完了後 |
| T-066 | タイムライン挿入UI（FAB型）実装 | flutter-dev | `DONE` | | T-065完了後 |
| T-067 | タイムライン挿入UI（FAB型）レビュー | reviewer | `DONE` | | T-066完了後 |
| T-068 | MichiInfo 日付セパレーター デザイン提案 | designer | `DONE` | | デザイン提案: `docs/Design/draft/2026-04-08_michi_info_date_placement.html` |
| T-069 | MichiInfo 日付セパレーター 要件書作成 | product-manager | `DONE` | | 要件書: `docs/Requirements/REQ-michi_info_date_separator.md` |
| T-070 | MichiInfo 日付セパレーター Spec 作成 | architect | `DONE` | | |
| T-071 | MichiInfo 日付セパレーター 実装 | flutter-dev | `DONE` | | |
| T-072 | MichiInfo 日付セパレーター レビュー | reviewer | `DONE` | | |

## Phase 7: 地点追加初期値・引き継ぎ・メンバー制限・メーター同期

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-073 | 地点追加初期値・引き継ぎ Spec作成 | architect | `DONE` | | REQ-mark_addition_defaults（REQ-MAD-001〜005）対応 |
| T-074 | 地点追加初期値・引き継ぎ 実装 | flutter-dev | `DONE` | | Spec: `docs/Spec/Features/EventDetail/MarkDetail/MarkAdditionDefaults_Spec.md` |
| T-075 | 地点追加初期値・引き継ぎ レビュー | reviewer | `DONE` | | |
| T-076 | 地点追加初期値・引き継ぎ テスト | tester | `DONE` | | 全8件PASS（TC-MAD-001〜008） |

## Phase 8: テストデータ更新

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-080 | シードデータ更新（トピック設定・Overview確認データ・MichiInfoパターン） | flutter-dev | `DONE` | | |
| T-081 | シードデータ更新 レビュー | reviewer | `DONE` | | |

---

## Phase 3: 機能追加・仕上げ

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-020 | EventList Feature 実装（Spec作成 → 実装 → レビュー） | architect / flutter-dev / reviewer | `DONE` | | 実機確認済み |
| T-021a | イベント新規作成フロー Spec作成（EventCreateWithTopic_Spec.md） | architect | `DONE` | | REQ-event_create_with_topic 対応 |
| T-021b | イベント新規作成フロー実装（Topic選択BottomSheet・BasicInfoBloc初期化・ルーター対応） | flutter-dev | `DONE` | | Spec: EventCreateWithTopic_Spec.md |
| T-021c | イベント新規作成フロー レビュー | reviewer | `DONE` | | 修正1件（fetchByType戻り値統一）対応済み |
| T-022 | マスターデータ初期投入（Trans/Member/Tag/Action のデフォルトデータ） | flutter-dev | `DONE` | | |
| T-023 | app_id / Bundle ID / アイコン等の設定 | orchestrator | `DONE` | | |
| T-030 | MichiInfo レイアウト変更 Spec作成 | architect | `DONE` | | 要件書: docs/Requirements/REQ-michi_info_layout.md |
| T-031 | MichiInfo レイアウト変更 実装 | flutter-dev | `DONE` | | T-030完了後 |
| T-032 | MichiInfo レイアウト変更 レビュー | reviewer | `DONE` | | T-031完了後 |

## Phase 9: EventDetail 概要タブ再設計

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-090 | EventDetail 概要タブ再設計 Spec作成 | architect | `DONE` | | REQ-event_detail_overview_redesign 対応 |
| T-091 | EventDetail 概要タブ再設計 実装 | flutter-dev | `DONE` | | T-090完了後 |
| T-092 | EventDetail 概要タブ再設計 レビュー | reviewer | `DONE` | | T-091完了後 |
| T-093 | EventDetail 概要タブ再設計 テスト | tester | `DONE` | | 12 PASS / 3 SKIP（シードデータ未整備）/ 0 FAIL |

## Phase 10: MichiInfo アクションボタン UI

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-094 | MichiInfo アクションボタン UI 要件書作成 | product-manager | `DONE` | | 要件書: `docs/Requirements/REQ-michi_info_action_button.md` |
| T-095 | MichiInfo アクションボタン UI Spec作成 | architect | `DONE` | | Spec: `docs/Spec/Features/MichiInfo/ActionTimeButton_Spec.md` |
| T-096 | MichiInfo アクションボタン UI 実装 | flutter-dev | `DONE` | | |
| T-097 | MichiInfo アクションボタン UI レビュー | reviewer | `DONE` | | 全項目PASS |
| T-098 | MichiInfo アクションボタン UI テスト | tester | `DONE` | | 全9件（8 PASS / 1 SKIP） |

## Phase 11: MichiInfo タイムライン カード挿入機能

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-099 | カード挿入機能 要件書作成 | product-manager | `DONE` | | 要件書: `docs/Requirements/REQ-michi_info_card_insert.md` |
| T-100 | カード挿入機能 Spec作成 | architect | `BLOCKED` | | T-099完了後 |
| T-101 | カード挿入機能 実装 | flutter-dev | `BLOCKED` | | T-100完了後 |
| T-102 | カード挿入機能 レビュー | reviewer | `BLOCKED` | | T-101完了後 |
| T-103 | カード挿入機能 テスト | tester | `BLOCKED` | | T-102完了後 |

## Phase 12: movingCost 概要タブ 走行コスト割り勘

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-110 | 走行コスト割り勘 UIデザイン確定 | designer | `DONE` | | 燃費推計vs給油実績をTopicTypeレベルで分離する案Cを採用 |
| T-111 | 走行コスト割り勘 要件書作成 | product-manager | `DONE` | | 要件書: `docs/Requirements/REQ-moving_cost_fuel_mode.md` |
| T-112 | 走行コスト割り勘 Spec作成 | architect | `DONE` | | Spec: `docs/Spec/Features/MovingCostFuelMode_Spec.md` |
| T-113 | 走行コスト割り勘 実装 | flutter-dev | `DONE` | | schemaVersion 4・movingCostEstimated追加・gasPayer追加 |
| T-114 | 走行コスト割り勘 レビュー | reviewer | `DONE` | | 全項目PASS |
| T-115 | 走行コスト割り勘 テスト | tester | `DONE` | | TC-FCM-001〜008 全件PASS |

## Phase 13: 燃費更新機能（別フェーズ）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-120 | 燃費更新機能 要件書作成 | product-manager | `TODO` | | 交通手段マスターのkmPerGasを概要タブから更新する機能 |
| T-121 | 燃費更新機能 Spec作成 | architect | `BLOCKED` | | T-120完了後 |
| T-122 | 燃費更新機能 実装 | flutter-dev | `BLOCKED` | | T-121完了後 |
| T-123 | 燃費更新機能 レビュー | reviewer | `BLOCKED` | | T-122完了後 |
| T-124 | 燃費更新機能 テスト | tester | `BLOCKED` | | T-123完了後 |

---

## 完了済みタスク（アーカイブ）

| ID | タスク | 完了日 | notes |
|---|---|---|---|
| A-001 | リポジトリ Clone・CLAUDE.md 整備・進捗記録ディレクトリ作成 | 2026-03-24 | |
| A-002 | Flutter プロジェクト初期セットアップ・フォルダ構造作成 | 2026-03-26 | |
| A-003 | 設計憲章・アーキテクチャ図・Spec テンプレート整備 | 2026-03-28 | |
| A-004 | basic_info Feature 実装 | 2026-03-27 | EventDetail 全タブ一括保存仕様含む |
| A-005 | selection Feature 実装 | 2026-03-27 | InMemory スタブ・go vs push 憲章追記 |
| A-006 | mark_detail Feature 実装 | 2026-03-27 | michi_info eventId 対応・router 追加 |
| A-007 | link_detail Feature 実装 | 2026-03-29 | router 追加 |
| A-008 | fuel_detail Feature 実装 | 2026-03-29 | MarkDetail/LinkDetail 更新含む |
| A-009 | payment_detail Feature 実装 | 2026-03-29 | Spec Delegate 追加・router 更新 |
| A-010 | payment_info Feature 実装 | 2026-03-29 | EventDetailPage 組み込み |
| A-011 | マーク/リンク 新規作成ルート追加 | 2026-03-29 | MichiInfoView TODO 解消 |
| A-012 | 設定系 Feature 実装（Trans/Member/Tag/Action） | 2026-03-29 | Spec + 実装 + router |
| A-013 | EventDetail 全タブ一括保存（§17）実装 | 2026-03-30 | |
| A-014 | UUID 化・新規エンティティ作成フロー実装 | 2026-04-01 | 方針 A 採用・レビュー修正完了 |
| A-015 | MarkDetail/LinkDetail Draft 反映フロー実装 | 2026-04-02 | MichiInfoView 接続・MarkLinkDraftAdapter 追加 |
| A-016 | InMemory seed data 投入（動作確認用ダミーデータ） | 2026-04-02 | |
| A-017 | drift Repository Spec 作成 | 2026-04-03 | `docs/Spec/Features/DriftRepository_Spec.md` |
