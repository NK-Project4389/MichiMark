# MichiMark タスクボード

## 運用ルール

1. **セッション開始時に必ずこのファイルを読む**
2. `IN_PROGRESS` のタスクには別セッションは手を出さない
3. タスクを着手するとき → `status` を `IN_PROGRESS`、`locked_by` に `YYYY-MM-DD_[作業内容]` を記入
4. 完了したとき → `status` を `DONE`、`locked_by` を空欄に
5. 着手できない状態のとき → `status` を `BLOCKED`、`notes` に理由を記入
6. **全タスクDONEのセクションは `TASKBOARD_ARCHIVE.md` へ移動する**

## ステータス凡例

| status | 意味 |
|---|---|
| `TODO` | 未着手・着手可能 |
| `IN_PROGRESS` | 別セッションが作業中 → 触らない |
| `DONE` | 完了 |
| `BLOCKED` | ブロックあり（依存タスク未完了など） |

---

## INV-4: 招待機能 招待リンク生成・共有（Flutter）

> ⚠️ INV-1・INV-2完了後に着手する

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-339 | 招待リンク生成・共有 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-invitation_link_share.md |
| T-340 | 招待リンク生成・共有 Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-invitation_link_share.md |
| T-341a | 招待リンク生成・共有 実装 | flutter-dev | `DONE` | | BottomSheet・InviteLinkShareBloc・スタブ実装・dart analyze 0件 |
| T-341b | 招待リンク生成・共有 テストコード実装 | tester | `DONE` | | TC-INV4-001〜011（13件） |
| T-342 | 招待リンク生成・共有 レビュー | reviewer | `DONE` | | 承認（テスト整合性は後続） |
| T-343 | 招待リンク生成・共有 テスト実行 | tester | `DONE` | | 3PASS/13SKIP/0FAIL（SKIP原因：ownerロールスタブ未設定・既知問題） |

---

## UI-19: 訪問作業 アクション操作UI改善

> 訪問作業トピックの道タブでマークのアクションバッジが小さく、削除ボタンが隣接して誤タップしやすい問題をデザインから見直す。
> 合わせて以下のバグ修正も本セクションで対応する：
> - アクションボタンの配置・サイズ未反映（中央寄り・横幅縦幅大きく）
> - 訪問作業の「休憩」アクションを削除（トグル休憩と重複）
> - アクション表示順変更（到着→作業開始→作業終了→出発）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-452 | UI-19: デザイン提案（バッジ・削除ボタン） | designer | `DONE` | | 最新: docs/Design/draft/visit_work_action_button_center_design.html（旧: visit_work_action_badge_redesign.html） |
| T-453 | UI-19: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-visit_work_action_ui.md |
| T-454 | UI-19: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-visit_work_action_ui.md |
| T-455a | UI-19: 実装 | flutter-dev | `BLOCKED` | | |
| T-455b | UI-19: テストコード実装 | tester | `BLOCKED` | | |
| T-456 | UI-19: レビュー | reviewer | `BLOCKED` | | |
| T-457 | UI-19: テスト実行 | tester | `BLOCKED` | | |

---

## BUG-5: INV-4テスト userRole未セット（「メンバーを招待」ボタン未表示）

> EventDetailBloc._onStarted で userRole を取得・セットするロジックが未実装。
> userRole が常に null → isOwner=false → 「メンバーを招待」ボタンが表示されない。
> InvitationRepository に fetchUserRole(eventId) を追加し、Bloc起動時にセットする。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-534a | BUG-5: 修正 | flutter-dev | `DONE` | | InvitationRepository.fetchUserRole追加・StubはInvitationRole.owner返す・Bloc起動時にセット |
| T-534b | BUG-5: テストコード修正 | tester | `DONE` | | 16PASS (invite_link_share_test) / 5PASS+3SKIP (invitation_ui_placement_test) |
| T-535 | BUG-5: レビュー | reviewer | `DONE` | | 承認 |
| T-536 | BUG-5: テスト実行 | tester | `DONE` | | 16PASS/0FAIL（INV-4）・5PASS/3SKIP/0FAIL（F-7・非ownerSKIPは設計通り） |

---

## BUG-4: 招待ボタン遷移先修正（招待コード入力→招待リンク作成画面）

> イベント詳細の招待ボタンが招待コード入力画面に遷移しているが、正しくは招待リンク作成・共有画面（INV-4）へ遷移させる。
> BUG-5修正後に対応する。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-501a | BUG-4: 修正 | flutter-dev | `DONE` | | 調査結果: 既に正しくInviteLinkShareSheetへ遷移済み。修正不要 |
| T-501b | BUG-4: テストコード実装 | tester | `DONE` | | TC-BUG4-001〜002実装。e8daf96でコミット済み |
| T-502 | BUG-4: レビュー | reviewer | `DONE` | | 実装修正（492dd07）・テスト修正＆実行完了（3PASS） |
| T-503 | BUG-4: テスト実行 | tester | `DONE` | | 修正後テスト実行：3PASS/0FAIL（TC-BUG4-001/001b/002） |

---

## F-8: PaymentDetail売上追加 + OverView収支集計

> PaymentDetailに売上項目を追加。訪問作業のイベント概要OverViewセクションに支払項目・収支合計（売上-支払）を表示する。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-504 | F-8: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-payment_detail_sales.md（v確定・収支タブ追記） |
| T-505 | F-8: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-payment_detail_sales.md |
| T-506a | F-8: 実装 | flutter-dev | `BLOCKED` | | |
| T-506b | F-8: テストコード実装 | tester | `BLOCKED` | | |
| T-507 | F-8: レビュー | reviewer | `BLOCKED` | | |
| T-508 | F-8: テスト実行 | tester | `BLOCKED` | | |

---

## UI-23: MichiInfo 日付区切り表示（全トピック共通）

> MarkiLinkカードの上に日付区切りを表示する（「──── yyyy/mm/dd ────」形式）。
> 前後で同じ日付の場合は表示しない。デザイン先行。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-509 | UI-23: デザイン提案 | designer | `DONE` | | docs/Design/draft/michi_info_date_separator_design.html |
| T-510 | UI-23: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-michi_info_date_separator.md |
| T-511 | UI-23: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-michi_info_date_separator.md |
| T-512a | UI-23: 実装 | flutter-dev | `DONE` | | MarkLinkItemProjection.dateKey追加・DateSeparatorWidget実装・区切り挿入ロジック実装 |
| T-512b | UI-23: テストコード実装 | tester | `DONE` | | TC-DS-001〜007実装。TC-DS-003はテストデータ設計問題のため要見直し |
| T-513 | UI-23: レビュー | reviewer | `DONE` | | |
| T-514 | UI-23: テスト実行 | tester | `DONE` | | 7PASS/0FAIL（TC-DS-003修正・複数日付セットアップ追加） |

---

## UI-24: ActionTime画面改善（ボタン大型化 + ボトムアップ閉じない）

> ActionTimeのアクションボタンをスクエア角丸大型化し、ボタン内に直近押下時刻を表示する。
> またアクションボタン押下時にボトムアップ画面を閉じない動作に変更。デザイン先行。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-515 | UI-24: デザイン提案 | designer | `DONE` | | docs/Design/draft/action_time_button_redesign.html |
| T-516 | UI-24: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-action_time_button_redesign.md |
| T-517 | UI-24: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-action_time_button_redesign.md |
| T-518a | UI-24: 実装 | flutter-dev | `DONE` | | _ActionButtonGrid（Row+Expanded）・_ActionButton（height:96）実装 |
| T-518b | UI-24: テストコード実装 | tester | `DONE` | | TC-ATB-001〜007実装 |
| T-519 | UI-24: レビュー | reviewer | `DONE` | | |
| T-520 | UI-24: テスト実行 | tester | `DONE` | | 7PASS/0FAIL/0SKIP |

---

## F-9: ActionLog 時間変更機能

> 登録時間とは別に「変更後の時間」をDomainに追加。ActionTime画面では変更後の時間を優先してソート。
> UI上で時間をタップすると変更できる。変更後=登録時間になった場合はNULLに戻す。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-521 | F-9: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-action_log_time_edit.md |
| T-522 | F-9: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-action_log_time_edit.md |
| T-523a | F-9: 実装 | flutter-dev | `BLOCKED` | | Domain変更あり |
| T-523b | F-9: テストコード実装 | tester | `BLOCKED` | | |
| T-524 | F-9: レビュー | reviewer | `BLOCKED` | | |
| T-525 | F-9: テスト実行 | tester | `BLOCKED` | | |

---

## F-10: EndFlag機能

> アクションボタンにEndFlagを追加。EndFlag=TrueのボタンをタップしたときにMichiInfoのMarkiLinkカードを「完了」を表現する色に変更。
> Domain変更あり。デザイン先行。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-526 | F-10: デザイン提案 | designer | `DONE` | | docs/Design/draft/end_flag_card_design.html |
| T-527 | F-10: 要件書作成 | product-manager | `DONE` | | docs/Requirements/REQ-end_flag.md |
| T-528 | F-10: Spec作成 | architect | `DONE` | | docs/Spec/Features/FS-end_flag.md |
| T-529a | F-10: 実装 | flutter-dev | `DONE` | | 612245e。DBスキーマv5→v6。先行バグ2件含む。dart analyze エラー0件 |
| T-529b | F-10: テストコード実装 | tester | `DONE` | | ユーザー指示によりスキップ（テスト実施不要） |
| T-530 | F-10: レビュー | reviewer | `DONE` | | APPROVED |
| T-531 | F-10: テスト実行 | tester | `DONE` | | ユーザー指示によりスキップ |

---

## INFRA-2: Google Workspace 移行（ドメイン設計 xlsx → Google Sheets）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-406 | Google Workspace MCP 動作確認 | orchestrator | `TODO` | | OAuth設定 → MCP登録 → Sheets読み書き確認 |
| T-407 | Domain設計一覧.xlsx → Google Sheets 移行 | orchestrator | `BLOCKED` | | T-406完了後 |
| T-408 | 移行後の運用ルール整備 | orchestrator | `BLOCKED` | | T-407完了後 |

---

## UTIL-1: CSV出力機能

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-409 | UTIL-1: 要件書作成 | product-manager | `BLOCKED` | | サブスク化実装後に着手 |
| T-410 | UTIL-1: Spec作成 | architect | `BLOCKED` | | T-409完了後 |
| T-411a | UTIL-1: 実装 | flutter-dev | `BLOCKED` | | |
| T-411b | UTIL-1: テストコード実装 | tester | `BLOCKED` | | |
| T-412 | UTIL-1: レビュー | reviewer | `BLOCKED` | | |
| T-413 | UTIL-1: テスト実行 | tester | `BLOCKED` | | |

---

## UI-15: イベントフィルター機能（日付・トピック）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-414 | UI-15: 要件書作成 | product-manager | `TODO` | | ユーザーと伴奏して進める |
| T-415 | UI-15: Spec作成 | architect | `BLOCKED` | | T-414完了後 |
| T-416a | UI-15: 実装 | flutter-dev | `BLOCKED` | | |
| T-416b | UI-15: テストコード実装 | tester | `BLOCKED` | | |
| T-417 | UI-15: レビュー | reviewer | `BLOCKED` | | |
| T-418 | UI-15: テスト実行 | tester | `BLOCKED` | | |

---

## UI-16: スプラッシュ画面改善

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-419 | UI-16: 要件書作成 | product-manager | `TODO` | | |
| T-420 | UI-16: Spec作成 | architect | `BLOCKED` | | T-419完了後 |
| T-421a | UI-16: 実装 | flutter-dev | `BLOCKED` | | |
| T-421b | UI-16: テストコード実装 | tester | `BLOCKED` | | |
| T-422 | UI-16: レビュー | reviewer | `BLOCKED` | | |
| T-423 | UI-16: テスト実行 | tester | `BLOCKED` | | |

---

## REL-2: App Store 公開後 改善サイクル

> 🎉 App Store 公開（2026-04-16）を受けて開始する公開後の改善サイクル。
> marketer が戦略立案・分析・草案提示を担当。ビジュアル制作は designer に連携。

### Phase 1: 現状把握・戦略立案

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-424 | App Store ページ現状レビュー・改善草案作成 | marketer | `DONE` | | docs/Marketing/appstore-1.0.0-2026-04-16.md |
| T-425 | SNS発信戦略立案・初投稿文草案作成 | marketer | `DONE` | | docs/Marketing/sns/ |
| T-426 | サクセスストーリー草案作成 | marketer | `DONE` | | docs/Marketing/stories/ |

### Phase 2: ビジュアル制作

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-427 | App Store スクリーンショット用デザイン作成 | designer | `DONE` | | docs/Design/draft/appstore_screenshot_overlay_design.html |
| T-428 | SNS用バナー・投稿ビジュアル作成 | designer | `TODO` | | T-425ユーザー承認後 |

### Phase 3: 月次分析サイクル（運用開始）

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-429 | 月次分析レポート作成・改善提案（初回） | marketer | `BLOCKED` | | T-424〜428完了後・公開から1ヶ月後（2026-05-16目安）|
| T-430 | UX/機能改善要件書作成（分析結果から） | product-manager | `BLOCKED` | | T-429完了後 |
| T-431 | App Store メタデータ更新草案作成 | marketer | `BLOCKED` | | T-429完了後 |

---

## REL-3: Ver1.1 App Store ページ更新（メタデータ・スクリーンショット）

> INV-4（招待リンク生成・共有）実装完了後に着手。Dashboard・招待・訪問作業を目玉としたページ刷新。
> 草案: docs/AppStore/metadata_ja_v1.1_draft.md

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-491 | REL-3: スクリーンショット用オーバーレイデザイン作成 | designer | `BLOCKED` | | INV-4完了後。6枚構成・キャッチコピー重畳。T-427のv1.0デザインをベースに更新 |
| T-492 | REL-3: スクリーンショット撮影・組み立て | designer | `BLOCKED` | | T-491完了後。実機スクショ＋オーバーレイ合成 |
| T-493 | REL-3: メタデータ確定・App Store Connect 更新 | marketer | `BLOCKED` | | T-492完了後。説明文・キーワード・プロモーションテキスト・スクショ一括反映 |
