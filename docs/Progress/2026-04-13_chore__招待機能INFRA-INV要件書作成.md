# 進捗記録：招待機能 INFRA-1・INV-1〜4 要件書作成

## 作業日
2026-04-13

## 完了した作業

### 要件書の叩き作成（5件）

| ファイル | 内容 |
|---|---|
| `REQ-firebase_infra.md` | INFRA-1: Firebase基盤整備（Anonymous Auth＋Apple Sign In＋Firestore移行） |
| `REQ-invitation_backend.md` | INV-1: 招待機能バックエンドAPI（Next.js / Firestore） |
| `REQ-invitation_web_page.md` | INV-2: 招待中間Webページ（Next.js / `/invite/[token]`） |
| `REQ-invitation_code_input.md` | INV-3: 招待コード入力画面（Flutter） |
| `REQ-invitation_link_share.md` | INV-4: 招待リンク生成・共有（Flutter） |

### 確定した設計方針

**DB・バックエンド**
- Firestore中心に移行（ローカルdriftはキャッシュ的役割）
- Web側機能拡張を見据えたスキーマ設計
- Next.js（Vercel）でAPIを実装、GitHubで公開

**ユーザーID管理**
- Firebase Anonymous Auth（アプリ起動時に自動UID発行）
- Apple Sign In でリンク → 機種変更時もデータ引き継ぎ可能

**権限モデル**

| 権限 | BasicInfo | MichiInfo | PaymentInfo | 招待機能 |
|---|---|---|---|---|
| owner | 編集 | 編集 | 編集 | 使用可能 |
| editor | 閲覧のみ | 編集 | 編集 | 不可 |
| viewer | 閲覧のみ | 閲覧のみ | 閲覧のみ | 不可 |

**実装順序（確定）**
```
REL-1（AppStoreリリース）
    ↓
INFRA-1（Firebase基盤整備）
    ↓
INV-1（バックエンドAPI）
    ↓
INV-2（中間Webページ）  INV-3（招待コード入力）← 並行可能
    ↓
INV-4（招待リンク生成・共有）
```

### タスクボード追加

- INFRA-1: T-344〜T-348（BLOCKED: REL-1後）
- INV-1: T-324〜T-328（BLOCKED: INFRA-1後）
- INV-2: T-329〜T-333（BLOCKED: INV-1後）
- INV-3: T-334〜T-338（BLOCKED: INV-1後）
- INV-4: T-339〜T-343（BLOCKED: INV-1/2後）

## 未完了・残課題

- 各要件書はまだ「叩き」段階。architect によるSpec作成はREL-1完了後
- Firestoreのデータモデル詳細設計は INFRA-1 Spec作成時に実施

## 次回セッションで最初にやること

- 現在進行中タスクを確認（UI-7 T-282b / B-7 T-291 / F-3 T-300b / UI-9 T-305 / UI-10 T-316a/b / UI-11 T-321a/b）
- タスクボード確認 → 未完了タスクの続きから再開
