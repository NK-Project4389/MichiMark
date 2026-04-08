# Feature Spec: MichiInfo ActionTime ボタン UI

- **Spec ID**: SPEC-MAB
- **要件書**: REQ-michi_info_action_button
- **作成日**: 2026-04-08
- **担当**: architect
- **ステータス**: 確定

---

## 1. Feature Overview

### Feature Name

MichiInfo ActionTime ボタン UI（ActionTimeButton）

### Purpose

MichiInfo タイムラインの Mark カードに ⚡ アイコンボタンと状態バッジを追加し、ボトムシート経由で ActionTime（出発・到着・休憩などの状態遷移）をワンタップで記録できる UI を提供する。ActionTime の Bloc / Repository / View は実装済みであり、本 Spec は MichiInfo への組み込み UI のみを定義する。

### Scope

含むもの
- Mark カード右上への Violet（`#7C3AED`）⚡ アイコンボタンの追加
- Mark カード内への ActionState 状態バッジの追加（`currentStateLabel` 表示）
- ⚡ ボタンタップで `ActionTimeView` をボトムシートとして表示
- ボトムシート内での ActionTime 記録・ログ表示
- 記録完了後のボトムシート自動クローズ
- 状態バッジのリアルタイム更新（記録後に即時反映）

含まないもの
- Link カードへの ⚡ ボタン・状態バッジの表示
- ActionTime ログ一覧の MichiInfo インライン表示
- ActionTime の自動記録（GPS連携）
- ActionTime 関連の新規 View の作成（既存 `ActionTimeView` を流用）

---

## 2. アーキテクチャ方針

### 2.1 ActionTimeBloc の提供方法

`ActionTimeBloc` は MichiInfoView の BlocProvider ツリーに **追加しない**。

各 Mark カードの ⚡ ボタンタップ時に `showModalBottomSheet` を呼び出し、その builder の中で **独立した BlocProvider** として `ActionTimeBloc` を生成・提供する。

理由:
- `ActionTimeBloc` は eventId 単位で状態を管理するため、Mark カードごとに独立した Bloc インスタンスが適切
- MichiInfoBloc の Stateに `ActionTimeProjection` を追加すると MichiInfoBloc の責務が拡大しすぎる
- ボトムシートのライフサイクルに Bloc のライフサイクルを合わせることで、不要なリソース保持を防ぐ

### 2.2 MichiInfoState への ActionTimeProjection の追加要否

**追加しない。** ただし、状態バッジ（`currentStateLabel`）のリアルタイム更新を実現するため、以下の方針を採用する。

- ボトムシートは `showModalBottomSheet` で表示され、内部に独自の `ActionTimeBloc` を持つ
- 状態バッジは `ActionTimeBloc` を個別に `watch` するのではなく、ボトムシート内の `ActionTimeState` から `currentStateLabel` を取得してボトムシートが閉じた後に更新する
- 具体的には、`MichiInfoLoaded` に **`Map<String, String> markActionStateLabels`** フィールドを追加し、ボトムシートを閉じた後に `MichiInfoActionStateLabelUpdated` イベントで更新する

この方針により:
- MichiInfo の関心と ActionTime の関心が分離される
- ボトムシートが開いている間はリアルタイム更新（ボトムシート内の ActionTimeState で表示）
- ボトムシートを閉じた後は MichiInfoLoaded の `markActionStateLabels` に反映されカードのバッジが更新される

### 2.3 ボトムシート表示方法

`showModalBottomSheet` を使用し、以下の構成とする。

- builder 内で `BlocProvider<ActionTimeBloc>` を生成し `ActionTimeStarted` を即時発火
- `ActionTimeView` を子として渡す（新規 View を作らない: REQ-MAB-005）
- `isScrollControlled: true` を指定して高さをコンテンツに応じて可変にする
- `DraggableScrollableSheet` でスワイプ閉じをサポートする

---

## 3. State Structure

### 3.1 MichiInfoLoaded への追加フィールド

既存 `MichiInfoLoaded` に以下を追加する。

| フィールド | 型 | 説明 |
|---|---|---|
| `markActionStateLabels` | `Map<String, String>` | markLinkId → currentStateLabel のマップ。ボトムシートを閉じた後に更新される。初期値は空Map |

状態バッジ表示時、`markActionStateLabels[item.id]` が null の場合は「滞留中」（デフォルト）を表示する。

### 3.2 ActionTimeState（変更なし）

既存の `ActionTimeState` をそのまま利用する。変更は不要。

---

## 4. Events

### 4.1 MichiInfoBloc に追加するイベント

| イベント名 | 発火タイミング | 説明 |
|---|---|---|
| `MichiInfoActionStateLabelUpdated` | ボトムシートを閉じた後 | markLinkId と currentStateLabel を受け取り `markActionStateLabels` を更新する |
| `MichiInfoActionButtonPressed` | ⚡ ボタンタップ | ボトムシート表示のトリガー。MichiInfoBloc はこのイベントを受けて `MichiInfoOpenActionTimeDelegate` を発火する |

#### MichiInfoActionButtonPressed フィールド

| フィールド | 型 | 説明 |
|---|---|---|
| `markLinkId` | `String` | タップされた Mark の ID |
| `eventId` | `String` | 対象イベントの ID（ActionTimeStarted に渡す） |
| `topicConfig` | `TopicConfig` | トピック設定（ActionTimeStarted に渡す） |
| `markOrLink` | `MarkOrLink` | Mark であることを示す（常に `MarkOrLink.mark`） |

#### MichiInfoActionStateLabelUpdated フィールド

| フィールド | 型 | 説明 |
|---|---|---|
| `markLinkId` | `String` | 更新対象 Mark の ID |
| `currentStateLabel` | `String` | 記録後の最新状態ラベル |

### 4.2 ActionTimeBloc イベント（変更なし）

既存の以下を流用する。
- `ActionTimeStarted` — ボトムシート表示時に発火
- `ActionTimeLogRecorded` — アクションボタンタップ時
- `ActionTimeBreakToggled` — 休憩トグル時
- `ActionTimeLogDeleted` — ログ削除時

---

## 5. Delegate Contract

### 5.1 MichiInfoDelegate に追加するDelegate

| Delegate名 | 通知先 | 説明 |
|---|---|---|
| `MichiInfoOpenActionTimeDelegate` | MichiInfoView の BlocListener | ⚡ ボタンタップによるボトムシート表示意図を通知する |

#### MichiInfoOpenActionTimeDelegate フィールド

| フィールド | 型 | 説明 |
|---|---|---|
| `markLinkId` | `String` | 対象 Mark の ID |
| `eventId` | `String` | 対象イベントの ID |
| `topicConfig` | `TopicConfig` | トピック設定 |

### 5.2 Navigationルール

- `MichiInfoOpenActionTimeDelegate` を受け取った MichiInfoView の BlocListener が `showModalBottomSheet` を呼び出す
- ボトムシートの表示・非表示は NavigationではなくWidget操作であり、`context.go()` / `context.push()` は不要
- ボトムシートを閉じた後、MichiInfoView は `MichiInfoActionStateLabelUpdated` を dispatch して状態バッジを更新する

---

## 6. UI 仕様

### 6.1 ⚡ アイコンボタンの配置

- 配置場所: Mark カード右上（`_TimelineItemOverlay` の Row 末尾）
- 表示条件: `item.markLinkType == MarkOrLink.mark` の場合のみ表示（REQ-MAB-008）
- サイズ: 28×28 px（圧迫感なく収まるサイズ）
- 背景色: Violet `#7C3AED`
- アイコン: `Icons.bolt`（白 `#FFFFFF`）
- 形状: 角丸矩形（`BorderRadius.circular(8)`）
- タップ時: `MichiInfoActionButtonPressed` を dispatch

### 6.2 状態バッジの配置

- 配置場所: Mark カード内の右下（⚡ ボタンの下に隣接）、または `_TimelineItemOverlay` の Column 内、メーター値テキストの下
- 表示条件: `item.markLinkType == MarkOrLink.mark` の場合のみ表示（REQ-MAB-008）
- 表示テキスト: `markActionStateLabels[item.id] ?? '滞留中'`（REQ-MAB-004）
- 背景色: Violet 10% alpha（`Color(0x197C3AED)`）
- テキスト色: `#7C3AED`
- フォントサイズ: 10px
- Padding: 水平 6px / 垂直 2px
- BorderRadius: 4px

### 6.3 ボトムシートの構成

- 表示方法: `showModalBottomSheet(isScrollControlled: true)`
- 初期高さ: 画面高さの 60%（`initialChildSize: 0.6`）
- 最大高さ: 画面高さの 90%（`maxChildSize: 0.9`）
- 最小高さ: 画面高さの 40%（`minChildSize: 0.4`）
- `DraggableScrollableSheet` でスワイプ閉じをサポート
- コンテンツ: `ActionTimeView`（既存 View をそのまま流用）
- ヘッダー: 「ActionTime」ラベル + 閉じるボタン（`Icons.close`）
- `BlocProvider<ActionTimeBloc>` を builder 内で生成し `ActionTimeStarted` を即時発火

---

## 7. Data Flow

### 7.1 ⚡ ボタンタップからボトムシート表示まで

1. ユーザーが Mark カードの ⚡ ボタンをタップ
2. Widget が `MichiInfoActionButtonPressed(markLinkId, eventId, topicConfig, markOrLink)` を `MichiInfoBloc` に dispatch
3. `MichiInfoBloc` が `MichiInfoOpenActionTimeDelegate` を State に乗せて emit
4. `MichiInfoView` の BlocListener が Delegate を受け取り `showModalBottomSheet` を呼び出す
5. builder 内で `BlocProvider<ActionTimeBloc>` を生成し `ActionTimeStarted(eventId, topicConfig: topicConfig, markOrLink: markOrLink)` を dispatch
6. `ActionTimeBloc` が Repository から ActionTimeLog を取得し `ActionTimeState` を emit
7. ボトムシート内の `ActionTimeView` が State を表示する

### 7.2 ボトムシート内での記録

1. ユーザーが `ActionTimeView` 内のアクションボタンをタップ
2. `ActionTimeView` が `ActionTimeLogRecorded(actionId)` を dispatch
3. `ActionTimeBloc` が Repository に ActionTimeLog を保存し、State を再 emit
4. `ActionTimeView` の `currentStateLabel` がリアルタイムに更新される
5. `ActionTimeState.delegate` が `ActionTimeNavigateBackDelegate` になった場合、ボトムシートを閉じる

### 7.3 ボトムシートを閉じた後の状態バッジ更新

1. ボトムシートが閉じる（スワイプ or 記録完了後自動クローズ）
2. `showModalBottomSheet` の `await` が完了
3. MichiInfoView が最後の `ActionTimeState.projection.currentStateLabel` を取得
4. `MichiInfoActionStateLabelUpdated(markLinkId, currentStateLabel)` を `MichiInfoBloc` に dispatch
5. `MichiInfoBloc` が `MichiInfoLoaded.markActionStateLabels` を更新して emit
6. Mark カードの状態バッジが新しいラベルで再描画される

---

## 8. Router 変更方針

Router への変更は不要。ボトムシートは `showModalBottomSheet` で表示するため、go_router のルート定義を追加しない。

---

## 9. Test Scenarios

### 前提条件

- iOS シミュレーターが起動済みであること
- テスト用イベントが1件以上存在すること（シードデータを使用）
- テスト用イベントに Mark が1件以上存在すること
- ActionTime 用の Action が1件以上マスターに登録されていること

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-MAB-001 | ⚡ ボタンが Mark カードにのみ表示される | High |
| TC-MAB-002 | 状態バッジが Mark カードに常時表示される（初期: 滞留中） | High |
| TC-MAB-003 | ⚡ ボタンタップでボトムシートが表示される | High |
| TC-MAB-004 | ボトムシート内でアクションを記録すると currentStateLabel が更新される | High |
| TC-MAB-005 | 記録完了後にボトムシートが閉じる | High |
| TC-MAB-006 | ボトムシートを閉じた後、Mark カードの状態バッジが更新される | High |
| TC-MAB-007 | ボトムシートをスワイプで閉じられる | Medium |
| TC-MAB-008 | Link カードに ⚡ ボタン・状態バッジが表示されない | High |
| TC-MAB-009 | 複数の Mark カードで独立した ActionTime を記録できる | Medium |

### シナリオ詳細

#### TC-MAB-001: ⚡ ボタンが Mark カードにのみ表示される

**前提**: MichiInfo タイムラインに Mark と Link が混在するイベントを表示

**操作手順:**
1. イベント一覧からテスト用イベントをタップ
2. MichiInfo タブを表示する

**期待結果:**
- Mark カードの右上に Violet の ⚡ アイコンボタンが表示される
- Link カードに ⚡ ボタンが表示されない

---

#### TC-MAB-002: 状態バッジが Mark カードに常時表示される（初期: 滞留中）

**前提**: ActionTime ログが存在しない Mark カードが表示されている

**操作手順:**
1. イベント一覧からテスト用イベントをタップ
2. MichiInfo タブを表示する

**期待結果:**
- Mark カードに「滞留中」の状態バッジが表示される
- Link カードに状態バッジが表示されない

---

#### TC-MAB-003: ⚡ ボタンタップでボトムシートが表示される

**操作手順:**
1. MichiInfo タブを表示する
2. いずれかの Mark カードの ⚡ ボタンをタップする

**期待結果:**
- ボトムシートが画面下部から表示される
- ボトムシート内に「現在の状態」ラベルが表示される
- ボトムシート内にアクションボタン一覧が表示される

---

#### TC-MAB-004: ボトムシート内でアクションを記録すると currentStateLabel が更新される

**操作手順:**
1. MichiInfo タブを表示する
2. Mark カードの ⚡ ボタンをタップする
3. ボトムシート内のアクションボタン（例: 「出発」）をタップする

**期待結果:**
- ボトムシート内の「現在の状態」表示が記録したアクションに応じたラベルに変わる（例: 「移動中」）
- ログ一覧に記録したアクションのタイムスタンプが表示される

---

#### TC-MAB-005: 記録完了後にボトムシートが閉じる

**操作手順:**
1. Mark カードの ⚡ ボタンをタップする
2. ボトムシート内のアクションボタンをタップする

**期待結果:**
- アクション記録後、ボトムシートが自動で閉じる
- MichiInfo タイムラインが表示された状態に戻る

---

#### TC-MAB-006: ボトムシートを閉じた後、Mark カードの状態バッジが更新される

**操作手順:**
1. Mark カードの ⚡ ボタンをタップする
2. ボトムシート内のアクションボタン（例: 「出発」）をタップしてボトムシートを閉じる

**期待結果:**
- ボトムシートが閉じた後、該当 Mark カードの状態バッジが記録したラベル（例: 「移動中」）に更新される
- 他の Mark カードの状態バッジは変わらない

---

#### TC-MAB-007: ボトムシートをスワイプで閉じられる

**操作手順:**
1. Mark カードの ⚡ ボタンをタップしてボトムシートを開く
2. ボトムシートを下方向にスワイプして閉じる

**期待結果:**
- ボトムシートが閉じる
- MichiInfo タイムラインが表示された状態に戻る
- Mark カードの状態バッジは変化しない（記録がなかったため）

---

#### TC-MAB-008: Link カードに ⚡ ボタン・状態バッジが表示されない

**前提**: MichiInfo タイムラインに Link カードが1件以上存在する

**操作手順:**
1. MichiInfo タブを表示する

**期待結果:**
- Link カードに ⚡ アイコンボタンが存在しない
- Link カードに状態バッジが存在しない

---

#### TC-MAB-009: 複数の Mark カードで独立した ActionTime を記録できる

**前提**: MichiInfo タイムラインに Mark が2件以上存在する

**操作手順:**
1. 1枚目の Mark カードの ⚡ ボタンをタップする
2. ボトムシート内でアクション A（例: 「出発」）を記録してボトムシートを閉じる
3. 2枚目の Mark カードの ⚡ ボタンをタップする
4. ボトムシート内でアクション B（例: 「到着」）を記録してボトムシートを閉じる

**期待結果:**
- 1枚目の Mark カードの状態バッジにアクション A のラベルが表示される
- 2枚目の Mark カードの状態バッジにアクション B のラベルが表示される
- 各 Mark カードが独立した状態バッジを持つ

---

## 10. 実装上の注意事項

### ActionTimeView の Navigator.of(context).pop() について

現在の `ActionTimeView` の BlocListener は `ActionTimeNavigateBackDelegate` を受け取ると `Navigator.of(context).pop()` を呼び出す。ボトムシート内ではこの動作が有効であるため（ボトムシートのルートに対して pop が実行される）、`ActionTimeView` の変更は不要。

### 状態バッジのデフォルト値

`markActionStateLabels` に該当 `markLinkId` のエントリが存在しない場合は「滞留中」をデフォルト表示とする（REQ-MAB-004 の「初回（ログなし）は滞留中を表示」に対応）。

### _TimelineItemOverlay の責務範囲

⚡ ボタンと状態バッジは `_TimelineItemOverlay` の Row 内に追加する。Mark であることの判定（`isMark`）が既存フィールドとして存在するため、条件分岐は既存パターンに倣う。

---

*End of Spec*
