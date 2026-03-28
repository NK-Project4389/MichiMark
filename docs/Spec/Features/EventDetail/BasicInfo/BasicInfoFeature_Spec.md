# BasicInfo Feature Specification

Feature
BasicInfoFeature

Parent Feature
EventDetailFeature

Purpose

イベントの基本情報を編集するSubFeature。

BasicInfoFeatureはEventDraftの基本情報部分を編集する。

BasicInfoFeatureは表示用Projectionを持ち、
編集用Draftを内部に保持する。

---

# Responsibilities

BasicInfoFeatureは以下を担当する。

eventName編集

交通手段選択

タグ選択

メンバー選択

燃費入力

ガソリン単価入力

支払者選択

BasicInfoFeatureはDomainを直接変更しない。

変更はEventDetailFeatureへDelegate通知する。

---

# State Structure

BasicInfoState

projection: BasicInfoProjection
- 保存済み表示データ

draft: BasicInfoDraft
- 入力途中データ

visibleFields: Set\<EventFieldID\>
- イベントパターンに応じた表示制御

eventID: EventID
- 外部参照

delegate: BasicInfoDelegate?
- 遷移意図の通知（BlocListenerが受け取り処理）

---

# Projection Model

BasicInfoProjection

Purpose

BasicInfo画面の表示専用モデル

fields

id

eventName

trans

tags

members

kmPerGas

displayKmPerGas

pricePerGas

displayPricePerGas

payMember

Projectionは表示専用であり
編集状態は保持しない。

---

# Draft Model

BasicInfoDraft

Purpose

BasicInfo編集状態

fields

eventName

selectedTransID

selectedTagIDs

selectedMemberIDs

selectedTagNames

selectedMemberNames

kmPerGas

pricePerGas

selectedPayMemberID

Draftは未確定データとして扱う。

---

# Draft Initialization

BasicInfoBloc初期化時

ProjectionからDraftを生成する。

Flow

Projection
 ↓
BasicInfoBloc.constructor（Started Event処理）
 ↓
BasicInfoDraft生成

---

# BLoC Events

BasicInfoEvent（sealed class）

Started
- 画面表示・Projectionから初期Draft生成

NameChanged(String value)
- イベント名入力

KmPerGasChanged(String value)
- 燃費入力

PricePerGasChanged(String value)
- ガソリン単価入力

TransTapped
- 交通手段選択画面を開く要求（Delegateで通知）

MembersTapped
- メンバー選択画面を開く要求

TagsTapped
- タグ選択画面を開く要求

PayMemberTapped
- 支払者選択画面を開く要求

SelectionApplied(SelectionResult result)
- 選択画面からの結果を受け取り Draft更新

SaveTapped
- 保存（Delegateで親へsaveDraft通知）

---

> **Note:** Delegateは `BasicInfoState` のフィールドとして保持する（Eventではない）。

---

# Selection Flow

ユーザーが選択画面を開く場合

transTapped
 ↓
delegate.selectionRequested

Root
 ↓
SelectionFeature表示

選択完了後

applySelection

Draft更新

---

# Save Flow

saveTapped
 ↓
delegate.saveDraft

EventDetailFeature
 ↓
EventDraft更新

---

# Delegate Contract

BasicInfoDelegate（sealed class）→ Stateのフィールドとして保持

SaveDraft(EventID eventId, BasicInfoDraft draft)
- EventDraft更新要求（BlocListenerがEventDetailBlocへ転送）

SelectionRequested(SelectionUseCase useCase)
- Selection画面表示要求（BlocListenerがcontext.push()で遷移）

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
BasicInfoDelegate（State）
 ↓
BlocListener → EventDetailBloc
 ↓
EventDomain更新

---

# Projection Adapter

BasicInfoProjectionAdapter

Purpose

Domain → Projection変換

Input

EventDomain

MemberDomain

TagDomain

TransDomain

Output

BasicInfoProjection

---

# Visibility Control

visibleFields

EventFieldIDのSetで管理する

イベントパターンに応じて
表示項目を制御する。

例

fuelFields

memberFields

tagFields

---

# Architecture Rules

BasicInfoFeatureは禁止

EventDomain直接変更

Repository呼び出し

Navigation管理

---

BasicInfoFeatureは

Draft編集

Delegate通知

のみ担当する。

---

# Future Extensions

以下の拡張を想定

EventCategory

VehicleAssignment

FuelCostCalculation

---

# Architecture Summary

BasicInfoFeatureは

Projection + Draft

の二層構造を持つ編集Featureである。

編集はDraftで行い

Delegate経由でEventDetailへ反映する。

---

# End of BasicInfo Feature Spec