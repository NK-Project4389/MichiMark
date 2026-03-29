# PaymentDetail Feature Specification

Feature
PaymentDetailFeature (PaymentDetailBloc)

Parent Feature
PaymentInfoFeature

Purpose

Payment（支払）の詳細編集を行うFeature。

PaymentDetailFeatureは支払情報の入力・編集を担当し、
編集結果はDraftとして親Featureへ返される。

---

# Responsibilities

PaymentDetailFeatureは以下を担当する。
```
1 支払名称編集
2 支払金額入力
3 支払者設定
4 関連MarkLink設定
5 メモ編集
```
PaymentDetailFeatureは禁止

Navigation管理
Repositoryアクセス
Domain直接保存

保存はEventDetailFeatureへ委譲する。

---

# Domain Model (Reference)

PaymentDomain

Key fields

id
paymentSeq

paymentAmount

paymentMember

splitMembers

paymentMemo

isDeleted

---

# Draft Model

PaymentDetailDraft

Purpose

Payment編集状態

fields

id
paymentSeq

paymentAmount（編集用文字列）

paymentMember（選択中MemberDomain）

splitMembers（選択中MemberDomain[]）

paymentMemo（編集用文字列）

Draftは未確定状態として扱う。

---

# Projection Model

PaymentDetailProjection

Purpose

PaymentDetail画面表示モデル

fields

id
paymentSeq

displayPaymentAmount

paymentMember（表示名）

splitMembers（表示名[]）

paymentMemo

Projectionは表示専用。

---

# Projection Adapter

PaymentDetailProjectionAdapter

Purpose

PaymentDomain → PaymentDetailProjection

Responsibilities

金額フォーマット
payer表示生成
MarkLink表示生成

---

# Amount Model

amount

Type
Int

Unit
円

Example

1000
2500
12000

---

# Payer Model

payer

Type
MemberDomain

Purpose

支払担当メンバー

---

# Related MarkLink Model

relatedMarkLink

Purpose

支払が発生した地点または移動区間

Example

Mark
Link

Optional

---

# UI Interaction Flow

Edit Flow

User Input
 ↓
Draft更新
 ↓
saveTapped
 ↓
Delegate
 ↓
EventDetailFeature

---

# BLoC Events

PaymentDetailEvent（sealed class）

Started
- 画面表示・初期データ読み込み

PaymentAmountChanged(String value)

PaymentMemberChanged(String memberId)

SplitMembersChanged(List<String> memberIds)

MemoChanged(String value)

SaveTapped

CancelTapped

---

> **Note:** `relatedMarkLinkChanged` はSpec Patchにより削除済み。
> Delegateは `PaymentDetailState` のフィールドとして保持する（Eventではない）。

---

# Delegate Contract

PaymentDetailDelegate（sealed class）→ Stateのフィールドとして保持

SaveDraft(PaymentDetailDraft draft)
- Payment編集完了通知

Dismiss
- 画面を閉じる要求

Purpose
Payment更新通知（BlocListenerがDelegateを受け取りNavigation処理）

---

# Architecture Rules

PaymentDetailFeatureは禁止

Repositoryアクセス
Domain永続化
Navigation管理

---

PaymentDetailFeatureは

Draft編集
Delegate通知

のみ担当する。

---

# Data Flow

Display Flow

Domain
 ↓
ProjectionAdapter
 ↓
Projection
 ↓
View

---

Edit Flow

User Input
 ↓
Draft
 ↓
Delegate
 ↓
EventDetailFeature
 ↓
EventDomain更新

---

# Ordering Rule

PaymentはpaymentSeqで並ぶ。

PaymentDetailFeatureは順序変更を行わない。

---

# Future Extensions

以下の拡張を想定

カテゴリ分類

複数payer分割

自動費用分析

Overview集計

---

# Architecture Summary

PaymentDetailFeatureは

Projection + Draft

構造の編集Featureである。

Payment編集はDraftで行い、

保存は親Featureへ委譲する。

---

# ===============================
# Patch : PaymentDetail Spec Fix
# ===============================

## 修正理由

現仕様では支払いはMark / Linkに紐づかない。
PaymentはEvent配下の独立したドメインとして扱う。

そのため以下のフィールドを削除する。

relatedMarkLink

---

# 削除対象

## Domain Model

削除

relatedMarkLink

---

## Draft Model

削除

relatedMarkLink

---

## Projection Model

削除

relatedMarkLink

---

## Reducer Actions

削除

relatedMarkLinkChanged

---

# 修正後のPayment構造

Payment

id
paymentSeq

paymentAmount

paymentMember

splitMembers

paymentMemo
isDeleted

---

# Notes

将来的に

Mark / Link別支払い

を導入する場合は

PaymentLinkDomain

を新規導入する予定。

現時点ではSpecから削除する。

# ===============================
# Patch : PaymentDetail Selection Delegate追加
# ===============================

## 修正理由

支払者・割り勘メンバーの選択はSelection画面経由で行う。
LinkDetailFeatureと同様のパターン（EditPressed → Delegate → Selected）を採用する。

---

## BLoC Events 変更

### 削除

```
PaymentMemberChanged(String memberId)
SplitMembersChanged(List<String> memberIds)
```

### 追加

```
EditMemberPressed
- 支払者選択ボタン押下 → OpenMemberSelectionDelegate を発火

MemberSelected(MemberDomain member)
- 選択画面から支払者が返却されたとき → Draft更新

EditSplitMembersPressed
- 割り勘メンバー選択ボタン押下 → OpenSplitMembersSelectionDelegate を発火

SplitMembersSelected(List<MemberDomain> members)
- 選択画面から割り勘メンバーが返却されたとき → Draft更新
```

---

## Delegate Contract 変更

### 追加（既存のSaveDraft・Dismissに追記）

```
OpenMemberSelection
- 支払者選択画面を開く要求（シングル選択）
- EditMemberPressed で発火

OpenSplitMembersSelection
- 割り勘メンバー選択画面を開く要求（マルチ選択）
- EditSplitMembersPressed で発火
```

---

## 修正後のBLoC Events全体

```
PaymentDetailEvent（sealed class）

Started
- 画面表示・初期データ読み込み

PaymentAmountChanged(String value)

EditMemberPressed
- 支払者選択ボタン押下

MemberSelected(MemberDomain member)
- 選択画面から支払者返却

EditSplitMembersPressed
- 割り勘メンバー選択ボタン押下

SplitMembersSelected(List<MemberDomain> members)
- 選択画面から割り勘メンバー返却

MemoChanged(String value)

SaveTapped

CancelTapped
```

---

## 修正後のDelegate Contract全体

```
PaymentDetailDelegate（sealed class）→ Stateのフィールドとして保持

SaveDraft(PaymentDetailDraft draft)
- Payment編集完了通知

Dismiss
- 画面を閉じる要求

OpenMemberSelection
- 支払者選択画面を開く要求（シングル選択）

OpenSplitMembersSelection
- 割り勘メンバー選択画面を開く要求（マルチ選択）
```

---

# End of PaymentDetail Feature Spec