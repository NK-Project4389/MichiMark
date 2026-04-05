# Settings Feature Specification

Feature
SettingsFeature (SettingsBloc)

Category
System Feature

Version: 2.0

## 改版履歴

| バージョン | 日付 | 変更概要 |
|---|---|---|
| 1.0 | 初版 | Settings Feature 初期設計 |
| 2.0 | 2026-04-05 | REQ-003・006対応。ActionSetting行非表示・イベント一覧へ戻るボタン追加 |

Purpose

MichiMarkのマスタデータを管理するFeature。

SettingsFeatureは以下のマスタを管理する。

Trans
Tag
Member
Action（導線は一時非表示・REQ-003）

---

# Responsibilities

SettingsFeatureは以下を担当する。

1 マスタ一覧表示
2 マスタ追加
3 マスタ編集
4 マスタ削除

SettingsFeatureは禁止

Repositoryアクセス  
Navigation管理  

---

# Settings Structure（v2.0）

SettingsFeatureは複数のマスタFeatureを管理する。

```
SettingsFeature
 ├ TransSettingFeature（TransSettingBloc）
 ├ TagSettingFeature（TagSettingBloc）
 ├ MemberSettingFeature（MemberSettingBloc）
 └ ActionSettingFeature（ActionSettingBloc）[UI導線のみ非表示 / REQ-003]
```

---

# Master Definitions

## Trans

交通手段

Example

Car  
Train  
Walk

---

## Tag

イベント分類

Example

Business  
Travel  
Family

---

## Member

イベント参加者

Example

Self  
Colleague  
Family

---

## Action

行動イベント

Example

Arrival  
Departure  
Fuel  

Actionは name のみを持つ。

---

# Master Domain Model

すべてのマスタは共通構造を持つ。

fields

id

name

isDeleted

---

# Projection Structure

各マスタはProjectionを持つ。

```
TransProjection
TagProjection
MemberProjection
ActionProjection
```

Projectionは表示専用。

---

# Projection Adapter

Domain → Projection変換を担当する。

```
TransProjectionAdapter
TagProjectionAdapter
MemberProjectionAdapter
ActionProjectionAdapter
```

Responsibilities

表示用name生成  
削除状態反映  

---

# Bloc Structure（v2.0）

```
SettingsBloc
 │
 ├ TransSettingBloc
 ├ TagSettingBloc
 ├ MemberSettingBloc
 └ ActionSettingBloc  ← Bloc・Route維持。SettingsPageからの導線のみ非表示（REQ-003）
```

## SettingsBloc 設計（v2.0 / REQ-006対応）

### SettingsBloc 追加Event

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `SettingsNavigateToEventsRequested` | 「イベント一覧へ戻る」ボタンタップ時 | EventList画面（`/events`）への遷移Delegateを発火する |

### SettingsState 追加フィールド

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `delegate` | `SettingsDelegate?` | 遷移意図の通知（REQ-006） |

### Delegate Contract（REQ-006）

| Delegate名 | 遷移先 | 説明 |
|---|---|---|
| `SettingsNavigateToEventsDelegate` | `/events` | BlocListenerが `context.go('/events')` を呼び出す |

> **[設計方針]** BLoC内・Widget内で `context.go()` を直接呼び出すことは禁止。SettingsBlocがDelegateをStateに乗せ、SettingsPageのBlocListenerが `context.go('/events')` で遷移する。

### 影響するクラス・ファイル（REQ-006）

| ファイル | 変更内容 |
|---|---|
| `features/settings/view/settings_page.dart` | AppBarまたはボトムに「イベント一覧へ戻る」ボタン追加・BlocListenerで `SettingsNavigateToEventsDelegate` を受け取り `context.go('/events')` を呼び出す |
| SettingsBlocファイル（新規または既存拡張） | `SettingsNavigateToEventsRequested` Event処理・`SettingsNavigateToEventsDelegate` Delegate発火 |
| SettingsStateファイル（新規または既存拡張） | `delegate: SettingsDelegate?` フィールド追加 |

---

# UI Interaction Flow

## Master List

User opens Settings
 ↓
SettingsFeature表示
 ↓
各マスタ一覧表示

---

## Add Master

User taps add
 ↓
name入力
 ↓
save
 ↓
Domain更新

---

## Edit Master

User selects item
 ↓
name編集
 ↓
save
 ↓
Domain更新

---

## Delete Master

User taps delete
 ↓
isDeleted = true

物理削除は行わない。

---

# Data Flow

Display

```
Domain
 ↓
ProjectionAdapter
 ↓
Projection
 ↓
View
```

Edit

```
User
 ↓
SettingsBloc（Event）
 ↓
Repository（DI経由）
 ↓
Domain更新
```

---

# Selection Integration

SettingsのマスタはSelectionFeatureで使用される。

```
Settings
 ├ Trans
 ├ Tag
 ├ Member
 └ Action
        ↓
SelectionFeature
```

SelectionFeatureはマスタの選択UIを提供する。

---

# Architecture Rules

SettingsFeatureは禁止

Navigation管理（go_routerはBlocListener経由）
WidgetからのRepository直接呼び出し

SettingsFeatureは

UI状態管理
Domain更新（Bloc経由・DI注入されたRepositoryを使用）

のみ担当する。

> **Note:** SettingsBlocはマスタデータ管理のためRepositoryを呼び出す。
> RepositoryはDI（get_it）経由でコンストラクタ注入して使用すること。

---

# Future Extensions

以下の拡張を想定

アイコン設定

色設定

並び順管理

ActionSetting画面の再公開（REQ-003は一時非表示のため）

---

# Architecture Summary

SettingsFeatureは

マスタデータ管理Featureである。

マスタは

Trans
Tag
Member
Action

の4種類を管理する。

---

# 受け入れ条件（v2.0）

## REQ-003 対応

- [ ] SettingsPageに「行動」の行が表示されないこと
- [ ] ActionSetting画面へのRouterおよびBlocのコードが削除されていないこと（実装維持）
- [ ] ActionSeedData（出発・到着）がアプリ起動時に自動投入されること

## REQ-006 対応

- [ ] SettingsPageに「イベント一覧へ戻る」ボタン（またはリンク）が表示されること
- [ ] ボタンタップでイベント一覧画面（`/events`）に遷移すること
- [ ] SettingsBloc内・SettingsPage Widget内で `context.go()` を直接呼び出していないこと（Delegate経由）

---

# End of Settings Feature Spec