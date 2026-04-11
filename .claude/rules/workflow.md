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
product-manager（要件書）→ architect（Spec・テストシナリオ込み）
    │
    ├──────────────────────┐
    ↓                      ↓  ← 並行実施
flutter-dev（実装）       tester（テストコード実装）
    │                      │   ※コードの詳細は見ない・Specのシナリオのみ参照
    └──────────┬────────────┘
               ↓ 両方完了
  reviewer（実装 + テストコードの整合確認・設計憲章確認）
               │
    ┌──────────┴──────────┐
    ↓                      ↓
  合格                   不合格
    │                      │
    ↓              不整合リスト生成 → ユーザーへ提示
tester（テスト実行）      │
    │             ┌────────┴────────┐
    ↓             ↓                 ↓
  FAIL        flutter-dev修正    tester修正
    │             └────────┬────────┘
    ↓                      ↓
  flutter-dev（問題切り分け）    reviewer（再レビュー）
    ├─ 設計レベル → architect → reviewer → flutter-dev & tester（並行）→ reviewer
    └─ コードレベル → flutter-dev & tester（並行）→ reviewer
```

- reviewer への交代はユーザー指示不要
- **tester が全件パスを報告したら、必ず進捗ファイル作成・更新 → git push をセットで実施する。**

## バグ修正サイクル

```
flutter-dev（バグ修正）＆ tester（テストコード実装） ← 並行
    │
    ↓ 両方完了
reviewer（実装 + テストコードの整合確認・設計憲章確認）
    → 合格 → tester（テスト実行）
    → 不合格 → 担当に修正依頼 → reviewer（再レビュー）

tester（テスト実行）
    → FAIL → flutter-dev（問題切り分け・再修正）＆ tester（テストコード修正） → reviewer → tester（再実行）
    → PASS → 進捗更新 → push
```

- バグ修正後も必ず `tester` にテストコード実装 + 実行を依頼する
- `tester` がテスト不可と判断した場合は理由をユーザーに報告して手動確認を促す
- **tester が全件パスを報告したら、必ず進捗ファイル作成・更新 → git push をセットで実施する。**

## tester 必須ルール（全サイクル共通）

- **tester は flutter-dev と並行してテストコードを実装する**（reviewer承認待ち不要）
- **テスト実行は reviewer 承認後に行う**（実行前に整合確認が必要）
- tester を省略してよいケースは存在しない（ドキュメントのみの変更・ルール変更を除く）
- tester が FAIL を報告した場合、FAIL の原因を修正してから再度 tester → 全件 PASS を確認するまで push しない
- tester がテスト不可と判断した場合のみ、理由をユーザーに報告して手動確認を促す

## Flutter移行タスクのフロー

```
architect（Spec・テストシナリオ込み）
    ├── flutter-dev（実装）  ← 並行
    └── tester（テストコード実装）
    ↓ 両方完了
reviewer（整合確認）→ tester（テスト実行）
```

## デザイン提案フロー

```
designer（HTMLレポート・docs/Design/draft/ に叩き作成）
  → product-manager（叩きをレビュー・ユーザーへフィードバック・方針確認）
  → 承認後 → docs/Requirements/ に要件書として格納
  → architect（Spec）→ flutter-dev（実装）→ reviewer（レビュー）
```

- ユーザーの承認なしに叩きをそのまま要件書として格納しない
