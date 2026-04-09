# 実装・レビューサイクルルール

## 追加要望の処理ルール

ユーザーからの新しい要望・変更依頼はすべて **要件書作成から始める**。

```
ユーザー要望 → product-manager（要件書: docs/Requirements/）→ 新機能サイクルへ
```

例外なし。会話中にユーザーが「〜してほしい」と言っても、直接実装に入らず必ず product-manager として要件書を作成・確認してから進む。

---

## 新機能サイクル

```
product-manager（要件書）→ architect（Spec・テストシナリオ込み）→ flutter-dev（実装）
  → reviewer（レビュー・自動交代）→ 違反あり → flutter-dev（修正）→ reviewer（再レビュー）
  → reviewer承認 → tester（Integration Test実行）
  → 失敗 → flutter-dev（問題切り分け）
      ├─ 設計レベル → architect（設計修正）→ reviewer → flutter-dev → reviewer → tester
      └─ コードレベル → flutter-dev（直接修正）→ reviewer → tester
```

違反がなくなるまでサイクルを繰り返す。reviewerへの交代はユーザー指示不要。testerへの引き継ぎもreviewer承認後に自動で行う。

**tester が全件パスを報告したら、必ず進捗ファイル作成・更新 → git push をセットで実施する。**

## バグ修正サイクル

```
flutter-dev（バグ修正）→ reviewer（レビュー・自動交代）→ 違反あり → flutter-dev（修正）→ reviewer（再レビュー）
  → reviewer承認 → tester（修正確認テスト実行）
  → 失敗 → flutter-dev（問題切り分け・再修正）→ reviewer → tester
```

- バグ修正後も必ず `tester` に動作確認テストを依頼する
- `tester` がテスト不可と判断した場合は理由をユーザーに報告して手動確認を促す
- **tester が全件パスを報告したら、必ず進捗ファイル作成・更新 → git push をセットで実施する。**

## tester 必須ルール（全サイクル共通）

- **reviewer承認後、git push する前に必ず tester を実行すること。tester未実行でのpushは禁止**
- tester を省略してよいケースは存在しない（ドキュメントのみの変更・ルール変更を除く）
- tester が FAIL を報告した場合、FAIL の原因を修正してから再度 tester → 全件 PASS を確認するまで push しない
- tester がテスト不可と判断した場合のみ、理由をユーザーに報告して手動確認を促す

## Flutter移行タスクのフロー

```
architect（Spec・テストシナリオ込み）→ flutter-dev（実装）→ reviewer（レビュー）→ tester（テスト）
```

## デザイン提案フロー

```
designer（HTMLレポート・docs/Design/draft/ に叩き作成）
  → product-manager（叩きをレビュー・ユーザーへフィードバック・方針確認）
  → 承認後 → docs/Requirements/ に要件書として格納
  → architect（Spec）→ flutter-dev（実装）→ reviewer（レビュー）
```

- ユーザーの承認なしに叩きをそのまま要件書として格納しない
