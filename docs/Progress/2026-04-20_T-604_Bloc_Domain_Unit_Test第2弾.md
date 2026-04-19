# T-604: Bloc/Domain Unit Test追加（第2弾）

## セッション概要

T-603（PaymentBalanceSectionAdapter・BasicInfoBloc Unit Test）に続き、EventDetailBloc・VisitWorkAggregationAdapterの Unit Test を実装・実行した。

---

## 完了タスク

### T-604: Bloc/Domain Unit Test追加（第2弾）

#### 対象1: VisitWorkAggregationAdapter

**ファイル:** `flutter/test/adapter/visit_work_aggregation_adapter_test.dart`

**テストケース:** 10件（TC-001〜TC-010）

| # | テストケース | 結果 |
|---|---|---|
| 1 | TC-001: revenue種別のみがrevenueTotalに集計される | ✅ PASS |
| 2 | TC-002: isDeleted=trueのPaymentがrevenueTotalに含まれない | ✅ PASS |
| 3 | TC-003: paymentsが空の場合、revenue = 0 | ✅ PASS |
| 4 | TC-004: revenue・expense混在の場合、revenue種別のみ合計 | ✅ PASS |
| 5 | TC-005: AggregationResultのnullフィールドがDuration.zeroにフォールバック | ✅ PASS |
| 6 | TC-006: AggregationResultの全フィールド指定時の正常系 | ✅ PASS |
| 7 | TC-007: isOngoingフラグが正しく保持される | ✅ PASS |
| 8 | TC-008: onSiteDurationが正しく転写される | ✅ PASS |
| 9 | TC-009: 大量Paymentでの合計計算が正確 | ✅ PASS |
| 10 | TC-010: 複合フィルター条件（isDeleted + PaymentType） | ✅ PASS |

**成績:** 10PASS / 0FAIL

**実装のポイント:**
- revenue種別のPaymentのみを集計（expense除外）
- isDeleted フラグによるフィルタリング
- AggregationResult の null フィールドを Duration.zero にフォールバック
- VisitWorkTimeline.onSiteDuration を正確に転写
- 複合フィルタリング条件の検証（isDeleted かつ PaymentType）

---

#### 対象2: EventDetailBloc

**ファイル:** `flutter/test/bloc/event_detail_bloc_test.dart`

**テストケース:** 17件（TC-001〜TC-017）

| # | テストケース | 結果 |
|---|---|---|
| 1 | TC-001: michiInfoタブをタップするとselectedTabがmichiInfoに変わる | ✅ PASS |
| 2 | TC-002: overviewタブをタップするとselectedTabがoverviewに変わる | ✅ PASS |
| 3 | TC-003: paymentInfoタブをタップするとselectedTabがpaymentInfoに変わる | ✅ PASS |
| 4 | TC-004: 削除ボタンを押すとshowDeleteConfirmDialogがtrueになる | ✅ PASS |
| 5 | TC-005: 削除ダイアログを閉じるとshowDeleteConfirmDialogがfalseに戻る | ✅ PASS |
| 6 | TC-006: 子Bloc保存時、isSavedAtLeastOnceがtrueになる | ✅ PASS |
| 7 | TC-007: delegateを消費するとdelegateがnullになる | ✅ PASS |
| 8 | TC-008: 既存イベントで戻る場合、EventDetailDismissDelegateが発行・delete呼ばれない | ✅ PASS |
| 9 | TC-009: 新規イベント・未保存で戻る場合、deleteが呼ばれてEventDetailDismissDelegateが発行 | ✅ PASS |
| 10 | TC-010: 新規イベント・1件以上保存で戻る場合、delete呼ばれない | ✅ PASS |
| 11 | TC-011: 支払保存時、isSavedAtLeastOnceがtrueになる（CachedEventUpdate並行） | ✅ PASS |
| 12 | TC-012: マーク詳細を開く要求時、delegateがEventDetailOpenMarkDelegateになる | ✅ PASS |
| 13 | TC-013: リンク詳細を開く要求時、delegateがEventDetailOpenLinkDelegateになる | ✅ PASS |
| 14 | TC-014: 支払詳細を開く要求時、delegateがEventDetailOpenPaymentDelegateになる | ✅ PASS |
| 15 | TC-015: マーク/リンク追加要求時、delegateがEventDetailAddMarkLinkDelegateになる | ✅ PASS |
| 16 | TC-016: メンバー招待ボタン押下時、delegateがEventDetailOpenInviteLinkDelegateになる | ✅ PASS |
| 17 | TC-017: 招待コード入力ボタン押下時、delegateがEventDetailOpenInviteCodeInputDelegateになる | ✅ PASS |

**成績:** 17PASS / 0FAIL

**実装のポイント:**
- EventDetailTab（overview/michiInfo/paymentInfo）の選択状態管理
- showDeleteConfirmDialog フラグの管理
- isSavedAtLeastOnce フラグのトリガー（EventDetailChildSaved・EventDetailPaymentSaved）
- delegate の管理（各操作に応じた delegate の発行・nullリセット）
- 新規イベント・既存イベント分岐（isNewEvent・isSavedAtLeastOnce）
- EventDetailPaymentSaved は EventDetailCachedEventUpdateRequested を自動 add するため2つの State が発行される点に注意
- mocktail での repository.fetch() モック設定

---

## テスト実行

### VisitWorkAggregationAdapter

```bash
cd flutter && flutter test test/adapter/visit_work_aggregation_adapter_test.dart
```

**結果:** 10PASS / 0FAIL ✅

### EventDetailBloc

```bash
cd flutter && flutter test test/bloc/event_detail_bloc_test.dart
```

**結果:** 17PASS / 0FAIL ✅

---

## 実装の学習ポイント

### Unit Test 設計時の工夫

1. **Fixture の構成**
   - EventDetailLoaded のシードデータをテスト内で完結するように構成
   - TopicConfig の初期値を常に明示的に指定（copyWith でのデフォルト設定に依存しない）

2. **Bloc event の副作用**
   - EventDetailPaymentSaved が CachedEventUpdateRequested を内部で add する点を把握してテスト設計
   - expect() で複数の State を予測する場合、順序と件数を正確に指定

3. **Mock の活用**
   - mocktail で repository メソッドをモック化
   - verifyNever() で「呼ばれていないこと」を検証する重要性

4. **State 変換テスト**
   - 純粋な State 変換のみをテスト（副作用を伴わない操作）
   - Event が Repository を呼び出す場合、その動作も mock で制御

---

## 関連ファイル

| ファイル | 内容 |
|---|---|
| `flutter/test/adapter/visit_work_aggregation_adapter_test.dart` | VisitWorkAggregationAdapter Unit Test（10PASS） |
| `flutter/test/bloc/event_detail_bloc_test.dart` | EventDetailBloc Unit Test（17PASS） |
| `docs/Tasks/TASKBOARD.md` | T-604 DONE に更新 |

---

## テスト実行ログ

### VisitWorkAggregationAdapter

```
00:00 +0: loading
00:00 +0: VisitWorkAggregationAdapter TC-001: revenue種別のみがrevenueTotalに集計される
00:00 +1: VisitWorkAggregationAdapter TC-002: isDeleted=trueのPaymentがrevenueTotalに含まれない
...（略）...
00:00 +10: All tests passed!
```

### EventDetailBloc

```
00:00 +0: loading
00:00 +0: EventDetailBloc - State変換テスト TC-001: michiInfoタブをタップするとselectedTabがmichiInfoに変わる
00:00 +1: EventDetailBloc - State変換テスト TC-002: overviewタブをタップするとselectedTabがoverviewに変わる
...（略）...
00:00 +17: All tests passed!
```

---

## 次回セッションやること

### 次の Unit Test 追加（T-605：予定）

- **EventDetailOverviewBloc**: AggregationService のモック化が複雑なため、T-604では除外
  - 実装側で AggregationService の mock を簡潔にできるようにリファクタリング検討
  - または Integration Test で十分か判断

### Integration Test との連携

- VisitWorkAggregationAdapter・EventDetailBloc の Unit Test が成功しているため、これらを呼び出す Integration Test のバグ特定が容易になる可能性
- 今後の改善フロー効率化に期待

---

## 成績

| 対象 | テストケース数 | PASS | FAIL | SKIP |
|---|---|---|---|---|
| VisitWorkAggregationAdapter | 10 | 10 | 0 | 0 |
| EventDetailBloc | 17 | 17 | 0 | 0 |
| **合計** | **27** | **27** | **0** | **0** |

**総成績: 27PASS / 0FAIL ✅**

---

**作成日:** 2026-04-20
**tester (Haiku 4.5)**
