# 2026-04-08 地点追加初期値・引き継ぎ Integration Test（T-076）

## 完了した作業

### T-076: 地点追加初期値・引き継ぎ テスト（全8件PASS）

- テストファイル作成: `flutter/integration_test/mark_addition_defaults_test.dart`
- デバイス: iPhone 16e シミュレーター（ID: 64918946-C8E3-4B4E-A356-5C6A45DE52A5）

### テスト結果

| シナリオID | シナリオ名 | 結果 |
|---|---|---|
| TC-MAD-001 | 地点なし → 交通手段のmeterValueが初期値 | PASS |
| TC-MAD-002 | 既存地点あり → 前の地点のmeterValueが初期値 | PASS |
| TC-MAD-003 | 既存地点あり → 前の地点のメンバーが引き継がれる | PASS |
| TC-MAD-004 | 既存地点あり → 前の地点の日付が初期値 | PASS |
| TC-MAD-005 | 地点なし → 本日の日付が初期値 | PASS |
| TC-MAD-006 | メンバー選択候補がイベントメンバーのみ | PASS |
| TC-MAD-007 | EventDetail保存後にTransのmeterValueが更新 | PASS |
| TC-MAD-008 | 既存地点編集時はDB値が表示（引き継ぎなし） | PASS |

### 実装上の注意点（テスト実装で発見したUI仕様）

- FABタップ → 「地点を追加」「区間を追加」のメニューが出現 → 「地点を追加」を追加タップが必要
- 日付表示フォーマット: `"YYYY/MM/DD"` 形式
- メンバー表示: `"太郎、花子"` のようなカンマ区切りテキスト
- メンバー選択候補: MarkDetail画面の IconButton[1] タップで「メンバーを選択」シートが開く
- 交通手段meterValue一覧フォーマット: `"燃費: 15.5 km/L　メーター: 45,230 km"`
- EventDetail保存後: ページは遷移せず「保存しました」トースト表示（`router.go('/')` で手動遷移が必要）

## 未完了・継続事項

- T-075（レビュー）はユーザー指示により先行してテストを実施。レビューは別途実施予定

## 次回セッションで最初にやること

- T-070: MichiInfo 日付セパレーター Spec 作成（architect）
- T-075: 地点追加初期値・引き継ぎ レビュー（reviewer）
