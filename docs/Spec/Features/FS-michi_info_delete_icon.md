# Feature Spec: MichiInfo Mark/Link削除UI変更 & 給油アイコンタイムライン統合

- **Spec ID**: FS-michi_info_delete_icon
- **要件ID**: REQ-michi_info_delete_icon
- **作成日**: 2026-04-12
- **担当**: architect
- **ステータス**: 確定

---

## 1. 概要（Purpose）

MichiInfo 画面（ミチタブ）の Mark カード・Link カードに対して以下の2点を変更する。

1. **削除UI変更**: `flutter_slidable` によるスワイプ削除を廃止し、カード右端に赤背景ゴミ箱アイコンを常時表示する方式に切り替える。スワイプの気づきにくさを解消し、削除操作を直感的にする。
2. **給油アイコンのタイムライン統合**: カード行内に表示していた給油アイコン（⛽）を廃止し、タイムライン縦罫線の区間接点ドット内に統合する。給油あり時は接点ドットを拡大してアイコンを内包する。

削除ロジック（論理削除・DB更新・リスト再描画）は既存実装（MichiInfoCardDelete_Spec.md）を流用し、変更しない。

---

## 2. Scope

### 含むもの

- Mark カード・Link カードの `flutter_slidable` スワイプUI撤去
- カード右端への削除アイコン（赤背景・ゴミ箱）常時表示
- `_TimelineItemOverlay` 内の `isFuel` アイコン廃止
- `_MichiTimelinePainter` の Mark 接点ドット描画変更（給油あり時に拡大・アイコン内包）
- `flutter_slidable` 依存の削除（`pubspec.yaml` および import 整理）

### 含まないもの

- 削除後のDB処理・リスト再描画ロジック（既存実装のまま）
- 削除確認ダイアログ（導入しない・タップ即削除）
- 削除取り消し（Undo）
- Link カード接点ドットの給油アイコン対応（Link は `isFuel` を持たないため対象外）
- ActionTime 自体の表示仕様変更

---

## 3. 変更対象レイヤー一覧

| レイヤー | ファイル | 変更種別 |
|---|---|---|
| Widget（View） | `michi_info_view.dart` | Slidable 撤去・削除アイコン常時表示・給油アイコン移動 |
| Widget（View）| `michi_info_view.dart` の `_MichiTimelinePainter` | 接点ドット描画変更（給油あり時の拡大・テキスト描画追加） |
| pubspec | `pubspec.yaml` | `flutter_slidable` 依存を削除 |

BLoC Event・State・Delegate・Draft・Projection・Repository・Adapter の変更はなし。

---

## 4. Widget 変更仕様

### 4.1 スワイプUI撤去

- 通常モード SliverList 内の `Slidable` ラップを削除する
- `SlidableAutoCloseBehavior` ラップを削除する
- `flutter_slidable` の import を削除する
- `pubspec.yaml` から `flutter_slidable` を削除する
- 挿入モード判定の `enabled: !widget.isInsertMode` 条件も不要になるため削除する

### 4.2 削除アイコン常時表示

通常モード SliverList で各カードをラップする `_TimelineItem` の右端に削除アイコンを常時表示する。

**削除アイコン仕様**

| 項目 | 値 |
|---|---|
| アイコン | `Icons.delete` |
| アイコン色 | `#DC2626` |
| 背景色 | `#FEE2E2` |
| サイズ | アイコン 20px、背景コンテナ 36×36 dp（`BorderRadius.circular(8)` ） |
| 配置 | カード右端（`_TimelineItemOverlay` の `Row` 末尾） |
| タップ時 | `MichiInfoCardDeleteRequested(item.id)` を Bloc に add |
| 挿入モード中 | 削除アイコンを非表示にする（`!isInsertMode` の条件で制御） |

**Widget Key**

| キー | 要素 |
|---|---|
| `Key('michiInfo_button_delete_${item.id}')` | 削除アイコンボタン（ Mark・Link 共通） |

### 4.3 給油アイコン廃止（カード内）

`_TimelineItemOverlay` の `Row` 内に存在する以下のコードを削除する。

```
if (item.isFuel)
  Icon(Icons.local_gas_station, ...)
```

---

## 5. CustomPainter 変更仕様（`_MichiTimelinePainter`）

### 5.1 変更対象

`_MichiTimelinePainter.paint()` 内の Mark ドット描画ブロック（`if (isMark)` 節）。

### 5.2 変更内容

**給油なし時（従来通り）**

- 白リング + Teal 円ドット（`_markDotRadius = 10.0`）

**給油あり時（新規）**

- ドットの高さを `_actionButtonsHeight`（48.0 dp）分だけ拡大した縦長楕円形または角丸矩形に変更する
- 拡大後ドットのサイズ: 幅 = `_markDotRadius * 2`（20 dp）、高さ = `_markDotRadius * 2 + _actionButtonsHeight`（68 dp）
- ドットの垂直中心は `centerY` に合わせる（上下に均等に拡大）
- ドット内部（中央）に `Icons.local_gas_station`（または相当のフォントアイコン）を `TextPainter` で描画する
- アイコン色: `_markPrimaryColor`（`#2B7A9B`）、サイズ: 14 dp

### 5.3 `_MichiTimelinePainter` への `isFuel` フィールド追加

`_MichiTimelinePainter` は現在 `markLinkType` のみ受け取っている。給油アイコン内包に対応するため `isFuel` フィールドを追加する。

**フィールド定義**

| フィールド名 | 型 | 説明 |
|---|---|---|
| `markLinkType` | `MarkOrLink` | Mark か Link かの区別（既存） |
| `isFuel` | `bool` | 給油ありかどうか（新規追加） |

**`shouldRepaint` の更新対象**

`isFuel` の変化で再描画が発生するよう `shouldRepaint` に追加する。

### 5.4 呼び出し側の変更

`_TimelineItem` が `_MichiTimelinePainter` を生成する際に `isFuel: item.isFuel` を渡す。

---

## 6. BLoC 変更

変更なし。既存の `MichiInfoCardDeleteRequested` Event・ハンドラーをそのまま使用する。

---

## 7. データフロー

```
ユーザー: 削除アイコンをタップ
  ↓
_TimelineItemOverlay の削除ボタン GestureDetector / InkWell
  ↓
MichiInfoCardDeleteRequested(markLinkId) を MichiInfoBloc に add
  ↓（既存ロジック・変更なし）
MichiInfoBloc._onCardDeleteRequested
  ↓
EventRepository.deleteMarkLink（論理削除）
  ↓
EventRepository.fetch → Projection 再構築
  ↓
MichiInfoLoaded.copyWith(projection: ...) emit
  ↓
_MichiTimelinePainter / _TimelineItemOverlay が再描画
```

---

## 8. 依存パッケージ変更

| パッケージ | 変更 |
|---|---|
| `flutter_slidable` | `pubspec.yaml` から削除 |

---

## 9. テストシナリオ

Integration Test グループ `TC-MID`（MichiInfo Delete Icon）

### 前提条件

- シードデータで対象イベントに Mark（給油あり 1 件・給油なし 1 件）・Link が存在する
- 各 `testWidgets` で `app.main()` を個別に呼び出す（統合テスト標準パターン）
- `pumpAndSettle()` は使用禁止。固定時間 `pump(Duration(...))` を使用する

---

### テストシナリオ一覧

| ID | シナリオ名 | 種別 | 優先度 |
|---|---|---|---|
| TC-MID-001 | Mark カードを左スワイプしても削除ボタンが表示されない | Widget | High |
| TC-MID-002 | Link カードを左スワイプしても削除ボタンが表示されない | Widget | High |
| TC-MID-003 | Mark カード右端に赤背景ゴミ箱アイコンが常時表示されている | Widget | High |
| TC-MID-004 | Link カード右端に赤背景ゴミ箱アイコンが常時表示されている | Widget | High |
| TC-MID-005 | 削除アイコンをタップすると該当カードが即座に削除される（確認ダイアログなし） | Integration | High |
| TC-MID-006 | 給油あり Mark の接点ドットが拡大されて給油アイコンが内部に表示される | Widget | Medium |
| TC-MID-007 | 給油なし Mark の接点ドットは通常サイズで表示される | Widget | Medium |

---

### シナリオ詳細

#### TC-MID-001: Mark カードを左スワイプしても削除ボタンが表示されない

**前提**: MichiInfo 画面に Mark カードが 1 件以上表示されている

**手順**:
1. MichiInfo 画面（ミチタブ）を表示する
2. Mark カードを左方向にスワイプする

**期待結果**:
- スワイプ後に削除ボタン（スライドアクション）が表示されない
- `Key('michi_info_card_delete_action_${markId}')` を持つ要素が存在しない（旧キーが消えていること）

**実装ノート（ウィジェットキー一覧）**:
- `Key('michiInfo_button_delete_${markId}')`: 削除アイコンボタン（常時表示）

---

#### TC-MID-002: Link カードを左スワイプしても削除ボタンが表示されない

**前提**: MichiInfo 画面に Link カードが 1 件以上表示されている

**手順**:
1. MichiInfo 画面を表示する
2. Link カードを左方向にスワイプする

**期待結果**:
- スワイプ後に削除ボタン（スライドアクション）が表示されない

**実装ノート（ウィジェットキー一覧）**:
- `Key('michiInfo_button_delete_${linkId}')`: 削除アイコンボタン（常時表示）

---

#### TC-MID-003: Mark カード右端に赤背景ゴミ箱アイコンが常時表示されている

**手順**:
1. MichiInfo 画面を表示する

**期待結果**:
- スワイプ操作なしに Mark カード右端の削除アイコンが表示されている
- `Key('michiInfo_button_delete_${markId}')` が `findsOneWidget`

**実装ノート（ウィジェットキー一覧）**:
- `Key('michiInfo_button_delete_${markId}')`: Mark カード削除アイコンボタン

---

#### TC-MID-004: Link カード右端に赤背景ゴミ箱アイコンが常時表示されている

**手順**:
1. MichiInfo 画面を表示する

**期待結果**:
- スワイプ操作なしに Link カード右端の削除アイコンが表示されている
- `Key('michiInfo_button_delete_${linkId}')` が `findsOneWidget`

**実装ノート（ウィジェットキー一覧）**:
- `Key('michiInfo_button_delete_${linkId}')`: Link カード削除アイコンボタン

---

#### TC-MID-005: 削除アイコンをタップすると該当カードが即座に削除される（確認ダイアログなし）

**前提**: Mark カードが 2 件以上存在する

**手順**:
1. MichiInfo 画面を表示する
2. 任意の Mark カードの削除アイコンをタップする（`Key('michiInfo_button_delete_${markId}')`）

**期待結果**:
- AlertDialog / ConfirmationDialog が表示されない
- タップした Mark カードが一覧から消える
- 他のカードは引き続き表示されている

**実装ノート（ウィジェットキー一覧）**:
- `Key('michiInfo_button_delete_${markId}')`: 削除アイコンボタン

---

#### TC-MID-006: 給油あり Mark の接点ドットが拡大されて給油アイコンが内部に表示される

**前提**: シードデータに `isFuel = true` の Mark が存在する

**手順**:
1. MichiInfo 画面を表示する
2. 給油あり Mark カードのタイムライン接点ドット領域を目視確認する

**期待結果**:
- 接点ドットが通常の円より縦方向に大きく描画されている
- ドット内部に給油アイコン（⛽）が表示されている
- カード行内（テキスト右横）には給油アイコンが表示されていない

**実装ノート（ウィジェットキー一覧）**:
- `Key('michiInfo_button_delete_${fuelMarkId}')`: 給油あり Mark の削除アイコンボタン（表示確認のため利用可）
- 接点ドットは `CustomPaint` のため Widget キーでの直接検証は不可。目視またはスクリーンショット比較で確認する

---

#### TC-MID-007: 給油なし Mark の接点ドットは通常サイズで表示される

**前提**: シードデータに `isFuel = false` の Mark が存在する

**手順**:
1. MichiInfo 画面を表示する
2. 給油なし Mark カードのタイムライン接点ドット領域を目視確認する

**期待結果**:
- 接点ドットが通常の円サイズ（変更前と同等）で表示されている
- ドット内部に給油アイコンが表示されていない

**実装ノート（ウィジェットキー一覧）**:
- `Key('michiInfo_button_delete_${noFuelMarkId}')`: 給油なし Mark の削除アイコンボタン（表示確認のため利用可）
- 接点ドットは `CustomPaint` のため Widget キーでの直接検証は不可

---

## 10. 対象外

- 削除取り消し（Undo）
- 物理削除
- 挿入モード中の削除（挿入モード中は削除アイコンを非表示にする）
- `seq` の再採番
- Link カード接点ドットの給油アイコン対応
- ActionTime 自体の表示仕様変更
