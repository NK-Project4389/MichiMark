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

## reviewer 不合格時のルール（全サイクル共通）

- reviewer で違反が見つかった場合は **自己解決する**（ユーザーへの確認不要）
- 修正後は **必ず別コミット** で「何を・なぜ修正したか」を記録する
  - コミットメッセージ例: `fix: reviewer指摘修正 - BlocからRepository直接参照を除去`
- 修正内容は進捗ファイルの「レビュー指摘・修正内容」セクションにも記載する
- 修正後は reviewer が再確認し、合格するまで繰り返す

## tester 必須ルール（全サイクル共通）

詳細は `.claude/agents/tester.md` を参照。

- **tester は省略不可**（ドキュメントのみの変更・ルール変更を除く）
- **FAIL → 全件 PASS まで push しない**

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

## マーケティングフロー

```
marketer（戦略立案・草案提示・考え方の説明）
  ├── App Store テキスト草案 → ユーザー確認 → docs/AppStore/ に保存
  ├── SNS投稿文草案 → ユーザー確認 → docs/Marketing/sns/ に保存
  ├── ビジュアル要件書（叩き）→ designer（HTML デザインレポート）→ ユーザー確認
  └── サクセスストーリー → ユーザー確認 → docs/Marketing/stories/ に保存

公開後の分析サイクル（月次）:
marketer（分析レポート作成・改善提案）
  → ユーザーへ提示
  ├── UX/機能改善 → product-manager（要件書）→ 通常の新機能サイクルへ
  └── App Store最適化 → marketer（メタデータ更新草案）→ ユーザー確認
```
