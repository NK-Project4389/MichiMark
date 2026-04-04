# 進捗記録 2026-04-04 MichiInfoレイアウト変更

## 完了した作業

- CLAUDE.md に要件vsバグ判断ルール・push時自動進捗登録ルールを追加
- push時自動進捗登録hookスクリプト（`.claude/hooks/on_push.sh`）を作成・設定
- T-030: MichiInfo レイアウト変更 要件書作成（`docs/Requirements/REQ-michi_info_layout.md`）
- T-030: MichiInfo レイアウト変更 Spec作成（`docs/Spec/Features/MichiInfo_Layout_Spec.md`）
- T-031: MichiInfo レイアウト変更 実装（タイムライン型レイアウトに全面リニューアル）
  - `MarkLinkItemProjection` に `displayMeterDiff` フィールド追加
  - `EventDetailAdapter` でメーター差分計算
  - `MichiInfoBloc` でDraft適用後の差分再計算
  - `michi_info_view.dart` を `_TimelineItem` / `_TimelineConnector` / `_MarkCard` / `_LinkCard` / `_DistanceColumn` / `_DistanceLegend` に全面置き換え
- T-032: MichiInfo レイアウト変更 レビュー → 全項目パス・修正不要

## 未完了

- T-010〜T-012: Phase 2 動作確認（前セッションのIN_PROGRESSのまま）
- T-020: EventList Feature 実装
- T-021: イベント新規作成フロー実装

## 次回セッションで最初にやること

- 実機またはシミュレーターで MichiInfo の新レイアウトを動作確認する
- T-010〜T-012（Phase 2 動作確認）の状況を確認し、未完了であれば継続する
