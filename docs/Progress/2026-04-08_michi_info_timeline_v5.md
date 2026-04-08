# 進捗: MichiInfo タイムライン UI v5.0（縦線分離・矢印位置・距離右配置・Mark-Mark間隔）

日付: 2026-04-08

---

## 完了した作業
- chore: MichiInfoアクションボタンUIタスク追加（Phase 10 / T-094〜T-098） (101bdcc)
- docs: 第7セッション進捗更新（動作確認フィードバック5件修正・アクションボタン未実装確認） (4d16e6a)
- fix: 概要編集ボタン右上移動・選択行全行タップ・設定遷移アニメ・トピック初期保存・delegateバグ修正 (6520e6e)
- docs: 次回やること更新（動作確認→T-092→T-093→T-080） (a39b0e2)
- docs: 第6セッション進捗更新（UI改善・保存バグ修正・燃費・メンバー制限） (c102153)
- fix: マスター選択UI改善・保存バグ修正・燃費自動設定・メンバー制限 (7ad570e)
- docs: CLAUDE.md最適化を進捗ファイルに反映 (ceddfc2)
- chore: CLAUDE.md最適化（31行に圧縮・詳細ルールを.claude/rules/に分離） (d242a72)
- feat: EventDetail 概要タブ再設計（タブ3つ・インライン編集・即DB保存） (bee087a)
- feat: EventDetail 概要タブ再設計（T-091） (a9ab061)
- docs: 本日セッション進捗最終更新（T-073〜076完了・次回やること更新） (5f4c6e1)
- docs: T-073〜T-076完了を進捗ファイルに反映 (1651982)
- test: T-076 地点追加初期値・引き継ぎ Integration Test 全8件PASS (2ee1afd)
- feat: 地点追加初期値・引き継ぎ・メンバー制限・メーター同期実装（T-074 / REQ-MAD-001〜005） (aab7a49)
- docs: 要件書作成（地点追加初期値・引き継ぎ・メンバー制限・メーター同期・シードデータ更新） (b501b8c)
- docs: 進捗記録追加（設定バグ修正・非表示フィルター） (1922837)
- fix: EventDetail保存後にEventListが更新されないバグ修正 (4a1e398)
- docs: 進捗ファイル更新（スタンドアロンLink線+矢印・delegateバグ修正） (a78022e)
- fix: 選択リストから非表示マスターを除外（Trans/Member/Tag/Action/Topic） (cda850c)
- fix: パターン2スタンドアロンLinkのスパン列縦線に矢印頭を追加 (57d9a53)
- fix: 設定ページ戻るバグ修正（/events→/）・非表示セクションヘッダー追加 (28a5110)
- fix: パターン2スタンドアロンLinkにスパン列縦線を追加 (48f36bd)
- docs: MichiInfo 日付セパレーター デザイン提案・要件書作成・タスクボード追加（T-068〜072） (9ed2e63)
- fix: delegateリピートタップ不可バグ修正・区間のみLink縦線表示追加 (da5e45e)
- docs: MichiInfo v5.0 進捗ファイルに Round 3 修正内容を追記 (2941db1)
- fix: MichiInfo タイムライン 区間距離未表示・縦線タブはみ出し・距離テキスト中央揃え修正 (79b3677)
- feat: MichiInfo タイムライン UI v5.0（縦線分離・矢印位置・距離右配置・Mark-Mark間隔） (78aa044)

### Round 2 UI フィードバック 4件を実装

`flutter/lib/features/michi_info/view/michi_info_view.dart` を全面更新。

#### 1. タイムライン縦線の分離描画

- **旧**: 各カードの `_MichiTimelinePainter` が自分のカード内だけ縦線を描画 → カード間の隙間で途切れる
- **新**: `_MichiTimelineCanvas` が全体を担当
  - 細い Teal 線（40% alpha）をリスト先頭〜末尾まで途切れなく描画
  - Link カード区間のみ Emerald グラデーション太線をオーバーレイ
  - `_MichiTimelinePainter` から縦線描画ロジックを完全削除

#### 2. スパン矢印の始終点変更

- **旧**: 上 Mark 中心 Y → 下 Mark 中心 Y
- **新**: 上 Mark 底辺 Y → 下 Mark 上辺 Y
- `SpanArrowData.startY = yOffsets[i] + cardHeightList[i]`
- `SpanArrowData.endY = yOffsets[j]`

#### 3. Mark カード幅の拡張

- `_MichiTimelinePainter` の Mark カード右余白を `_cardRight: 8 → _markCardRight: 0` に変更
- Mark カードが Expanded エリア右端まで延伸（距離表示エリアの手前まで）
- Link カードは従来通り `_linkCardRight: 8`

#### 4. 距離表示の右側集約

- **旧**: 区間距離が左列（`_LinkDistanceCell`）、メーター差分が右列（スパン矢印と同一）
- **新**: 両方ともスパン列（右側）に配置
  - メーター差分テキスト: 矢印上端の右側（上）
  - 区間距離テキスト: Link カード中心 Y の右側（下）
- `_LinkDistanceCell` Widget を廃止
- `_linkDistanceColumnWidth` 定数を廃止
- Row レイアウト: Mark・Link 両行とも `[Expanded card] [SizedBox(width: 72)]`

#### 5. Mark-Mark 直接隣接時の間隔拡大

- 新定数 `_markMarkGap = 50.0` 追加
- `_buildTimelineData()` で Mark→Mark 直接隣接を検出し、`_markMarkGap` を適用
- `_TimelineItem` に `gapAfter` パラメーターを追加（`_itemGap` の定数を直接使わない設計）

### アーキテクチャ改善

- `_buildSpanArrows()` → `_buildTimelineData()` にリネーム・機能拡張
- 戻り値を `_TimelineData` クラスにまとめ（spans / linkSegments / linkDistances / gapAfterItem / totalContentHeight）
- `_buildIsSpanLink()` を廃止（縦線描画不要になったため）
- `_MichiTimelinePainter` から `isFirst`, `isLast`, `isLinkActive` パラメーターを削除

### テスト結果

- **15 PASS / 1 SKIP / 0 FAIL**
- TS-09（Mark-Mark パターン）: シードデータ起因の SKIP（前回と同様）
- `dart analyze`: 0 issues

---

## 追加修正（Round 3・同日）

1. **縦線範囲制限**: 始点ドット中心〜終点ドット中心のみ描画
2. **Mark カード幅を右端まで拡張**: Mark 行の SizedBox を削除
3. **距離テキスト縦中央揃え + 1 テキストボックス統合**: `linkDistanceTexts` を `SpanArrowData` に内包し、スパン矢印の縦中央に 1 つの TextPainter でまとめて表示
4. **区間距離未表示バグ修正**: スパン外 Link の距離を `standaloneLinkDistances` で表示
5. **縦線タブはみ出し修正**: `Positioned.fill(top: 48)` + `ClipRect` でクリップ

テスト: 15 PASS / 1 SKIP / 0 FAIL

---

## 追加修正（2026-04-08 第2セッション）

### デリゲート消費バグ修正（MichiInfo / EventList / PaymentInfo）

**原因**: `Equatable` を使用した delegate は同じオブジェクトを emit すると `BlocConsumer` listener が発火しない。
→ ナビゲーション後に戻り、再度同じボタンを押しても反応しない症状。

**修正**: delegate を消費後に `DelegateConsumed` イベントを dispatch して state から null に戻す。

対応ファイル:
- `michi_info_event.dart` / `michi_info_bloc.dart` / `michi_info_view.dart`
- `event_list_event.dart` / `event_list_bloc.dart` / `event_list_page.dart`
- `payment_info_event.dart` / `payment_info_bloc.dart` / `payment_info_view.dart`

### スタンドアロン Link の Emerald グラデーション線 + スパン列矢印表示

**修正**: パターン2（区間だけ）のときに、距離テキストのみでなく線を描画。

1. 軸側: `linkSegments` にスタンドアロン Link を追加 → Emerald グラデーション縦線
2. スパン列: `standaloneLinkLines` を新設 → スパン列 (`arrowX`) に縦線 + 上下矢印頭を描画
   - Mark-Link-Mark パターンのスパン矢印と同じサイズ・Emerald カラー
   - `_TimelineData` に `standaloneLinkLines: List<(double, double)>` フィールド追加
   - `_MichiTimelineCanvas` の step 5 として描画

コミット:
- fix: パターン2スタンドアロンLinkにスパン列縦線を追加 (48f36bd)
- fix: パターン2スタンドアロンLinkのスパン列縦線に矢印頭を追加 (57d9a53)

テスト: 未実施（次回）

---

## 追加修正（2026-04-08 第3セッション）

### EventDetail保存後にEventListが更新されないバグ修正

**原因**: `EventListPage._handleDelegate` で `context.push('/event/$eventId')` 後に `EventListBloc` のリロード処理がなかった。保存はDBに成功しているが、一覧が再フェッチされないため古いデータのまま表示されていた。

**修正**: `context.push(...).then((_) { if (!mounted) return; bloc.add(const EventListStarted()); })` を追加。EventDetailから pop したタイミングで `fetchAll()` を再実行する。

対応ファイル:
- `flutter/lib/features/event_list/view/event_list_page.dart`

テスト: `flutter/integration_test/event_list_reload_test.dart` 追加（TC-BUG-001・TC-BUG-002）
- **2 PASS / 0 FAIL**

---

## 追加実装（2026-04-08 第4セッション）

### T-074: 地点追加初期値・引き継ぎ 実装（REQ-MAD-001〜005）

**実装内容:**

- `MarkDetailArgs` に初期値フィールド4件追加（`initialMeterValueInput` / `initialSelectedMembers` / `initialMarkLinkDate` / `eventMembers`）
- `MarkDetailStarted` に同フィールド追加（デフォルト値あり・後方互換性保持）
- `MarkDetailLoaded` に `availableMembers` フィールド追加
- `MarkDetailBloc._onStarted`: 新規作成モードで `args` の初期値を Draft に反映
- `MichiInfoAddMarkDelegate` に初期値フィールド4件追加
- `MichiInfoBloc._onAddMarkPressed`: `EventRepository.fetch()` で最新ドメイン取得 → 前の地点から初期値を算出して Delegate に設定（REQ-MAD-001〜004）
- `MichiInfoView`: `MichiInfoAddMarkDelegate` から全フィールドを受け取り `MarkDetailArgs` 構築
- `router.dart`: `/event/mark/:markId` ビルダーで `MarkDetailArgs` から初期値を取り出し `MarkDetailStarted` に渡す・`EventDetailBloc` に `TransRepository` 注入追加
- `SelectionArgs` に `candidateMembers: List<MemberDomain>?` 追加（REQ-MAD-004）
- `SelectionBloc`: `markMembers` / `linkMembers` タイプのとき `_candidateMembers` を優先使用
- `MarkDetailPage._handleDelegate`: `availableMembers` を `SelectionArgs.candidateMembers` として渡す
- `EventDetailBloc`: `TransRepository` 依存追加・`_updateTransMaxMeterValue()` 実装（REQ-MAD-005）
- `dart analyze`: 0 errors

**対応ファイル:**
- `flutter/lib/features/mark_detail/mark_detail_args.dart`
- `flutter/lib/features/mark_detail/bloc/mark_detail_event.dart`
- `flutter/lib/features/mark_detail/bloc/mark_detail_state.dart`
- `flutter/lib/features/mark_detail/bloc/mark_detail_bloc.dart`
- `flutter/lib/features/mark_detail/view/mark_detail_page.dart`
- `flutter/lib/features/michi_info/bloc/michi_info_state.dart`
- `flutter/lib/features/michi_info/bloc/michi_info_bloc.dart`
- `flutter/lib/features/michi_info/view/michi_info_view.dart`
- `flutter/lib/features/event_detail/bloc/event_detail_bloc.dart`
- `flutter/lib/features/selection/selection_args.dart`
- `flutter/lib/features/selection/bloc/selection_bloc.dart`
- `flutter/lib/app/router.dart`

---

## 追加実装（2026-04-08 第5セッション）

### T-091: EventDetail 概要タブ再設計 実装

**実装内容:**

- **Mark/Link/Payment の DB 直接保存化**: `MarkDetailBloc` / `LinkDetailBloc` / `PaymentDetailBloc` が `EventRepository.save()` を直接呼び出す。`MarkDetailSavedDelegate` / `LinkDetailSavedDelegate` / `PaymentDetailSavedDelegate` を emit してページに通知。
- **BasicInfo インライン編集モード**: `BasicInfoDraft.isEditing` フラグ追加。参照モード（`_BasicInfoReadView`）と編集モード（`_BasicInfoForm`）を切り替え。編集モードで保存・キャンセルの FloatingButton 表示。`BasicInfoSavePressed` イベントで DB 保存 → `BasicInfoSavedDelegate` emit。
- **EventDetailTab 3タブ化**: `EventDetailTab` を `{ overview, michiInfo, paymentInfo }` に変更（旧 `basicInfo` タブを削除）。
- **概要タブ**: `BasicInfoView` + `EventDetailOverviewPage` を縦並びで `SingleChildScrollView` に表示する `_OverviewTabContent`。
- **タブ切り替え保護**: `BasicInfoLoaded.draft.isEditing == true` の場合にタブ切り替えをブロックし、未保存変更ダイアログを表示（キャンセル / 破棄して移動 / 保存して移動）。
- **EventDetailBloc 簡素化**: `TransRepository` 依存と `EventDetailSaveRequested` ハンドラーを削除。`EventDetailCachedEventUpdateRequested` を追加（BasicInfo 保存後に cachedEvent を再フェッチ）。
- **MichiInfoView**: `context.push` 後の draft 戻り値処理を削除（DB 保存は MarkDetailBloc/LinkDetailBloc 側が担当）。

**dart analyze**: 0 errors

**対応ファイル:**
- `flutter/lib/app/router.dart`
- `flutter/lib/features/basic_info/draft/basic_info_draft.dart`
- `flutter/lib/features/basic_info/bloc/basic_info_event.dart`
- `flutter/lib/features/basic_info/bloc/basic_info_state.dart`
- `flutter/lib/features/basic_info/bloc/basic_info_bloc.dart`
- `flutter/lib/features/basic_info/view/basic_info_view.dart`
- `flutter/lib/features/event_detail/draft/event_detail_draft.dart`
- `flutter/lib/features/event_detail/bloc/event_detail_event.dart`
- `flutter/lib/features/event_detail/bloc/event_detail_state.dart`
- `flutter/lib/features/event_detail/bloc/event_detail_bloc.dart`
- `flutter/lib/features/event_detail/view/event_detail_page.dart`
- `flutter/lib/features/mark_detail/bloc/mark_detail_state.dart`
- `flutter/lib/features/mark_detail/bloc/mark_detail_bloc.dart`
- `flutter/lib/features/mark_detail/view/mark_detail_page.dart`
- `flutter/lib/features/link_detail/bloc/link_detail_state.dart`
- `flutter/lib/features/link_detail/bloc/link_detail_bloc.dart`
- `flutter/lib/features/link_detail/view/link_detail_page.dart`
- `flutter/lib/features/payment_detail/bloc/payment_detail_state.dart`
- `flutter/lib/features/payment_detail/bloc/payment_detail_bloc.dart`
- `flutter/lib/features/payment_detail/view/payment_detail_page.dart`
- `flutter/lib/features/payment_info/bloc/payment_info_event.dart`
- `flutter/lib/features/payment_info/bloc/payment_info_bloc.dart`
- `flutter/lib/features/payment_info/view/payment_info_view.dart`
- `flutter/lib/features/michi_info/bloc/michi_info_event.dart`
- `flutter/lib/features/michi_info/bloc/michi_info_bloc.dart`
- `flutter/lib/features/michi_info/view/michi_info_view.dart`

---

## 追加実装（2026-04-08 第6セッション）

### fix: マスター選択UI改善・保存バグ修正・燃費自動設定・メンバー制限 (7ad570e)

1. **保存ボタンバグ修正**: `MarkDetailPage`/`LinkDetailPage` の `SavedDelegate` から `context.read<MichiInfoBloc>()` を削除し `context.pop()` のみに。`MichiInfoView` は push 後に `MichiInfoReloadRequested` で DB リロード。
2. **選択行全体タップ**: `_SelectionRow` を `InkWell` で囲んで行全体が反応するように。
3. **単一選択で即確定**: `SelectionBloc._onItemToggled` で `single` モード時に即 `SelectionConfirmedDelegate` を emit。
4. **交通手段選択で燃費自動設定**: `BasicInfoBloc._onTransSelected` で `trans.kmPerGas` を `kmPerGasInput` に反映。
5. **Mark/Link メンバー選択をイベントメンバーに限定**: `MichiInfoLoaded.eventMembers` キャッシュ → 各デリゲートに伝播 → `LinkDetailLoaded.availableMembers` → `SelectionArgs.candidateMembers`。

---

## 未完了・次回やること

- [x] **T-075**: T-074 レビュー PASS
- [x] **T-076**: Integration Test 全8件PASS（TC-MAD-001〜008）
- [x] **T-091**: EventDetail 概要タブ再設計 実装完了
- [x] **T-092**: EventDetail 概要タブ再設計 レビュー
- [x] **T-093**: EventDetail 概要タブ再設計 テスト（12 PASS / 3 SKIP）
- [ ] **T-080**: シードデータ更新（トピック設定・Overview確認データ・MichiInfoパターン）
- [ ] **MichiInfo_Layout_Spec.md v5.0 追記**: v4→v5 変更内容の Spec 反映（architect タスク）
- [ ] **TS-09 パターン1の検証**: Mark-Mark 直接のシードデータを作って手動確認
- [ ] **T-064〜T-067**: タイムライン挿入UI（FAB型）— 次の大きな機能

## 追加修正（2026-04-08 第7セッション: 動作確認フィードバック対応）

1. **概要編集ボタン右上移動**: FAB → `Positioned(top: 4, right: 8)` の `IconButton` に変更
2. **選択行全行タップ**: `_SelectionRow` を `InkWell` で包んで行全体タップ可能に
3. **設定遷移アニメ修正**: `context.go('/settings')` → `push`・`context.go('/')` → `pop`
4. **新規イベントトピック初期保存**: `EventDetailBloc` に `TopicRepository` 追加・新規作成時に topic を DB 保存
5. **BasicInfo delegate再タップ不可バグ修正**: `BasicInfoDelegateConsumed` 追加・`_handleDelegate` 先頭で即消費

未実装確認: **MichiInfoアクションボタン**（地点カードへのアクション記録ボタンUI）は未実装。

## 次回セッションで最初にやること

1. **動作確認**: 今回の修正（編集ボタン右上・行全体タップ・設定遷移アニメ・トピック初期保存・delegate再タップ）を手動確認
2. **T-080**: シードデータ更新（flutter-dev タスク）
3. **T-094**: MichiInfo アクションボタン UI 要件書作成（product-manager タスク）

---

## 備考

- v4.0（C-2 デザイン）の上に Round 2 UI フィードバックを重ねて v5.0 として完成
- カード間隙間による縦線途切れ問題を根本解決（分離描画）
- メーター差分・区間距離を右側に集約してレイアウトをシンプル化
