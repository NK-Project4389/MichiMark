# 進捗記録: T-269 B-6 Phase C Spec 作成完了

**日付**: 2026-04-12
**担当ロール**: architect

---

## 完了した作業

### T-269: B-6 ガソリン支払い者インラインチップ選択 Phase C Spec 作成

- Spec ファイル作成: `docs/Spec/Features/FS-gas_payer_chip_selection_phaseC.md`
- TASKBOARD 更新: T-269 → `DONE`、T-270a → `TODO`（着手可能）

### Spec 概要

**変更対象**:
- `mark_detail` Feature: Event/State/Bloc/View
- `link_detail` Feature: Event/State/Bloc/View

**変更方針**:
- `_SelectionRow`（InkWell + chevron_right → 別画面遷移）を廃止
- `_GasPayerChipSection`（FilterChip インライン選択）に置き換え
- `MarkDetailEditGasPayerPressed` / `MarkDetailGasPayerSelected` を削除
- `MarkDetailGasPayerChipToggled` を新規追加（single 選択ロジック）
- `MarkDetailOpenGasPayerSelectionDelegate` を削除
- LinkDetail も同様
- Draft / Domain / Adapter / Repository は変更なし

**Widget Key**:
- `Key('markDetail_chip_gasPayer_${member.id}')` — MarkDetail ガソリン支払者チップ
- `Key('linkDetail_chip_gasPayer_${member.id}')` — LinkDetail ガソリン支払者チップ
- `Key('markDetail_button_save')` — MarkDetail 保存ボタン（既存）
- `Key('linkDetail_button_save')` — LinkDetail 保存ボタン（既存）

**テストシナリオ**: TC-GPS-001〜008（実装済み: `gas_payer_chip_test.dart`）

---

## 未完了・次回やること

| タスク | 担当 | 状態 |
|---|---|---|
| T-270a: ガソリン支払者チップ選択 実装 | flutter-dev | `TODO`（着手可能） |
| T-271: レビュー | reviewer | `BLOCKED`（T-270a/b 完了後） |
| T-272: テスト実行 | tester | `BLOCKED`（T-271 承認後） |

**次回セッションで最初にやること**:
- flutter-dev として T-270a の実装を開始する
- 参照 Spec: `docs/Spec/Features/FS-gas_payer_chip_selection_phaseC.md`
