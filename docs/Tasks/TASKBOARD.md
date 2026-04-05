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
| T-010 | `flutter run` で全Feature動作確認（イベント一覧・詳細・マーク・リンク・支払） | flutter-dev | `IN_PROGRESS` | 2026-04-03_phase2_verification | |
| T-011 | 設定Feature動作確認（Trans/Member/Tag/Action） | flutter-dev | `IN_PROGRESS` | 2026-04-03_phase2_verification | T-010と同時着手 |
| T-012 | drift データ保存・再起動後の永続化確認 | flutter-dev | `IN_PROGRESS` | 2026-04-03_phase2_verification | T-010と同時着手 |

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

## Phase 3: 機能追加・仕上げ

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-020 | EventList Feature 実装（Spec作成 → 実装 → レビュー） | architect / flutter-dev / reviewer | `TODO` | | 現状スタブのみ |
| T-021a | イベント新規作成フロー Spec作成（EventCreateWithTopic_Spec.md） | architect | `DONE` | | REQ-event_create_with_topic 対応 |
| T-021b | イベント新規作成フロー実装（Topic選択BottomSheet・BasicInfoBloc初期化・ルーター対応） | flutter-dev | `DONE` | | Spec: EventCreateWithTopic_Spec.md |
| T-021c | イベント新規作成フロー レビュー | reviewer | `DONE` | | 修正1件（fetchByType戻り値統一）対応済み |
| T-022 | マスターデータ初期投入（Trans/Member/Tag/Action のデフォルトデータ） | flutter-dev | `TODO` | | |
| T-023 | app_id / Bundle ID / アイコン等の設定 | orchestrator | `TODO` | | ストア公開準備 |
| T-030 | MichiInfo レイアウト変更 Spec作成 | architect | `DONE` | | 要件書: docs/Requirements/REQ-michi_info_layout.md |
| T-031 | MichiInfo レイアウト変更 実装 | flutter-dev | `DONE` | | T-030完了後 |
| T-032 | MichiInfo レイアウト変更 レビュー | reviewer | `DONE` | | T-031完了後 |

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
