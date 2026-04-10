# Feature Spec: 燃費更新機能

- **Spec ID**: FuelEfficiencyUpdate_Spec
- **要件ID**: REQ-fuel_efficiency_update
- **作成日**: 2026-04-10
- **担当**: architect
- **ステータス**: 確定

---

## 1. 概要

`movingCostEstimated` イベントの概要タブで交通手段を選択したとき、
選択した交通手段マスターの `kmPerGas` を概要タブの燃費入力欄（`kmPerGasInput`）に自動反映する。

**既存実装の状態**：`BasicInfoBloc._onTransSelected` にほぼ実装済み。以下の2点のみ修正が必要。

---

## 2. 変更対象

### ファイル: `flutter/lib/features/basic_info/bloc/basic_info_bloc.dart`

#### 変更箇所: `_onTransSelected` ハンドラー

**変更前（現状）**:
```dart
final kmPerGas = event.trans?.kmPerGas;
final newKmPerGasInput = kmPerGas != null
    ? (kmPerGas / 10.0).toString()
    : current.draft.kmPerGasInput;
emit(current.copyWith(
  draft: current.draft.copyWith(
    selectedTrans: event.trans,
    kmPerGasInput: newKmPerGasInput,
  ),
```

**変更後**:
```dart
final kmPerGas = event.trans?.kmPerGas;
final isEstimatedMode = current.draft.selectedTopic?.topicType == TopicType.movingCostEstimated;
final newKmPerGasInput = (kmPerGas != null && isEstimatedMode)
    ? (kmPerGas / 10.0).toStringAsFixed(1)
    : current.draft.kmPerGasInput;
emit(current.copyWith(
  draft: current.draft.copyWith(
    selectedTrans: event.trans,
    kmPerGasInput: newKmPerGasInput,
  ),
```

#### 変更点の説明

| 変更 | 理由 |
|---|---|
| `(kmPerGas / 10.0).toString()` → `.toStringAsFixed(1)` | 浮動小数点誤差（例: `15.299999...`）を防ぐ |
| `isEstimatedMode` チェックを追加 | REQ-FEU-003: `movingCostEstimated` のみ反映する |

---

## 3. 変更なしファイル

- `basic_info_event.dart`: 変更なし（`BasicInfoTransSelected` は既存）
- `basic_info_state.dart`: 変更なし
- `basic_info_draft.dart`: 変更なし（`kmPerGasInput` は既存フィールド）
- View 層: 変更なし

---

## 4. テストシナリオ

| ID | シナリオ | 確認内容 |
|---|---|---|
| TC-FEU-001 | `movingCostEstimated` イベントの概要タブで、`kmPerGas` が設定済みの交通手段を選択する | 燃費入力欄に `kmPerGas` の変換値（例: 155 → "15.5"）が表示される |
| TC-FEU-002 | `movingCostEstimated` イベントの概要タブで、`kmPerGas` が null の交通手段を選択する | 燃費入力欄の値が変化しない |
| TC-FEU-003 | `movingCostEstimated` イベントで交通手段を選択後、燃費入力欄を手動変更する | 手動変更が反映される（上書き後も編集可能） |

---

## 5. 備考

- `kmPerGas = 153` → `(153 / 10.0).toStringAsFixed(1)` = `"15.3"`（修正前は `"15.299999999999999"` になる恐れがあった）
- `movingCost`（給油実績モード）では `showKmPerGas = false` のため燃費欄は非表示だが、本Spec の `isEstimatedMode` チェックにより Draft への影響もなくなる
