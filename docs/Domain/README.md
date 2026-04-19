# Domain 設計ドキュメント 運用ルール

## 概要

MichiMark の Domain 設計は **Google Spreadsheets** で管理している。
各 Domain の詳細な設計書（フィールド一覧・型・バージョン履歴）はスプレッドシートが正とする。
このディレクトリ内の `*.md` ファイルはスプレッドシートの概要・補足説明を記載したサマリーである。

---

## Google Spreadsheets（正式ドキュメント）

| 用途 | スプレッドシート名 | URL |
|---|---|---|
| **メイン（現行）** | MichiMark Domain設計一覧 | https://docs.google.com/spreadsheets/d/1hwMQuhej1o-OHm4YhYX-2XiqyLAoN-3w65wlRVNjYCo/edit |
| バックアップ（旧） | Domain設計一覧 | https://docs.google.com/spreadsheets/d/13d2rywy_Kq7Nz1m0Ybzyvif_SVYZgFhKgmHmlG4W_sg/edit |

> **作業時は「MichiMark Domain設計一覧」を参照・更新すること。**

---

## シート構成

| シート名 | 対応 Domain | 現在の schemaVersion |
|---|---|---|
| Event | イベント | v8 |
| MarkLink | マーク・リンク | v8 |
| Payment | 支払い・売上 | v8 |
| Member | メンバー | v8 |
| Trans | 交通手段 | v8 |
| Tag | タグ | v8 |
| Action | アクション定義 | v8 |
| ActionTimeLogs | アクション時間ログ | v8 |

---

## スプレッドシート更新手順

### 通常の更新（フィールド追加・変更）

1. drift の `*.dart` ファイルでスキーマ変更を実施（`schemaVersion` を +1 する）
2. 変更に合わせてスプレッドシートの該当シートを更新する
   - フィールド行を追加・修正
   - `schemaVersion` 備考欄を「現在値: vX」に更新
3. このディレクトリの該当 `*.md` ファイルがあれば内容を同期する
4. git commit に「chore: Domain設計 vX 更新 - [変更概要]」を記載する

### MCP ツールでの更新

Claude Code から Google Workspace MCP を使って直接セルを更新できる。

```
# セル更新
mcp__google-workspace__gsheets_update_cell

# シート読み込み
mcp__google-workspace__gsheets_read

# Drive 検索
mcp__google-workspace__gdrive_search
```

> **認証トラブル時**: `~/.config/gsheets-mcp/` に OAuth トークンが格納されている。
> トークン切れの場合は `npx @isaacphi/mcp-gdrive` を再起動して再認証する。

---

## Domain MD ファイルと Google Sheets の関係

| ファイル | 役割 |
|---|---|
| `docs/Domain/*.md` | Domain 概要・補足説明（サマリー） |
| Google Sheets | フィールド一覧・型・バージョン履歴（正） |

スプレッドシートを正として、`*.md` は必要に応じて参照する補足資料として扱う。
スプレッドシートと `*.md` に矛盾がある場合は **スプレッドシートを優先**する。

---

## バージョン履歴（主要変更）

| バージョン | 変更内容 |
|---|---|
| v1 | 初期設計（Event / MarkLink / Payment / Member / Trans / Tag） |
| v2 | Action Domain 追加・ActionTimeLogs 追加 |
| v3 | Action.needsTransition 追加 |
| v4 | MarkLink.members / MarkLink.gasPayer 追加 |
| v5 | Payment.markLinkID 追加 |
| v6 | Action.endFlag 追加 |
| v7 | ActionTimeLogs.adjustedAt 追加 |
| v8 | Payment.paymentType（expense/revenue）追加・Google Sheets 移行完了 |
