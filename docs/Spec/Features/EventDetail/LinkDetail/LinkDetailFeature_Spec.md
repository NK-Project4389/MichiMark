# LinkDetail Feature Specification

Feature
LinkDetailFeature (LinkDetailBloc)

Parent Feature
MichiInfoFeature

Purpose

Link（移動区間）の詳細編集を行うFeature。

Linkは2つのMark間の移動を表すDomainであり、
走行距離・メンバー・行動・メモを管理する。

LinkDetailFeatureは編集中心Featureであり、
編集結果はDraftとして親Featureへ返される。

---

# Responsibilities

LinkDetailFeatureは以下を担当する。

1 Link名編集
2 走行距離（DistanceValue）編集
3 メンバー設定
4 行動（Action）管理
5 メモ編集

LinkDetailFeatureは禁止

Navigation管理  
Repositoryアクセス  
Domain直接保存  

保存はEventDetailFeatureへ委譲する。

---

# Domain Model (Reference)

LinkはMarkLinkDomainの一種として扱われる。

Key fields

id
markLinkSeq
markLinkType = link

markLinkName

distanceValue

members

actions

memo

---

# Draft Model

LinkDetailDraft

Purpose

Link編集状態

fields

id
markLinkSeq

markLinkName

distanceValue

members

actions

memo

Draftは未確定データとして扱う。

---

# Projection Model

LinkDetailProjection

Purpose

LinkDetail画面の表示モデル

fields

id
markLinkSeq

markLinkName

displayDistanceValue

members

actions

memo

Projectionは表示専用。

---

# Projection Adapter

LinkDetailProjectionAdapter

Purpose

MarkLinkDomain → LinkDetailProjection

Responsibilities

distance表示フォーマット

member表示生成

action表示生成

---

# Distance Model

distanceValue

Meaning
実走行距離（ユーザー入力値 / 実測値）

Type
Int

Unit
km

Notes
- LinkDomain/MarkLinkDomainのdistanceValueは、Linkの一次データとして保持する。
- LinkDetailFeatureは distanceValue を編集対象とする。

---

# Distance Priority Rule (Important)

実走行距離の「採用値」は以下の優先順位で決定する。

1 meter差分（前後MarkのmeterValue差分が妥当な場合）
2 distanceValue（ユーザー入力 / 実測の走行距離）

このルールは以下の用途で適用される。

- 一覧表示時の距離表示
- 解析（将来Overview）での距離採用
- 不整合検知（将来）

LinkDetailFeature自体は meter差分を計算しない。
（meter差分計算は上位の集計層 / Adapter / Domainルール側で行う）

---

# Display / Editing Rule

編集対象
- distanceValue（ユーザー入力値）

表示対象（採用値）
- meter差分が利用可能で妥当なら meter差分
- そうでなければ distanceValue

備考
- 画面上で「採用値」と「入力値」を分けて見せるかどうかはUI設計次第。
  現時点のSpecでは、編集はdistanceValue、採用は優先順位ルールとする。

---

# Members Model

members

Type
[MemberDomain]

Purpose
移動に参加したメンバー

---

# Actions Model

actions

Type
[ActionDomain]

Purpose
移動中に発生したイベント

Examples
drive
rest
toll

Actionは時系列順で保持される。

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

LinkDetailEvent（sealed class）

Started
- 画面表示・初期データ読み込み

NameChanged(String value)

DistanceChanged(String value)

MembersChanged(List<String> memberIds)

ActionAdded(String actionId)

ActionRemoved(String actionId)

MemoChanged(String value)

SaveTapped

CancelTapped

---

> **Note:** Delegateは `LinkDetailState` のフィールドとして保持する（Eventではない）。

---

# Delegate Contract

LinkDetailDelegate（sealed class）→ Stateのフィールドとして保持

SaveDraft(LinkDetailDraft draft)
- Link編集完了通知

Dismiss
- 画面を閉じる要求

Purpose
Link更新通知（BlocListenerがDelegateを受け取りNavigation処理）

---

# Architecture Rules

LinkDetailFeatureは禁止

Repositoryアクセス
Domain永続化
Navigation管理

---

LinkDetailFeatureは

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

LinkDetailFeatureは順序変更を行わない。

---

# Future Extensions

以下の拡張を想定

- meter差分とdistanceValueの不整合検知（異常値検出）
- Action詳細属性
- Segment生成
- 移動分析（Overview）

---

# Architecture Summary

LinkDetailFeatureは

Projection + Draft

構造の編集Featureである。

Link編集はDraftで行い、
保存は親Featureへ委譲する。

距離の採用値は
meter差分 > distanceValue
の優先順位ルールで決定する。

---

# End of LinkDetail Feature Spec