# F-3 訪問作業トピック Integration Test 実行結果

## 日時
2026-04-16

## 概要
F-3「訪問作業トピック（visitWork）」のIntegration Testを実装・実行。
16件中15件PASS、1件FAIL（TC-VW-I004）。

---

## テスト実行結果

### Integration テスト: visit_work_topic_test.dart

| シナリオID | テスト名 | 結果 |
|---|---|---|
| TC-VW-I001 | visitWorkトピックでイベントを作成しMarkを追加できる | PASS |
| TC-VW-I001b | visitWorkトピックで作成したイベントにMarkを追加してミチタブに表示される | PASS |
| TC-VW-I002 | visitWorkトピックのMarkタップで到着アクションボタンが表示される | PASS |
| TC-VW-I002b | visitWorkトピックのMarkタップで出発アクションボタンが表示される | PASS |
| TC-VW-I002c | visitWorkトピックのMarkタップで作業開始アクションボタンが表示される | PASS |
| TC-VW-I002d | visitWorkトピックのMarkタップで作業終了アクションボタンが表示される | PASS |
| TC-VW-I002e | visitWorkトピックのMarkタップで休憩アクションボタンが表示される | PASS |
| TC-VW-I003 | 到着アクションを記録すると滞在状態バッジが表示される | PASS |
| TC-VW-I004 | 作業開始→休憩→作業終了の順でアクション記録後、集計タブにプログレスバーが表示される | FAIL |
| TC-VW-I005 | 集計タブに移動（移動）の時間サマリーラベルが表示される | PASS |
| TC-VW-I005b | 集計タブに滞在の時間サマリーラベルが表示される | PASS |
| TC-VW-I005c | 集計タブに作業の時間サマリーラベルが表示される | PASS |
| TC-VW-I005d | 集計タブに休憩の時間サマリーラベルが表示される | PASS |
| TC-VW-I006 | visitWorkトピックの集計タブに売上セクションが表示される | PASS |
| TC-VW-I006b | PaymentInfo未登録のとき売上合計欄に---が表示される | PASS |
| TC-VW-I007 | visitWorkトピックのミチタブにリンク追加ボタンが表示されない | PASS |
| TC-VW-I008 | visitWorkトピックのMarkDetailにメンバー選択が表示されない | PASS |

ログ: docs/TestLogs/2026-04-16_01-34_visit_work_topic.log

---

## テストコード修正一覧（tester自身が修正した内容）

1. **Podfile修正**: iOS platform を `15.0` に設定（cloud_firestoreの最小要件）
2. **`tapMarkCardToOpenActionSheet`**: キー名を `michiInfo_card` → `mark_action_button` に修正
3. **`addMarkAndOpenActionSheet`**: visitWorkは `addMenuItems` が1件のみのためFABタップで直接MarkDetailに遷移する流れに修正
4. **`openVisitWorkEventMichiTab`**: 毎テストでイベントとMarkを作成する独立したフローに変更（既存イベント依存を廃止）
5. **`goToAggregationTab`**: 「集計」タブ（存在しない）→「概要」タブ（visitWork集計はここに表示）に修正
6. **TC-VW-I003の状態バッジキー**: `michiInfo_badge_actionState` → `mark_action_state_badge` に修正
7. **TC-VW-I003のアクション待機**: ActionTimeNavigateBackDelegateで自動クローズする実装に合わせたフローに修正
8. **前方参照修正**: `saveMark` の呼び出しをインライン展開（Dartクロージャの前方参照エラー解消）

---

## TC-VW-I004 失敗詳細（flutter-devへの引き継ぎ）

- **テスト名**: 作業開始→休憩→作業終了の順でアクション記録後、集計タブにプログレスバーが表示される
- **操作**: visitWorkイベント作成 → Mark追加 → ⚡ボタンタップ → 4つのアクション（到着→作業開始→休憩→作業終了）を順に記録 → 概要タブに移動
- **期待結果**: `visit_work_progress_bar` ウィジェットが表示されること
- **実際の結果**: `visit_work_progress_bar` が見つからない（0件）
- **根本原因（推定）**: ActionTime記録後に `EventDetailBloc.cachedEvent` が更新されない。概要タブに遷移したときに `OverviewStarted(event: cachedEvent)` が発火するが、この `cachedEvent` にはActionTimeLogs が含まれていない古いデータが渡される。`MichiInfoReloadedDelegate` や `EventDetailCachedEventUpdateRequested` がActionTime記録後には発火しないため、`cachedEvent` のactionTimeLogs が空のまま集計が実行されてしまう。
- **確認済みの実装コードの流れ**:
  - ActionTimeBloc: `ActionTimeLogRecorded` → DBに保存 → `ActionTimeNavigateBackDelegate` 発火 → ボトムシートが自動で閉じる
  - MichiInfoBloc: `MichiInfoActionStateLabelUpdated` → `markActionStateLabels` を更新するのみ（`MichiInfoReloadedDelegate` は発火しない）
  - EventDetailPage: `MichiInfoReloadedDelegate` が発火したときのみ `EventDetailCachedEventUpdateRequested` を発火して `cachedEvent` を更新する
  - したがってActionTime記録後は `cachedEvent` のactionTimeLogsが更新されない

---

## 環境修正内容（ビルド環境）

- `flutter/ios/Podfile`: `platform :ios, '15.0'` を有効化（INFRA-1でcloud_firestoreを追加したが最小iOS要件が13.0→15.0に上がったため）

---

## 次回セッションでやること

- **flutter-dev**: TC-VW-I004の失敗原因を修正する
  - ActionTime記録後に `cachedEvent` を更新するフローを追加する
  - または概要タブ表示時に最新のeventDomain（actionTimeLogs含む）を再取得する
- **tester**: flutter-devの修正後にTC-VW-I004を再実行する
