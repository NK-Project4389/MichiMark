# 進捗: 設定Feature バグ修正・非表示フィルター実装

日付: 2026-04-08

---

## 完了した作業

### 1. 設定ページ 戻るボタン PageNotFound バグ修正

**原因**: `settings_page.dart` の `context.go('/events')` が存在しないルートを指定していた（イベント一覧のルートは `/`）

**修正**: `context.go('/')` に変更

対象ファイル:
- `flutter/lib/features/settings/view/settings_page.dart`

コミット: `fix: 設定ページ戻るバグ修正（/events→/）・非表示セクションヘッダー追加` (28a5110)

---

### 2. 設定一覧 非表示セクションヘッダー追加（Trans/Member/Tag/Action 全4ページ）

**仕様**:
- 表示アイテムが上、非表示アイテムが下に集約
- 非表示アイテムが1件以上ある場合、境目に「非表示」セクションヘッダーを表示
- ヘッダー色: `colorScheme.surfaceContainerHighest`
- 非表示アイテムがない場合は従来通りのフラットリスト

対象ファイル:
- `flutter/lib/features/settings/trans_setting/view/trans_setting_page.dart`
- `flutter/lib/features/settings/member_setting/view/member_setting_page.dart`
- `flutter/lib/features/settings/tag_setting/view/tag_setting_page.dart`
- `flutter/lib/features/settings/action_setting/view/action_setting_page.dart`

---

### 3. 選択リストから非表示マスターを除外

**仕様**:
- `SelectionAdapter` の各 `from*` メソッドに `.where((x) => x.isVisible)` フィルターを追加
- 対象: Trans / Tag / Action / Topic
- Member のみ例外: `fixedSelectedIds`（支払者など固定済みID）に含まれる場合は非表示でも表示を維持

対象ファイル:
- `flutter/lib/adapter/selection_adapter.dart`

コミット: `fix: 選択リストから非表示マスターを除外（Trans/Member/Tag/Action/Topic）` (cda850c)

---

## 未完了・次回やること

- [ ] **tester**: 今回のバグ修正2件の動作確認テスト（設定ページ戻り・選択フィルター）
- [ ] **T-070**: MichiInfo 日付セパレーター Spec 作成（architect）
- [ ] **T-071→072**: 日付セパレーター 実装・レビュー

## 次回セッションで最初にやること

1. **tester** に動作確認テスト依頼（設定ページ戻り・選択フィルター）
2. **T-070** 日付セパレーター Spec 作成（architect）
3. **Phase2 動作確認**（T-010〜012）の続きか次のフィーチャー着手
