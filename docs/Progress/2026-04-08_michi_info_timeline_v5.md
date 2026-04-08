# 進捗: MichiInfo タイムライン UI v5.0（縦線分離・矢印位置・距離右配置・Mark-Mark間隔）

日付: 2026-04-08

---

## 完了した作業
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

## 未完了・次回やること

- [ ] **T-075**: T-074 レビュー（reviewer タスク）
- [ ] **T-076**: T-075通過後 Integration Test（tester タスク）
- [ ] **MichiInfo_Layout_Spec.md v5.0 追記**: v4→v5 変更内容の Spec 反映（architect タスク）
- [ ] **TS-09 パターン1の検証**: Mark-Mark 直接のシードデータを作って手動確認
- [ ] **T-064〜T-067**: タイムライン挿入UI（FAB型）— 次の大きな機能

## 次回セッションで最初にやること

1. **T-075**: 地点追加初期値・引き継ぎ レビュー（reviewer）
2. **T-076**: Integration Test 実施（tester）
3. **T-064**: タイムライン挿入UI の要件書作成（product-manager タスク）

---

## 備考

- v4.0（C-2 デザイン）の上に Round 2 UI フィードバックを重ねて v5.0 として完成
- カード間隙間による縦線途切れ問題を根本解決（分離描画）
- メーター差分・区間距離を右側に集約してレイアウトをシンプル化
