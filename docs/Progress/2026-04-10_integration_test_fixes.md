# 進捗: 2026-04-10 Integration Test 修正（TS-03/04/05・TC-MAD-001〜008）

**日付**: 2026-04-10

---

## 完了した作業

### Integration Test 修正（TC-MCI カード挿入機能による既存テスト壊れ対応）

TC-MCI カード挿入機能（T-101〜103）の実装でFABの挙動が変わり、既存テストが一斉に壊れていた問題を修正。

#### michi_info_layout_test.dart

| テスト | 修正内容 |
|---|---|
| TS-03 | `ensureVisible` 追加・pump待機条件を `'保存'/'累積メーター'` に変更（`'地点詳細'/'名称（任意）'` は既存マークでは表示されない）|
| TS-04 | `ensureVisible` 追加・pump待機条件を `'保存'/'給油'` に変更 |
| TS-05 | FABのダイレクトBottomSheet → 新insertモードフロー（FAB → `Icons.add_circle_outline` → "地点を追加"）に全面書き換え |

#### mark_addition_defaults_test.dart

| テスト | 修正内容 |
|---|---|
| TC-MAD-001 | `openAddMarkDetail` が空リスト判定で false 返却 → `markTestSkipped` （空リストはinsertモードにインジケーターが出ない。仕様レベルの制限）|
| TC-MAD-002 | ラベル `'累積メーター (km)'` → `'累積メーター'`、値 `'45340'` → `'45,340'`（NumericInputRow のカンマ整形を考慮） |
| TC-MAD-003 | `openAddMarkDetail` ヘルパー更新で自動修正 |
| TC-MAD-004 | 同上 |
| TC-MAD-005 | TC-MAD-001 同様、空リスト → `markTestSkipped` |
| TC-MAD-006 | メンバー選択UI: `IconButton` → `InkWell` に変更（`_SelectionRow` は `InkWell` を使用） |
| TC-MAD-007 | 完全書き換え。前提誤り修正: Trans.meterValueはEventDetail保存では更新されない。MarkDetail保存時のみ更新（`mark_detail_bloc.dart`）。フロー: MichiInfoタブ→'大涌谷'タップ→MarkDetail→保存→Settings→Trans確認 |
| TC-MAD-008 | pump待機条件を `'保存'/'累積メーター'` に変更、値をカンマ整形済み文字列に修正 |

#### `openAddMarkDetail` ヘルパー 書き換え内容（核心）

```
旧: FAB → BottomSheet直接表示
新: FAB → insertモード切替 → Icons.add_circle_outline インジケーター表示
    → indicators.last タップ → BottomSheet → '地点を追加' タップ → MarkDetail
```

### 根本原因まとめ

| 原因 | 影響テスト |
|---|---|
| TC-MCI insertモード実装でFABのダイレクトBottomSheet動作が廃止 | TC-MAD 全8件・TS-05 |
| `NumericInputRow` がカンマ整形した値を表示（`'45,340'` not `'45340'`）| TC-MAD-002/008 |
| MarkDetail AppBarタイトル: 既存マークは名前を表示（`'地点詳細'` は空名前のみ）| TS-03/04 |
| Trans.meterValue 更新は `mark_detail_bloc.dart` のみ（EventDetail保存では更新されない） | TC-MAD-007 |

### テスト結果

**michi_info_layout_test.dart**: TS-01〜06 PASS、TS-07 SKIP、TS-08 PASS、TS-09 SKIP、TS-10〜16 PASS

**mark_addition_defaults_test.dart**: TC-MAD-001 SKIP、TC-MAD-002〜004 PASS、TC-MAD-005 SKIP、TC-MAD-006〜008 PASS

---

## 未完了・次回やること

1. **T-124（燃費更新機能 テスト）** — `IN_PROGRESS` のまま。`basic_info_bloc.dart`（REQ-FEU-003）の変更がコミット未。TC-BAS相当のテスト実行が必要
2. **T-131（イベント削除機能 Spec作成）** — `TODO`。T-130要件書は完了済み
3. **IntegrationTest_Spec.md 実装**（既存テストファイルの整理・統合）— 設計書は完成済み。廃止ファイルの削除・統合はまだ
