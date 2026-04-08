# 要件書: 地点追加時の初期値・引き継ぎルール / 交通手段メーター同期 / メンバー選択スコープ

要件書ID: REQ-mark_addition_defaults
作成日: 2026-04-08
ステータス: 確定
関連タスク: T-073〜T-079（新規）

---

## 背景・目的

MichiInfo タブで地点（Mark）を新規追加するとき、毎回メーター・メンバー・日付をゼロから入力するのは手間がかかる。
直前の地点や設定済みの交通手段から情報を引き継ぐことで入力コストを下げ、データの一貫性も高める。

また、地点のメンバー選択候補がマスター全員になっていると、イベントに参加していないメンバーが混入するリスクがある。
これを防ぐためにイベントの基本タブで設定したメンバーのみを候補とする。

さらに、EventDetail を保存したタイミングで交通手段の最大メーター値を更新することで、
次回以降の地点追加時のメーター初期値を正確に保つ。

---

## 用語定義

| 用語 | 定義 |
|---|---|
| 地点（Mark） | MichiInfo タブに表示される MarkOrLink.mark タイプのエントリ |
| 前の地点 | EventDomain.markLinks を markLinkSeq 昇順で並べたとき、新規追加位置より前にある最後の Mark |
| 交通手段（Trans） | BasicInfo タブで設定した TransDomain（meterValue フィールドを持つ） |
| 基本タブメンバー | EventDomain.members に登録されたメンバーリスト |

---

## 要件一覧

### REQ-MAD-001: 地点追加時のメーター初期値

**概要**
MichiInfo タブで地点を新規追加するとき、メーター入力欄の初期値を以下のルールで設定する。

**ルール**
- 前の地点が存在する場合 → 前の地点の `meterValue` を初期値とする
- 前の地点が存在しない場合（イベントの最初の地点） → 設定済み交通手段の `meterValue` を初期値とする
- 交通手段も未設定の場合 → 空文字（入力なし）

**補足**
- メーター値は `meterValueInput` 文字列（例: `"12345"`）として MarkDetailDraft に渡す
- meterValue が 0 の場合も初期値として設定する（未設定と区別しない）

---

### REQ-MAD-002: 地点追加時のメンバー初期値

**概要**
MichiInfo タブで地点を新規追加するとき、メンバーの初期値を以下のルールで設定する。

**ルール**
- 前の地点が存在する場合 → 前の地点の `members` をそのまま引き継ぐ
- 前の地点が存在しない場合 → 空リスト（未選択）

---

### REQ-MAD-003: 地点追加時の日付初期値

**概要**
MichiInfo タブで地点を新規追加するとき、記録日（markLinkDate）の初期値を以下のルールで設定する。

**ルール**
- 前の地点が存在する場合 → 前の地点の `markLinkDate` を初期値とする
- 前の地点が存在しない場合 → 本日の日付（`DateTime.now()` の年月日部分）

---

### REQ-MAD-004: 地点のメンバー選択候補をイベントメンバーに限定

**概要**
地点詳細（MarkDetail）でメンバーを選択するとき、選択候補を EventDomain.members（基本タブで登録したメンバー）のみとする。

**現状の問題**
- 現状、地点のメンバー選択候補はマスター全件（MemberRepository.fetchAll()）になっている
- イベントに参加していないメンバーが選択できてしまう

**変更内容**
- MarkDetailArgs にイベントの `members: List<MemberDomain>` を追加する
- MarkDetailBloc は MemberRepository からの fetchAll() を使わず、渡された members を候補として使用する
- 候補リストが空の場合（BasicInfo でメンバー未設定）は選択不可として空リストを表示する

---

### REQ-MAD-005: EventDetail 保存時に交通手段の最大メーター値を更新する

**概要**
EventDetail の保存ボタンを押したとき、EventDomain.markLinks の中の最大 meterValue を交通手段（TransDomain）の meterValue に反映させる。

**ルール**
- EventDetail 保存時、`markLinks` の `meterValue` の最大値を算出する
- 選択中の交通手段（`trans`）が存在し、かつ算出した最大値が現在の `trans.meterValue` より大きい場合のみ更新する
- markLinks が空の場合、またはすべての meterValue が null / 0 の場合は更新しない
- 交通手段が未設定の場合は更新しない

**目的**
次回以降、同じ交通手段を使うイベントで地点を追加するとき（REQ-MAD-001の後半ルール）に最新のメーター値が初期値として表示される。

**更新対象**
- `TransRepository.save(trans.copyWith(meterValue: newMax))` を呼ぶ

---

## 実装スコープ

| 変更対象 | 内容 | 対応要件 |
|---|---|---|
| `MarkDetailArgs` | `previousMark: MarkLinkDomain?`・`transMeterValue: int?`・`eventMembers: List<MemberDomain>` を追加 | REQ-MAD-001〜004 |
| `MarkDetailBloc._onStarted` | `MarkDetailArgs` の情報をもとに Draft 初期値を設定 | REQ-MAD-001〜003 |
| `MarkDetailBloc._onStarted` | 候補メンバーを `args.eventMembers` に変更 | REQ-MAD-004 |
| `MichiInfoBloc._onAddMarkLinkRequested` | 直前 Mark の情報・Trans のメーター・Event メンバーを `MarkDetailArgs` に詰めて渡す | REQ-MAD-001〜004 |
| `EventDetailBloc._onSaveRequested` | 保存後に `TransRepository.save()` で最大メーター値を更新 | REQ-MAD-005 |
| `EventDetailBloc` | `TransRepository` 依存を追加 | REQ-MAD-005 |

---

## 非機能要件

- 既存の地点（MarkDetail 編集時）には初期値ルールを適用しない（DB 値をそのまま表示する）
- 初期値は「初期値」であり、ユーザーが変更可能であること
- メンバー候補が空のとき、選択 UI は「メンバーが設定されていません」等のメッセージを表示すること（空リストのままでもクラッシュしないこと）

---

## スコープ外（今回対応しない）

- Link（リンク）の初期値ルール（必要になったタイミングで別要件として追加）
- メーター自動補完・距離自動計算

---

## 関連ドキュメント

- `docs/Spec/Features/MichiInfo_Layout_Spec.md`
- `docs/Spec/Features/EventDetail/` （MarkDetail・BasicInfo Spec）
