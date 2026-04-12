# Feature Spec: ガソリン支払者インラインチップ選択 (Phase C)

**Spec ID**: FS-gas_payer_chip_selection_phaseC
**要件ID**: （Phase B スコープ外として分離）
**作成日**: 2026-04-12
**ステータス**: Draft
**スコープ**: Phase C — MarkDetail・LinkDetail のガソリン支払者選択インライン化

---

# 1. Feature Overview

## Feature Name

ガソリン支払者インラインチップ選択 (Phase C)

## Purpose

MarkDetail・LinkDetail の給油フラグ ON 時に表示される「ガソリン支払者」選択を、
現在の `_SelectionRow`（InkWell + chevron_right アイコン → 別画面遷移）から
インライン FilterChip 選択 UI に置き換える。
PaymentDetail の支払者選択（Phase B 実装済み）と同じパターンを採用し、
タップ数を削減して同一画面内で操作を完結させる。

## Scope

含むもの
- MarkDetail: 給油フラグ ON 時の「ガソリン支払者」`_SelectionRow` を `_GasPayerChipSection`（single 選択）に置き換え
- LinkDetail: 同上
- MarkDetailBloc: `MarkDetailEditGasPayerPressed` / `MarkDetailGasPayerSelected` イベントを廃止し、新規に `MarkDetailGasPayerChipToggled` を追加
- LinkDetailBloc: `LinkDetailEditGasPayerPressed` / `LinkDetailGasPayerSelected` イベントを廃止し、新規に `LinkDetailGasPayerChipToggled` を追加
- MarkDetailDelegate: `MarkDetailOpenGasPayerSelectionDelegate` の削除
- LinkDetailDelegate: `LinkDetailOpenGasPayerSelectionDelegate` の削除
- MarkDetailPage の `_handleDelegate` から `MarkDetailOpenGasPayerSelectionDelegate` 分岐を削除
- LinkDetailPage の `_handleDelegate` から `LinkDetailOpenGasPayerSelectionDelegate` 分岐を削除

含まないもの
- Phase A（BasicInfo）の変更
- Phase B（MarkDetail/LinkDetail メンバー選択・PaymentDetail 支払者選択）の変更
- FuelDetail フィールド（ガソリン単価・給油量・合計金額）の変更
- SelectionPage の完全削除（markActions・linkActions は別画面遷移を維持）
- アクション選択の変更
- 保存処理・Domain・Repository の変更

---

# 2. Feature Responsibility

## MarkDetailBloc の責務（変更後）

- MarkDetailDraft の所有・更新
- `availableMembers`（イベントメンバー一覧）を `MarkDetailStarted.eventMembers` から初期化（変更なし）
- **ガソリン支払者チップ ON/OFF ロジック（single 選択）を内部で処理**
  - 同一メンバーをタップ → 選択解除（toggle）
  - 別メンバーをタップ → 前の選択を解除し新しいメンバーを選択
- Delegate 通知（保存完了・エラー・Dismiss のみ。`MarkDetailOpenGasPayerSelectionDelegate` は削除）

## LinkDetailBloc の責務（変更後）

MarkDetailBloc と同様。

---

# 3. State Structure

## MarkDetailLoaded（変更なし）

新規フィールド追加なし。`availableMembers` は既存フィールドをガソリン支払者チップにも兼用する。

| フィールド | 型 | 説明 |
|---|---|---|
| `draft` | `MarkDetailDraft` | 編集状態 |
| `delegate` | `MarkDetailDelegate?` | 遷移・操作意図 |
| `topicConfig` | `TopicConfig` | Topic に基づく表示制御 |
| `isSaving` | `bool` | DB 保存中フラグ |
| `availableMembers` | `List<MemberDomain>` | イベントメンバー全件（メンバーチップ・ガソリン支払者チップ共用） |

## LinkDetailLoaded（変更なし）

MarkDetailLoaded と同構造。

---

# 4. Draft Model

## MarkDetailDraft（変更なし）

既存フィールドをそのまま使用。

| フィールド | 型 | 説明 |
|---|---|---|
| `selectedGasPayer` | `MemberDomain?` | 選択中のガソリン支払者（null = 未選択） |
| その他フィールド | 既存通り | 変更なし |

`selectedGasPayer` は nullable のまま維持する。
チップタップ時に同一メンバーを再タップした場合は null にセットする（選択解除）。

## LinkDetailDraft（変更なし）

MarkDetailDraft と同構造。

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

## MarkDetailBloc 変更点

### 削除するイベント

| イベント名 | 理由 |
|---|---|
| `MarkDetailEditGasPayerPressed` | 別画面遷移を起動するイベント。インライン化により不要 |
| `MarkDetailGasPayerSelected` | 選択画面からの返却イベント。インライン化により不要 |

### 追加するイベント

| イベント名 | 発火タイミング | フィールド |
|---|---|---|
| `MarkDetailGasPayerChipToggled` | ガソリン支払者チップがタップされたとき | `member: MemberDomain` |

## LinkDetailBloc 変更点

### 削除するイベント

| イベント名 | 理由 |
|---|---|
| `LinkDetailEditGasPayerPressed` | 同上 |
| `LinkDetailGasPayerSelected` | 同上 |

### 追加するイベント

| イベント名 | 発火タイミング | フィールド |
|---|---|---|
| `LinkDetailGasPayerChipToggled` | ガソリン支払者チップがタップされたとき | `member: MemberDomain` |

---

# 9. Delegate

## MarkDetailDelegate 変更点

### 削除する Delegate

| Delegate 名 | 理由 |
|---|---|
| `MarkDetailOpenGasPayerSelectionDelegate` | 別画面遷移が不要になるため削除 |

### 維持する Delegate

| Delegate 名 | 用途 |
|---|---|
| `MarkDetailDismissDelegate` | 戻るボタン |
| `MarkDetailOpenActionsSelectionDelegate` | アクション選択（変更なし） |
| `MarkDetailSavedDelegate` | 保存完了 |
| `MarkDetailSaveErrorDelegate` | 保存エラー |

## LinkDetailDelegate 変更点

### 削除する Delegate

| Delegate 名 | 理由 |
|---|---|
| `LinkDetailOpenGasPayerSelectionDelegate` | 同上 |

### 維持する Delegate

| Delegate 名 | 用途 |
|---|---|
| `LinkDetailDismissDelegate` | 戻るボタン |
| `LinkDetailOpenActionsSelectionDelegate` | アクション選択（変更なし） |
| `LinkDetailSavedDelegate` | 保存完了 |
| `LinkDetailSaveErrorDelegate` | 保存エラー |

---

# 10. Bloc Responsibility

## MarkDetailBloc

`MarkDetailGasPayerChipToggled` ハンドラの処理方針:
- タップされた `member` と `draft.selectedGasPayer` が同一 ID → `selectedGasPayer = null`（選択解除）
- 異なる ID → `selectedGasPayer = member`（新規選択）
- Draft を更新して emit する。Delegate は不要。

## LinkDetailBloc

MarkDetailBloc と同様。

---

# 11. Navigation

ガソリン支払者選択は別画面遷移を廃止する。
`MarkDetailPage._handleDelegate` から `MarkDetailOpenGasPayerSelectionDelegate` の分岐を削除する。
`LinkDetailPage._handleDelegate` から `LinkDetailOpenGasPayerSelectionDelegate` の分岐を削除する。

アクション選択は引き続き `context.push` による別画面遷移を維持する（変更なし）。

---

# 12. Data Flow

ガソリン支払者チップ選択時のデータフロー:

- ユーザーがチップをタップ
- `MarkDetailGasPayerChipToggled(member)` / `LinkDetailGasPayerChipToggled(member)` が発火
- Bloc がトグルロジックを適用して `draft.selectedGasPayer` を更新
- State を emit
- `_GasPayerChipSection` が BlocBuilder 経由で再描画
- チップの `selected` 状態が変化

---

# 13. Persistence

変更なし。`selectedGasPayer` は `MarkDetailDraft` / `LinkDetailDraft` に保持し、
保存時に既存の Adapter → Domain → Repository の流れで永続化される。

---

# 14. Validation

変更なし。ガソリン支払者は任意項目（null 許容）のため、未選択でも保存可能。

---

# 15. SwiftUI版との対応

| Flutter Feature | 対応SwiftUI Reducer |
|---|---|
| mark_detail (GasPayer選択) | MarkDetailReducer |
| link_detail (GasPayer選択) | LinkDetailReducer |

---

# 16. 変更対象ファイル一覧

| ファイル | 変更内容 |
|---|---|
| `flutter/lib/features/mark_detail/bloc/mark_detail_event.dart` | `MarkDetailEditGasPayerPressed` / `MarkDetailGasPayerSelected` 削除、`MarkDetailGasPayerChipToggled` 追加 |
| `flutter/lib/features/mark_detail/bloc/mark_detail_state.dart` | `MarkDetailOpenGasPayerSelectionDelegate` 削除 |
| `flutter/lib/features/mark_detail/bloc/mark_detail_bloc.dart` | 上記イベントのハンドラ変更 |
| `flutter/lib/features/mark_detail/view/mark_detail_page.dart` | `_SelectionRow`（ガソリン支払者）を `_GasPayerChipSection` に置き換え、Delegate 分岐削除 |
| `flutter/lib/features/link_detail/bloc/link_detail_event.dart` | `LinkDetailEditGasPayerPressed` / `LinkDetailGasPayerSelected` 削除、`LinkDetailGasPayerChipToggled` 追加 |
| `flutter/lib/features/link_detail/bloc/link_detail_state.dart` | `LinkDetailOpenGasPayerSelectionDelegate` 削除 |
| `flutter/lib/features/link_detail/bloc/link_detail_bloc.dart` | 上記イベントのハンドラ変更 |
| `flutter/lib/features/link_detail/view/link_detail_page.dart` | `_SelectionRow`（ガソリン支払者）を `_GasPayerChipSection` に置き換え、Delegate 分岐削除 |

Draft・Domain・Adapter・Repository は変更不要。

---

# 17. Test Scenarios

テストコードは `flutter/integration_test/gas_payer_chip_test.dart` として実装済み（T-270b 完了）。
以下のシナリオ定義は既実装テストコードの参照用。

## 前提条件

- iOSシミュレーターが起動済みであること
- シードデータ「箱根日帰りドライブ」イベントが存在すること
- 当該イベントに Mark「大涌谷」・Link「東名高速」が存在すること
- イベントにメンバーが2名以上登録されていること（TC-GPS-004 の単一選択検証に必要）

## テストシナリオ一覧

| ID | シナリオ名 | 対象 | 優先度 |
|---|---|---|---|
| TC-GPS-001 | 給油ONにするとガソリン支払者チップが表示されること | MarkDetail | High |
| TC-GPS-002 | ガソリン支払者チップをタップすると選択状態になること | MarkDetail | High |
| TC-GPS-003 | ガソリン支払者チップ選択後に保存・再表示で選択が維持されること | MarkDetail | High |
| TC-GPS-004 | ガソリン支払者チップは単一選択であること | MarkDetail | High |
| TC-GPS-005 | 給油OFFにするとガソリン支払者チップが非表示になること | MarkDetail | Medium |
| TC-GPS-006 | 給油ONにするとガソリン支払者チップが表示されること | LinkDetail | High |
| TC-GPS-007 | ガソリン支払者チップをタップすると選択状態になること | LinkDetail | High |
| TC-GPS-008 | ガソリン支払者チップ選択後に保存・再表示で選択が維持されること | LinkDetail | High |

## シナリオ詳細

### TC-GPS-001: MarkDetail — 給油ONにするとガソリン支払者チップが表示されること

**前提:**
- 「箱根日帰りドライブ」イベントが存在する
- イベント内に Mark「大涌谷」が存在する

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「箱根日帰りドライブ」をタップして EventDetail を開く
3. ミチタブに切り替える
4. Mark「大涌谷」をタップして MarkDetail を開く
5. 給油スイッチを ON にする

**期待結果:**
- 「ガソリン支払者」ラベルが表示される
- FilterChip が1件以上表示される（インラインチップ選択 UI）
- chevron_right アイコンによる別画面遷移ボタンが「ガソリン支払者」行に存在しない

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 用途 |
|---|---|---|
| `Key('markDetail_chip_gasPayer_${member.id}')` | FilterChip | ガソリン支払者チップ（メンバー毎） |
| `Key('markDetail_button_save')` | ElevatedButton | 保存ボタン |

---

### TC-GPS-002: MarkDetail — ガソリン支払者チップをタップすると選択状態になること

**前提:** TC-GPS-001 と同様

**操作手順:**
1. TC-GPS-001 の手順 1〜5 を実行する
2. `markDetail_chip_gasPayer_*` キーを持つ FilterChip のうち最初の1件をタップする

**期待結果:**
- タップしたチップの `selected` プロパティが `true` になる

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 用途 |
|---|---|---|
| `Key('markDetail_chip_gasPayer_${member.id}')` | FilterChip | ガソリン支払者チップ（メンバー毎） |

---

### TC-GPS-003: MarkDetail — ガソリン支払者チップ選択後に保存・再表示で選択が維持されること

**前提:** TC-GPS-001 と同様

**操作手順:**
1. TC-GPS-002 の手順を実行してチップを選択する
2. `markDetail_button_save` をタップして保存する
3. 再度 Mark「大涌谷」を開いて給油スイッチを ON にする

**期待結果:**
- 「ガソリン支払者」ラベルが表示される
- 保存前に選択したメンバーのチップが `selected=true` で表示される

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 用途 |
|---|---|---|
| `Key('markDetail_chip_gasPayer_${member.id}')` | FilterChip | ガソリン支払者チップ（メンバー毎） |
| `Key('markDetail_button_save')` | ElevatedButton | 保存ボタン |

---

### TC-GPS-004: MarkDetail — ガソリン支払者チップは単一選択であること

**前提:** TC-GPS-001 と同様、かつメンバーが2名以上存在すること

**操作手順:**
1. TC-GPS-001 の手順 1〜5 を実行する
2. `markDetail_chip_gasPayer_*` キーの1つ目をタップする
3. `markDetail_chip_gasPayer_*` キーの2つ目をタップする

**期待結果:**
- `selected=true` の `markDetail_chip_gasPayer_*` チップが1件のみである

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 用途 |
|---|---|---|
| `Key('markDetail_chip_gasPayer_${member.id}')` | FilterChip | ガソリン支払者チップ（メンバー毎） |

---

### TC-GPS-005: MarkDetail — 給油OFFにするとガソリン支払者チップが非表示になること

**前提:** TC-GPS-001 と同様

**操作手順:**
1. TC-GPS-001 の手順 1〜4 を実行して MarkDetail を開く
2. 給油スイッチが ON の場合は OFF にする

**期待結果:**
- 「ガソリン支払者」ラベルが表示されない

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 用途 |
|---|---|---|
| `Key('markDetail_chip_gasPayer_${member.id}')` | FilterChip | 給油OFF時は表示されないこと |

---

### TC-GPS-006: LinkDetail — 給油ONにするとガソリン支払者チップが表示されること

**前提:**
- 「箱根日帰りドライブ」イベントが存在する
- イベント内に Link「東名高速」が存在する

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「箱根日帰りドライブ」をタップして EventDetail を開く
3. ミチタブに切り替える
4. Link「東名高速」をタップして LinkDetail を開く
5. 給油スイッチを ON にする

**期待結果:**
- 「ガソリン支払者」ラベルが表示される
- FilterChip が1件以上表示される（インラインチップ選択 UI）
- chevron_right アイコンによる別画面遷移ボタンが「ガソリン支払者」行に存在しない

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 用途 |
|---|---|---|
| `Key('linkDetail_chip_gasPayer_${member.id}')` | FilterChip | ガソリン支払者チップ（メンバー毎） |
| `Key('linkDetail_button_save')` | ElevatedButton | 保存ボタン |

---

### TC-GPS-007: LinkDetail — ガソリン支払者チップをタップすると選択状態になること

**前提:** TC-GPS-006 と同様

**操作手順:**
1. TC-GPS-006 の手順 1〜5 を実行する
2. `linkDetail_chip_gasPayer_*` キーを持つ FilterChip のうち最初の1件をタップする

**期待結果:**
- タップしたチップの `selected` プロパティが `true` になる

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 用途 |
|---|---|---|
| `Key('linkDetail_chip_gasPayer_${member.id}')` | FilterChip | ガソリン支払者チップ（メンバー毎） |

---

### TC-GPS-008: LinkDetail — ガソリン支払者チップ選択後に保存・再表示で選択が維持されること

**前提:** TC-GPS-006 と同様

**操作手順:**
1. TC-GPS-007 の手順を実行してチップを選択する
2. `linkDetail_button_save` をタップして保存する
3. 再度 Link「東名高速」を開いて給油スイッチを ON にする

**期待結果:**
- 「ガソリン支払者」ラベルが表示される
- 保存前に選択したメンバーのチップが `selected=true` で表示される

**実装ノート（ウィジェットキー一覧）:**
| キー | 要素 | 用途 |
|---|---|---|
| `Key('linkDetail_chip_gasPayer_${member.id}')` | FilterChip | ガソリン支払者チップ（メンバー毎） |
| `Key('linkDetail_button_save')` | ElevatedButton | 保存ボタン |

---

# End of Feature Spec
