# 2026-04-15 POST-1/F-5 Spec作成完了（T-362 DONE）

## 完了した作業

### T-362: POST-1/F-5 Spec作成
- `docs/Spec/Features/FS-payment_from_mark_link.md` 作成
- PaymentDomain / PaymentDetailDraft / PaymentDetailArgs に `markLinkID: String?` 追加
- MarkDetail/LinkDetail に `PaymentSectionProjection` + Delegate 2件 + Event 3件 追加
- 保存フロー設計（PaymentDetail保存 → MarkDetail/LinkDetail同時保存 → 元画面へ戻る）
- カスケード削除設計（Repository.deleteMarkLink 内で markLinkID 一致 Payment を論理削除）
- PaymentInfoProjection グルーピング設計（markLinkDate 日付 > markLinkName > items / NULL→直接登録セクション）
- Integration Test シナリオ TC-PML-I001〜I010 定義

### リモートトリガー更新
- 4/16 2:10 JST リモートセッションを更新
- PART A: F-3 visitWork 実装
- PART B: POST-1/F-5 実装（Spec読み込み → 実装 → テスト → レビュー）

---

## 未完了

- T-363a: 実装（4/16 リモート自動実行予定）
- T-363b: テストコード実装（同上）
- T-364: レビュー（同上）
- T-365: Integration Test 実行（ローカル手動実行が必要）

---

## 次回セッションで最初にやること

1. **T-403c: リモート実行結果確認** — `git pull` → `git log` で F-3 + POST-1/F-5 コミット確認
2. F-3: T-405 Integration Test 実行
3. POST-1/F-5: T-365 Integration Test 実行
