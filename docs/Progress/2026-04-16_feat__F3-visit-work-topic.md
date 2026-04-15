# F-3: 訪問作業トピック（visitWork）実装完了

## 日時
2026-04-16

## 概要
F-3「訪問作業トピック」を実装・テスト・レビューし、Integration Test 17件全件PASSを達成。

---

## 完了した作業

### 実装（flutter-dev）

**新規作成ファイル:**
- `flutter/lib/domain/visit_work/visit_work_segment.dart`
- `flutter/lib/domain/visit_work/visit_work_timeline.dart`
- `flutter/lib/domain/visit_work/visit_work_aggregation.dart`
- `flutter/lib/domain/visit_work/visit_work_state_interpreter.dart`
- `flutter/lib/adapter/visit_work_aggregation_adapter.dart`
- `flutter/lib/features/event_detail/projection/visit_work_projection.dart`
- `flutter/lib/shared/widgets/visit_work_progress_bar.dart`
- `flutter/lib/features/overview/view/visit_work_overview_view.dart`

**変更ファイル:**
- `flutter/lib/domain/topic/topic_domain.dart` — `TopicType.visitWork` 追加
- `flutter/lib/domain/topic/topic_theme_color.dart` — `TopicThemeColor.skyBlue` 追加
- `flutter/lib/domain/topic/topic_config.dart` — visitWork case 追加
- `flutter/lib/repository/impl/in_memory/seed_data.dart` — visitWork ActionDomain 5件 + TopicDomain 1件
- `flutter/lib/adapter/aggregation_service.dart` — `fetchActions()` 追加
- `flutter/lib/features/overview/bloc/overview_state.dart` — `visitWorkProjection` 追加
- `flutter/lib/features/overview/bloc/overview_bloc.dart` — visitWork集計分岐追加
- `flutter/lib/features/overview/view/event_detail_overview_page.dart` — visitWork表示分岐追加
- `flutter/lib/repository/impl/in_memory/in_memory_event_repository.dart` — `fetch()` で `actionTimeLogs` を populate するよう修正
- `flutter/lib/features/michi_info/view/michi_info_view.dart` — ActionTime記録後に `MichiInfoReloadRequested` を発火して `cachedEvent` を更新

### レビュー指摘・修正内容

| 修正 | 内容 |
|---|---|
| `InMemoryEventRepository.fetch()` バグ修正 | `actionTimeLogs` が常に空になっていたバグを修正（`fetchActionTimeLogs` を呼んで `copyWith` でマージ） |
| ActionTime記録後の cachedEvent 更新 | ボトムシートクローズ後に `MichiInfoReloadRequested` を発火し既存パスで `cachedEvent` を更新 |

### テスト結果

| 種別 | 結果 |
|---|---|
| Unit Test（TC-VW-U001〜U006） | 14件 PASS |
| Integration Test（TC-VW-I001〜I008） | 17件 PASS / 0 FAIL / 0 SKIP |

---

## 未完了・次回やること

1. **4/16 2:10 JST スケジュール実行**（F-3は完了済みのためスキップされる）
   - POST-1/F-5: MarkDetail/LinkDetailからPaymentDetail登録
   - F-2: 期間集計機能（ダッシュボード）
   - UI-14: MichiInfoタイムライン 道路イメージ
2. **App Store審査結果の確認**
3. **INV-2/INV-3**: 招待機能の継続実装
