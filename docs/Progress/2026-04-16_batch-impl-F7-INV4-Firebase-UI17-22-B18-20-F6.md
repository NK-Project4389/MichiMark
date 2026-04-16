# 2026-04-16 一括実装セッション（F-7/INV-4/Firebase/UI-17〜22/B-18〜20/F-6）

## 完了した作業

### 要件書・Spec作成
- REQ/FS 10件作成（UI-17〜22, B-18〜20, F-6, F-7）
- INV-4 Spec作成（FS-invitation_link_share.md）— BottomSheet方式に変更
- UI-19 デザイン提案（HTMLレポート2件）— ユーザーレビュー待ち

### 実装（12タスク）
| タスク | 内容 |
|---|---|
| F-7 | 招待UI配置（InvitationRole enum・Event/Delegate・_InvitationSection） |
| INV-4 | 招待リンク生成・共有（InviteLinkShareBloc・BottomSheet・スタブ実装） |
| UI-17 | ダッシュボードタブ左側配置・初期タブ化（initialLocation変更） |
| UI-18 | タブ名変更「イベント」→「イベント一覧」 |
| UI-20 | マスター詳細 保存/キャンセルボタン下部配置（4画面） |
| UI-21 | マスター一覧 FABボタン追加（4画面） |
| UI-22 | 移動コストグラフ ポップアップ改善（タップ/長押し・ダーク背景） |
| B-18 | 訪問作業マーク支払い保存バグ修正 |
| B-19 | 訪問作業シードデータ区間削除 |
| B-20 | ActionTimeLog 11件追加（A社3件・B社5件・C社3件） |
| F-6 | 訪問作業メンバー非表示（TopicConfig.showMarkMembers） |
| Firebase | Firestore Repository 6件 + MigrationRepository + DI設定更新 |

### レビュー（全タスク合格）
- 実装レビュー: 12タスク全件合格
- INV-4単体レビュー: 合格（Widget Key 18件一致確認）
- テストコード整合性レビュー: Widget Key一致・pumpAndSettle未使用・GetIt.I.reset()準拠

### テストコード実装（11ファイル・107テスト）
| ファイル | テスト数 |
|---|---|
| dashboard_tab_position_test.dart | 4件 |
| dashboard_tab_rename_test.dart | 4件 |
| master_detail_button_layout_test.dart | 28件 |
| master_list_fab_button_test.dart | 16件 |
| dashboard_graph_popup_test.dart | 5件 |
| visit_work_payment_save_test.dart | 3件 |
| visit_work_seed_data_fix_test.dart | 9件 |
| visit_work_seed_data_actiontime_test.dart | 8件 |
| visit_work_no_member_test.dart | 8件 |
| invitation_ui_placement_test.dart | 9件 |
| invite_link_share_test.dart | 13件 |

### dart analyze
- lib/: エラー0件
- integration_test/: エラー0件（info 219件のみ）

## 未完了

### テスト実行（全件）
- UI-17〜22, B-18〜20, F-6, F-7, INV-4 のIntegration Test実行が未実施
- Firebase (INFRA-1) T-346b テストコード実装も未実施

### UI-19 デザイン承認待ち
- ユーザーが新デザイン（中央アクションボタン）を確認中
- 承認後 → 要件書 → Spec → 実装サイクル

### Firebase テストコード（INFRA-1 T-346b）
- fake_cloud_firestore を使ったUnit Test未実装

## 次回セッションで最初にやること

1. **Integration Test 全件実行**（3シャード並行）— UI-17〜22, B-18〜20, F-6, F-7, INV-4
2. **UI-19 デザイン確認** → 承認されたら要件書→Spec→実装
3. **Firebase Unit Test実装**（INFRA-1 T-346b）
4. FAIL があればバグ修正サイクル
