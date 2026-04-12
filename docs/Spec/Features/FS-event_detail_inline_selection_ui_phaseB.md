# Feature Spec: Detail画面 メンバー選択インライン化 (Phase B)

**Spec ID**: FS-event_detail_inline_selection_ui_phaseB
**要件ID**: REQ-event_detail_inline_selection_ui
**作成日**: 2026-04-12
**ステータス**: Draft
**スコープ**: Phase B — MarkDetail・LinkDetail・PaymentDetail のメンバー選択インライン化

---

# 1. Feature Overview

## Feature Name

Detail画面 メンバー選択インライン化 (Phase B)

## Purpose

MarkDetail・LinkDetail・PaymentDetailのメンバー選択UIを、フルスクリーン別画面遷移（SelectionPage）からインラインチップ式UIに置き換える。すべての選択操作を同一画面内で完結させ、タップ数を最小化する。

## Scope

含むもの
- MarkDetail メンバー選択の `_SelectionRow` + 遷移 → `_MemberChipSection`（イベントメンバー全員チップ、multiple選択）への置き換え
- LinkDetail メンバー選択の `_SelectionRow` + 遷移 → `_MemberChipSection`（同上）への置き換え
- PaymentDetail 支払者選択の `_SelectionRow` + 遷移 → `_PayMemberChipSection`（single選択）への置き換え
- PaymentDetail 割り勘メンバー選択の `_SelectionRow` + 遷移 → `_SplitMemberChipSection`（multiple選択、支払者は常にON固定）への置き換え
- 各Delegateの削除（Members・PayMember・SplitMembers 遷移系）

含まないもの
- MarkDetail / LinkDetail の GasPayer 選択インライン化（Phase B スコープ外。別画面遷移を維持）
- Phase A（BasicInfo）の変更
- SelectionPage の完全削除（eventTopic・markActions・linkActions は別画面遷移を維持）
- メンバーマスタ設定画面の変更
- 既存のデータモデル・保存処理の変更

---

# 2. Feature Responsibility

## MarkDetailBloc の責務（変更後）

- MarkDetailDraft の所有・更新
- `availableMembers`（イベントメンバー一覧）を `MarkDetailStarted.eventMembers` から初期化
- メンバーチップON/OFFロジック（multiple選択）
- Delegate通知（保存完了・エラー・Dismiss のみ。Members遷移系Delegateは削除）

## LinkDetailBloc の責務（変更後）

MarkDetailBlocと同様。

## PaymentDetailBloc の責務（変更後）

- PaymentDetailDraft の所有・更新
- `availableMembers`（イベントメンバー一覧）を `PaymentDetailStarted` 経由で初期化
- 支払者チップON/OFFロジック（single選択）
- 割り勘メンバーチップON/OFFロジック（multiple選択、支払者は常にON固定）
- Delegate通知（保存完了・エラー・Dismiss のみ。遷移系Delegateは削除）

---

# 3. State Structure

## MarkDetailLoaded（変更なし）

`availableMembers` は既存フィールドとして存在する。新規フィールド追加なし。

| フィールド | 型 | 説明 |
|---|---|---|
| `draft` | `MarkDetailDraft` | 編集状態 |
| `delegate` | `MarkDetailDelegate?` | 遷移・操作意図 |
| `topicConfig` | `TopicConfig` | Topicに基づく表示制御 |
| `isSaving` | `bool` | DB保存中フラグ |
| `availableMembers` | `List<MemberDomain>` | イベントメンバー全件（チップ表示用） |

## LinkDetailLoaded（変更なし）

MarkDetailLoadedと同構造。`availableMembers` は既存フィールド。

## PaymentDetailLoaded（変更なし）

`availableMembers` は既存フィールドとして存在する。新規フィールド追加なし。

| フィールド | 型 | 説明 |
|---|---|---|
| `draft` | `PaymentDetailDraft` | 編集状態 |
| `delegate` | `PaymentDetailDelegate?` | 遷移・操作意図 |
| `isSaving` | `bool` | DB保存中フラグ |
| `availableMembers` | `List<MemberDomain>` | イベントメンバー全件（チップ表示用） |

---

# 4. Draft Model

## MarkDetailDraft（変更なし）

既存フィールドをそのまま使用。

| フィールド | 型 | 説明 |
|---|---|---|
| `selectedMembers` | `List<MemberDomain>` | 選択中メンバー（既存） |

## LinkDetailDraft（変更なし）

MarkDetailDraftと同様。

## PaymentDetailDraft（変更なし）

| フィールド | 型 | 説明 |
|---|---|---|
| `paymentMember` | `MemberDomain?` | 選択中支払者（単一、既存） |
| `splitMembers` | `List<MemberDomain>` | 選択中割り勘メンバー（複数、既存） |

---

# 5. Domain Model

対象外。既存Adapterで処理済み。変更なし。

---

# 6. Projection Model

変更なし。既存のProjectionをそのまま使用。

---

# 7. Adapter

変更なし。Draft → Domain / Domain → Projection の変換ロジックはそのまま。

---

# 8. Events

## MarkDetail

### 削除するイベント

| イベント名 | 削除理由 |
|---|---|
| `MarkDetailEditMembersPressed` | Members選択画面への遷移が不要 |
| `MarkDetailMembersSelected` | 選択画面からの返却が不要 |

### 追加するイベント

| イベント名 | 発火タイミング | 説明 |
|---|---|---|
| `MarkDetailMemberChipToggled(MemberDomain member)` | メンバーチップのタップ時 | 同一MemberをタップでON/OFF切り替え（multiple選択） |

### 維持するイベント（変更なし）

`MarkDetailEditActionsPressed` / `MarkDetailActionsSelected` / `MarkDetailEditGasPayerPressed` / `MarkDetailGasPayerSelected` / その他既存イベントはすべて維持。

---

## LinkDetail

### 削除するイベント

| イベント名 | 削除理由 |
|---|---|
| `LinkDetailEditMembersPressed` | Members選択画面への遷移が不要 |
| `LinkDetailMembersSelected` | 選択画面からの返却が不要 |

### 追加するイベント

| イベント名 | 発火タイミング | 説明 |
|---|---|---|
| `LinkDetailMemberChipToggled(MemberDomain member)` | メンバーチップのタップ時 | 同一MemberをタップでON/OFF切り替え（multiple選択） |

### 維持するイベント（変更なし）

`LinkDetailEditActionsPressed` / `LinkDetailActionsSelected` / `LinkDetailEditGasPayerPressed` / `LinkDetailGasPayerSelected` / その他既存イベントはすべて維持。

---

## PaymentDetail

### 削除するイベント

| イベント名 | 削除理由 |
|---|---|
| `PaymentDetailEditMemberPressed` | 支払者選択画面への遷移が不要 |
| `PaymentDetailMemberSelected` | 選択画面からの返却が不要 |
| `PaymentDetailEditSplitMembersPressed` | 割り勘メンバー選択画面への遷移が不要 |
| `PaymentDetailSplitMembersSelected` | 選択画面からの返却が不要 |

### 追加するイベント

| イベント名 | 発火タイミング | 説明 |
|---|---|---|
| `PaymentDetailPayMemberChipToggled(MemberDomain member)` | 支払者チップのタップ時 | 同一MemberをタップでOFF、別MemberをタップでON（single選択） |
| `PaymentDetailSplitMemberChipToggled(MemberDomain member)` | 割り勘メンバーチップのタップ時 | 支払者以外のチップのON/OFF切り替え（multiple選択）。支払者は常にON固定 |

---

# 9. Delegate

## MarkDetail

### 削除するDelegate

| Delegate名 | 削除理由 |
|---|---|
| `MarkDetailOpenMembersSelectionDelegate` | Members選択画面遷移が不要 |

### 維持するDelegate

| Delegate名 | 説明 |
|---|---|
| `MarkDetailDismissDelegate` | 画面を閉じる |
| `MarkDetailOpenActionsSelectionDelegate` | Actionsは別画面遷移を維持 |
| `MarkDetailOpenGasPayerSelectionDelegate` | GasPayerは別画面遷移を維持（Phase B スコープ外） |
| `MarkDetailSavedDelegate` | 保存成功 |
| `MarkDetailSaveErrorDelegate` | 保存エラー |

---

## LinkDetail

### 削除するDelegate

| Delegate名 | 削除理由 |
|---|---|
| `LinkDetailOpenMembersSelectionDelegate` | Members選択画面遷移が不要 |

### 維持するDelegate

| Delegate名 | 説明 |
|---|---|
| `LinkDetailDismissDelegate` | 画面を閉じる |
| `LinkDetailOpenActionsSelectionDelegate` | Actionsは別画面遷移を維持 |
| `LinkDetailOpenGasPayerSelectionDelegate` | GasPayerは別画面遷移を維持（Phase B スコープ外） |
| `LinkDetailSavedDelegate` | 保存成功 |
| `LinkDetailSaveErrorDelegate` | 保存エラー |

---

## PaymentDetail

### 削除するDelegate

| Delegate名 | 削除理由 |
|---|---|
| `PaymentDetailOpenMemberSelectionDelegate` | 支払者選択画面遷移が不要 |
| `PaymentDetailOpenSplitMembersSelectionDelegate` | 割り勘メンバー選択画面遷移が不要 |

### 維持するDelegate

| Delegate名 | 説明 |
|---|---|
| `PaymentDetailSavedDelegate` | 保存成功 |
| `PaymentDetailSaveErrorDelegate` | 保存エラー |
| `PaymentDetailDismissDelegate` | 画面を閉じる |

---

# 10. Bloc Responsibility

## MarkDetailBloc

### _onStarted の変更点

- 既存: `eventMembers` を `availableMembers` にセット（既存ロジックそのまま）
- 変更なし: 初期化フローはそのまま

### 削除するハンドラ

- `_onEditMembersPressed`（`MarkDetailEditMembersPressed` のハンドラ）
- `_onMembersSelected`（`MarkDetailMembersSelected` のハンドラ）

### 追加するハンドラ

#### _onMemberChipToggled

- 受信: `MarkDetailMemberChipToggled(member)`
- 処理:
  - `draft.selectedMembers` に `member` が含まれる場合 → 削除（選択解除）
  - 含まれない場合 → 追加（選択）
- emit: draftを更新した `MarkDetailLoaded`

---

## LinkDetailBloc

MarkDetailBlocと同様のパターン。

### 削除するハンドラ

- `_onEditMembersPressed`（`LinkDetailEditMembersPressed` のハンドラ）
- `_onMembersSelected`（`LinkDetailMembersSelected` のハンドラ）

### 追加するハンドラ

#### _onMemberChipToggled

- 受信: `LinkDetailMemberChipToggled(member)`
- 処理: MarkDetailと同様（multiple選択）
- emit: draftを更新した `LinkDetailLoaded`

---

## PaymentDetailBloc

### _onStarted の変更点

- 既存: `availableMembers` の初期化処理（既存ロジック確認の上維持）
- 変更なし

### 削除するハンドラ

- `_onEditMemberPressed`（`PaymentDetailEditMemberPressed` のハンドラ）
- `_onMemberSelected`（`PaymentDetailMemberSelected` のハンドラ）
- `_onEditSplitMembersPressed`（`PaymentDetailEditSplitMembersPressed` のハンドラ）
- `_onSplitMembersSelected`（`PaymentDetailSplitMembersSelected` のハンドラ）

### 追加するハンドラ

#### _onPayMemberChipToggled

- 受信: `PaymentDetailPayMemberChipToggled(member)`
- 処理:
  - `draft.paymentMember == member` の場合 → `paymentMember = null`（選択解除）
  - 異なるMemberの場合 → `paymentMember = member`（選択切り替え）
  - 変更後の `paymentMember` が `splitMembers` に含まれていない場合 → `splitMembers` に追加（支払者は常にON固定）
  - 変更前の `paymentMember`（解除されたMember）が `splitMembers` に残る場合の扱い → **そのまま維持**（ユーザーが手動でOFF可能）
- emit: draftを更新した `PaymentDetailLoaded`

#### _onSplitMemberChipToggled

- 受信: `PaymentDetailSplitMemberChipToggled(member)`
- 処理:
  - `member == draft.paymentMember` の場合 → **無視**（支払者は常にON固定）
  - 含まれる場合 → `splitMembers` から削除（選択解除）
  - 含まれない場合 → `splitMembers` に追加（選択）
- emit: draftを更新した `PaymentDetailLoaded`

---

# 11. Navigation

## MarkDetail

削除: `MarkDetailOpenMembersSelectionDelegate` のBlocListenerハンドリング（mark_detail_page.dart）

維持: `MarkDetailDismissDelegate` / `MarkDetailOpenActionsSelectionDelegate` / `MarkDetailOpenGasPayerSelectionDelegate` / `MarkDetailSavedDelegate` / `MarkDetailSaveErrorDelegate` のBlocListenerハンドリング

## LinkDetail

削除: `LinkDetailOpenMembersSelectionDelegate` のBlocListenerハンドリング（link_detail_page.dart）

維持: `LinkDetailDismissDelegate` / `LinkDetailOpenActionsSelectionDelegate` / `LinkDetailOpenGasPayerSelectionDelegate` / `LinkDetailSavedDelegate` / `LinkDetailSaveErrorDelegate` のBlocListenerハンドリング

## PaymentDetail

削除: `PaymentDetailOpenMemberSelectionDelegate` / `PaymentDetailOpenSplitMembersSelectionDelegate` のBlocListenerハンドリング（payment_detail_page.dart）

維持: `PaymentDetailSavedDelegate` / `PaymentDetailSaveErrorDelegate` / `PaymentDetailDismissDelegate` のBlocListenerハンドリング

---

# 12. Data Flow

## MarkDetail メンバー選択フロー

1. 画面表示時に `MarkDetailStarted(eventMembers: [...])` → Blocが `availableMembers` に初期化（既存）
2. Widgetが `availableMembers` を参照して `_MemberChipSection` をレンダリング
3. ユーザーがチップをタップ → `MarkDetailMemberChipToggled` を発火
4. BlocがDraftの `selectedMembers` を更新 → Stateをemit
5. Widgetが新しいStateを受けてチップの選択状態を更新

## LinkDetail メンバー選択フロー

MarkDetailと同様のフロー。

## PaymentDetail 支払者選択フロー

1. 画面表示時に `availableMembers` が初期化される（既存）
2. Widgetが `availableMembers` を参照して `_PayMemberChipSection` をレンダリング
3. ユーザーがチップをタップ → `PaymentDetailPayMemberChipToggled` を発火
4. BlocがDraftの `paymentMember` を更新 → Stateをemit
5. 新しい支払者が `splitMembers` に含まれていない場合は自動追加

## PaymentDetail 割り勘メンバー選択フロー

1. Widgetが `availableMembers` を参照して `_SplitMemberChipSection` をレンダリング
2. 支払者（`draft.paymentMember`）は常にON・非活性状態で表示
3. ユーザーが支払者以外のチップをタップ → `PaymentDetailSplitMemberChipToggled` を発火
4. BlocがDraftの `splitMembers` を更新 → Stateをemit

---

# 13. View設計

## 変更対象ファイル一覧

| ファイル | 変更種別 | 説明 |
|---|---|---|
| `mark_detail_page.dart` | 改修 | `_SelectionRow`（Members）を `_MemberChipSection` に置き換え、`MarkDetailOpenMembersSelectionDelegate` のBlocListenerハンドリング削除 |
| `mark_detail_event.dart` | 改修 | 削除イベント除去・`MarkDetailMemberChipToggled` 追加 |
| `mark_detail_state.dart` | 改修 | `MarkDetailOpenMembersSelectionDelegate` 削除 |
| `mark_detail_bloc.dart` | 改修 | 削除ハンドラ除去・`_onMemberChipToggled` 実装 |
| `link_detail_page.dart` | 改修 | MarkDetailと同様 |
| `link_detail_event.dart` | 改修 | 削除イベント除去・`LinkDetailMemberChipToggled` 追加 |
| `link_detail_state.dart` | 改修 | `LinkDetailOpenMembersSelectionDelegate` 削除 |
| `link_detail_bloc.dart` | 改修 | 削除ハンドラ除去・`_onMemberChipToggled` 実装 |
| `payment_detail_page.dart` | 改修 | `_SelectionRow`（支払者・割り勘）を各チップセクションに置き換え、遷移系DelegateのBlocListenerハンドリング削除 |
| `payment_detail_event.dart` | 改修 | 削除イベント除去・`PaymentDetailPayMemberChipToggled`・`PaymentDetailSplitMemberChipToggled` 追加 |
| `payment_detail_state.dart` | 改修 | 遷移系Delegate削除 |
| `payment_detail_bloc.dart` | 改修 | 削除ハンドラ除去・`_onPayMemberChipToggled`・`_onSplitMemberChipToggled` 実装 |

## _MemberChipSection（MarkDetail・LinkDetail 共通）

- **レイアウト**: `Wrap` で `availableMembers` を全件チップ横並び表示
- **未選択状態**: アウトライン表示（枠線のみ）
- **選択済み状態**: テーマprimaryColor塗りつぶし＋✓アイコン
- **タップ**: `MarkDetailMemberChipToggled` / `LinkDetailMemberChipToggled` を発火
- **ウィジェットキー**:
  - `Key('markDetail_chip_member_${member.id}')` — MarkDetailの各メンバーチップ
  - `Key('linkDetail_chip_member_${member.id}')` — LinkDetailの各メンバーチップ

## _PayMemberChipSection（PaymentDetail）

- **レイアウト**: `Wrap` で `availableMembers` を全件チップ横並び表示
- **未選択状態**: アウトライン表示（枠線のみ）
- **選択済み状態**: テーマprimaryColor塗りつぶし＋✓アイコン
- **タップ**: `PaymentDetailPayMemberChipToggled` を発火
- **ウィジェットキー**:
  - `Key('paymentDetail_chip_payMember_${member.id}')` — 各支払者チップ

## _SplitMemberChipSection（PaymentDetail）

- **レイアウト**: `Wrap` で `availableMembers` を全件チップ横並び表示
- **支払者チップ**: 常にON（塗りつぶし＋✓）・`onTap: null`（非活性）
- **その他チップ未選択**: アウトライン表示
- **その他チップ選択済み**: テーマprimaryColor塗りつぶし＋✓アイコン
- **タップ（支払者以外）**: `PaymentDetailSplitMemberChipToggled` を発火
- **ウィジェットキー**:
  - `Key('paymentDetail_chip_splitMember_${member.id}')` — 各割り勘メンバーチップ

## チップデザイン統一仕様

Phase Aと統一。

| 状態 | 見た目 |
|---|---|
| 未選択チップ | アウトライン表示（枠線のみ） |
| 選択済みチップ | テーマprimaryColor塗りつぶし＋✓アイコン |
| 非活性チップ（支払者固定） | テーマprimaryColor塗りつぶし＋✓アイコン（`onTap: null`） |

---

# 14. 非機能要件

- `availableMembers` は画面表示時（Started）に渡される `eventMembers` をそのまま使用する。DB追加呼び出しなし
- チップ数が多い場合は `Wrap` による自動折り返しで対応

---

# 15. Test Scenarios

## 前提条件

- iOSシミュレーターが起動済みであること
- テスト用データとして以下が事前登録済みであること
  - メンバーマスタ: 「田中」「鈴木」「佐藤」の3件
  - イベントが1件以上存在し、BasicInfoのメンバーとして「田中」「鈴木」が設定済み
- 各Detail画面（MarkDetail・LinkDetail・PaymentDetail）が表示されていること

## テストシナリオ一覧

| ID | シナリオ名 | 画面 | 区分 | 優先度 |
|---|---|---|---|---|
| TC-PBM-001 | MarkDetail: イベントメンバーが全員チップで表示される | MarkDetail | Widget | High |
| TC-PBM-002 | MarkDetail: チップタップで選択状態になる（multiple） | MarkDetail | Integration | High |
| TC-PBM-003 | MarkDetail: 選択済みチップを再タップで選択解除 | MarkDetail | Integration | Medium |
| TC-PBM-004 | MarkDetail: 初期値（既存選択）が選択状態で表示される | MarkDetail | Widget | Medium |
| TC-PBM-005 | LinkDetail: イベントメンバーが全員チップで表示される | LinkDetail | Widget | High |
| TC-PBM-006 | LinkDetail: チップタップで選択状態になる（multiple） | LinkDetail | Integration | High |
| TC-PBM-007 | LinkDetail: 選択済みチップを再タップで選択解除 | LinkDetail | Integration | Medium |
| TC-PBM-008 | LinkDetail: 初期値（既存選択）が選択状態で表示される | LinkDetail | Widget | Medium |
| TC-PBM-009 | PaymentDetail: イベントメンバーが支払者チップで全員表示される | PaymentDetail | Widget | High |
| TC-PBM-010 | PaymentDetail: 支払者チップタップで単一選択（他は非選択） | PaymentDetail | Integration | High |
| TC-PBM-011 | PaymentDetail: 割り勘チップで全員表示される | PaymentDetail | Widget | High |
| TC-PBM-012 | PaymentDetail: 割り勘チップタップでON/OFF切り替え | PaymentDetail | Integration | High |
| TC-PBM-013 | PaymentDetail: 支払者は割り勘チップで常にON固定（非活性） | PaymentDetail | Widget | High |
| TC-PBM-014 | PaymentDetail: 初期値（既存選択）が選択状態で表示される | PaymentDetail | Widget | Medium |

---

## シナリオ詳細

### TC-PBM-001: MarkDetail — イベントメンバーが全員チップで表示される

**前提**: MarkDetail画面が表示されている。イベントメンバーに「田中」「鈴木」が設定済み

**操作手順:**
1. MarkDetail画面を表示する

**期待結果:**
- `Key('markDetail_chip_member_${田中のid}')` が表示される
- `Key('markDetail_chip_member_${鈴木のid}')` が表示される

**実装ノート:**
```
ウィジェットキー一覧:
- markDetail_chip_member_*  : メンバーチップ（id付き）
```

---

### TC-PBM-002: MarkDetail — チップタップで選択状態になる（multiple）

**前提**: MarkDetail画面が表示されている。「田中」「鈴木」がイベントメンバー。メンバーが未選択状態

**操作手順:**
1. `Key('markDetail_chip_member_${田中のid}')` をタップする
2. `Key('markDetail_chip_member_${鈴木のid}')` をタップする

**期待結果:**
- 「田中」チップが選択状態（塗りつぶし＋✓）になる
- 「鈴木」チップが選択状態（塗りつぶし＋✓）になる（multipleなので両方選択可）

**実装ノート:**
```
ウィジェットキー一覧:
- markDetail_chip_member_*  : メンバーチップ（選択状態はチップの見た目で確認）
```

---

### TC-PBM-003: MarkDetail — 選択済みチップを再タップで選択解除

**前提**: MarkDetail画面が表示されている。「田中」が選択済み状態

**操作手順:**
1. `Key('markDetail_chip_member_${田中のid}')` を再度タップする

**期待結果:**
- 「田中」チップが未選択状態（アウトライン表示）になる

**実装ノート:**
```
ウィジェットキー一覧:
- markDetail_chip_member_*  : メンバーチップ
```

---

### TC-PBM-004: MarkDetail — 初期値（既存選択）が選択状態で表示される

**前提**: 「田中」が選択済みのMarkDetailを表示する

**操作手順:**
1. MarkDetail画面を表示する

**期待結果:**
- `Key('markDetail_chip_member_${田中のid}')` が選択状態（塗りつぶし＋✓）で表示される
- 「鈴木」チップは未選択状態で表示される

**実装ノート:**
```
ウィジェットキー一覧:
- markDetail_chip_member_*  : メンバーチップ
```

---

### TC-PBM-005: LinkDetail — イベントメンバーが全員チップで表示される

**前提**: LinkDetail画面が表示されている。イベントメンバーに「田中」「鈴木」が設定済み

**操作手順:**
1. LinkDetail画面を表示する

**期待結果:**
- `Key('linkDetail_chip_member_${田中のid}')` が表示される
- `Key('linkDetail_chip_member_${鈴木のid}')` が表示される

**実装ノート:**
```
ウィジェットキー一覧:
- linkDetail_chip_member_*  : メンバーチップ（id付き）
```

---

### TC-PBM-006: LinkDetail — チップタップで選択状態になる（multiple）

**前提**: LinkDetail画面が表示されている。「田中」「鈴木」がイベントメンバー。メンバーが未選択状態

**操作手順:**
1. `Key('linkDetail_chip_member_${田中のid}')` をタップする
2. `Key('linkDetail_chip_member_${鈴木のid}')` をタップする

**期待結果:**
- 「田中」チップが選択状態（塗りつぶし＋✓）になる
- 「鈴木」チップが選択状態（塗りつぶし＋✓）になる

**実装ノート:**
```
ウィジェットキー一覧:
- linkDetail_chip_member_*  : メンバーチップ
```

---

### TC-PBM-007: LinkDetail — 選択済みチップを再タップで選択解除

**前提**: LinkDetail画面が表示されている。「田中」が選択済み状態

**操作手順:**
1. `Key('linkDetail_chip_member_${田中のid}')` を再度タップする

**期待結果:**
- 「田中」チップが未選択状態（アウトライン表示）になる

**実装ノート:**
```
ウィジェットキー一覧:
- linkDetail_chip_member_*  : メンバーチップ
```

---

### TC-PBM-008: LinkDetail — 初期値（既存選択）が選択状態で表示される

**前提**: 「田中」が選択済みのLinkDetailを表示する

**操作手順:**
1. LinkDetail画面を表示する

**期待結果:**
- `Key('linkDetail_chip_member_${田中のid}')` が選択状態（塗りつぶし＋✓）で表示される
- 「鈴木」チップは未選択状態で表示される

**実装ノート:**
```
ウィジェットキー一覧:
- linkDetail_chip_member_*  : メンバーチップ
```

---

### TC-PBM-009: PaymentDetail — イベントメンバーが支払者チップで全員表示される

**前提**: PaymentDetail画面が表示されている。イベントメンバーに「田中」「鈴木」が設定済み

**操作手順:**
1. PaymentDetail画面を表示する

**期待結果:**
- `Key('paymentDetail_chip_payMember_${田中のid}')` が表示される
- `Key('paymentDetail_chip_payMember_${鈴木のid}')` が表示される

**実装ノート:**
```
ウィジェットキー一覧:
- paymentDetail_chip_payMember_*  : 支払者チップ（id付き）
```

---

### TC-PBM-010: PaymentDetail — 支払者チップタップで単一選択（他は非選択）

**前提**: PaymentDetail画面が表示されている。「田中」「鈴木」がイベントメンバー。支払者未選択状態

**操作手順:**
1. `Key('paymentDetail_chip_payMember_${田中のid}')` をタップする

**期待結果:**
- 「田中」支払者チップが選択状態（塗りつぶし＋✓）になる
- 「鈴木」支払者チップは未選択状態のまま（single選択）

**実装ノート:**
```
ウィジェットキー一覧:
- paymentDetail_chip_payMember_*  : 支払者チップ
```

---

### TC-PBM-011: PaymentDetail — 割り勘チップで全員表示される

**前提**: PaymentDetail画面が表示されている。イベントメンバーに「田中」「鈴木」が設定済み

**操作手順:**
1. PaymentDetail画面を表示する

**期待結果:**
- `Key('paymentDetail_chip_splitMember_${田中のid}')` が表示される
- `Key('paymentDetail_chip_splitMember_${鈴木のid}')` が表示される

**実装ノート:**
```
ウィジェットキー一覧:
- paymentDetail_chip_splitMember_*  : 割り勘メンバーチップ（id付き）
```

---

### TC-PBM-012: PaymentDetail — 割り勘チップタップでON/OFF切り替え

**前提**: PaymentDetail画面が表示されている。「田中」「鈴木」がイベントメンバー。支払者が「田中」。割り勘未選択状態

**操作手順:**
1. `Key('paymentDetail_chip_splitMember_${鈴木のid}')` をタップする

**期待結果:**
- 「鈴木」割り勘チップが選択状態（塗りつぶし＋✓）になる

**実装ノート:**
```
ウィジェットキー一覧:
- paymentDetail_chip_splitMember_*  : 割り勘メンバーチップ
```

---

### TC-PBM-013: PaymentDetail — 支払者は割り勘チップで常にON固定（非活性）

**前提**: PaymentDetail画面が表示されている。「田中」が支払者として選択済み

**操作手順:**
1. `Key('paymentDetail_chip_splitMember_${田中のid}')` をタップする（支払者チップ）

**期待結果:**
- 「田中」割り勘チップは選択状態のまま変わらない（非活性のためタップ無効）

**実装ノート:**
```
ウィジェットキー一覧:
- paymentDetail_chip_splitMember_*  : 割り勘メンバーチップ（支払者は onTap: null）
```

---

### TC-PBM-014: PaymentDetail — 初期値（既存選択）が選択状態で表示される

**前提**: 「田中」が支払者・割り勘メンバーとして選択済みのPaymentDetailを表示する

**操作手順:**
1. PaymentDetail画面を表示する

**期待結果:**
- `Key('paymentDetail_chip_payMember_${田中のid}')` が選択状態（塗りつぶし＋✓）で表示される
- `Key('paymentDetail_chip_splitMember_${田中のid}')` が選択状態（塗りつぶし＋✓）で表示される
- 「鈴木」の各チップは未選択状態で表示される

**実装ノート:**
```
ウィジェットキー一覧:
- paymentDetail_chip_payMember_*    : 支払者チップ
- paymentDetail_chip_splitMember_*  : 割り勘メンバーチップ
```

---

# End of Feature Spec
