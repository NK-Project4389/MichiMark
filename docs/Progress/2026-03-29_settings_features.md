# 2026-03-29 設定系Feature実装

## 完了した作業

### Spec作成（architect）

| ファイル | 対象 |
|---|---|
| `docs/Spec/Features/System/Settings/TransSetting_Spec.md` | 交通手段マスタ |
| `docs/Spec/Features/System/Settings/MemberSetting_Spec.md` | メンバーマスタ |
| `docs/Spec/Features/System/Settings/TagSetting_Spec.md` | タグマスタ |
| `docs/Spec/Features/System/Settings/ActionSetting_Spec.md` | アクションマスタ |

### 実装（flutter-dev）

**SettingsAdapter**
- `flutter/lib/adapter/settings_adapter.dart`
- Domain → Projection 変換（Trans / Member / Tag / Action）

**TransSetting Feature**（燃費・メーター値フィールドあり・バリデーション複雑）
- Draft / List Bloc / Detail Bloc / ListPage / DetailPage

**MemberSetting Feature**
- Draft / List Bloc / Detail Bloc / ListPage / DetailPage

**TagSetting Feature**
- Draft / List Bloc / Detail Bloc / ListPage / DetailPage

**ActionSetting Feature**
- Draft / List Bloc / Detail Bloc / ListPage / DetailPage

**SettingsPage（設定トップ画面）**
- `flutter/lib/features/settings/view/settings_page.dart`

**ルーター追加**
- `/settings` → SettingsPage
- `/settings/trans`、`/settings/trans/new`、`/settings/trans/:transId`
- `/settings/member`、`/settings/member/new`、`/settings/member/:memberId`
- `/settings/tag`、`/settings/tag/new`、`/settings/tag/:tagId`
- `/settings/action`、`/settings/action/new`、`/settings/action/:actionId`

---

## 設計メモ

- DetailBloc が Repository を直接持つ構成（mark_detail/link_detail と同じパターン）
- 保存成功後 `context.pop(true)` でリスト側が `TagSettingStarted` 等を再発行してリフレッシュ
- TransSetting は `displayKmPerGas`・`displayMeterValue` の文字列⇄数値変換をDraft内のgetterで実装

---

## 次回やること

1. EventDetail 全タブ一括保存（§17）
2. InMemory スタブへのテストデータ投入（seed data）
3. drift Repository 実装（永続化）
4. get_it DI セットアップ
