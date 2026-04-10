# 進捗記録 2026-04-11

## 完了した作業
- docs: Phase16/17タスク追加・進捗登録（MichiInfo/PaymentInfoカード削除・ロードマップ再設計） (d3f1b5e)
- docs: Roadmap再設計（Phase A〜E・ターゲット8セグメント・マーケターAgent定義） (a51205a)
- chore: Roadmap.md の完了済みPhase・実装状況を削除（再設計前の整理） (4273b7f)
- chore: タスクボードの完了済みPhaseを削除（Phase 1〜13・アーカイブ） (79414ce)
- chore: SwiftUI資材を削除（Flutter移植完了のため不要） (95e2ccc)
- docs: Phase15（B-1〜B-4 バグ修正）をタスクボードに追加 (94d0f09)
- docs: 2026-04-11セッション進捗更新（Integration Test修正・pumpAndSettle禁止ルール追加） (4335635)

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
