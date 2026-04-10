# REQ-member_required_guard: メンバー未選択時の入力ガード

## 要件番号
REQ-member_required_guard

## 優先度
Medium

## 背景・目的
メンバーを1人も選択していない状態で、メンバーに関連する入力項目（支払者・割り勘メンバーなど）を操作できてしまう。メンバーが未選択の場合、これらの項目を選択しても意味がないため、UI上で非活性化（disabled）してユーザーを適切に誘導する。

## 対象画面と対象項目

| 画面 | 項目 | 条件 |
|---|---|---|
| 概要タブ（BasicInfo） | ガソリン支払者 | selectedMembers が空 |
| MarkDetail | 参加メンバー | eventMembers が空 |
| LinkDetail | 参加メンバー | eventMembers が空 |
| PaymentDetail | 支払い者 | eventMembers が空 |
| PaymentDetail | 割り勘メンバー | eventMembers が空 |
| 給油計算（FuelDetail） | 支払い者 | eventMembers が空 |

## 要件

### REQ-MRG-001: BasicInfo ガソリン支払者
- `draft.selectedMembers.isEmpty` のとき、ガソリン支払者の選択行を非活性化（タップ不可・グレー表示）する
- 非活性化時、押しても選択画面に遷移しない

### REQ-MRG-002: MarkDetail 参加メンバー
- `eventMembers.isEmpty` のとき、参加メンバーの選択行を非活性化する

### REQ-MRG-003: LinkDetail 参加メンバー
- `eventMembers.isEmpty` のとき、参加メンバーの選択行を非活性化する

### REQ-MRG-004: PaymentDetail 支払い者・割り勘メンバー
- `eventMembers.isEmpty` のとき、支払い者・割り勘メンバーの選択行を非活性化する

### REQ-MRG-005: FuelDetail 支払い者
- `eventMembers.isEmpty` のとき、支払い者の選択行を非活性化する

## UI仕様
- 非活性化時: テキストをグレー表示（`onSurfaceVariant`）、`>` アイコンを非表示またはグレー表示、タップイベントを無効化
- ツールチップ等は不要（過度な説明は避ける）
