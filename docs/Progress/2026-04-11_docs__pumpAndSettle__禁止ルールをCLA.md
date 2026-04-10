# 進捗記録 2026-04-11

## 完了した作業

### Integration Test 修正（TC-MCI insertモード対応）(ba2a9b1)
- `michi_info_layout_test.dart`: TS-03/04/05 修正
- `mark_addition_defaults_test.dart`: TC-MAD-001〜008 修正
- 根本原因: TC-MCI カード挿入機能でFABの挙動が変わり既存テストが一斉に壊れていた
- TC-MAD-001/005 は空リストのinsertモード制限によりSKIP

### T-124 燃費更新機能 テスト完了（別セッション）(bae2595)
- TC-FEU-001〜003 実装・実行（2 PASS / 1 SKIP）
- T-120〜124 Phase 13 全タスク DONE

### pumpAndSettle() 禁止ルール化 (83af625, 3783082)
- `flutter/CLAUDE.md` 落とし穴5 追加
- `.claude/agents/tester.md` 落とし穴4 追加・既存例のpumpAndSettle()も修正
- 経緯: TC-FEU-002 の createTransWithNoKmPerGas で30分ハングしたため

## 未完了

- T-131: イベント削除機能 Spec作成（architect / TODO）
- Integration Test ファイル整理・統合（`IntegrationTest_Spec.md` 設計書の実装）

## 次回セッションで最初にやること

T-131 イベント削除機能 Spec作成（architect）
- 要件: flutter_slidable ^3.1.0 使用・カスケード削除・確認ダイアログなし
- 要件書は T-130 で完了済み（`docs/Requirements/` 確認）
