# Feature Spec: 招待機能 バックエンド実装（INV-1）

Platform: **Next.js / TypeScript**（Vercel）
Version: 1.0
Status: Draft
Created: 2026-04-15
Requirement: `docs/Requirements/REQ-invitation_backend.md`

---

# 1. Feature Overview

## Feature Name

InvitationBackend

## Purpose

MichiMarkのイベント招待機能を支えるバックエンドAPIとFirestoreデータ基盤を実装する。
イベントオーナーが招待トークン・招待コードを生成し、招待されたユーザーがURLまたはコード入力でイベントに参加できる仕組みを提供する。

## Scope

含むもの
- Next.js App Router による API Routes 4本
- `invitations` Firestoreコレクション設計（スキーマ・インデックス）
- `eventMembers` Firestoreコレクション設計（参加記録）
- Firestoreセキュリティルール追加（invitations / eventMembers）
- Firebase Admin SDK 初期化モジュール
- 招待ロジックサービスモジュール
- Next.jsプロジェクト新規作成（michimark-web リポジトリへの追加）

含まないもの
- INV-2 中間Webページ（`/invite/[token]` ページ）
- INV-3 Flutter招待コード入力画面
- INV-4 Flutter招待リンク生成・共有画面
- Firebaseコンソール上の手動設定
- メール通知・プッシュ通知

## 実装リポジトリ

`/Users/kurosakinobuyuki/ClaudeCode/App/michimark-web`

現状: 静的HTMLのみ（privacy.html / support.html / index.html）。Next.jsプロジェクトを新規セットアップしてこのリポジトリに追加する。

---

# 2. 前提条件

- INFRA-1（Firebase基盤整備）の完了が必須
- ユーザーIDは Firebase Anonymous Auth の UID を使用する
- Firebase Admin SDK 用のサービスアカウントキーをVercel環境変数に設定する

---

# 3. Firestoreデータ設計

## 3.1 既存コレクション構造（INFRA-1で定義済み）

```
users/{uid}/
  ├── profile
  ├── members/{memberId}
  ├── trans/{transId}
  ├── tags/{tagId}
  ├── actions/{actionId}
  ├── topics/{topicId}
  └── events/{eventId}/
        ├── （eventドキュメント本体）
        ├── markLinks/{markLinkId}
        └── payments/{paymentId}
```

## 3.2 新規コレクション: invitations

**パス:** `invitations/{invitationId}`

| フィールド | 型 | 制約 | 説明 |
|---|---|---|---|
| id | string | ドキュメントIDと同一 | UUID |
| eventId | string | 必須 | users/{uid}/events/{eventId} への参照（eventId部分のみ保持） |
| ownerUid | string | 必須 | イベントオーナーの Firebase UID |
| invitedBy | string | 必須 | 招待者の Firebase UID（ownerUidと同一のケースが多いが分離して定義） |
| token | string | 必須・ユニーク | URL用ランダム8文字英数字（小文字）。例: `abc123xy` |
| code | string | 必須・ユニーク | 手入力用。形式: `XXX-9999`（英大文字3文字 + ハイフン + 数字4桁）。例: `ABC-1234` |
| role | string | 必須 | `'viewer'` または `'editor'` |
| expiresAt | Timestamp | 必須 | 有効期限（作成時刻 + expiresHours） |
| maxUses | number \| null | - | 最大使用回数。null の場合は無制限 |
| usedCount | number | 初期値 0 | 使用済み回数 |
| createdAt | Timestamp | 必須 | 作成日時 |

**インデックス:**
- `token` フィールドの単独インデックス（GET /api/invitations/[token] でのルックアップ）
- `code` フィールドの単独インデックス（POST /api/invitations/code でのルックアップ）

## 3.3 新規コレクション: eventMembers

招待承諾後のイベント参加記録。invitations コレクションとは独立して保持する。

**パス:** `eventMembers/{membershipId}`

| フィールド | 型 | 制約 | 説明 |
|---|---|---|---|
| id | string | ドキュメントIDと同一 | UUID（バックエンドが生成） |
| eventId | string | 必須 | イベントID |
| ownerUid | string | 必須 | イベントオーナーの Firebase UID（アクセス制御用） |
| memberUid | string | 必須 | 参加ユーザーの Firebase UID |
| role | string | 必須 | `'viewer'` または `'editor'` |
| invitationId | string | 必須 | 使用した invitations ドキュメントのID |
| joinedAt | Timestamp | 必須 | 参加日時 |

**インデックス:**
- `eventId + memberUid` の複合インデックス（重複参加チェック用）

## 3.4 eventsコレクションとの関係

- `eventMembers` は `invitations` 経由で参加したユーザーの記録
- イベントオーナー自身は `eventMembers` に記録しない（ownerUid で識別）
- Flutter クライアントがイベントを表示する際は `eventMembers` を参照してメンバーの `role` を取得する

---

# 4. APIエンドポイント詳細設計

## 4.1 型定義（TypeScript）

### リクエスト型

```typescript
// POST /api/invitations
type CreateInvitationRequest = {
  eventId: string;
  invitedBy: string;      // Firebase UID
  role: 'viewer' | 'editor';
  maxUses: number | null; // 1 | 5 | null
  expiresHours: number;   // 24 | 72 | 168
};

// POST /api/invitations/[token]/use
type UseInvitationRequest = {
  uid: string; // 参加ユーザーの Firebase UID
};

// POST /api/invitations/code
type UseInvitationByCodeRequest = {
  code: string; // "ABC-1234" 形式
  uid: string;  // 参加ユーザーの Firebase UID
};
```

### レスポンス型

```typescript
// POST /api/invitations - 成功
type CreateInvitationResponse = {
  token: string;
  code: string;
  expiresAt: string; // ISO 8601
  inviteUrl: string; // https://[domain]/invite/[token]
};

// GET /api/invitations/[token] - 有効
type InvitationInfoResponse = {
  eventName: string;
  inviterName: string;
  role: 'viewer' | 'editor';
};

// GET /api/invitations/[token] - 無効
type InvitationErrorResponse = {
  errorType: 'expired' | 'used_up' | 'not_found';
};

// POST /api/invitations/[token]/use - 成功
// POST /api/invitations/code - 成功
type JoinEventResponse = {
  eventId: string;
  role: 'viewer' | 'editor';
};

// エラー共通
type ApiErrorResponse = {
  errorType: string;
  message: string;
};
```

## 4.2 POST /api/invitations（招待トークン生成）

**認証:** リクエストボディの `invitedBy` UID を Firebase Admin SDK で検証し、該当イベントのオーナーであることを確認する。

**バリデーション:**
- `eventId` : 必須・空文字禁止
- `invitedBy` : 必須・Firebase Admin SDK で有効なUIDであること
- `role` : `'viewer'` または `'editor'` であること
- `maxUses` : `null` または正の整数であること
- `expiresHours` : 1以上の正の整数であること
- `invitedBy` UID が `users/{uid}/events/{eventId}` の ownerUid と一致すること

**token生成ロジック:**
1. `crypto.randomBytes(6)` 相当で8文字の小文字英数字文字列を生成する
2. 生成したtokenで `invitations` コレクションを検索し、重複がないことを確認する
3. 重複があれば最大5回リトライし、失敗した場合は 500 を返す

**code生成ロジック:**
1. 英大文字3文字 + `-` + 数字4桁の形式で生成する（例: `ABC-1234`）
2. 生成したcodeで `invitations` コレクションを検索し、重複がないことを確認する
3. 重複があれば最大5回リトライし、失敗した場合は 500 を返す

**expiresAt計算:** `new Date(Date.now() + expiresHours * 60 * 60 * 1000)`

**Firestore操作:** `invitations` コレクションに新規ドキュメントを作成する。

**レスポンス:**
- 成功: 201 + `CreateInvitationResponse`

**エラーレスポンス:**

| errorType | HTTPステータス | 条件 |
|---|---|---|
| `unauthorized` | 401 | invitedByがイベントオーナーではない |
| `event_not_found` | 404 | eventIdに対応するイベントが存在しない |
| `invalid_request` | 400 | バリデーションエラー |
| `internal_error` | 500 | token/code重複リトライ上限超過 |

## 4.3 GET /api/invitations/[token]（トークン情報取得）

**認証:** 不要（認証なしでアクセス可能）

**バリデーション:**
- `token` : URLパスパラメータ・空文字禁止

**Firestore操作:**
1. `invitations` コレクションで `token == [token]` のドキュメントを取得する
2. ドキュメントが存在しない場合 → `not_found` エラー
3. `expiresAt` が現在時刻より過去の場合 → `expired` エラー
4. `maxUses != null && usedCount >= maxUses` の場合 → `used_up` エラー
5. 有効な場合 → `ownerUid` からユーザープロフィールと `eventId` からイベント情報を取得して返す

**レスポンス:**
- 成功: 200 + `InvitationInfoResponse`
- エラー: 200 + `InvitationErrorResponse`（エラー種別をクライアントが判定できるよう200で返す）

**NOTE:** `inviterName` はFirestoreの `users/{ownerUid}/profile` からDisplayName相当の情報を取得するか、プロフィール未整備の場合は空文字を返す。INFRA-1のprofileドキュメントはdisplayNameフィールドを持たないため、本Specでは `ownerUid` の末尾8文字を識別子として返す暫定仕様とする（INV-2実装時に要確認）。

## 4.4 POST /api/invitations/[token]/use（トークン使用・参加）

**認証:** リクエストボディの `uid` を Firebase Admin SDK で検証する。

**バリデーション:**
- `uid` : 必須・Firebase Admin SDK で有効なUIDであること

**Firestoreトランザクション（アトミック操作）:**
1. `invitations` コレクションで `token == [token]` のドキュメントを取得する
2. ドキュメントが存在しない場合 → `not_found` エラー（400）
3. `expiresAt` が現在時刻より過去の場合 → `expired` エラー（400）
4. `maxUses != null && usedCount >= maxUses` の場合 → `used_up` エラー（400）
5. `eventMembers` コレクションで `eventId + memberUid == uid` の重複チェックを行う
6. 重複が存在する場合 → `already_joined` エラー（400）
7. トランザクション内で以下を実行する:
   - `invitations/{invitationId}` の `usedCount` を +1 インクリメントする
   - `eventMembers/{newId}` に新規ドキュメントを作成する

**レスポンス:**
- 成功: 200 + `JoinEventResponse`

**エラーレスポンス:**

| errorType | HTTPステータス | 条件 |
|---|---|---|
| `not_found` | 404 | tokenに対応する招待が存在しない |
| `expired` | 400 | 有効期限切れ |
| `used_up` | 400 | 使用回数超過 |
| `already_joined` | 400 | 既に参加済み |
| `invalid_request` | 400 | バリデーションエラー |

## 4.5 POST /api/invitations/code（コード手入力参加）

**認証:** リクエストボディの `uid` を Firebase Admin SDK で検証する。

**バリデーション:**
- `code` : 必須・`^[A-Z]{3}-[0-9]{4}$` 正規表現に一致すること
- `uid` : 必須・Firebase Admin SDK で有効なUIDであること

**Firestore操作:**
1. `invitations` コレクションで `code == [code]` のドキュメントを1件取得する
2. 取得後は POST /api/invitations/[token]/use と同一のロジック（4.4）で処理する

**レスポンス・エラーレスポンス:** 4.4 と同一。

---

# 5. Firestoreセキュリティルール

INFRA-1で定義したルールに以下を追加する。

## 5.1 invitations コレクション

```
match /invitations/{invitationId} {
  // 作成: 認証済みユーザーがリクエストする
  //   ownerUid == request.auth.uid の検証はバックエンドAPIで行う（Admin SDK経由）
  //   クライアント直接書き込みは不可
  allow create: if false;
  allow update: if false;
  allow delete: if false;

  // 読み取り: token または code の照合はバックエンドAPI経由のみ
  //   クライアントからの直接読み取りは不可
  allow read: if false;
}
```

**設計根拠:** `invitations` コレクションへのアクセスはすべて Firebase Admin SDK（サービスアカウント）経由のバックエンドAPIが行う。クライアントからの直接Firestoreアクセスを禁止することでtokenの総当たり攻撃を防ぐ。

## 5.2 eventMembers コレクション

```
match /eventMembers/{membershipId} {
  // すべてのクライアント操作を禁止
  // バックエンドAPIの Admin SDK 経由のみ書き込み可
  allow read, write: if false;
}
```

**設計根拠:** `eventMembers` はバックエンドAPIのトランザクション内でのみ操作される。クライアントからの直接操作はすべて禁止する。

---

# 6. 認証方式

## 6.1 Firebase Admin SDK

- `firebase-admin` npm パッケージを使用する
- サービスアカウントキー（JSON）をVercel環境変数 `FIREBASE_SERVICE_ACCOUNT_KEY` に格納する
- 初期化は `lib/firebase-admin.ts` で行い、シングルトンパターンで再利用する

## 6.2 クライアントUID検証方法

- クライアントからの `uid` パラメータは信頼せず、Firebase Admin SDKの `admin.auth().getUser(uid)` でUID存在確認を行う
- または、将来的にはクライアントが `idToken` を送信し `admin.auth().verifyIdToken(idToken)` で検証することを推奨する（本Spec時点は `uid` 検証の暫定方式）

## 6.3 環境変数

| 変数名 | 説明 |
|---|---|
| `FIREBASE_SERVICE_ACCOUNT_KEY` | サービスアカウントJSONをBase64エンコードした文字列 |
| `NEXT_PUBLIC_INVITE_BASE_URL` | 招待URLのベース（例: `https://michimark.vercel.app`） |

---

# 7. 実装ファイル構成

michimark-web は現時点でNext.jsプロジェクトが未作成のため、新規セットアップが必要。

## 7.1 Next.jsプロジェクト構成

```
michimark-web/
  app/
    api/
      invitations/
        route.ts                    # POST /api/invitations
        [token]/
          route.ts                  # GET /api/invitations/[token]
          use/
            route.ts                # POST /api/invitations/[token]/use
        code/
          route.ts                  # POST /api/invitations/code
  lib/
    firebase-admin.ts               # Firebase Admin SDK 初期化（シングルトン）
    invitation-service.ts           # 招待ロジック（token/code生成・バリデーション・Firestore操作）
    types/
      invitation.ts                 # TypeScript型定義
  privacy.html                      # 既存静的ファイル（移動不要）
  support.html                      # 既存静的ファイル（移動不要）
  index.html                        # 既存静的ファイル（移動不要）
  package.json
  next.config.ts
  tsconfig.json
```

## 7.2 Next.jsプロジェクト初期設定方針

- `npx create-next-app@latest` で App Router を選択して初期化する
- TypeScript・Tailwind CSS を有効にする（INV-2ページで使用するため）
- Runtime: Node.js（デフォルト）を使用する。Edge Runtimeは使用しない（Firebase Admin SDKがEdge非対応のため）
- 既存の静的HTMLファイルは `public/` ディレクトリまたはルートに移動せず、`next.config.ts` の `rewrites` でそのまま配信できるよう調整する方針とする（実装者判断で最適な方法を選ぶ）

---

# 8. Data Flow

## 招待トークン生成フロー

1. Flutter（INV-4）が POST /api/invitations を呼び出す
2. バックエンドAPIがリクエストのinvitedBy UIDをAdmin SDKで検証する
3. Firestoreで eventId のオーナーを確認する
4. token・codeをランダム生成し、ユニーク性を確認する
5. `invitations` コレクションに新規ドキュメントを書き込む
6. token・code・inviteURL をFlutterに返す

## 招待リンク経由の参加フロー（INV-2→バックエンド）

1. 招待されたユーザーがWebブラウザで `/invite/[token]` を開く（INV-2）
2. INV-2ページが GET /api/invitations/[token] を呼び出してイベント情報を取得する
3. ユーザーが「アプリで参加する」をタップするとカスタムURLスキームでFlutterアプリが起動する
4. FlutterアプリがPOST /api/invitations/[token]/use を呼び出して参加を確定する
5. バックエンドがトランザクションで usedCount++・eventMembers 追加を行う
6. eventId・role をFlutterに返す

## 招待コード手入力の参加フロー（INV-3→バックエンド）

1. Flutter（INV-3）がPOST /api/invitations/code を呼び出す
2. バックエンドが code でinvitationsを検索し、トークン使用と同一ロジックで参加処理を行う
3. eventId・role をFlutterに返す

---

# 9. テストシナリオ

INV-1はNext.js APIの実装であり、Integration TestはHTTPリクエスト単位で実施する。

## 前提条件

- Firebase エミュレーター（Firestore + Auth）が起動していること
- Next.js開発サーバーが起動していること（`npm run dev`）
- テスト用Firebase UID（オーナー・参加者）が発行済みであること

## テストシナリオ一覧

| ID | シナリオ名 | 種別 | 優先度 |
|---|---|---|---|
| TC-INV1-001 | 招待トークン生成 - 正常系 | Integration | High |
| TC-INV1-002 | 招待トークン生成 - 権限なし（オーナーでない） | Unit | High |
| TC-INV1-003 | 招待トークン生成 - 存在しないeventId | Unit | High |
| TC-INV1-004 | トークン情報取得 - 有効なトークン | Integration | High |
| TC-INV1-005 | トークン情報取得 - 有効期限切れ | Unit | High |
| TC-INV1-006 | トークン情報取得 - 使用回数上限 | Unit | High |
| TC-INV1-007 | トークン情報取得 - 存在しないトークン | Unit | High |
| TC-INV1-008 | トークン使用・参加 - 正常系 | Integration | High |
| TC-INV1-009 | トークン使用・参加 - 有効期限切れ | Unit | High |
| TC-INV1-010 | トークン使用・参加 - 使用回数上限 | Unit | High |
| TC-INV1-011 | トークン使用・参加 - 重複参加 | Unit | High |
| TC-INV1-012 | コード手入力参加 - 正常系 | Integration | High |
| TC-INV1-013 | コード手入力参加 - 不正フォーマット | Unit | Medium |
| TC-INV1-014 | コード手入力参加 - 存在しないコード | Unit | Medium |
| TC-INV1-015 | トークン使用・参加 - usedCountインクリメントの正確性 | Unit | Medium |
| TC-INV1-016 | token・codeのユニーク性 | Unit | Low |

## シナリオ詳細

### TC-INV1-001: 招待トークン生成 - 正常系

**前提:**
- オーナーUID: `owner-uid-001` のユーザーが存在する
- `users/owner-uid-001/events/event-001` が存在する

**手順:**
1. POST /api/invitations を呼び出す
   - Body: `{ eventId: "event-001", invitedBy: "owner-uid-001", role: "editor", maxUses: 1, expiresHours: 24 }`

**期待結果:**
- HTTPステータス 201
- レスポンスに `token`（8文字英数字）・`code`（XXX-9999形式）・`expiresAt`・`inviteUrl` が含まれる
- Firestoreの `invitations` コレクションに新規ドキュメントが作成されている
- `usedCount == 0`・`role == "editor"` であること

---

### TC-INV1-002: 招待トークン生成 - 権限なし

**前提:**
- オーナーUID: `owner-uid-001`・別ユーザーUID: `other-uid-002`
- `users/owner-uid-001/events/event-001` が存在する

**手順:**
1. POST /api/invitations を呼び出す
   - Body: `{ eventId: "event-001", invitedBy: "other-uid-002", role: "editor", maxUses: 1, expiresHours: 24 }`

**期待結果:**
- HTTPステータス 401
- レスポンスの `errorType == "unauthorized"`

---

### TC-INV1-003: 招待トークン生成 - 存在しないeventId

**前提:**
- オーナーUID: `owner-uid-001` のユーザーが存在する
- `event-999` は存在しない

**手順:**
1. POST /api/invitations を呼び出す
   - Body: `{ eventId: "event-999", invitedBy: "owner-uid-001", role: "editor", maxUses: 1, expiresHours: 24 }`

**期待結果:**
- HTTPステータス 404
- レスポンスの `errorType == "event_not_found"`

---

### TC-INV1-004: トークン情報取得 - 有効なトークン

**前提:**
- 有効な招待（未期限・未使用）が `invitations` コレクションに存在する
- token = `abc123xy`

**手順:**
1. GET /api/invitations/abc123xy を呼び出す

**期待結果:**
- HTTPステータス 200
- レスポンスに `eventName`・`inviterName`・`role` が含まれる
- `errorType` フィールドが存在しない

---

### TC-INV1-005: トークン情報取得 - 有効期限切れ

**前提:**
- `expiresAt` が過去日時の招待が `invitations` コレクションに存在する

**手順:**
1. GET /api/invitations/[expired-token] を呼び出す

**期待結果:**
- HTTPステータス 200
- レスポンスの `errorType == "expired"`

---

### TC-INV1-006: トークン情報取得 - 使用回数上限

**前提:**
- `maxUses == 1`・`usedCount == 1` の招待が存在する（使用済み）

**手順:**
1. GET /api/invitations/[used-token] を呼び出す

**期待結果:**
- HTTPステータス 200
- レスポンスの `errorType == "used_up"`

---

### TC-INV1-007: トークン情報取得 - 存在しないトークン

**手順:**
1. GET /api/invitations/notexist を呼び出す

**期待結果:**
- HTTPステータス 200
- レスポンスの `errorType == "not_found"`

---

### TC-INV1-008: トークン使用・参加 - 正常系

**前提:**
- 有効な招待（未期限・maxUses=1・usedCount=0）が存在する
- 参加ユーザーUID: `member-uid-001`（まだ参加していない）

**手順:**
1. POST /api/invitations/[valid-token]/use を呼び出す
   - Body: `{ uid: "member-uid-001" }`

**期待結果:**
- HTTPステータス 200
- レスポンスに `eventId`・`role` が含まれる
- Firestoreの `invitations/{id}` の `usedCount == 1` になっている
- Firestoreの `eventMembers` コレクションに参加記録が追加されている
  - `memberUid == "member-uid-001"`・`role` が正しく設定されている

---

### TC-INV1-009: トークン使用・参加 - 有効期限切れ

**前提:**
- `expiresAt` が過去日時の招待が存在する

**手順:**
1. POST /api/invitations/[expired-token]/use を呼び出す
   - Body: `{ uid: "member-uid-001" }`

**期待結果:**
- HTTPステータス 400
- レスポンスの `errorType == "expired"`
- Firestoreの `usedCount` は変化しない

---

### TC-INV1-010: トークン使用・参加 - 使用回数上限

**前提:**
- `maxUses == 1`・`usedCount == 1` の招待が存在する

**手順:**
1. POST /api/invitations/[used-token]/use を呼び出す
   - Body: `{ uid: "member-uid-002" }`

**期待結果:**
- HTTPステータス 400
- レスポンスの `errorType == "used_up"`
- `eventMembers` に新規ドキュメントが追加されない

---

### TC-INV1-011: トークン使用・参加 - 重複参加

**前提:**
- 有効な招待が存在する
- `member-uid-001` が既に `eventMembers` に参加記録を持つ

**手順:**
1. POST /api/invitations/[valid-token]/use を呼び出す
   - Body: `{ uid: "member-uid-001" }`

**期待結果:**
- HTTPステータス 400
- レスポンスの `errorType == "already_joined"`
- `usedCount` は変化しない

---

### TC-INV1-012: コード手入力参加 - 正常系

**前提:**
- 有効な招待（code = `ABC-1234`、未期限・usedCount=0）が存在する
- 参加ユーザーUID: `member-uid-003`

**手順:**
1. POST /api/invitations/code を呼び出す
   - Body: `{ code: "ABC-1234", uid: "member-uid-003" }`

**期待結果:**
- HTTPステータス 200
- レスポンスに `eventId`・`role` が含まれる
- `usedCount` がインクリメントされている
- `eventMembers` に参加記録が追加されている

---

### TC-INV1-013: コード手入力参加 - 不正フォーマット

**手順:**
1. POST /api/invitations/code を呼び出す
   - Body: `{ code: "abc-1234", uid: "member-uid-003" }` （小文字・フォーマット不正）

**期待結果:**
- HTTPステータス 400
- レスポンスの `errorType == "invalid_request"`

---

### TC-INV1-014: コード手入力参加 - 存在しないコード

**手順:**
1. POST /api/invitations/code を呼び出す
   - Body: `{ code: "ZZZ-9999", uid: "member-uid-003" }`

**期待結果:**
- HTTPステータス 404
- レスポンスの `errorType == "not_found"`

---

### TC-INV1-015: usedCountインクリメントの正確性

**前提:**
- 有効な招待（maxUses=5・usedCount=0）が存在する

**手順:**
1. 異なるUIDで POST /api/invitations/[token]/use を3回順番に呼び出す

**期待結果:**
- 3回とも HTTPステータス 200
- `invitations/{id}` の `usedCount == 3`

---

### TC-INV1-016: token・codeのユニーク性

**前提:**
- `invitations` コレクションが空の状態

**手順:**
1. POST /api/invitations を10回呼び出す

**期待結果:**
- 10件すべてのドキュメントで `token` がユニークである
- 10件すべてのドキュメントで `code` がユニークである

---

# 10. 依存関係

| 依存 | 方向 | 説明 |
|---|---|---|
| INFRA-1 | INV-1が依存 | Firebase Admin SDKが参照するFirestoreプロジェクトはINFRA-1で作成済みであること |
| INV-2 | INV-1が被依存 | INV-2のWebページはINV-1のGET /api/invitations/[token] を使用する |
| INV-3 | INV-1が被依存 | INV-3のFlutter画面はINV-1のPOST /api/invitations/code を使用する |
| INV-4 | INV-1が被依存 | INV-4のFlutter画面はINV-1のPOST /api/invitations を使用する |

---

# End of Feature Spec: INV-1
