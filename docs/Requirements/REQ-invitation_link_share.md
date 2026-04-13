# 要件書：招待機能 招待リンク生成・共有（INV-4）

## 概要

イベント詳細画面のオーナーが招待リンクを生成・共有できる機能を Flutter で実装する。

## ユーザーストーリー

- イベントオーナーとして、招待設定（権限・有効期限・使用回数）を選んで招待リンクを生成したい
- 生成したリンクをLINEで友達に共有したい
- 招待コードをコピーして口頭や別の方法で伝えたい

## 前提

- INFRA-1（Firebase基盤整備）の完了が必須
- INV-1（バックエンドAPI）の完了が必須
- INV-2（中間Webページ）の完了が必須

## 権限モデル

| 権限 | 説明 |
|---|---|
| `owner`（招待したユーザー） | 全操作（BasicInfo・MichiInfo・PaymentInfo・招待機能） |
| `editor`（招待された側・デフォルト） | MichiInfo・PaymentInfo の編集可能、BasicInfo は閲覧のみ |
| `viewer`（招待された側・選択制） | すべて閲覧のみ |

招待ボタンは **owner にのみ表示**する（editor・viewer には非表示）。

## スコープ

### 招待ボタン

- イベント詳細画面にシェアボタンを追加
- owner にのみ表示

### 招待設定シート（BottomSheet or Sheet）

以下の設定項目を選択できるUI：

| 項目 | 選択肢 |
|---|---|
| 権限 | 「閲覧のみ」（viewer） / 「編集可能」（editor・デフォルト） |
| 有効期限 | 「24時間」 / 「72時間」 / 「7日間」 |
| 使用回数 | 「1回」 / 「5回」 / 「無制限」 |

「招待リンクを作成」ボタン

### リンク作成後の表示

- 作成した招待URL（コピーボタン付き）
- 招待コード（大きく表示・コピーボタン付き）
- 「LINEで共有」ボタン → iOS標準シェアシートを起動

### API呼び出し

```
POST /api/invitations
Body: {
  eventId: [イベントID],
  invitedBy: [Firebase Anonymous Auth の UID],
  role: "viewer" or "editor",
  expiresHours: 24 or 72 or 168,
  maxUses: 1 or 5 or null
}
```

## 前提・制約

- INFRA-1 / INV-1 / INV-2 の完了が必須
- 既存のイベント詳細画面の構成を確認してから実装すること
- 設計憲章に従い BLoC パターンで実装する
- AppStore 無料版リリース（REL-1）完了後に着手する

## 関連タスク

- INFRA-1: Firebase基盤整備（依存）
- INV-1: バックエンド実装（依存）
- INV-2: 招待中間Webページ（依存）
- INV-3: 招待コード入力画面（Flutter）
