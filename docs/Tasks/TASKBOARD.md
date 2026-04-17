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
| T-343 | 招待リンク生成・共有 テスト実行 | tester | `BLOCKED` | | |

---

## UI-19: 訪問作業 道タブ マークアクションバッジ・削除ボタン改善

> 訪問作業トピックの道タブでマークのアクションバッジが小さく、削除ボタンが隣接して誤タップしやすい問題をデザインから見直す。

| ID | タスク | 役割 | status | locked_by | notes |
|---|---|---|---|---|---|
| T-452 | UI-19: デザイン提案 | designer | `DONE` | | docs/Design/draft/visit_work_action_badge_redesign.html |
| T-453 | UI-19: 要件書作成 | product-manager | `BLOCKED` | | T-452完了後 |
| T-454 | UI-19: Spec作成 | architect | `BLOCKED` | | T-453完了後 |
| T-455a | UI-19: 実装 | flutter-dev | `BLOCKED` | | |
| T-455b | UI-19: テストコード実装 | tester | `BLOCKED` | | |
| T-456 | UI-19: レビュー | reviewer | `BLOCKED` | | |
| T-457 | UI-19: テスト実行 | tester | `BLOCKED` | | |

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
| T-409 | UTIL-1: 要件書作成 | product-manager | `TODO` | | ユーザーと伴奏して進める |
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
