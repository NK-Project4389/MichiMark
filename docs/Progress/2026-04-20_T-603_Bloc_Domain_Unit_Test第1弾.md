# T-603: Bloc/Domain Unit Test追加（第1弾）

## 完了日
2026-04-20

## 実装内容

### 1. PaymentBalanceSectionAdapter Unit Test実装
**ファイル:** `flutter/test/adapter/payment_balance_section_adapter_test.dart`

Adapterロジックを10ケースで検証：
- TC-001: revenue種別のみの場合の合計計算
- TC-002: expense種別のみの場合の合計計算
- TC-003: revenue・expense混在時の収支合計計算
- TC-004: paymentMemoのフォールバック表示（「支払 #N」）
- TC-005: 論理削除済みデータの除外
- TC-006: 空リスト入力時のhasItems制御
- TC-007: 収支合計がマイナスの場合のフラグ制御
- TC-008: displayAmountの符号付きフォーマット確認
- TC-009: paymentIdの正確な保持
- TC-010: 大量データ（100件）での計算正確性

**結果:** 全10テスト PASS ✅

### 2. BasicInfoBloc Unit Test実装
**ファイル:** `flutter/test/bloc/basic_info_bloc_test.dart`

BlocTestを使用してイベントハンドラのState変換を10ケースで検証：
- TC-001: BasicInfoTransChipToggled - 別Transタップで変更
- TC-002: BasicInfoTransChipToggled - 同一Transタップでnullに（トグルOFF）
- TC-003: movingCostEstimatedモード時のTrans変更でkmPerGasInput自動反映
- TC-004: movingCostEstimated以外ではkmPerGasInput不変
- TC-005: BasicInfoMemberRemoved - 削除メンバーがpayMemberと同一でpayMemberもクリア
- TC-006: BasicInfoMemberRemoved - 削除メンバーがpayMemberと別でpayMember不変
- TC-007: BasicInfoPayMemberChipToggled - 別Memberタップで変更
- TC-008: BasicInfoPayMemberChipToggled - 同一Memberタップでnullに（トグルOFF）
- TC-009: BasicInfoEditCancelled - originalDraftある場合は復元
- TC-010: BasicInfoEditCancelled - originalDraftない場合はisEditing=false

**結果:** 全10テスト PASS ✅

### 3. 依存パッケージ追加
**ファイル:** `flutter/pubspec.yaml`

```yaml
dev_dependencies:
  # Bloc テスト
  bloc_test: ^10.0.0
  # mocktailも自動インストール（bloc_testの依存関係）
```

## テスト実行結果

```
$ flutter test test/adapter/ test/bloc/
00:00 +20: All tests passed!
```

- PaymentBalanceSectionAdapter: 10 PASS
- BasicInfoBloc: 10 PASS
- **合計: 20 PASS**

## チェックリスト

- [x] Unit Testコード実装（Specシナリオに基づく）
- [x] 正常系・異常系・境界値を網羅
- [x] テスト内でfixture生成（シードデータ依存なし）
- [x] 1testブロック＝1expect
- [x] テスト名にシナリオID（TC-XXX）を含める
- [x] Mock使用（Adapterはなし、Blocはrepository mock）
- [x] Integration Test依存なし（GetIt・drift実DB・GoRouter不使用）
- [x] flutter test で全件PASS確認
- [x] pubspec.yaml に bloc_test 追加

## 次回セッションでやること

- reviewer による本テストコードの整合性確認（シードデータハードコード確認）
- テスト実行承認後の結果報告・進捗更新・push

## ファイル一覧

| ファイル | 役割 |
|---|---|
| `flutter/test/adapter/payment_balance_section_adapter_test.dart` | PaymentBalanceSectionAdapter Unit Test（10テスト） |
| `flutter/test/bloc/basic_info_bloc_test.dart` | BasicInfoBloc Unit Test（10テスト） |
| `flutter/pubspec.yaml` | bloc_test ^10.0.0 追加 |
