# 要件書: メンバー選択UI タグ式リニューアル

**要件ID**: REQ-member_selection_tag_style
**作成日**: 2026-04-11
**ステータス**: 廃止（2026-04-12）→ REQ-event_detail_inline_selection_ui に統合

---

## 背景・目的

現状、メンバー選択は `SelectionPage`（フルスクリーン画面遷移）を使用しており、操作ステップが多い。
タグ選択が実現した「インラインUI＋サジェスト＋手入力でマスター追加」（REQ-tag_inline_suggest）と同様の体験をメンバー選択にも適用し、UXを統一・改善する。

選択の用途によって2種類のUIモードを設ける。

---

## ユーザーストーリー

- As a ユーザー, I want to イベントの基本画面でメンバーをタグと同様にインラインで追加・削除したい, so that 別画面に遷移せずにメンバー設定を完了できる
- As a ユーザー, I want to 最近選択したメンバーをサジェストとして表示してほしい, so that 繰り返し使うメンバーをすばやく追加できる
- As a ユーザー, I want to マスタにないメンバー名を手入力すると自動でマスター追加したい, so that 新しいメンバーをその場でスムーズに追加できる
- As a ユーザー, I want to マーク・リンク・支払い等の選択画面でも選択済み/未選択を視覚的にわかりやすく切り替えたい, so that どのメンバーが選ばれているかひと目でわかる

---

## 機能要件

### モード1: インライン選択（BasicInfo eventMembers）

タグ入力（`_TagInputSection`）と同様のインラインウィジェット `_MemberInputSection` を実装する。

#### FR-001: インライン入力フィールドへの置き換え
- BasicInfo 基本画面のメンバー行を `_SelectionRow`（選択画面遷移型）から `_MemberInputSection`（インライン入力型）に変更する
- 画面遷移は発生させない

#### FR-002: 選択済みメンバーのチップ表示
- 選択済みメンバーは `Chip` ウィジェットで表示する
- 各チップに削除ボタン（×）を設け、タップで選択解除できる

#### FR-003: テキスト入力フィールド
- メンバー名を直接テキスト入力できるフィールドを表示する
- 入力中は部分一致でメンバーマスタを検索しサジェストリストを表示する
- 既に選択済みのメンバーはサジェストから除外する

#### FR-004: 最近選択したメンバーのサジェスト
- 入力が空の場合、「最近選択したメンバー」として過去イベントで使用したメンバーを `ActionChip` で表示する
- 表示順序：直近イベントでの使用頻度・時系列を考慮する（実装は `BasicInfoBloc` の責務）
- サジェストチップをタップするとそのメンバーが選択状態になる

#### FR-005: キーボード確定による追加
- テキストフィールドでキーボードの確定（submitAction）を押すとメンバーを追加する
- 既存マスタに完全一致するメンバーがある場合はそれを使用する
- マスタに存在しない名前の場合はメンバーマスタに新規追加してからイベントに紐づける

#### FR-006: 重複チェック
- 既に選択済みのメンバーと同名を追加しようとした場合は無視する
- マスタへの新規追加時も同名の既存メンバーがないか確認する

---

### モード2: 参加メンバー選択（SelectionPage の改善）

マーク・リンク・支払い・割り勘など、イベントのメンバー（候補）から選ぶ選択画面を改善する。
対象: `SelectionType.markMembers`, `linkMembers`, `splitMembers`, `payMember`, `gasPayMember`

#### FR-010: 選択済みセクションと未選択セクションの分離表示
- 画面上部に「選択済みメンバー」、下部に「未選択の参加メンバー」をセクション分けして表示する
- 視覚的にどちらのグループかひと目でわかるようにする

#### FR-011: タップによるトグル
- 未選択メンバーをタップ → 選択済みに移動する
- 選択済みメンバーをタップ → 未選択に移動する
- 現状の `SelectionItemToggled` イベントの動作は維持する

#### FR-012: 手入力による新規メンバー追加
- 選択画面下部にテキスト入力フィールドを追加する
- 入力確定時: メンバーマスタに新規追加 + イベントのメンバー候補に追加 + 選択済みとして表示する
- マスタに既存の同名メンバーが存在する場合はマスタ追加せず選択済みに追加するのみ

#### FR-013: 既存の SelectionPage との互換性
- `SelectionType.eventTags`, `eventTrans`, `eventTopic` など、メンバー以外の選択は現状の UI を維持する
- モード2の改善はメンバー系 SelectionType のみに適用する

---

## 非機能要件

- メンバーマスタは画面読み込み時にキャッシュし、入力変化のたびにDBを叩かない
- 部分一致検索は大文字・小文字を区別しない
- モード1のサジェストは直近 10 イベント程度を参照する（パフォーマンス考慮）

---

## 影響範囲

### モード1（BasicInfo 変更）

| ファイル | 変更種別 |
|---|---|
| `basic_info_event.dart` | 新イベント追加（MemberInputChanged, MemberSuggestionSelected, MemberInputConfirmed, MemberRemoved） |
| `basic_info_state.dart` | `BasicInfoLoaded` に `memberSuggestions` フィールド追加 |
| `basic_info_bloc.dart` | `MemberRepository`・`NomikaiEventRepository` DI追加・新ハンドラ実装 |
| `basic_info_view.dart` | メンバー行を `_MemberInputSection` に置き換え |

### モード2（SelectionPage 変更）

| ファイル | 変更種別 |
|---|---|
| `selection_page.dart` | メンバー系 SelectionType のみ新UI（セクション分け＋テキスト入力）に切り替え |
| `selection_bloc.dart` | メンバー追加イベント・処理追加 |
| `selection_event.dart` | `SelectionMemberAdded` イベント追加 |
| `selection_args.dart` | 変更なし（既存の `candidateMembers` を活用） |

---

## 対応しないもの

- タグ選択UIの変更
- メンバーマスタ設定画面（member_setting）の変更
- `isFixed`（固定選択）の動作変更
