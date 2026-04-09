# 進捗: 2026-04-09 セッション（TestFlight アップロード）

**日付**: 2026-04-09

---

## 完了した作業
- test: PaymentInfo FABカラー変更 Integration Test 追加（TC-PIF-001〜002 全件PASS） (9f88b46)
- docs: 2026-04-09セッション進捗登録（MichiInfo追加ボタン改善・集計整理・TF1.0.0(5)） (e9b6ef4)
- docs: TestFlight 1.0.0(5) アップロード完了・flutter test integration_test を自動許可設定 (562e87a)
- feat: MichiInfo追加FABカラー・addMenuItems配列制御・集計時間セクション削除・シードデータ修正 (6e95a2b)
- test: MichiInfo追加ボタン改善・集計ページ整理 Integration Test 追加（TC-MAB-001〜003 全件PASS） (fa597aa)
- docs: TestFlight 1.0.0(4) アップロード完了（90087対策: arm64バイナリ差し替え） (0c183ca)
- docs: 2026-04-09 UI修正・共通化セッション進捗記録 (aa10341)
- docs: TestFlight アップロード進捗記録追加 (3ee3ce9)

### 1. TestFlight アップロード（ビルド 1.0.0 (3)）

- `flutter build ios --release` → ビルド成功
- `flutter build ipa` 経由でアーカイブ作成
- **エラー 91169**: `objective_c.framework` の arm64 スライスが `IOSSIMULATOR` プラットフォームとしてマークされていた
  - `vtool -set-build-version ios 13.0 13.0 -replace` で修正 → `codesign` で再署名
- **エラー 90208**: minos を `14.0` で設定したためアプリの最小OS（13.0）と不一致
  - minos を `13.0` に修正して再アップロード → `Upload succeeded` 確認

### 2. Podfile にシミュレータースライス除去フックを追加 (871018e / 673643a)

- `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64`（Release ビルドでシミュレーター arm64 を除外）
- ビルドフェーズスクリプト `[MichiMark] Strip Simulator Slices` 追加
  - 全フレームワークを走査し IOSSIMULATOR タグを検出したら `vtool` で iOS に書き換え → `codesign` で再署名
  - minos は `13.0`（アプリの最小 OS バージョンに合わせる）
- `pod install` 適用済み

---

### 3. TestFlight アップロード（ビルド 1.0.0 (4)）

- `flutter build ios --release` → ビルド成功
- `xcodebuild archive` → アーカイブ成功
- **エラー 90087/90086/90203**: `objective_c.framework` が x86_64 のみ（シミュレーター用バイナリがリリースビルドに混入）
  - 前回アーカイブ（2026-04-08）の arm64 版 `objective_c` バイナリをコピーして上書き
  - `xcodebuild -exportArchive` 再実行 → `Upload succeeded` 確認
- dSYM warning は動作に影響なし

### 4. TestFlight アップロード（ビルド 1.0.0 (5)）

- 含む変更: MichiInfo追加FABカラー・addMenuItems配列制御・集計時間セクション削除・シードデータ修正
- `flutter build ios --release` → ビルド成功
- `xcodebuild archive` → アーカイブ成功
- `objective_c.framework` を arm64 版に差し替え → `Upload succeeded` 確認

### 6. TestFlight アップロード（ビルド 1.0.0 (6)）

- 含む変更: MovingCostFuelMode実装（movingCostEstimated追加・gasPayer追加・schemaVersion 4）
- `flutter build ios --release` → ビルド成功
- `xcodebuild archive` → アーカイブ成功
- `objective_c.framework` を arm64 版に差し替え → `Upload succeeded` 確認
- testflightスキル（`~/.claude/skills/testflight/skill.md`）にStep 2.5として arm64 差し替え手順をルール化

---

## 未完了 / 要対応

### 既存テスト失敗（UI変更に伴うテスト更新が必要）

| テストファイル | テストID | 原因 |
|---|---|---|
| `mark_addition_defaults_test.dart` | TC-MAD-006 | `IconButton.at(1)` でメンバー追加ボタンを探しているが UI 変更で順番が変わった |
| `mark_addition_defaults_test.dart` | TC-MAD-007 | AppBar の `Icons.check` 保存ボタンを探しているが概要タブ再設計で FAB に変更済み |
| `michi_info_layout_test.dart` | TS-03, TS-04 | Mark/Link タップ後の遷移確認テキストが UI 変更で変わった可能性 |

### 「給油計算」バグ
ユーザーから「給油計算がおかしい」と報告あり。FuelDetail の具体的な問題内容は未確認。

---

## 次回セッションで最初にやること

1. `docs/Tasks/TASKBOARD.md` を確認してタスクを確認する
2. 既存テスト失敗を修正する（TC-MAD-006/007、TS-03/04）
3. 「給油計算」バグの詳細をユーザーに確認する

### 5. PaymentInfo FAB カラー Integration Test 追加

- テストファイル: `flutter/integration_test/payment_info_fab_color_test.dart`
- テストシナリオ: TC-PIF-001, TC-PIF-002（全2件 PASS）
- TC-PIF-001: movingCostトピック設定済みイベント（近所のドライブ）の支払タブFABが存在・操作可能
- TC-PIF-002: Topicありイベント（箱根日帰りドライブ）の支払タブFABが存在・操作可能
- 補足: FABの backgroundColor（topicThemeColor?.primaryColor）を WidgetTester で直接検証するのは困難なため、
  FABの存在確認と操作可能確認に留めた
