# 2026-04-15 INV-2/INV-3 Spec作成・F-3 要件書+Spec作成・タスクボード整理

## 完了した作業

### INV-2: 招待Webページ Spec作成（T-330 DONE）
- `docs/Spec/Features/FS-invitation_web_page.md` 作成
- Next.js Server Component `/invite/[token]` ページ設計
- アプリ起動（カスタムURLスキーム）・2秒フォールバック・OGP・エラー3種
- テストシナリオ TC-INV2-001〜008
- **INV-1への追記依頼:** `GET /api/invitations/[token]` レスポンスに `code` フィールド追加が必要

### INV-3: 招待コード入力 Spec作成（T-335 DONE）
- `docs/Spec/Features/FS-invitation_code_input.md` 作成
- Flutter BLoC 2ステップフロー（コード入力 → member選択 → 参加確定）
- **INV-1 API追加必要:** `GET /api/invitations/code/[code]` 新規エンドポイント
- テストシナリオ TC-INV3-001〜010

### タスクボード整理
- POST-1（T-361〜365）と F-5（T-406〜410）を統合 → `POST-1/F-5` として T-361〜365 に集約
- INV-2/INV-3 ブロック解除 → T-331a/b・T-336a/b を TODO に変更

### F-3: 訪問作業トピック 要件書作成（T-401 DONE）
- `docs/Requirements/REQ-visit_work_topic.md` 作成
- トピック種別 `visitWork`・5アクション定義・状態遷移ロジック
- 時給換算（売上÷作業時間）を集計に含める
- Phase A（トピック本体）→ Phase B（MarkからPaymentDetail登録）の2段階

### F-3: 訪問作業トピック Spec作成（T-402 DONE）
- `docs/Spec/Features/FS-visit_work_topic.md` 作成
- 既存 `ActionState` / `AggregationResult` / `ActionTimeLog` / `PaymentInfo` を変更ゼロで流用
- 新規: `VisitWorkStateInterpreter` / `VisitWorkTimeline` / `VisitWorkAggregation` / `VisitWorkProgressBar`
- シードデータ: 到着/出発/作業開始/作業終了/休憩 の 5 アクション
- Unit テスト TC-VW-U001〜U006 / Integration テスト TC-VW-I001〜I008

### リモートスケジュール設定
- トリガーID: `trig_01RuYPZfAvJ7nS1q2qvXWGr6`
- 実行時刻: 4/16（水）2:10 JST
- 内容: flutter-dev 実装 → tester テストコード → Unit Test 実行 → reviewer → push

---

## 未完了

- T-331a/b: INV-2 実装・テストコード（TODO）
- T-336a/b: INV-3 実装・テストコード（TODO）
- T-403a/b/T-404: F-3 実装・テストコード・レビュー（リモート自動実行予定）
- T-405: F-3 Integration Test 実行（ローカル手動実行が必要）

---

## 次回セッションで最初にやること

1. **T-403c: リモート実行結果確認** — `git pull` → `git log` でコミット確認
2. コミットが入っていれば T-405 Integration Test を実行
   ```bash
   cd flutter && flutter test integration_test/visit_work_topic_test.dart -d DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6
   ```
3. 全件 PASS → T-405 DONE → push
4. 次の実装候補: INV-2（T-331a/b）または INV-3（T-336a/b）
