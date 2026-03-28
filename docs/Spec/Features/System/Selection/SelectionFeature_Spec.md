# Selection Feature Specification

Feature
SelectionFeature (SelectionBloc)

Category
System Feature

Purpose

汎用選択UIを提供する共通Feature。

SelectionFeatureは任意の選択対象をリスト表示し、
ユーザーの選択結果を呼び出し元Featureへ返す。

SelectionFeatureは

single selection  
multi selection  

の両方に対応する。

---

# Responsibilities

SelectionFeatureは以下を担当する。

1 選択対象一覧表示

2 single selection

3 multi selection

4 検索（将来拡張）

5 選択結果の返却

SelectionFeatureは禁止

Domain永続化  
Repositoryアクセス  
Navigation管理  

---

# Selection Concept

SelectionFeatureは汎用選択エンジンとして動作する。

```
SelectionUseCase
      │
      ▼
SelectionFeature
      │
      ▼
SelectionListProjection
      │
      ▼
SelectionItemProjection
```

Selection対象のDomainには依存しない。

---

# Selection Mode

SelectionMode

single

1つの要素のみ選択可能

例

Trans  
Payer

---

multiple

複数要素選択可能

例

Member  
Tag

---

# State Structure

SelectionState

useCase: SelectionUseCase
- 選択対象の定義

projection: SelectionListProjection
- 表示モデル

selectedIDs: Set\<String\>
- 現在の選択状態

mode: SelectionMode
- single / multiple

delegate: SelectionDelegate?
- 遷移意図の通知（BlocListenerが受け取り処理）

---

# Selection UseCase

SelectionUseCase

Purpose

選択対象の定義

fields

selectionType

Selection対象の種類

---

mode

single / multiple

---

items

選択対象データ

---

# Projection Model

SelectionListProjection

Purpose

選択画面表示モデル

fields

items

[SelectionItemProjection]

---

# Selection Item Projection

SelectionItemProjection

fields

id

title

subtitle

isSelected

---

# Projection Adapter

SelectionProjectionAdapter

Purpose

Domain → SelectionItemProjection

Responsibilities

表示タイトル生成  
subtitle生成  
選択状態反映

---

# UI Interaction Flow

## Open Selection

Feature
 ↓
delegate.selectionRequested(SelectionUseCase)
 ↓
Root
 ↓
SelectionFeature表示

---

## Single Selection

User selects item
 ↓
selectedIDs更新
 ↓
confirm
 ↓
delegate.selectionCompleted

---

## Multi Selection

User selects multiple items
 ↓
selectedIDs更新
 ↓
confirm
 ↓
delegate.selectionCompleted

---

# BLoC Events

SelectionEvent（sealed class）

Started
- 画面表示・初期データ読み込み

ItemTapped(String id)

ConfirmTapped

CancelTapped

---

> **Note:** Delegateは `SelectionState` のフィールドとして保持する（Eventではない）。

---

# Delegate Contract

SelectionDelegate（sealed class）→ Stateのフィールドとして保持

SelectionCompleted(Set\<String\> selectedIds)
- 選択完了通知（BlocListenerが受け取りDraft更新）

Cancel
- 選択キャンセル

---

# Data Flow

Display

```
Domain
 ↓
SelectionProjectionAdapter
 ↓
SelectionItemProjection
 ↓
View
```

Selection

```
User
 ↓
SelectionBloc
 ↓
SelectionState.selectedIDs更新
 ↓
SelectionState.delegate
 ↓
BlocListener（Parent）
```

---

# Architecture Rules

SelectionFeatureは禁止

Repositoryアクセス  
Domain永続化  
Navigation管理  

SelectionFeatureは

UI状態管理  
選択結果生成  

のみ担当する。

---

# Supported Selection Types

現在想定されるSelection

TransSelection

交通手段

---

MemberSelection

メンバー

---

TagSelection

タグ

---

PayerSelection

支払者

---

将来拡張

VehicleSelection

---

# Future Extensions

以下の拡張を想定

検索

並び替え

階層選択

---

# Architecture Summary

SelectionFeatureは

汎用選択エンジンとして設計される。

Selection対象Domainに依存せず

single / multiple selection

を提供する。

---

# End of Selection Feature Spec