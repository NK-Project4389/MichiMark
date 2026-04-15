# 2026-04-15 POST-1/F-5 要件書作成（T-361 DONE）

## 完了した作業

### T-361: POST-1/F-5 要件書作成
- `docs/Requirements/REQ-payment_from_mark_link.md` 作成
- MarkDetail/LinkDetail に支払セクション追加・「＋」ボタンから PaymentDetail 遷移
- PaymentDomain に `markLinkID: MarkLinkID?` 追加（NULL = 直接登録）
- 保存時: PaymentDetail と MarkDetail/LinkDetail を同時保存
- カスケード削除: MarkDetail/LinkDetail 削除 → 紐づく PaymentDetail も削除
- PaymentInfo グルーピング: `markLinkDate` 日付 > `markLinkName` 名称 > 支払いカード
- PaymentInfo / MarkDetail・LinkDetail 両方から編集・削除可能

---

## 未完了

- T-362: POST-1/F-5 Spec作成（architect 着手可能）
- T-363a/b: 実装・テストコード（T-362完了後）
- T-403c: F-3 リモート実行結果確認（4/16 朝）

---

## 次回セッションで最初にやること

1. **T-403c: リモート実行結果確認** — `git pull` → `git log` で F-3 コミット確認
2. コミットが入っていれば T-405 Integration Test 実行
3. **T-362: POST-1/F-5 Spec作成**（architect）
