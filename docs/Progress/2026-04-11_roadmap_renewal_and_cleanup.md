# 2026-04-11 セッション進捗（ロードマップ再設計・整理）

## 完了した作業

### リポジトリ整理
- SwiftUI資材を全削除（197ファイル）：MichiMark/・MichiMark.xcodeproj・MichiMarkTests・MichiMarkUITests・MichiMark.xctestplan・testConpil.swift
- Flutter一本に絞ったクリーンな構成になった

### タスクボード整理
- 完了済み Phase 1〜13・アーカイブセクションを全削除
- Phase 14・15 のみ残した状態にスリム化

### Roadmap.md 再設計
- 完了済みPhase・陳腐化した実装状況セクションを削除
- Phase A〜E の5段階で再設計
  - Phase A: App Store 無料版リリース（バグ修正 + イベント削除まで）
  - Phase B: 期間集計機能
  - Phase C: サブスク実装 + ファーストキャッシュ
  - Phase D: マーケターAgent 本格稼働
  - Phase E: チームプラン・スケール
- ターゲットセグメント8種を定義（ツーリング・ロードバイク・ランニング・ドライブ・散歩・旅行・マーケット出店者・訪問介護）
- マーケターAgent の役割・アウトプット形式・サクセスストーリー8本の軸を定義

### タスク追加
- Phase 16: MichiInfo カード削除機能（T-150〜T-154）
- Phase 17: PaymentInfo カード削除機能（T-155〜T-159）

## 未完了・持ち越し

### Phase 15: バグ修正（IN_PROGRESS・コード変更済み・未コミット）
- T-140: B-1/B-2 BasicInfo 燃費/ガソリン単価 単位表示・即時反映修正
- T-141: B-3 MichiInfo 0件時 追加ボタン修正
- T-142: B-4 MichiInfo InsertMode時タイムライン座標ズレ修正
- T-143: レビュー（BLOCKED）
- T-144: テスト（BLOCKED）

### Phase 14: イベント削除機能
- T-131: Spec作成（TODO）
- T-132〜134: 実装・レビュー・テスト（BLOCKED）

## 次回最初にやること

1. `git pull`
2. `docs/Tasks/TASKBOARD.md` 確認
3. **Phase 15 バグ修正（B-1〜B-4）の続きから着手**
   - 変更済みファイルを確認して実装完了 → レビュー → テスト
4. Phase 14 イベント削除 Spec作成（T-131）へ
