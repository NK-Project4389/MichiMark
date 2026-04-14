# Feature Spec: イベント追加ボタン 選択肢スキップ遷移

**ID**: FS-event_add_skip_selection
**要件書**: REQ-event_add_skip_selection
**日付**: 2026-04-13
**ステータス**: 確定

---

# 1. Feature Overview

## Feature Name

MichiInfo 追加ボタン 選択肢スキップ遷移

## Purpose

MichiInfo 画面の FAB（追加ボタン）をタップした後、挿入ポイントを選択した際に `TopicConfig.addMenuItems` が 1 件のみの場合は選択肢ボトムシートを表示せず直接登録画面へ遷移する。

これにより `travelExpense` トピック（地点登録のみ）でのユーザー操作が「FABタップ → 挿入ポイント選択 → MarkDetail 直接遷移」に短縮される。

## Scope

含むもの
- 挿入ポイント確定後のボトムシート表示判定変更（1 件のみの場合はスキップ）
- スキップ時の `MichiInfoInsertMarkPressed` / `MichiInfoInsertLinkPressed` Event の自動 dispatch

含まないもの
- `TopicConfig` / `AddMenuItemType` の変更
- Bloc / State / Delegate の構造変更
- 挿入モードのインジケーター UI の変更
- addMenuItems が 0 件の場合の処理（FAB 非表示のため到達しない）
- addMenuItems が 3 件以上の場合の処理

---

# 2. Feature Responsibility

本 Feature の変更対象は MichiInfoView の BlocListener のみ。

- BlocListener が `pendingInsertAfterSeq` 確定を検知したとき `addMenuItems.length` を判定する
- `addMenuItems.length == 1` の場合、ボトムシートを開かずに対応する Event を Bloc に dispatch する
- `addMenuItems.length == 2` の場合、従来通り `_showInsertBottomSheet` を呼び出す

Bloc・State・Delegate 構造は変更しない。

---

# 3. State Structure

変更なし。既存の `MichiInfoLoaded` を使用する。

関連フィールド（参照のみ）:

| フィールド | 型 | 説明 |
|---|---|---|
| `topicConfig.addMenuItems` | `List<AddMenuItemType>` | 追加可能な項目のリスト（1 件 = スキップ、2 件 = ボトムシート）|
| `pendingInsertAfterSeq` | `int?` | 挿入ポイント確定後に非 null になる。null → 非 null への変化がスキップ判定トリガー |
| `isInsertMode` | `bool` | 挿入モード中かどうか |

---

# 4. Draft Model

変更なし。

---

# 5. Domain Model

変更なし。

---

# 6. Projection Model

変更なし。

---

# 7. Adapter

変更なし。

---

# 8. Events

変更なし。既存の以下 Event を使用する。

| Event | 用途 |
|---|---|
| `MichiInfoInsertMarkPressed` | スキップ時に自動 dispatch（地点追加） |
| `MichiInfoInsertLinkPressed` | スキップ時に自動 dispatch（区間追加） |

---

# 9. Delegate

変更なし。

---

# 10. Bloc Responsibility

変更なし。`_onInsertMarkPressed` / `_onInsertLinkPressed` は従来通り Delegate を emit する。

---

# 11. Navigation

変更なし。BlocListener が Delegate を受け取り `context.push()` で遷移する。

---

# 12. Data Flow

## スキップが発生するフロー（addMenuItems.length == 1 のとき）

1. ユーザーが FAB をタップする
2. `MichiInfoInsertModeFabPressed` が dispatch される
3. Bloc が `isInsertMode: true` を emit する
4. ユーザーが挿入インジケーターをタップする
5. `MichiInfoInsertPointSelected(insertAfterSeq)` が dispatch される
6. Bloc が `pendingInsertAfterSeq: <seq>` を emit する
7. BlocListener が `pendingInsertAfterSeq != null` を検知する
8. `topicConfig.addMenuItems.length == 1` を判定する
9. ボトムシートを開かず、唯一の `addMenuItems` 要素に応じて `MichiInfoInsertMarkPressed` または `MichiInfoInsertLinkPressed` を dispatch する
10. Bloc が Delegate を emit する
11. BlocListener が Delegate を受け取り、MarkDetail または LinkDetail へ遷移する

## 0 件時フロー（リストが空かつ addMenuItems.length == 1 のとき）

1. ユーザーが FAB をタップする
2. `MichiInfoInsertModeFabPressed` が dispatch される
3. Bloc が `isInsertMode: true, pendingInsertAfterSeq: -1` を emit する（0 件シグナル値）
4. BlocListener が `pendingInsertAfterSeq != null` を検知する
5. `topicConfig.addMenuItems.length == 1` を判定する
6. ボトムシートを開かず、対応する Event を dispatch する

## 従来通りのフロー（addMenuItems.length == 2 のとき）

挿入ポイント確定後に `_showInsertBottomSheet` を呼び出す（既存動作を維持）。

---

# 13. Persistence

変更なし。

---

# 14. Validation

スキップ判定ロジック（BlocListener 内）:

```
pendingInsertAfterSeq が null → 非 null に変化したとき:
  addMenuItems.length == 1:
    addMenuItems[0] == mark → MichiInfoInsertMarkPressed を dispatch
    addMenuItems[0] == link → MichiInfoInsertLinkPressed を dispatch
  addMenuItems.length == 2:
    _showInsertBottomSheet を呼び出す（従来通り）
  addMenuItems.length == 0:
    何もしない（安全ガード、到達しない想定）
```

---

# 15. SwiftUI版との対応

本機能は Flutter 版独自の改善であり、SwiftUI 版に対応する機能はない。

---

# 16. Test Scenarios

## 前提条件

- iOSシミュレーターが起動済みであること
- シードデータが読み込まれた状態でアプリが起動していること
- 以下のシードデータが存在すること:
  - `event-001`（箱根日帰りドライブ）: `movingCost` トピック、`addMenuItems = [mark, link]`
  - `event-002`（富士五湖キャンプ）: `travelExpense` トピック、`addMenuItems = [mark]`

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-EAS-001 | travelExpense: FABタップ後インジケーター選択で直接MarkDetail遷移（リスト空） | High |
| TC-EAS-002 | travelExpense: FABタップ後インジケーター選択で直接MarkDetail遷移（リストあり） | High |
| TC-EAS-003 | movingCost: FABタップ後インジケーター選択でボトムシートが表示される | High |
| TC-EAS-004 | movingCost: ボトムシートで「地点を追加」を選択するとMarkDetailへ遷移する | Medium |
| TC-EAS-005 | movingCost: ボトムシートで「区間を追加」を選択するとLinkDetailへ遷移する | Medium |
| TC-EAS-006 | travelExpense: MarkDetail保存後にMichiInfo一覧に戻れる | Medium |

---

## TC-EAS-001: travelExpense FABタップ後インジケーター選択で直接MarkDetail遷移（リスト空）

**前提:**
- `event-002`（富士五湖キャンプ / travelExpense トピック）を開いている
- MichiInfo タブにアイテムが 0 件

**操作手順:**
1. アプリを起動する
2. イベント一覧から「富士五湖キャンプ」をタップして EventDetail を開く
3. 「記録」タブ（MichiInfo）を表示する
4. FAB（追加ボタン）をタップする
5. 自動的に挿入ポイント（`pendingInsertAfterSeq: -1`）が確定される

**期待結果:**
- ボトムシート（選択肢画面）は表示されない
- MarkDetail 画面（地点追加）が直接表示される

**実装ノート（ウィジェットキー一覧）:**

| キー | 要素 | 配置場所 |
|---|---|---|
| `Key('michiInfo_fab_add')` | FAB（追加ボタン） | MichiInfo 画面 |
| `Key('markDetail_screen')` | MarkDetail 画面全体 | MarkDetail 画面 |

---

## TC-EAS-002: travelExpense FABタップ後インジケーター選択で直接MarkDetail遷移（リストあり）

**前提:**
- `event-002`（富士五湖キャンプ / travelExpense トピック）を開いている
- MichiInfo タブに 1 件以上のアイテムが存在する（TC-EAS-001 実行後の状態、または事前にアイテムを追加）

**操作手順:**
1. アプリを起動する
2. イベント一覧から「富士五湖キャンプ」をタップして EventDetail を開く
3. 「記録」タブ（MichiInfo）を表示する
4. FAB（追加ボタン）をタップして挿入モードに入る
5. 先頭インジケーター（リスト上部の挿入位置）をタップする

**期待結果:**
- ボトムシート（選択肢画面）は表示されない
- MarkDetail 画面（地点追加）が直接表示される

**実装ノート（ウィジェットキー一覧）:**

| キー | 要素 | 配置場所 |
|---|---|---|
| `Key('michiInfo_fab_add')` | FAB（追加ボタン） | MichiInfo 画面 |
| `Key('michiInfo_button_insertIndicator_head')` | 先頭挿入インジケーター（insertAfterSeq: -1） | MichiInfo 挿入モード |
| `Key('markDetail_screen')` | MarkDetail 画面全体 | MarkDetail 画面 |

---

## TC-EAS-003: movingCost FABタップ後インジケーター選択でボトムシートが表示される

**前提:**
- `event-001`（箱根日帰りドライブ / movingCost トピック）を開いている

**操作手順:**
1. アプリを起動する
2. イベント一覧から「箱根日帰りドライブ」をタップして EventDetail を開く
3. 「記録」タブ（MichiInfo）を表示する
4. FAB（追加ボタン）をタップして挿入モードに入る
5. 先頭インジケーターをタップする（0 件の場合は FAB タップ直後に自動確定）

**期待結果:**
- ボトムシートが表示される
- ボトムシートに「地点を追加」の選択肢が存在する
- ボトムシートに「区間を追加」の選択肢が存在する

**実装ノート（ウィジェットキー一覧）:**

| キー | 要素 | 配置場所 |
|---|---|---|
| `Key('michiInfo_fab_add')` | FAB（追加ボタン） | MichiInfo 画面 |
| `Key('michiInfo_button_insertIndicator_head')` | 先頭挿入インジケーター | MichiInfo 挿入モード |
| `Key('michiInfo_button_addMark')` | ボトムシート「地点を追加」 | 選択肢ボトムシート |
| `Key('michiInfo_button_addLink')` | ボトムシート「区間を追加」 | 選択肢ボトムシート |

---

## TC-EAS-004: movingCost ボトムシートで「地点を追加」を選択するとMarkDetailへ遷移する

**前提:**
- `event-001`（箱根日帰りドライブ / movingCost トピック）を開いている

**操作手順:**
1. アプリを起動する
2. イベント一覧から「箱根日帰りドライブ」をタップして EventDetail を開く
3. 「記録」タブ（MichiInfo）を表示する
4. FABをタップして挿入モードに入る
5. インジケーターをタップする
6. ボトムシートの「地点を追加」をタップする

**期待結果:**
- MarkDetail 画面（地点追加）が表示される

**実装ノート（ウィジェットキー一覧）:**

| キー | 要素 | 配置場所 |
|---|---|---|
| `Key('michiInfo_fab_add')` | FAB（追加ボタン） | MichiInfo 画面 |
| `Key('michiInfo_button_addMark')` | ボトムシート「地点を追加」 | 選択肢ボトムシート |
| `Key('markDetail_screen')` | MarkDetail 画面全体 | MarkDetail 画面 |

---

## TC-EAS-005: movingCost ボトムシートで「区間を追加」を選択するとLinkDetailへ遷移する

**前提:**
- `event-001`（箱根日帰りドライブ / movingCost トピック）を開いている

**操作手順:**
1. アプリを起動する
2. イベント一覧から「箱根日帰りドライブ」をタップして EventDetail を開く
3. 「記録」タブ（MichiInfo）を表示する
4. FABをタップして挿入モードに入る
5. インジケーターをタップする
6. ボトムシートの「区間を追加」をタップする

**期待結果:**
- LinkDetail 画面（区間追加）が表示される

**実装ノート（ウィジェットキー一覧）:**

| キー | 要素 | 配置場所 |
|---|---|---|
| `Key('michiInfo_fab_add')` | FAB（追加ボタン） | MichiInfo 画面 |
| `Key('michiInfo_button_addLink')` | ボトムシート「区間を追加」 | 選択肢ボトムシート |
| `Key('linkDetail_screen')` | LinkDetail 画面全体 | LinkDetail 画面 |

---

## TC-EAS-006: travelExpense MarkDetail保存後にMichiInfo一覧に戻れる

**前提:**
- `event-002`（富士五湖キャンプ / travelExpense トピック）を開いている

**操作手順:**
1. アプリを起動する
2. イベント一覧から「富士五湖キャンプ」をタップして EventDetail を開く
3. 「記録」タブ（MichiInfo）を表示する
4. FABをタップして MarkDetail 画面へ直接遷移する
5. 名前フィールドに「テスト地点」を入力する
6. 保存ボタンをタップする

**期待結果:**
- MichiInfo 一覧画面に戻る
- 一覧に追加した地点が表示される

**実装ノート（ウィジェットキー一覧）:**

| キー | 要素 | 配置場所 |
|---|---|---|
| `Key('michiInfo_fab_add')` | FAB（追加ボタン） | MichiInfo 画面 |
| `Key('markDetail_screen')` | MarkDetail 画面全体 | MarkDetail 画面 |
| `Key('markDetail_field_name')` | 名前入力フィールド | MarkDetail 画面（トピックが showNameField: true の場合のみ表示） |
| `Key('markDetail_button_save')` | 保存ボタン | MarkDetail 画面 |

**備考:**
- `travelExpense` トピックの `showNameField` が `true` の場合のみ名前フィールドが表示される
- MichiInfo 一覧への復帰確認は `Key('michiInfo_screen')` またはタイムラインアイテムの存在確認で代替してよい

---

# 17. 変更対象ファイル

| ファイル | 変更種別 | 変更内容 |
|---|---|---|
| `flutter/lib/features/michi_info/view/michi_info_view.dart` | BlocListener の判定ロジック変更 | `pendingInsertAfterSeq` 確定時に `addMenuItems.length` を判定してスキップ処理を行う |

---

# 18. 実装上の注意事項

1. `addMenuItems.length == 1` の判定を `pendingInsertAfterSeq != null` の検知条件と組み合わせること
2. スキップ時に dispatch する Event は `MichiInfoInsertMarkPressed` または `MichiInfoInsertLinkPressed` とし、`pendingInsertAfterSeq` の値（挿入位置）は Bloc 内の `current.pendingInsertAfterSeq` から参照される（変更不要）
3. `_showInsertBottomSheet` 呼び出し後の `MichiInfoInsertPointCancelled` dispatch はスキップ時には不要（MarkDetail/LinkDetail 遷移後のリロードで挿入モードは自動リセットされる）
4. ボトムシートのキャンセル処理（挿入モード中断）は従来通り `_showInsertBottomSheet` 内で行う

---

# End of Feature Spec
