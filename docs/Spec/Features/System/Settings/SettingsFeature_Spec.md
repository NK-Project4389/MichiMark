# Settings Feature Specification

Feature
SettingsFeature (SettingsReducer)

Category
System Feature

Purpose

MichiMarkのマスタデータを管理するFeature。

SettingsFeatureは以下のマスタを管理する。

Trans  
Tag  
Member  
Action  

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

# Settings Structure

SettingsFeatureは複数のマスタFeatureを管理する。

```
SettingsFeature
 ├ TransSettingFeature
 ├ TagSettingFeature
 ├ MemberSettingFeature
 └ ActionSettingFeature
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

# Reducer Structure

```
SettingsReducer
 │
 ├ TransSettingReducer
 ├ TagSettingReducer
 ├ MemberSettingReducer
 └ ActionSettingReducer
```

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
Reducer
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

Navigation管理  
Repository直接操作  

SettingsFeatureは

UI状態管理  
Domain更新  

のみ担当する。

---

# Future Extensions

以下の拡張を想定

アイコン設定

色設定

並び順管理

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

# End of Settings Feature Spec