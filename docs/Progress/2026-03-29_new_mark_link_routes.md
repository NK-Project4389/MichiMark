# 2026-03-29 マーク/リンク新規作成ルート追加

## 完了した作業

### Event・Bloc更新（flutter-dev）

| ファイル | 変更内容 |
|---|---|
| `mark_detail/bloc/mark_detail_event.dart` | `MarkDetailStarted.markLinkId` を `String?` に変更（null = 新規） |
| `mark_detail/bloc/mark_detail_bloc.dart` | `_onStarted`: null時に `DateTime.now()` で初期Draft生成 |
| `link_detail/bloc/link_detail_event.dart` | `LinkDetailStarted.markLinkId` を `String?` に変更（null = 新規） |
| `link_detail/bloc/link_detail_bloc.dart` | `_onStarted`: null時に `DateTime.now()` で初期Draft生成 |

### ルーター追加（flutter-dev）

| ルート | extra | 用途 |
|---|---|---|
| `/event/mark/new` | `String` eventId | マーク新規作成 |
| `/event/mark/:markId` | `String` eventId | マーク既存編集（変更なし） |
| `/event/link/new` | `String` eventId | リンク新規作成 |
| `/event/link/:linkId` | `String` eventId | リンク既存編集（変更なし） |

静的ルートをパラメータルートより先に定義（go_router優先順位対応）。

### MichiInfoView TODO解消（flutter-dev）

- `MichiInfoAddMarkDelegate` → `context.go('/event/mark/new', extra: eventId)` 実装
- `MichiInfoAddLinkDelegate` → `context.go('/event/link/new', extra: eventId)` 実装

---

## 次回やること

### 優先タスク
1. EventDetail 全タブ一括保存（§17）
2. InMemory スタブへのテストデータ投入（seed data）
3. drift Repository 実装（永続化）
4. get_it DI セットアップ
5. 設定系 Feature（trans_setting, member_setting, tag_setting, action_setting）
