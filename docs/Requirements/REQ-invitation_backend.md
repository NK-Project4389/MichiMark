# 要件書：招待機能 バックエンド実装（INV-1）

## 概要

ミチマークにイベント招待機能を追加するためのバックエンド基盤を実装する。
ディープリンク＋中間Webページ方式を採用する。
DBはFirestore、バックエンドAPIはNext.js（Vercel）で実装する。

## ユーザーストーリー

- イベントオーナーとして、招待リンク・招待コードを生成して他のユーザーを招待したい
- 招待されたユーザーとして、リンクまたはコードを使ってイベントに参加したい

## 前提

- INFRA-1（Firebase基盤整備）の完了が必須
- ユーザーIDは Firebase Anonymous Auth の UID を使用する

## スコープ

### Firestoreコレクション設計

新規コレクション `invitations` を追加する。

```
invitations/{invitationId}
- id              : string（ドキュメントID）
- eventId         : string（eventsコレクションへの参照）
- invitedBy       : string（招待者の Firebase UID）
- token           : string（URL用ランダム文字列、ユニーク 例：abc123xyz）
- code            : string（手入力用、ユニーク 例：ABC-1234）
- role            : string（'viewer' or 'editor'）
- expiresAt       : Timestamp（作成から指定時間後）
- maxUses         : number | null（null の場合は1回限り）
- usedCount       : number（デフォルト 0）
- createdAt       : Timestamp
```

### 権限モデル（確定）

| 権限 | 説明 |
|---|---|
| `owner`（招待したユーザー） | 全操作（BasicInfo・MichiInfo・PaymentInfo・招待機能） |
| `editor`（招待された側・デフォルト） | MichiInfo・PaymentInfo の編集可能、BasicInfo は閲覧のみ |
| `viewer`（招待された側・選択制） | すべて閲覧のみ |

### APIエンドポイント（Next.js）

| メソッド | パス | 説明 |
|---|---|---|
| POST | /api/invitations | 招待トークン生成 |
| GET | /api/invitations/[token] | トークン情報取得（Webページ表示用） |
| POST | /api/invitations/[token]/use | 招待トークン使用・イベント参加 |
| POST | /api/invitations/code | 招待コード手入力による参加 |

#### POST /api/invitations

リクエスト：`eventId, invitedBy, role, maxUses, expiresHours`

- `token`：ランダム8文字英数字で自動生成
- `code`：`XXX-9999` 形式で自動生成
- `expiresAt`：現在時刻 + `expiresHours` で自動設定

レスポンス：`token, code, expiresAt, inviteUrl`

#### GET /api/invitations/[token]

バリデーション：有効期限チェック・使用回数チェック

- 有効な場合：イベント名・招待者名・role を返す
- 無効な場合：`errorType`（`expired` / `used_up` / `not_found`）を返す

#### POST /api/invitations/[token]/use

リクエスト：参加ユーザーの Firebase UID

バリデーション：有効期限・使用回数・重複参加チェック

成功時：
- `usedCount` をインクリメント
- `eventMembers` コレクションにメンバー追加
- `role` を設定

レスポンス：`eventId, role`

#### POST /api/invitations/code

`token` と同じ処理を `code` で実行する。

## Firestoreセキュリティルール

- `invitations` の作成：当該イベントのオーナーのみ
- `invitations` の読み取り：token / code が一致する場合のみ（認証不要）
- `eventMembers` の書き込み：バックエンドAPIのサービスアカウント経由のみ

## 前提・制約

- INFRA-1（Firebase基盤整備）の完了が必須
- AppStore 無料版リリース（REL-1）完了後に着手する
- Next.js プロジェクトを新規作成してGitHubで公開する

## 関連タスク

- INFRA-1: Firebase基盤整備（依存）
- INV-2: 招待中間Webページ（依存）
- INV-3: 招待コード入力画面（Flutter）
- INV-4: 招待リンク生成・共有機能（Flutter）
