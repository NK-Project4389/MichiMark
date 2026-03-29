# FuelDetail Feature Specification

Feature
FuelDetailFeature (FuelDetailBloc)

Parent Feature
MarkDetailFeature / LinkDetailFeature（インライン埋め込み）

Purpose

給油情報（ガソリン単価・給油量・合計金額）の入力補助と自動計算を行うFeature。

FuelDetailは独自のDomainを持たない計算補助Featureであり、
MarkDetail / LinkDetail 画面内にインラインで組み込まれる。
別画面へのナビゲーションは行わない。

---

# Responsibilities

FuelDetailFeatureは以下を担当する。

1 ガソリン単価・給油量・合計金額の入力状態管理
2 CalculateTapped時の自動計算実行
3 ClearTapped時の全フィールドリセット
4 フィールド変更・計算結果をDelegateで親Featureへ通知

FuelDetailFeatureは禁止

- Navigation管理
- Repositoryアクセス
- Domain永続化
- isFuelフラグの管理（親Featureが担当）

---

# Domain Model

FuelDetailFeatureはDomainを持たない。

参照先Domain: MarkLinkDomain（親Feature経由）

fuel関連フィールド（参照のみ）

isFuel（親Featureが管理）
pricePerGas: int?（単位：円/L）
gasQuantity: int?（単位：0.1L、永続値は10倍。例：300 = 30.0L）
gasPrice: int?（単位：円）

---

# Draft Model

FuelDetailDraft

Purpose

FuelDetail画面の入力状態

fields

| フィールド | Dart型 | 初期値 | 備考 |
|---|---|---|---|
| `pricePerGas` | `String` | `""` | ガソリン単価（入力文字列） |
| `gasQuantity` | `String` | `""` | 給油量（入力文字列。UI/Draft: Lを表すdouble文字列。例："30.0"） |
| `gasPrice` | `String` | `""` | 合計金額（入力文字列） |

型変換ルール

| フィールド | Draft値 | Domain値 | 変換 |
|---|---|---|---|
| `gasQuantity` | `String`（例: "30.0"） | `int`（例: 300） | Draft→Domain: `×10` → `int`変換。Domain→Draft: `/10` → `toStringAsFixed(1)` |
| `pricePerGas` | `String`（例: "150"） | `int`（例: 150） | 整数変換 |
| `gasPrice` | `String`（例: "4500"） | `int`（例: 4500） | 整数変換 |

Draftは未確定状態として扱う。

---

# Projection Model

FuelDetailFeatureはProjectionを持たない。

Domainが存在しないため、ProjectionAdapterも不要。
初期値は親FeatureのDraftから `Started` イベント経由で受け取る。

---

# Calculation Logic

## 計算実行条件

以下をすべて満たすときのみ計算を実行する。

1. `pricePerGas` が非空かつ `int` に変換可能
2. `gasQuantity` / `gasPrice` のうち **ちょうど1つが空**

## 計算方向

| 入力済み2値 | 計算対象 | 計算式 |
|---|---|---|
| 単価 + 給油量 | 合計 | `gasPrice = pricePerGas × gasQuantity`（整数） |
| 単価 + 合計 | 給油量 | `gasQuantity = gasPrice ÷ pricePerGas`（小数点1桁） |

単価（pricePerGas）は計算の対象外。常にユーザー入力。

## 計算不実行の条件

- 単価が空または非数値
- gasQuantity・gasPriceがともに入力済み
- gasQuantity・gasPriceがともに空

上記の場合、CalculateTappedを受け取っても状態を変更しない。

---

# BLoC Events

FuelDetailEvent（sealed class）

Started({required String pricePerGas, required String gasQuantity, required String gasPrice})
- 画面表示・初期値設定（親FeatureのDraftから値を受け取る）

PricePerGasChanged(String value)
- 単価フィールド変更

GasQuantityChanged(String value)
- 給油量フィールド変更

GasPriceChanged(String value)
- 合計金額フィールド変更

CalculateTapped
- 計算実行。条件を満たさない場合は何もしない

ClearTapped
- 全フィールドを空文字にリセット

---

> **Note:** Delegateは `FuelDetailState` のフィールドとして保持する（Eventではない）。

---

# Delegate Contract

FuelDetailDelegate（sealed class）→ Stateのフィールドとして保持

FuelDraftChanged(FuelDetailDraft draft)
- 発火タイミング: 各フィールド変更後・Calculate成功後・Clear後
- 目的: 親Feature（MarkDetailBloc / LinkDetailBloc）のDraftを常に最新の入力値に同期する

## 親Featureとの連携パターン

```
FuelDetailWidget（BlocListener）
  ↓ FuelDraftChanged(draft)
MarkDetailBloc.add(FuelFieldsChanged(pricePerGas, gasQuantity, gasPrice))
  ↓
MarkDetailDraft更新
```

- FuelDetailWidgetは `BlocListener<FuelDetailBloc, FuelDetailState>` でDelegateを監視する
- Delegateを受け取ったとき、親BlocのFuelFieldsChangedイベントを発火する
- FuelDetailBloc自身はNavigation・親Bloc参照を行わない

---

# Architecture Rules

FuelDetailFeatureは禁止

- Repositoryアクセス・Domain永続化
- Navigation操作（context.go / context.push）
- isFuelフラグの直接変更
- 親Bloc（MarkDetailBloc / LinkDetailBloc）への直接参照

FuelDetailFeatureは

- Draft管理（入力状態）
- 計算ロジック実行
- Delegate通知

のみ担当する。

---

# State Structure

```dart
class FuelDetailState extends Equatable {
  final FuelDetailDraft draft;
  final FuelDetailDelegate? delegate;

  const FuelDetailState({
    required this.draft,
    this.delegate,
  });

  @override
  List<Object?> get props => [draft, delegate];
}
```

---

# Data Flow

## 初期化フロー

```
親FeatureDraft（pricePerGas / gasQuantity / gasPrice）
  ↓ Started event
FuelDetailBloc
  ↓
FuelDetailDraft（初期値設定）
```

## 編集・計算フロー

```
User Input
  ↓
FuelDetailEvent（PricePerGasChanged / CalculateTapped / etc.）
  ↓
FuelDetailDraft更新
  ↓
FuelDraftChanged(draft) Delegate
  ↓
MarkDetailWidget BlocListener
  ↓
MarkDetailBloc.add(FuelFieldsChanged(...))
  ↓
MarkDetailDraft更新
```

---

# Integration Notes

## MarkDetail Spec との整合性

- MarkDetailDraftはすでにfuel fields（isFuel, pricePerGas, gasQuantity, gasPrice）を持つ
- MarkDetailEventに `FuelFieldsChanged(String pricePerGas, String gasQuantity, String gasPrice)` を追加すること
  - 既存の `FuelChanged(bool isFuel, ...)` はisFuelトグルと分離することを推奨
  - MarkDetail Spec側の更新が必要（architectが対応）

## LinkDetail Spec との整合性

- 現在のLinkDetailDraftにfuel fieldsが存在しない
- LinkDetailDraftに以下を追加すること: `isFuel`, `pricePerGas`, `gasQuantity`, `gasPrice`
- LinkDetail Spec側の更新が必要（architectが対応）

---

# SwiftUI版との対応

| Flutter Feature | 対応SwiftUI Reducer |
|---|---|
| `fuel_detail` | `FuelDetailReducer`（FuelDetailReducer.swift） |

## SwiftUI版からの変更点

| 項目 | SwiftUI版 | Flutter版 |
|---|---|---|
| 計算方向 | 単価+給油量→合計 / 単価+合計→給油量（単価必須） | 同じ（単価は計算対象外） |
| 配置 | MarkDetail内にネスト | インライン埋め込み（FuelDetailBlocとして独立） |
| 通信方式 | State直接参照（TCA） | Delegate経由（BLoC） |
| gasQuantity型 | String（UI） | String（Draft）/ double（中間）/ int×10（Domain） |

---

# Future Extensions

以下の拡張を想定

燃費計算（走行距離との組み合わせ）
給油履歴サマリー
単位切り替え（L / ガロン）

---

# Architecture Summary

FuelDetailFeatureは

Draft管理 + 計算ロジック

のみを担当する計算補助Featureである。

Domainを持たず、永続化はMarkDetail / LinkDetail経由で行う。
Delegateで親FeatureのDraftを同期し、保存責務は親Featureに委譲する。

---

# End of FuelDetail Feature Spec
