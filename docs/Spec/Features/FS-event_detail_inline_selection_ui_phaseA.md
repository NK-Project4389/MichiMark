# Feature Spec: BasicInfo インライン選択UI (Phase A)

**Spec ID**: FS-event_detail_inline_selection_ui_phaseA
**要件ID**: REQ-event_detail_inline_selection_ui
**作成日**: 2026-04-12
**ステータス**: Draft
**スコープ**: Phase A — BasicInfo タブのみ

---

# 1. Feature Overview

## Feature Name

BasicInfo インライン選択UI (Phase A)

## Purpose

BasicInfoタブの交通手段・メンバー・タグ・ガソリン支払者の選択UIを、フルスクリーン別画面遷移（SelectionPage）からインラインチップ式UIに置き換える。すべての選択操作を同一画面内で完結させ、タップ数を最小化する。

## Scope

含むもの
- BasicInfo タグ入力エリアの3ブロック縦並び → チップ+インライン入力欄（Wrap）への改善
- BasicInfo 交通手段選択の `_SelectionRow` → `_TransChipSection`（全件チップ横並び）への置き換え
- BasicInfo メンバー選択の `_SelectionRow` → `_MemberInputSection`（チップ+インライン入力）への置き換え
- BasicInfo ガソリン支払者選択の `_SelectionRow` → `_GasPayMemberChipSection`（イベントメンバー全員チップ）への置き換え
- 選択画面遷移用Delegateの削除（Trans・Members・Tags・PayMember）
- `BasicInfoBloc` への `MemberRepository` / `TransRepository` のDI追加
- `BasicInfoState` への `allTrans` / `allMembers` / `memberSuggestions` フィールド追加

含まないもの
- Phase B（MarkDetail・LinkDetail・PaymentDetail のインライン化）
- SelectionPage の完全削除（eventTopic・markActions・linkActions は別画面遷移を維持）
- メンバーマスタ設定画面・タグマスタ設定画面の変更
- 既存のデータモデル・保存処理の変更

---

# 2. Feature Responsibility

BasicInfoBloc の責務（変更後）

- BasicInfoDraft の所有・更新
- TransRepository / MemberRepository / TagRepository / TopicRepository / EventRepository からのマスタデータキャッシュ
- サジェストフィルタリングロジック（入力変化時）
- チップON/OFFロジック（Trans単一選択・GasPayMember単一選択）
- Adapter呼び出しによるDomain生成・Projection生成
- Delegate通知（保存完了のみ。遷移系Delegateは削除）

---

# 3. State Structure

## BasicInfoLoaded（追加フィールド）

既存フィールドはそのまま維持し、以下を追加する。

| フィールド | 型 | 説明 |
|---|---|---|
| `allTrans` | `List<TransDomain>` | 交通手段マスタ全件キャッシュ（画面表示時に取得） |
| `allMembers` | `List<MemberDomain>` | メンバーマスタ全件キャッシュ（画面表示時に取得） |
| `memberSuggestions` | `List<MemberDomain>` | 現在表示中のメンバーサジェスト（入力内容に応じて変化） |

既存フィールド（変更なし）

| フィールド | 型 | 説明 |
|---|---|---|
| `draft` | `BasicInfoDraft` | 編集状態 |
| `delegate` | `BasicInfoDelegate?` | 遷移・操作意図 |
| `topicConfig` | `TopicConfig` | Topicに基づく表示制御 |
| `allTags` | `List<TagDomain>` | タグマスタ全件キャッシュ（既存） |
| `tagSuggestions` | `List<TagDomain>` | タグサジェスト（既存） |
| `isSaving` | `bool` | DB保存中フラグ |
| `originalDraft` | `BasicInfoDraft?` | キャンセル用元Draft |

---

# 4. Draft Model

## BasicInfoDraft（変更なし）

既存フィールドをそのまま使用する。変更なし。

| フィールド | 型 | 説明 |
|---|---|---|
| `selectedTrans` | `TransDomain?` | 選択中交通手段（既存） |
| `selectedMembers` | `List<MemberDomain>` | 選択中メンバー（既存） |
| `selectedTags` | `List<TagDomain>` | 選択中タグ（既存） |
| `selectedPayMember` | `MemberDomain?` | 選択中ガソリン支払者（既存） |

---

# 5. Domain Model

対象外。BasicInfoDraft → EventDomain の変換は既存Adapterで処理済み。変更なし。

---

# 6. Projection Model

変更なし。既存のProjectionをそのまま使用する。

---

# 7. Adapter

変更なし。Draft → Domain / Domain → Projection の変換ロジックはそのまま。

---

# 8. Events

## 削除するイベント

以下のイベントは別画面遷移が不要になるため削除する。

| イベント名 | 削除理由 |
|---|---|
| `BasicInfoEditTransPressed` | Trans選択画面への遷移が不要 |
| `BasicInfoTransSelected` | 選択画面からの返却が不要 |
| `BasicInfoEditMembersPressed` | Member選択画面への遷移が不要 |
| `BasicInfoMembersSelected` | 選択画面からの返却が不要 |
| `BasicInfoEditTagsPressed` | タグ選択画面への遷移が不要（コメントに「現在未使用」とある） |
| `BasicInfoTagsSelected` | 選択画面からの返却が不要（同上） |
| `BasicInfoEditPayMemberPressed` | PayMember選択画面への遷移が不要 |
| `BasicInfoPayMemberSelected` | 選択画面からの返却が不要 |

## 維持するイベント（タグ系・既存）

| イベント名 | 発火タイミング | 説明 |
|---|---|---|
| `BasicInfoTagInputChanged(String input)` | タグ入力欄のテキスト変化時 | サジェストフィルタリングをトリガー |
| `BasicInfoTagSuggestionSelected(TagDomain tag)` | タグサジェストのタップ時 | 選択タグをdraftに追加・入力クリア |
| `BasicInfoTagInputConfirmed(String input)` | タグ入力欄でキーボード確定時 | 新規タグ作成またはマスタ一致タグ追加 |
| `BasicInfoTagRemoved(TagDomain tag)` | タグチップの×タップ時 | 選択タグからdraft削除 |

## 追加するイベント

### Trans系

| イベント名 | 発火タイミング | 説明 |
|---|---|---|
| `BasicInfoTransChipToggled(TransDomain trans)` | TransチップのタップMFY時 | 同一TransをタップでOFF、別TransをタップでON（単一選択） |

### Members系

| イベント名 | 発火タイミング | 説明 |
|---|---|---|
| `BasicInfoMemberInputChanged(String input)` | メンバー入力欄のテキスト変化時 | 入力空→最近のサジェスト、入力あり→部分一致フィルタリング（選択済み除外） |
| `BasicInfoMemberSuggestionSelected(MemberDomain member)` | メンバーサジェストのタップ時 | 選択メンバーをdraftに追加・入力クリア・ドロップダウン閉じる |
| `BasicInfoMemberInputConfirmed(String input)` | メンバー入力欄でキーボード確定時 | マスタ一致→追加、未登録→マスタ登録+追加、重複→無視 |
| `BasicInfoMemberRemoved(MemberDomain member)` | メンバーチップの×タップ時 | 選択メンバーからdraft削除 |

### GasPayMember系

| イベント名 | 発火タイミング | 説明 |
|---|---|---|
| `BasicInfoPayMemberChipToggled(MemberDomain member)` | GasPayMemberチップのタップ時 | 同一MemberをタップでOFF、別MemberをタップでON（単一選択） |

---

# 9. Delegate

## 削除するDelegate

| Delegate名 | 削除理由 |
|---|---|
| `BasicInfoOpenTransSelectionDelegate` | Trans選択画面遷移が不要 |
| `BasicInfoOpenMembersSelectionDelegate` | Members選択画面遷移が不要 |
| `BasicInfoOpenTagsSelectionDelegate` | Tags選択画面遷移が不要 |
| `BasicInfoOpenPayMemberSelectionDelegate` | PayMember選択画面遷移が不要 |

## 維持するDelegate

| Delegate名 | 遷移・通知先 | 説明 |
|---|---|---|
| `BasicInfoSavedDelegate` | EventDetailPage（保存完了通知） | 保存成功 |
| `BasicInfoSavedAndDismissDelegate` | EventDetailPage（画面を閉じる） | 保存して戻る |

---

# 10. Bloc Responsibility

## _onStarted の変更点

- 既存: `TagRepository.fetchAll()` でタグキャッシュ
- 追加: `TransRepository.fetchAll()` を呼んで `allTrans` にキャッシュ
- 追加: `MemberRepository.fetchAll()` を呼んで `allMembers` にキャッシュ
- 追加: `EventRepository` から直近10件のイベントを取得し、使用頻度の高いメンバーを `memberSuggestions` に初期設定（選択済みメンバーを除外）

## 追加するハンドラ

### _onTransChipToggled

- 受信: `BasicInfoTransChipToggled(trans)`
- 処理:
  - `draft.selectedTrans == trans` の場合 → `draft.selectedTrans = null`（選択解除）
  - 異なるTransの場合 → `draft.selectedTrans = trans`（選択切り替え）
- emit: draftを更新した `BasicInfoLoaded`

### _onMemberInputChanged

- 受信: `BasicInfoMemberInputChanged(input)`
- 処理:
  - 入力が空文字 → 最近のサジェスト（`memberSuggestions`の初期値）から選択済みを除外してemit
  - 入力あり → `allMembers` を部分一致（大文字小文字区別なし）でフィルタリング、選択済みを除外してemit
- emit: `memberSuggestions` を更新した `BasicInfoLoaded`

### _onMemberSuggestionSelected

- 受信: `BasicInfoMemberSuggestionSelected(member)`
- 処理:
  - 重複チェック（選択済みに同じMemberIdが存在する場合は無視）
  - `draft.selectedMembers` に追加
  - `memberSuggestions` を再フィルタリング（追加したメンバーを除外）
- emit: draft・memberSuggestionsを更新した `BasicInfoLoaded`

### _onMemberInputConfirmed

- 受信: `BasicInfoMemberInputConfirmed(input)`
- 処理:
  - 入力が空文字 → 無視
  - `allMembers` に同名（大文字小文字区別なし）が存在 → マスタメンバーとして追加（重複チェックあり）
  - 未登録名 → `MemberRepository` に新規登録後、draftに追加
- emit: draftを更新した `BasicInfoLoaded`

### _onMemberRemoved

- 受信: `BasicInfoMemberRemoved(member)`
- 処理:
  - `draft.selectedMembers` から対象を削除
  - `draft.selectedPayMember` が削除メンバーと同一の場合は `selectedPayMember = null` にクリア
- emit: draftを更新した `BasicInfoLoaded`

### _onPayMemberChipToggled

- 受信: `BasicInfoPayMemberChipToggled(member)`
- 処理:
  - `draft.selectedPayMember == member` の場合 → `selectedPayMember = null`（選択解除）
  - 異なるMemberの場合 → `selectedPayMember = member`（選択切り替え）
- emit: draftを更新した `BasicInfoLoaded`

---

# 11. Repository DI 変更

## BasicInfoBloc コンストラクタへの追加

| Repository | 変更種別 | 理由 |
|---|---|---|
| `MemberRepository` | 追加 | メンバーマスタ全件取得・新規登録 |
| `TransRepository` | 追加 | 交通手段マスタ全件取得 |

## event_detail_page.dart の変更

- `BasicInfoBloc(...)` の生成箇所（BlocProvider）に `MemberRepository` / `TransRepository` を追加注入する

---

# 12. Navigation

Phase Aではインライン化により選択画面遷移が不要になる。

削除: `BasicInfoOpenTransSelectionDelegate` / `BasicInfoOpenMembersSelectionDelegate` / `BasicInfoOpenTagsSelectionDelegate` / `BasicInfoOpenPayMemberSelectionDelegate` のBlocListenerハンドリング

維持: `BasicInfoSavedDelegate` / `BasicInfoSavedAndDismissDelegate` のBlocListenerハンドリング（既存）

---

# 13. Data Flow

## Trans選択フロー

1. 画面表示時に `BasicInfoStarted` → BlocがTransマスタ全件を `allTrans` にキャッシュ
2. Widgetが `allTrans` を参照して `_TransChipSection` をレンダリング
3. ユーザーがチップをタップ → `BasicInfoTransChipToggled` を発火
4. BlocがDraftの `selectedTrans` を更新 → Stateをemit
5. Widgetが新しいStateを受けてチップの選択状態を更新

## Member選択フロー

1. 画面表示時に `BasicInfoStarted` → BlocがMemberマスタ全件を `allMembers` にキャッシュ・直近10イベントから `memberSuggestions` を初期設定
2. ユーザーがメンバー入力欄をフォーカス → Widgetがドロップダウンを表示（`memberSuggestions` を参照）
3. ユーザーが入力 → `BasicInfoMemberInputChanged` を発火 → Blocがフィルタリングして `memberSuggestions` 更新
4. ユーザーがサジェストをタップ → `BasicInfoMemberSuggestionSelected` → Draftに追加・サジェスト更新
5. Widgetが新しいStateを受けてメンバーチップとサジェストを更新

## GasPayMember選択フロー

1. Widgetが `draft.selectedMembers` を参照して `_GasPayMemberChipSection` をレンダリング
2. ユーザーがチップをタップ → `BasicInfoPayMemberChipToggled` を発火
3. BlocがDraftの `selectedPayMember` を更新 → Stateをemit
4. Widgetが新しいStateを受けてチップの選択状態を更新

## Tag選択フロー（改善版レイアウト、ロジックは既存を流用）

1. 画面表示時に `BasicInfoStarted` → Blocがタグマスタ全件を `allTags` にキャッシュ（既存）
2. Widgetが `draft.selectedTags` + 入力欄を `Wrap` で一体表示
3. ユーザーが入力 → `BasicInfoTagInputChanged` → Blocがフィルタリング（既存ロジック）
4. サジェストはオーバーレイ（ドロップダウン）で表示
5. 候補タップ→ `BasicInfoTagSuggestionSelected` → チップ追加・入力クリア・ドロップダウン閉じる（既存ロジック）

---

# 14. View設計

## 変更対象ファイル一覧

| ファイル | 変更種別 | 説明 |
|---|---|---|
| `basic_info_view.dart` | 改修 | `_SelectionRow`（Trans・Members・PayMember）を各インラインセクションに置き換え、`_TagInputSection`を改善 |
| `basic_info_event.dart` | 改修 | 削除イベント除去・追加イベント定義 |
| `basic_info_state.dart` | 改修 | 削除Delegate除去・`allTrans`/`allMembers`/`memberSuggestions`フィールド追加 |
| `basic_info_bloc.dart` | 改修 | MemberRepository/TransRepository DI追加・各ハンドラ実装・削除ハンドラ除去 |
| `event_detail_page.dart` | 改修 | BasicInfoBloc生成箇所にMemberRepository/TransRepositoryを追加注入 |

## _TagInputSection（改善）

- **レイアウト**: 選択済みタグチップ（×付き）と入力欄を同一エリアに `Wrap` で横並び配置
- **入力欄**: チップの末尾に追従して配置
- **候補表示**: `OverlayEntry` または `CompositedTransformFollower` を使ったドロップダウン
- **候補件数**: 最大4件（スクロール可、最大高さ160dp程度）
- **未登録文字列**: 候補リスト最下部に `'"xxx" を追加'` のListTileを表示
- **候補タップ後**: チップ追加 → 入力クリア → ドロップダウン閉じる
- **ウィジェットキー**:
  - `Key('basicInfo_field_tagInput')` — タグ入力欄
  - `Key('basicInfo_item_tagSuggestion_${tag.id}')` — 各サジェストアイテム
  - `Key('basicInfo_item_tagAddNew')` — 「"xxx" を追加」アイテム
  - `Key('basicInfo_chip_tag_${tag.id}')` — 選択済みタグチップ

## _TransChipSection（新規）

- **レイアウト**: `Wrap` で `allTrans` を全件チップ横並び表示
- **未選択状態**: `FilterChip` またはアウトライン表示（枠線のみ）
- **選択済み状態**: テーマprimaryColor塗りつぶし＋✓アイコン
- **タップ**: `BasicInfoTransChipToggled` を発火
- **ウィジェットキー**:
  - `Key('basicInfo_chip_trans_${trans.id}')` — 各Transチップ

## _MemberInputSection（新規）

- **レイアウト**: 選択済みメンバーチップ（塗りつぶし＋×ボタン）と入力欄を `Wrap` で横並び
- **候補表示**: 入力欄フォーカスでドロップダウン（`_TagInputSection` と同様の実装パターン）
- **未入力時**: 最近のメンバーサジェスト（`state.memberSuggestions`）を表示
- **入力時**: `allMembers` を部分一致フィルタリング（選択済み除外）
- **未登録名**: 候補リスト最下部に `'"xxx" を追加'` を表示
- **重複チェック**: 既に選択済みと同名は追加しない
- **ウィジェットキー**:
  - `Key('basicInfo_field_memberInput')` — メンバー入力欄
  - `Key('basicInfo_item_memberSuggestion_${member.id}')` — 各サジェストアイテム
  - `Key('basicInfo_item_memberAddNew')` — 「"xxx" を追加」アイテム
  - `Key('basicInfo_chip_member_${member.id}')` — 選択済みメンバーチップ

## _GasPayMemberChipSection（新規）

- **レイアウト**: `draft.selectedMembers` 全員を `Wrap` でチップ表示
- **未選択状態**: アウトライン表示（枠線のみ）
- **選択済み状態**: テーマprimaryColor塗りつぶし＋✓アイコン
- **メンバー0人の場合**: チップを表示せず「メンバーを先に選択してください」のヒントテキストを表示
- **タップ**: `BasicInfoPayMemberChipToggled` を発火
- **ウィジェットキー**:
  - `Key('basicInfo_chip_payMember_${member.id}')` — 各GasPayMemberチップ
  - `Key('basicInfo_text_payMemberHint')` — メンバー未選択時のヒントテキスト

## チップデザイン統一仕様

全セクションのチップデザインは以下で統一する。

| 状態 | 見た目 |
|---|---|
| 未選択チップ（Trans・GasPayMember） | `FilterChip` またはアウトライン表示（枠線のみ） |
| 選択済みチップ（Trans・GasPayMember） | テーマprimaryColor塗りつぶし＋✓アイコン |
| 選択済みチップ（Tags・Members） | テーマprimaryColor塗りつぶし＋×ボタン |

---

# 15. 非機能要件

- メンバーマスタ・タグマスタ・交通手段マスタは画面表示時に一括キャッシュし、入力変化のたびにDBを叩かない
- メンバー・タグの検索は大文字・小文字を区別しない
- メンバーサジェストは直近10イベントを参照（パフォーマンス考慮）

---

# 16. Test Scenarios

## 前提条件

- iOSシミュレーターが起動済みであること
- テスト用データとして以下が事前登録済みであること
  - 交通手段マスタ: 「車」「バイク」「電車」の3件
  - メンバーマスタ: 「田中」「鈴木」「佐藤」の3件
  - タグマスタ: 「高速」「下道」の2件
  - イベントが1件以上存在し、最近使用したメンバー・タグが取得可能な状態
- BasicInfoタブが表示されていること
- 編集モードになっていること

## テストシナリオ一覧

| ID | シナリオ名 | 区分 | 優先度 |
|---|---|---|---|
| TC-BII-001 | タグ: 入力欄タップでドロップダウン表示 | Widget | High |
| TC-BII-002 | タグ: 既存タグ候補タップでチップ追加 | Integration | High |
| TC-BII-003 | タグ: 未登録文字列で「追加」アイテム表示→タップでチップ追加 | Integration | High |
| TC-BII-004 | タグ: チップの×タップで削除 | Integration | High |
| TC-BII-005 | Trans: 全登録交通手段がチップ表示される | Widget | High |
| TC-BII-006 | Trans: チップタップで選択状態になる（他Transは非選択） | Integration | High |
| TC-BII-007 | Trans: 初期値（既存選択）が選択状態で表示される | Widget | Medium |
| TC-BII-008 | Trans: 選択済みチップを再タップで選択解除 | Integration | Medium |
| TC-BII-009 | Members: 入力欄タップでサジェストドロップダウン表示 | Widget | High |
| TC-BII-010 | Members: サジェストタップでチップ追加（ドロップダウン閉じる） | Integration | High |
| TC-BII-011 | Members: チップの×タップでメンバーチップ削除 | Integration | High |
| TC-BII-012 | Members: 未登録名で「追加」表示→タップでマスタ登録+チップ追加 | Integration | High |
| TC-BII-013 | GasPayMember: イベントメンバーが全員チップで表示される | Widget | High |
| TC-BII-014 | GasPayMember: チップタップで選択状態になる（他は非選択） | Integration | High |
| TC-BII-015 | GasPayMember: イベントメンバー0人時にヒントテキスト表示 | Widget | Medium |
| TC-BII-016 | GasPayMember: 選択済みチップを再タップで選択解除 | Integration | Medium |

---

## シナリオ詳細

### TC-BII-001: タグ — 入力欄タップでドロップダウン表示

**前提**: BasicInfoタブが編集モードで表示されている

**操作手順:**
1. `Key('basicInfo_field_tagInput')` の入力欄をタップする

**期待結果:**
- タグサジェストのドロップダウンが表示される
- 最近使用したタグが候補として表示される（`Key('basicInfo_item_tagSuggestion_${tag.id}')` が1件以上存在する）

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_field_tagInput        : タグ入力欄
- basicInfo_item_tagSuggestion_*  : タグサジェストアイテム（id付き）
```

---

### TC-BII-002: タグ — 既存タグ候補タップでチップ追加

**前提**: BasicInfoタブが編集モードで表示されている。タグマスタに「高速」が存在する

**操作手順:**
1. `Key('basicInfo_field_tagInput')` をタップしてフォーカス
2. 「高速」に対応する `Key('basicInfo_item_tagSuggestion_${高速のid}')` をタップする

**期待結果:**
- 「高速」タグのチップ `Key('basicInfo_chip_tag_${高速のid}')` が表示される
- タグ入力欄の内容がクリアされる
- ドロップダウンが閉じる

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_field_tagInput          : タグ入力欄
- basicInfo_item_tagSuggestion_*    : タグサジェストアイテム
- basicInfo_chip_tag_*              : 選択済みタグチップ
```

---

### TC-BII-003: タグ — 未登録文字列で「追加」アイテム表示→タップでチップ追加

**前提**: BasicInfoタブが編集モードで表示されている。「テスト新タグ」はタグマスタに未存在

**操作手順:**
1. `Key('basicInfo_field_tagInput')` をタップしてフォーカス
2. 「テスト新タグ」と入力する
3. ドロップダウンに `Key('basicInfo_item_tagAddNew')` が表示されることを確認する
4. `Key('basicInfo_item_tagAddNew')` をタップする

**期待結果:**
- 「テスト新タグ」のタグチップが追加表示される
- タグ入力欄の内容がクリアされる
- ドロップダウンが閉じる

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_field_tagInput    : タグ入力欄
- basicInfo_item_tagAddNew    : 「"xxx" を追加」アイテム
- basicInfo_chip_tag_*        : 選択済みタグチップ
```

---

### TC-BII-004: タグ — チップの×タップで削除

**前提**: BasicInfoタブが編集モードで表示されている。タグ「高速」が選択済み状態

**操作手順:**
1. `Key('basicInfo_chip_tag_${高速のid}')` のチップの×ボタンをタップする

**期待結果:**
- 「高速」タグのチップが画面から消える

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_chip_tag_*  : 選択済みタグチップ（×ボタン付き）
```

---

### TC-BII-005: Trans — 全登録交通手段がチップ表示される

**前提**: BasicInfoタブが編集モードで表示されている。交通手段マスタに「車」「バイク」「電車」が登録済み

**操作手順:**
1. BasicInfoタブを表示する

**期待結果:**
- `Key('basicInfo_chip_trans_${車のid}')` が表示される
- `Key('basicInfo_chip_trans_${バイクのid}')` が表示される
- `Key('basicInfo_chip_trans_${電車のid}')` が表示される

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_chip_trans_*  : 交通手段チップ（id付き）
```

---

### TC-BII-006: Trans — チップタップで選択状態になる（他Transは非選択）

**前提**: BasicInfoタブが編集モードで表示されている。交通手段が未選択状態

**操作手順:**
1. `Key('basicInfo_chip_trans_${車のid}')` をタップする

**期待結果:**
- 「車」チップが選択状態（塗りつぶし＋✓）になる
- 「バイク」「電車」チップは未選択状態のまま

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_chip_trans_*  : 交通手段チップ（選択状態はチップの見た目で確認）
```

---

### TC-BII-007: Trans — 初期値（既存選択）が選択状態で表示される

**前提**: 「バイク」が選択済みのイベントをBasicInfoで表示する

**操作手順:**
1. BasicInfoタブを表示する

**期待結果:**
- `Key('basicInfo_chip_trans_${バイクのid}')` が選択状態（塗りつぶし＋✓）で表示される
- 他のTransチップは未選択状態で表示される

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_chip_trans_*  : 交通手段チップ
```

---

### TC-BII-008: Trans — 選択済みチップを再タップで選択解除

**前提**: BasicInfoタブが編集モードで表示されている。「車」が選択済み状態

**操作手順:**
1. `Key('basicInfo_chip_trans_${車のid}')` を再度タップする

**期待結果:**
- 「車」チップが未選択状態（アウトライン表示）になる
- 交通手段が未選択状態になる

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_chip_trans_*  : 交通手段チップ
```

---

### TC-BII-009: Members — 入力欄タップでサジェストドロップダウン表示

**前提**: BasicInfoタブが編集モードで表示されている。最近使用したメンバーが存在する

**操作手順:**
1. `Key('basicInfo_field_memberInput')` をタップしてフォーカス

**期待結果:**
- メンバーサジェストのドロップダウンが表示される
- 最近使用したメンバーが候補として表示される（`Key('basicInfo_item_memberSuggestion_${member.id}')` が1件以上存在する）

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_field_memberInput           : メンバー入力欄
- basicInfo_item_memberSuggestion_*     : メンバーサジェストアイテム（id付き）
```

---

### TC-BII-010: Members — サジェストタップでチップ追加（ドロップダウン閉じる）

**前提**: BasicInfoタブが編集モードで表示されている。メンバーマスタに「田中」が存在

**操作手順:**
1. `Key('basicInfo_field_memberInput')` をタップしてフォーカス
2. 「田中」に対応する `Key('basicInfo_item_memberSuggestion_${田中のid}')` をタップする

**期待結果:**
- 「田中」のメンバーチップ `Key('basicInfo_chip_member_${田中のid}')` が表示される
- メンバー入力欄の内容がクリアされる
- ドロップダウンが閉じる

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_field_memberInput          : メンバー入力欄
- basicInfo_item_memberSuggestion_*    : メンバーサジェストアイテム
- basicInfo_chip_member_*              : 選択済みメンバーチップ
```

---

### TC-BII-011: Members — チップの×タップでメンバーチップ削除

**前提**: BasicInfoタブが編集モードで表示されている。「田中」が選択済み状態

**操作手順:**
1. `Key('basicInfo_chip_member_${田中のid}')` のチップの×ボタンをタップする

**期待結果:**
- 「田中」のメンバーチップが画面から消える

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_chip_member_*  : 選択済みメンバーチップ（×ボタン付き）
```

---

### TC-BII-012: Members — 未登録名で「追加」表示→タップでマスタ登録+チップ追加

**前提**: BasicInfoタブが編集モードで表示されている。「新メンバー太郎」はメンバーマスタに未存在

**操作手順:**
1. `Key('basicInfo_field_memberInput')` をタップしてフォーカス
2. 「新メンバー太郎」と入力する
3. ドロップダウンに `Key('basicInfo_item_memberAddNew')` が表示されることを確認する
4. `Key('basicInfo_item_memberAddNew')` をタップする

**期待結果:**
- 「新メンバー太郎」のメンバーチップが追加表示される
- メンバー入力欄の内容がクリアされる
- ドロップダウンが閉じる

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_field_memberInput   : メンバー入力欄
- basicInfo_item_memberAddNew   : 「"xxx" を追加」アイテム
- basicInfo_chip_member_*       : 選択済みメンバーチップ
```

---

### TC-BII-013: GasPayMember — イベントメンバーが全員チップで表示される

**前提**: BasicInfoタブが編集モードで表示されている。「田中」「鈴木」が選択済みメンバー

**操作手順:**
1. BasicInfoタブを表示する

**期待結果:**
- `Key('basicInfo_chip_payMember_${田中のid}')` が表示される
- `Key('basicInfo_chip_payMember_${鈴木のid}')` が表示される

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_chip_payMember_*  : GasPayMemberチップ（id付き）
```

---

### TC-BII-014: GasPayMember — チップタップで選択状態になる（他は非選択）

**前提**: BasicInfoタブが編集モードで表示されている。「田中」「鈴木」が選択済みメンバー。GasPayMemberは未選択状態

**操作手順:**
1. `Key('basicInfo_chip_payMember_${田中のid}')` をタップする

**期待結果:**
- 「田中」チップが選択状態（塗りつぶし＋✓）になる
- 「鈴木」チップは未選択状態のまま

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_chip_payMember_*  : GasPayMemberチップ
```

---

### TC-BII-015: GasPayMember — イベントメンバー0人時にヒントテキスト表示

**前提**: BasicInfoタブが編集モードで表示されている。選択済みメンバーが0人の状態

**操作手順:**
1. BasicInfoタブを表示する（またはメンバーをすべて削除する）

**期待結果:**
- GasPayMemberセクションにチップが表示されない
- `Key('basicInfo_text_payMemberHint')` のヒントテキストが表示される

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_text_payMemberHint  : 「メンバーを先に選択してください」ヒストテキスト
- basicInfo_chip_payMember_*    : GasPayMemberチップ（この状態では表示されない）
```

---

### TC-BII-016: GasPayMember — 選択済みチップを再タップで選択解除

**前提**: BasicInfoタブが編集モードで表示されている。「田中」がGasPayMemberとして選択済み状態

**操作手順:**
1. `Key('basicInfo_chip_payMember_${田中のid}')` を再度タップする

**期待結果:**
- 「田中」チップが未選択状態（アウトライン表示）になる
- GasPayMemberが未選択状態になる

**実装ノート:**
```
ウィジェットキー一覧:
- basicInfo_chip_payMember_*  : GasPayMemberチップ
```

---

# End of Feature Spec
