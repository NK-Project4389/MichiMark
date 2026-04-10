# 2026-04-10 燃費更新機能 要件書作成

## 完了した作業

- T-120: 燃費更新機能 要件書作成（REQ-fuel_efficiency_update.md）
  - 概要タブで変更した燃費を交通手段マスターにも反映できる機能
  - 保存後に確認ダイアログ表示（「更新する」/「このイベントのみ」）
  - 表示条件：movingCostEstimated + 交通手段選択済み + 燃費値が変化した場合のみ

## 未完了・次回やること

### 最優先
- **T-121: 燃費更新機能 Spec作成**（architect）
  - 要件書: `docs/Requirements/REQ-fuel_efficiency_update.md`
  - BasicInfoBloc への確認ダイアログトリガー追加
  - TransRepository.save() の呼び出し方針

### その後
- T-122〜124: 実装 → レビュー → テスト
