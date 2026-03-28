# EventDetail Feature Specification

Feature
EventDetail

Purpose

Eventの編集を行うFeature。
イベントに関連する基本情報、Michi情報、支払情報を統合して管理する。

EventDetailは **編集中心Feature** として設計される。

Overviewのみ表示中心Featureとする。

---

# Responsibilities

EventDetailFeatureは以下を担当する。

1 Event編集
2 SubFeature管理
3 EventDomain更新
4 Repository保存
5 RootNavigation要求

EventDetailは **Aggregate Feature** として振る舞う。

EventDetailBlocがSubFeature（BasicInfo / MichiInfo / PaymentInfo）からのDraftを集約し、EventDomainを更新する。

---

# Feature Structure

EventDetailFeature

EventDetailBloc
 ↓
SubFeatures（各Bloc独立）

BasicInfoBloc
MichiInfoBloc
PaymentInfoBloc
OverviewFeature（将来拡張・現実装スコープ外）

> **Note:** TCA版の `EventDetailCoreReducer` に相当する責務（Domain更新・Repository保存・Projection更新・Delegate通知）は `EventDetailBloc` が担う。

---

# Draft Model

EventDraft

Purpose

イベント編集状態を保持する。

EventDraft

eventId  
eventName  
eventDate  
members  
markLinks  
payments  

Draftは未確定データとして扱う。

---

# Domain Model

EventDomain

Purpose

イベントのビジネスロジックを保持する。

EventDomain

eventId  
eventName  
eventDate  
markLinks  
payments  

DomainはUIを知らない。

---

# Projection Model

EventDetailProjection

Purpose

EventDetail画面表示モデル

Structure

EventDetailProjection

basicInfo  
michiInfo  
paymentInfo  
overview  
visibleTabs  
visibleFields  

Projectionは表示専用。

---

# SubFeatures

EventDetailは以下のSubFeatureを持つ。

BasicInfoFeature

Purpose

イベント基本情報編集

---

MichiInfoFeature

Purpose

Mark / Link情報管理

---

PaymentInfoFeature

Purpose

支払情報管理

---

OverviewFeature

Purpose

イベント分析表示

Overviewのみ表示中心Feature

---

# EventDetailBloc の責務

EventDetailBloc

Purpose

EventDetailのUseCase処理を担当する。

Responsibilities

EventDomain更新
Repository保存（DI経由）
Projection更新
Delegate通知
SubFeatureからのDraft集約（保存時）

EventDetailBlocはUIを持たない。
RepositoryはDI（get_it）経由でコンストラクタ注入して使用する。

---

# Data Flow

Edit Flow

User Input
 ↓
View
 ↓
Draft
 ↓
DraftDomainAdapter
 ↓
Domain
 ↓
Repository

---

Display Flow

Repository
 ↓
Domain
 ↓
ProjectionAdapter
 ↓
Projection
 ↓
View

---

# Navigation

NavigationはRootが管理する。

EventDetailから発生するNavigation要求

openMarkDetail  
openLinkDetail  
openPaymentDetail  

NavigationはDelegate経由でRootへ通知する。

---

# Delegates

EventDetail → Root

saved  
dismiss  
selectionRequested  

EventDetail → ChildFeature

openMarkDetail  
openLinkDetail  
openPaymentDetail  

---

# Validation

Event編集時に以下を検証する。

eventName empty check

date validity check

validationはDraftまたはAdapterで実行する。

---

# Persistence

Repositoryが永続化を担当する。

EventRepository

saveEvent  
loadEvent  
deleteEvent  

EventDetailBlocはRepositoryをDI（get_it）経由で呼び出す。

WidgetからRepositoryを直接呼び出すことは禁止。

---

# Architecture Rules

Root

routing layer only

Rootは禁止

Draft編集  
Domain変更  
Repository呼び出し  

---

Feature

Draft所有  
Projection生成  
Delegate発火  

---

Projection

表示専用  

---

Domain

UIを知らない  

---

Repository

永続化担当  

---

# Future Extensions

以下の拡張を想定する。

Vehicle管理  
Analytics  
Team共有  

---

# Architecture Summary

EventDetailFeatureは

Aggregate Editing Feature

として設計される。

Responsibilities

SubFeature管理  
EventDomain更新  
Navigation要求  

---

# End of EventDetail Spec