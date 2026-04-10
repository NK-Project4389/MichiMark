# 進捗: 2026-04-10 Integration Test 設計書整理・testerルール更新

**日付**: 2026-04-10

---

## 完了した作業
- feat: MichiInfoカード間挿入機能 実装・全10件PASS（TC-MCI-001〜010） (6cf2a88)

### Integration Test 設計書の作成

- ファイル: `docs/Spec/IntegrationTest_Spec.md`
- 既存12テストファイル・約78件を分析し、方針を整理した
- 削除対象: 色・スタイル・単純存在確認のみのテスト（約22件）
- 統合対象: 同一フローで分割されていたケース（約8件→3件）
- 結果: 10グループ・41件のシナリオ設計書として再定義

#### 各グループ

| グループ | 件数 |
|---|---|
| TC-EVT（イベント管理） | 2 |
| TC-OVR（概要タブ） | 5 |
| TC-MICHI（ミチInfo） | 5 |
| TC-MAD（地点追加初期値・引き継ぎ） | 8 |
| TC-ACT（ActionTime） | 4 |
| TC-PAY（支払・精算） | 4 |
| TC-FCM（燃費モード） | 8 |
| TC-BAS（BasicInfo燃費換算） | 2 |
| TC-BACK（未保存ダイアログ） | 2 |
| TC-FLT（参加者絞り込み） | 1 |

### tester.md の更新

- 責務に「トータルテスト設計書との照合・更新」を追加
- tools に `Edit, Write` を追加（設計書の更新に必要）
- 「トータルテスト設計書との照合ルール」セクションを新設
  - タイミング: 新機能テスト実装前または並行して
  - 追記する基準: 計算ロジック・データ整合性・表示制御の分岐
  - 追記しない基準: 色・スタイル・単純存在確認

### workflow.md の更新

- 新機能サイクルのtesterステップを2段階に明記
  - Step 1: IntegrationTest_Spec.md との照合・必要に応じて更新
  - Step 2: 新機能の Integration Test 実装・実行

---

## 未完了・次回やること

1. **既存テストファイルの整理・統合・修正**（本設計書の実装）
   - 失敗中4件の修正: TS-03/04（Mark/Linkタップ遷移）・TC-MAD-006/007（UIに合わせて更新）
   - 削除対象ファイルの廃止: `payment_info_fab_color_test.dart` 等
   - 統合: `michi_info_layout_test.dart` + `michi_info_add_button_test.dart` → `e2e_michi_info_test.dart` など
2. T-100以降のタスク（カード挿入機能 Spec → 実装）
