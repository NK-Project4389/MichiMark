# 要件書：招待機能 バックエンド実装

## 概要

ミチマークにイベント招待機能を追加するためのバックエンド基盤を実装する。
ディープリンク＋中間Webページ方式を採用する。

## ユーザーストーリー

- イベントオーナーとして、招待リンク・招待コードを生成して他のユーザーを招待したい
- 招待されたユーザーとして、リンクまたはコードを使ってイベントに参加したい

## スコープ

### DBテーブル設計

新規テーブル `invitations` を追加する。

```sql
invitations
- id              : UUID, PK
- event_id        : 既存 events テーブルへの外部キー
- invited_by      : 招待者の user_id（外部キー）
- token           : TEXT, UNIQUE（URL用ランダム文字列 例：abc123xyz）
- code            : TEXT, UNIQUE（手入力用 例：ABC-1234）
- role            : TEXT（'viewer' or 'editor'）
- expires_at      : TIMESTAMP（作成から72時間後）
- max_uses        : INTEGER（NULL の場合は1回限り）
- used_count      : INTEGER, DEFAULT 0
- created_at      : TIMESTAMP
```

### APIエンドポイント

| メソッド | パス | 説明 |
|---|---|---|
| POST | /invitations | 招待トークン生成 |
| GET | /invitations/[token] | トークン情報取得（Webページ表示用） |
| POST | /invitations/[token]/use | 招待トークン使用・イベント参加 |
| POST | /invitations/code | 招待コード手入力による参加 |

#### POST /invitations

リクエスト：`event_id, invited_by, role, max_uses`

- `token`：ランダム8文字英数字で自動生成
- `code`：`XXX-9999` 形式で自動生成
- `expires_at`：現在時刻 +72時間で自動設定

レスポンス：`token, code, expires_at, invite_url`

#### GET /invitations/[token]

バリデーション：有効期限チェック・使用回数チェック

- 有効な場合：イベント名・招待者名・role を返す
- 無効な場合：`error_type`（`expired` / `used_up` / `not_found`）を返す

#### POST /invitations/[token]/use

リクエスト：参加ユーザーの `user_id`

バリデーション：有効期限・使用回数・重複参加チェック

成功時：
- `used_count` をインクリメント
- `event_members` テーブルに追加
- `role` を設定

レスポンス：`event_id, role`

#### POST /invitations/code

`token` と同じ処理を `code` で実行する。

## 権限モデル

| 権限 | 説明 |
|---|---|
| `viewer` | イベント情報の閲覧のみ |
| `editor` | イベント情報の編集・アクションログ追加が可能 |
| `owner`（作成者） | 全操作＋招待機能の使用が可能 |

## 前提・制約

- 既存の DB スキーマと API 構成を確認してから実装すること
- AppStore 無料版リリース（REL-1）完了後に着手する
- バックエンドの技術スタックは既存プロジェクトに合わせる

## 関連タスク

- INV-2: 招待中間Webページ（Next.js）
- INV-3: 招待コード入力画面（Flutter）
- INV-4: 招待リンク生成・共有機能（Flutter）
