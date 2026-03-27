# MichiMark CLAUDE.md

## プロジェクト概要

MichiMarkはドライブの記録・マーク・リンク管理を行うFlutterアプリ。SwiftUIから移植。

- プラットフォーム：iOS / Android
- フレームワーク：Flutter
- 言語：Dart
- 状態管理：flutter_bloc
- ナビゲーション：go_router

## プロジェクト目的

1. **SwiftUI → Flutter へのフレームワーク変換**
   - 既存のSwiftUI（TCA + SwiftData）実装をFlutter（BLoC + drift）へ移植する
   - アーキテクチャの設計思想（Domain / Projection / Draft / Repository）は維持する

2. **既存ソースコードのリファクタリング**
   - 移植にあわせて設計・実装の改善を行う
   - 設計憲章に従い、レイヤー責務・依存方向を整理する

---

## 設計原則

本プロジェクトは `docs/Architecture/MichiMark_Design_Constitution.md` に定義された設計憲章に従う。

AIはコード生成前に必ず設計憲章を参照すること。

---

## レイヤー構造（依存方向）

```
Widget（View）
  ↓
Projection
  ↓
Draft
  ↓
Adapter
  ↓
Domain
  ↓
Repository
```

依存は上から下のみ許可。逆方向は禁止。

---

## BLoC構造

```
Event  → Bloc → State
```

- Eventはユーザーアクションまたはシステムイベント
- BlocはビジネスロジックとDraft更新のみを担当
- StateはUIに渡す状態

---

## Navigationルール

- `go_router` を使用する
- BlocはDelegateをStateに乗せて遷移意図を通知する
- PageのBlocListenerがDelegateを受け取り `context.go()` で遷移する
- Bloc内・Widget内で `Navigator.of(context).push()` を呼び出すことは禁止

---

## AI実装禁止事項

- `dynamic` 型の使用
- `!`（null assertion）の乱用
- `BuildContext` を async gap をまたいで使用（mounted チェック必須）
- Widget の `build()` 内にビジネスロジックを記述
- Domain からUI（Widget）を参照
- Widget から Repository を直接呼び出し（BlocはDI経由で呼び出し可）
- `switch` の `default` によるコンパイル回避

---

## 設計変更ルール

設計変更が必要な場合はAIは実装を停止し、変更提案を行うこと。
勝手に設計を変更することは禁止。

---

## Spec駆動開発ルール

### 基本方針

全Featureの実装は必ず **Specを先に用意してから** 行う。

- Spec格納場所: `docs/Spec/Features/`
- `architect` がSpecを作成・更新する
- `flutter-dev` はSpecを参照して実装する

### architectの責務（Spec作成）

- 実装着手前に対象FeatureのSpec MDを作成する
- Specに記載すべき内容:
  - Purpose（Feature目的）
  - Draft / Projection / Domain フィールド定義
  - BlocEvent一覧
  - Delegate Contract
  - Architecture Rules（禁止事項）
  - Data Flow
- SpecはFlutter/Dart/BLoC用語で記述する（TCA/SwiftUI用語は禁止）
  - `XxxReducer.Action` → `XxxEvent`（sealed class）
  - `appeared` → `Started`
  - `delegate`（Action） → `XxxDelegate`（Stateのフィールド）

### flutter-devのSpec参照ルール

- 実装前に対象Featureの Spec MDを必ず参照すること
- 以下の場合は実装を停止し、`architect` に差し戻しを要求すること:
  - 対象FeatureのSpecが存在しない
  - Specのフィールド・Event・Delegateに曖昧・矛盾・欠落がある
  - 実装中にSpec未定義の挙動が必要になった
- 差し戻し要求はユーザーへ報告し、architectがSpecを修正してから再開する

---

## 実装・レビューサイクルルール

### 全体フロー

```
architect（Spec作成）
  ↓ Spec完成
flutter-dev（実装）← Specを必ず参照すること
  ↓ Spec不足・曖昧 → architect へ差し戻し（自動）
  ↓ 実装完了
reviewer（レビュー）← 自動で役割交代・ユーザー指示不要
  ↓ 違反なし → 完了
  ↓ 違反あり → flutter-dev へ差し戻し（自動）
flutter-dev（修正）
  ↓ 修正完了
reviewer（再レビュー）← 再度自動交代
  ↓ 違反なし → 完了
```

違反がなくなるまでレビューサイクルを繰り返す。

### 役割の侵食禁止

| 役割 | 許可 | 禁止 |
|---|---|---|
| `architect` | Spec作成・更新、差し戻し対応 | 実装・コード生成・レビュー |
| `flutter-dev` | Specに基づくコード生成・修正 | Spec作成・レビュー・違反判定 |
| `reviewer` | 違反指摘・差し戻し指示 | Spec作成・コード生成・修正 |

### reviewerのレビュー観点

以下をすべてチェックすること。

**アーキテクチャ違反**
- レイヤー依存方向の違反（逆方向参照）
- DomainからWidget / Projectionへの参照
- RootによるDraft編集・Domain操作
- WidgetからRepositoryへの直接呼び出し（BlocはDI経由で呼び出し可）

**型安全・Null安全**
- `dynamic` 型の使用
- `!`（null assertion）の乱用
- `switch` の `default` によるコンパイル回避

**非同期・ビジネスロジック**
- `BuildContext` の async gap をまたいだ使用（`mounted` チェックなし）
- `build()` 内のビジネスロジック

**Spec整合性**
- Specに定義されていないフィールド・Event・Delegateが実装に含まれていないか
- Specのフィールド名・型・Delegate構造と実装が一致しているか
- NavigationルールへのBlocによる直接呼び出し（`context.go()` / `context.push()` のBloc内使用）

---

## 回答時の役割明示ルール

AIは回答の冒頭に、どの役割として回答しているかを以下の形式で明示すること。

```
> 役割: [役割名] — [役割の説明]
```

いずれの役割にも該当しない場合は `orchestrator` として回答すること。

### 役割一覧（`.claude/agents/` 参照）

| 役割名 | 担当 |
|---|---|
| `architect` | Feature Spec作成・アーキテクチャ設計。実装・レビューは行わない |
| `charter-reviewer` | 設計憲章・アーキテクチャドキュメントのレビューと改善提案 |
| `flutter-dev` | Specに基づくFlutter/Dart実装。Spec不足・曖昧な場合はarchitectに差し戻す |
| `reviewer` | 生成コードが設計憲章・Specに従っているかレビュー。違反・アンチパターンを検出 |
| `orchestrator` | 上記に該当しない作業（環境構築・ツール操作・進捗管理・会話の調整など） |

---

## Git操作ルール

### 編集前
ファイルを編集する前に、必ずユーザーに以下の形式で確認すること。

```
最新版をGitHubからPULLしますか？
- Yes → Pull
- No → スキップ

[ Yes / No ]
```

### 編集後
ファイルの編集が完了したタイミングで、必ずユーザーに以下の形式で確認すること。

```
GitHubにPUSHしますか？
- Yes → Push
- No → スキップ

[ Yes / No ]
```

ユーザーが Yes と答えた場合のみPULL/PUSHを実行すること。

---

## 進捗記録ルール

AIはセッション開始時に必ず `docs/Progress/README.md` を確認し、最新の進捗ファイルを読んでから作業を開始すること。

- 記録場所: `docs/Progress/YYYY-MM-DD_[作業内容].md`
- セッション終了時またはユーザーが記録を求めた際に進捗MDを作成・更新する
- 記録内容：完了した作業・未完了の作業・次回やること
- 新規ファイル作成時は `docs/Progress/README.md` のファイル一覧も更新する

---

## ドキュメント参照

| ドキュメント | 用途 |
|---|---|
| `docs/Architecture/MichiMark_Design_Constitution.md` | 設計憲章 |
| `docs/Architecture/MichiMark_Architecture_Diagram.md` | アーキテクチャ図 |
| `docs/Templates/Feature_Spec_Template.md` | Feature仕様テンプレート |
| `docs/Spec/Features/` | Feature Spec格納ディレクトリ（architect作成） |
| `docs/Progress/README.md` | 進捗記録一覧 |
