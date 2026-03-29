# 2026-03-29 payment_detail Feature実装

## 完了した作業

### Spec更新（architect）
- `docs/Spec/Features/EventDetail/PaymentDetail/PaymentDetailFeature_Spec.md` にパッチ追記
  - BLoC Events: `PaymentMemberChanged` / `SplitMembersChanged` を削除
  - 代替: `EditMemberPressed` + `MemberSelected(MemberDomain)` / `EditSplitMembersPressed` + `SplitMembersSelected(List<MemberDomain>)` に分離
  - Delegate追加: `OpenMemberSelection`（シングル選択）/ `OpenSplitMembersSelection`（マルチ選択）
  - LinkDetailFeatureと同パターンに統一

### PaymentDetail Feature実装（flutter-dev）

| ファイル | 内容 |
|---|---|
| `draft/payment_detail_draft.dart` | Draft: id/paymentSeq/paymentAmount/paymentMember/splitMembers/paymentMemo |
| `projection/payment_detail_projection.dart` | Projection: displayPaymentAmount/paymentMemberName/splitMemberNames |
| `projection/payment_detail_projection_adapter.dart` | Domain → Projection 変換・金額フォーマット |
| `bloc/payment_detail_event.dart` | Event sealed class（9種） |
| `bloc/payment_detail_state.dart` | State sealed class + Delegate sealed class（4種） |
| `bloc/payment_detail_bloc.dart` | Bloc: 新規作成(UUID)/既存編集(Repository)対応 |
| `payment_detail_args.dart` | router extra用引数（eventId + paymentId?） |
| `view/payment_detail_page.dart` | Page: BlocConsumer + Delegateハンドリング + Selection連携 |
| `app/router.dart` | `/event/payment` ルート追加 |

### レビュー結果（reviewer）
- アーキテクチャ違反：なし
- 型安全・Null安全：なし
- 非同期（mounted チェック）：なし
- Spec整合性：なし

---

## 未完了の作業

なし（payment_detail Feature完結）

---

## 次回やること

### 優先タスク
1. **payment_info** Feature実装（EventDetailタブ）
2. マーク/リンク新規作成ルート（`/event/mark/new`, `/event/link/new`）
3. EventDetail 全タブ一括保存（§17）
4. InMemory スタブへのテストデータ投入（seed data）
5. drift Repository 実装（永続化）
6. get_it DI セットアップ
7. 設定系 Feature（trans_setting, member_setting, tag_setting, action_setting）

### 設計メモ
- PaymentDetail は `/event/payment` に `PaymentDetailArgs(eventId, paymentId?)` を extra で渡す
- paymentId = null → 新規作成（UUID生成）
- paymentId = 指定 → 既存編集（Repository取得）
- SelectionType.payMember（single） → MembersSelectionResult.first
- SelectionType.splitMembers（multiple） → MembersSelectionResult
