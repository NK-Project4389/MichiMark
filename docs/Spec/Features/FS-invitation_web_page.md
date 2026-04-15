# Feature Spec: 招待機能 中間Webページ（INV-2）

Platform: **Next.js / TypeScript**（Vercel）
Version: 1.0
Status: Draft
Created: 2026-04-15
Requirement: `docs/Requirements/REQ-invitation_web_page.md`

---

# 1. Feature Overview

## Feature Name

InvitationWebPage

## Purpose

招待リンクをLINEで共有したとき、ブラウザで開く中間Webページを提供する。
INV-1 で整備した Next.js プロジェクトに `/invite/[token]` ページを追加し、
アプリ起動へのブリッジ・招待コード表示・エラーハンドリングを担う。

## Scope

**含むもの**
- `app/invite/[token]/page.tsx`（Server Component）
- 招待情報取得（GET /api/invitations/[token]）
- 未紐づけmember一覧取得（GET /api/invitations/[token]/members）
- アプリ起動ボタン（カスタムURLスキーム）
- App Store 誘導フォールバック
- エラー状態表示
- OGPメタタグ設定

**含まないもの**
- member選択・参加確定（アプリ側 INV-3 の責務）
- 招待リンク生成（INV-4 の責務）

---

# 2. 前提条件

- INFRA-1（Firebase基盤整備）完了
- INV-1（バックエンドAPI）完了

---

# 3. ページ仕様

## 3.1 URL

```
https://[ドメイン]/invite/[token]
```

`token` はINV-1 `POST /api/invitations` の `token` フィールド（8文字の小文字英数字）。

## 3.2 データ取得

Server Component として実装する。`page.tsx` の `generateMetadata` と本体でそれぞれ
`GET /api/invitations/[token]` を呼び、結果に応じてUI分岐する。

```
GET /api/invitations/[token]
→ 成功: InvitationInfoResponse { eventName, inviterName, code, role }
→ エラー: InvitationErrorResponse { errorType: 'expired' | 'used_up' | 'not_found' }
```

> **Note:** INV-1 Spec `GET /api/invitations/[token]` のレスポンスに `code` フィールドを追加する。
> （招待コードをWebページで表示するために必要。INV-1 実装側で追加対応すること）

## 3.3 表示状態

### 正常状態

```
┌─────────────────────────────┐
│  MichiMark                  │
│─────────────────────────────│
│  [inviterName]さんが         │
│  イベントに招待しています      │
│                             │
│  📍 [eventName]             │
│                             │
│  招待コード                  │
│  ┌─────────────────────┐   │
│  │   ABC-1234          │   │
│  └─────────────────────┘   │
│                             │
│  [アプリで参加する] ←ボタン  │
│                             │
│  App Storeからダウンロード   │
└─────────────────────────────┘
```

### エラー状態

| errorType | 表示メッセージ |
|---|---|
| `expired` | 「この招待リンクの有効期限が切れています」 |
| `used_up` | 「この招待リンクは使用済みです」 |
| `not_found` | 「招待リンクが見つかりません」 |

エラー時は参加ボタンを非表示にする。App Storeリンクは常時表示する。

## 3.4 「アプリで参加する」ボタン

- タップ時に `michimark://invite/[token]` のカスタムURLスキームを起動する
- 2秒後にページが閉じていない（アプリが反応しない）場合、App Store URLへ遷移する

```typescript
// クライアントコンポーネントとして実装
const handleJoinApp = () => {
  window.location.href = `michimark://invite/${token}`;
  setTimeout(() => {
    window.location.href = APP_STORE_URL;
  }, 2000);
};
```

## 3.5 「App Storeからダウンロード」リンク

- 常時表示
- `APP_STORE_URL` は環境変数 `NEXT_PUBLIC_APP_STORE_URL` から取得する

## 3.6 OGPメタタグ

`generateMetadata` で設定する。

| タグ | 値（正常時） | 値（エラー時） |
|---|---|---|
| `og:title` | 「[eventName]への招待」 | 「MichiMark」 |
| `og:description` | 「[inviterName]さんがミチマークのイベントに招待しています」 | 「ドライブ記録アプリ MichiMark」 |
| `og:image` | `/og-image.png`（静的） | `/og-image.png`（静的） |

---

# 4. ファイル構成

```
app/
  invite/
    [token]/
      page.tsx          ← Server Component（メインページ）
      InvitePageClient.tsx  ← Client Component（ボタンのインタラクション）
```

## 4.1 page.tsx（Server Component）

```typescript
// app/invite/[token]/page.tsx
import { getInvitationInfo } from '@/lib/invitation-service';
import { InvitePageClient } from './InvitePageClient';

type Props = { params: Promise<{ token: string }> };

export async function generateMetadata({ params }: Props) {
  const { token } = await params;
  const result = await getInvitationInfo(token);
  // OGP設定
}

export default async function InvitePage({ params }: Props) {
  const { token } = await params;
  const result = await getInvitationInfo(token);

  if ('errorType' in result) {
    return <ErrorView errorType={result.errorType} />;
  }
  return <InvitePageClient token={token} info={result} />;
}
```

## 4.2 InvitePageClient.tsx（Client Component）

- `'use client'` 宣言
- 「アプリで参加する」ボタンのクリックハンドラを実装
- `token` と `InvitationInfoResponse` を props で受け取る
- `APP_STORE_URL` は `process.env.NEXT_PUBLIC_APP_STORE_URL` から取得

## 4.3 lib/invitation-service.ts への追加

既存の `invitation-service.ts` に `getInvitationInfo(token: string)` 関数を追加する。
`GET /api/invitations/[token]` を呼び、`InvitationInfoResponse | InvitationErrorResponse` を返す。

> **注意:** Server Component から直接 API Routes を fetch するのではなく、
> `lib/invitation-service.ts` の関数を直接呼び出す（同一プロセス内関数呼び出し）。

---

# 5. 環境変数

| 変数名 | 用途 |
|---|---|
| `NEXT_PUBLIC_APP_STORE_URL` | App Store URL（公開後に設定） |

---

# 6. デザイン

- Tailwind CSS でスタイリング
- ミチマークのブランドカラー（Teal系）を使用
- モバイルファーストレスポンシブ

---

# 7. テストシナリオ

## 7.1 テスト種別

INV-2 はNext.jsのServer Component + Client ComponentのためFlutter Integration Testの対象外。
以下のシナリオはJest + React Testing Library によるコンポーネントテスト（Unit/Integration）として実装する。

## 7.2 テストシナリオ一覧

| ID | シナリオ | テスト種別 | 優先度 |
|---|---|---|---|
| TC-INV2-001 | 有効なtoken → イベント名・招待者名・招待コードが表示される | Unit | 高 |
| TC-INV2-002 | expired → エラーメッセージ「有効期限が切れています」が表示され、参加ボタンが非表示 | Unit | 高 |
| TC-INV2-003 | used_up → エラーメッセージ「使用済みです」が表示され、参加ボタンが非表示 | Unit | 高 |
| TC-INV2-004 | not_found → エラーメッセージ「見つかりません」が表示され、参加ボタンが非表示 | Unit | 高 |
| TC-INV2-005 | 「アプリで参加する」ボタンタップ → `michimark://invite/[token]` が呼び出される | Unit | 高 |
| TC-INV2-006 | 正常時OGP → `og:title` が「[eventName]への招待」になっている | Unit | 中 |
| TC-INV2-007 | エラー時OGP → `og:title` が「MichiMark」になっている | Unit | 中 |
| TC-INV2-008 | App Storeリンクが正常状態・エラー状態ともに表示される | Unit | 中 |

---

# 8. 依存関係

- **INV-1:** `GET /api/invitations/[token]` のレスポンスに `code` フィールド追加が必要
- **INV-3:** アプリ起動後の member 選択・参加確定はINV-3で実装
- **INV-4:** 招待リンク生成はINV-4で実装
