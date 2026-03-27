# MarkDetail Feature Specification

Feature
MarkDetailFeature (MarkDetailReducer)

Parent Feature
MichiInfoFeature

Purpose

Mark（地点）の詳細編集を行うFeature。

Markはイベント内の地点情報を表し、
メーター値、アクション、燃料情報、メモを管理する。

MarkDetailFeatureは編集中心Featureであり、
編集結果はDraftとして親Featureへ返される。

---

# Responsibilities

MarkDetailFeatureは以下を担当する。

1 Mark名編集
2 メーター値編集
3 Action管理
4 Fuel入力
5 Memo編集

MarkDetailFeatureは禁止

- Navigation管理
- Repositoryアクセス
- Domain直接保存

保存は親Feature（EventDetail）経由で行う。

---

# Domain Model (Reference)

MarkはMarkLinkDomainの一種として扱われる。

Key fields

id
markLinkSeq
markLinkType = mark

markLinkName
meterValue
actions
memo

fuel関連

isFuel
pricePerGas
gasQuantity
gasPrice

---

# Draft Model

MarkDetailDraft

Purpose

Mark編集状態

fields

id
markLinkSeq
markLinkName

meterValue

actions

memo

isFuel
pricePerGas
gasQuantity
gasPrice

Draftは未確定データとして扱う。

---

# Projection Model

MarkDetailProjection

Purpose

MarkDetail画面の表示モデル

fields

id
markLinkSeq
markLinkName

displayMeterValue

actions

displayFuelInfo

memo

Projectionは表示専用。

---

# Projection Adapter

MarkDetailProjectionAdapter

Purpose

MarkLinkDomain → MarkDetailProjection

Responsibilities

meterValueフォーマット
fuel表示整形
action表示生成

---

# Meter Model

meterValue

Type
Int

Unit
km

Example

10000
10050
10120

---

# Distance Relation

Link距離はMarkのmeter差分から算出される。

distance = nextMark.meter - currentMark.meter

MarkDetailFeatureはdistanceを直接計算しない。

LinkDomain側で計算する。

---

# Actions Model

actions

Type
[ActionDomain]

Purpose

地点で発生したイベント

Examples

arrival
departure
fuel
stop

Actionは時系列順で保持される。

---

# Fuel Model

Fuel入力はMarkに紐づく。

fields

isFuel

pricePerGas
単価（円/L）

gasQuantity
給油量（0.1L単位）

gasPrice
給油金額

---

# UI Interaction Flow

Edit Flow
```
User Input
 ↓
Draft更新
 ↓
saveTapped
 ↓
Delegate
 ↓
EventDetailFeature
```
---

# Reducer Actions

MarkDetailReducer.Action

appeared

nameChanged

meterChanged

actionAdded

actionRemoved

fuelChanged

memoChanged

saveTapped

cancelTapped

delegate

---

# Delegate Contract

MarkDetailFeature → Parent

saveDraft(MarkDetailDraft)

dismiss

Purpose

Mark更新通知

---

# Architecture Rules

MarkDetailFeatureは禁止

Repositoryアクセス

Domain永続化

Navigation管理

---

MarkDetailFeatureは

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

MarkLinkはmarkLinkSeqで並ぶ。

MarkDetailFeatureは順序変更を行わない。

---

# Future Extensions

以下の拡張を想定

滞在時間

Action詳細属性

Segment生成

Fuel自動計算

---

# Architecture Summary

MarkDetailFeatureは

Projection + Draft

構造の編集Featureである。

Markの編集はDraftで行い

保存は親Featureへ委譲する。

---

# End of MarkDetail Feature Spec