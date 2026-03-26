# MichiMark Design Constitution

Version: 1.0
Platform: **Flutter / Dart**（SwiftUI版とは別ドキュメント）
Purpose: MichiMark FlutterアプリのアーキテクチャをAIおよび開発者が一貫して実装するための設計原則を定義する。

> **注意**: 本ドキュメントはFlutter実装専用の設計憲章である。
> SwiftUIソースコード（`MichiMark/` ディレクトリ）とは別の設計方針を持つ。

---

# 1. 基本方針

MichiMark Flutterは以下の思想に基づいて設計する。

- **責務分離を徹底する**
- **Feature単位でDraftを所有する**
- **Rootは画面ルーティングのみを担当する**
- **Widget・Domain・永続化の依存方向を固定する**
- **AIによるコード生成でも設計破壊が起きない構造にする**
- **SwiftUI版の設計思想を継承しつつ、Flutterのイディオムに沿って再設計する**

---

# 2. レイヤー構造

MichiMark Flutterは以下のレイヤー構造を厳守する。

```
Widget（View）
  ↓
Projection
  ↓
Draft
  ↓
Adapter
  ↓
Domain
  ↓
Repository
```

依存は上から下のみ許可。逆方向は禁止。

## Widget（View）

- Flutter Widget
- UI表示のみを担当
- ビジネスロジックを持たない
- Domainを直接参照しない
- BlocBuilder / BlocListener で State を受け取る

## Projection

- 表示専用データ
- Domain → Widget の変換を行う
- 状態を保持しない
- UIロジックのみ許容（表示フォーマット・表示文字列など）

## Draft

- 編集中の一時状態
- 永続化されない
- Featureが唯一の所有者となる
- RootはDraftを編集しない
- DomainとUI入力値の橋渡しをする（型変換・不完全な値を許容）

## Adapter

- Draft ↔ Domain の変換
- Domain → Projection の変換
- UI入力の整形・バリデーション補助

## Domain

- ビジネスロジック
- アプリの真のデータ構造
- UIを知らない
- Dartの純粋なimmutableクラスで定義する（`const` コンストラクタ推奨）
- `equatable` を使用して値比較を実現する

## Repository

- 永続化層（drift / ローカルDB）
- **WidgetからRepositoryを直接呼び出すことは禁止**
- BlocはDI（get_it）経由でRepositoryをコンストラクタ注入して呼び出してよい
- インターフェース（abstract class）で定義し、実装を差し替え可能にする

---

# 3. BLoC構造

## 基本構造

```
Event → Bloc → State
```

## Event

- ユーザーアクションまたはシステムイベントを表す
- 命名は動詞句（過去形または進行形）とする
  - 例: `AppStarted`, `SaveButtonPressed`, `DraftUpdated`, `MarkDetailOpened`

## Bloc

- Draft更新・Adapter呼び出し・Delegate通知・Repository呼び出しを行う
- RepositoryはDI（get_it）経由でコンストラクタ注入して使用する
- **WidgetからRepositoryを直接呼び出すことは禁止**
- Navigation操作は禁止（Delegateで意図を伝える）

## State

- UIに渡す状態のみを持つ
- Projectionを含める
- Draftを含める（編集フォームの場合）
- Delegateを含める（遷移意図の通知に使用）

## Cubit

- 単純な状態管理（トグル・ローカルUIステートなど）にはCubitを使用してよい
- ビジネスロジックを含む場合はBlocを使用する

---

# 4. Rootの責務

Rootはナビゲーション管理のみを担当する。

### Rootが行ってよいこと

- `go_router` によるルーティング定義
- Draft の生成 / 破棄 / 受け渡し（編集のみ禁止）
- BlocProviderによる依存注入

### Rootが行ってはいけないこと

- Draft編集
- Domain操作
- ビジネスロジック実装
- Repository呼び出し

---

# 5. Featureの責務

各Featureは以下を担当する。

- Draft所有
- Draft編集
- Domain生成・更新（Adapter経由）
- Projection生成（Adapter経由）

DraftはFeatureが唯一の所有者となる。

---

# 6. Draftのルール

Draftは以下を満たす。

- 未確定データ（保存前の入力値）
- 編集状態
- 永続化しない
- Domainと完全一致する必要はない（UI補助値・入力途中の値を許容）

Draftは以下を持つことがある。

- UI補助値（例: テキストフィールドの入力中文字列）
- Validation状態・エラーメッセージ
- 選択中IDのSet

---

# 7. Projectionのルール

Projectionは以下の制約を持つ。

- 表示整形専用
- ロジックを持たない
- Domainを書き換えない
- 状態を保持しない
- 表示文字列・フォーマット済み値のみを含む

ProjectionはWidgetの入力モデルとする。

---

# 8. Delegateのルール

Feature間通信はDelegateパターンで行う。

```dart
// Stateにdelegateフィールドを持たせ、Rootがlistenして処理する
class FeatureState {
  final FeatureDelegate? delegate;
  ...
}
```

### 許可される内容

- 保存要求
- 削除要求
- 画面遷移要求
- 選択結果の通知

### 禁止事項

- Domain変更
- Draft変更
- Repository呼び出し

---

# 9. Navigationルール

- `go_router` を使用する
- BlocはNavigationを直接操作しない（`context.go()` の呼び出しはBlocに書かない）
- BlocはDelegateをStateに乗せることで遷移意図を通知する
- PageのBlocListener がDelegateを受け取り、`context.go()` で画面遷移する

```dart
// 正しいパターン
BlocConsumer<FeatureBloc, FeatureState>(
  listener: (context, state) {
    // Delegateの種類に応じてgo_routerで遷移
    switch (state.delegate) {
      case OpenDetailDelegate(:final id):
        context.go('/detail/$id');
    }
  },
  builder: (context, state) {
    // UIの描画のみ
  },
)
```

### 禁止事項

- Bloc内で `context.go()` を呼び出すこと
- Widget内で `Navigator.of(context).push()` を呼び出すこと（go_routerに統一）

---

# 10. ドメイン定義

MichiMark Flutterで扱うDomainは以下の通り。

| Domain | 主要プロパティ | ID型 |
|---|---|---|
| EventDomain | eventName, trans, members, tags, markLinks, payments | EventId |
| MarkLinkDomain | type(Mark/Link), date, members, actions, isFuel, memo | MarkLinkId |
| PaymentDomain | amount, payMember, splitMembers, memo | PaymentId |
| MemberDomain | name, mailAddress, isVisible | MemberId |
| TransDomain | name, kmPerGas, meterValue, isVisible | TransId |
| TagDomain | name, isVisible | TagId |
| ActionDomain | name, isVisible | ActionId |

- IDはすべて `String`（UUID）で定義する
- DomainはEquatableを継承する
- DomainはUIを知らない・Draftを知らない

---

# 11. Feature一覧

| Feature | 責務 | 対応SwiftUI Reducer |
|---|---|---|
| event_list | イベント一覧表示・新規作成 | EventListReducer |
| event_detail | タブ管理（basicInfo / michiInfo / paymentInfo） | EventDetailReducer |
| basic_info | イベント基本情報編集 | BasicInfoReducer |
| michi_info | マーク/リンク一覧 | MichiInfoReducer |
| mark_detail | マーク詳細編集 | MarkDetailReducer |
| link_detail | リンク詳細編集 | LinkDetailReducer |
| fuel_detail | 給油詳細編集（mark_detailのサブ） | FuelDetailReducer |
| payment_detail | 支払詳細編集 | PaymentDetailReducer |
| payment_info | 支払情報表示 | PaymentInfoReducer |
| selection | 汎用単一/複数選択 | SelectionFeature |
| settings | 設定メニュー | SettingsReducer |
| trans_setting | 交通手段管理 | TransSettingReducer |
| member_setting | メンバー管理 | MemberSettingReducer |
| tag_setting | タグ管理 | TagSettingReducer |
| action_setting | アクション管理 | ActionSettingReducer |

---

# 12. 選択画面（Selection）の設計

SwiftUI版のSelectioFeatureをFlutter版に移植する際は、以下の方針に従う。

- `SelectionType` enum でユースケースを型安全に区別する
- 単一選択と複数選択は `SelectionMode` enum で区別する
- 選択結果はDelegateで親Featureに返す

```dart
enum SelectionType {
  eventTrans,
  eventMembers,
  eventTags,
  gasPayMember,
  markMembers,
  markActions,
  linkMembers,
  linkActions,
  payMember,
  splitMembers,
}

enum SelectionMode { single, multiple }
```

---

# 13. 永続化方針（drift）

SwiftDataからdriftへの移行方針。

| SwiftData | drift |
|---|---|
| `@Model class EventModel` | `class Events extends Table` |
| `@Relationship(deleteRule: .cascade)` | 外部キー + `onDelete: KeyAction.cascade` |
| `@Relationship(deleteRule: .nullify)` | 外部キー + `onDelete: KeyAction.setNull` |
| `FetchDescriptor` | `select().where()` |
| `ModelContext.save()` | `into(table).insertOrReplace()` |
| `isDeleted: Bool`（論理削除） | `is_deleted BOOLEAN`（論理削除維持） |

Repositoryはabstract classで定義し、drift実装とinMemory実装を切り替え可能にする。

---

# 14. AI実装禁止事項

## 14.1 型安全性の破壊

- `dynamic` 型の使用
- 不必要な型キャスト

## 14.2 Null安全の破壊

- `!`（null assertion）の乱用
- nullチェックなしのアクセス

## 14.3 非同期処理の不正実装

- `BuildContext` を async gap をまたいで使用すること
  - `await` の後に `context` を使う場合は `mounted` チェック必須

## 14.4 ビジネスロジックの混入

- Widget の `build()` 内にビジネスロジックを記述すること

## 14.5 アーキテクチャ破壊

- RootからDomain変更
- WidgetからDomain変更
- DomainからWidget参照
- FeatureからRepository直接呼び出し

## 14.6 コンパイル回避のための不正実装

- `switch` に `default` を追加してコンパイルを通すこと

---

# 15. 設計破壊の禁止

AIが以下を行うことは禁止。

- Feature責務の無断変更
- レイヤー依存の破壊
- Domain構造の無断変更
- Navigation構造の無断変更

設計変更が必要な場合は**実装を停止し提案すること**。

---

# 16. リファクタリング方針

SwiftUI版から移植する際に以下を改善する。

| 改善項目 | SwiftUI版の課題 | Flutter版での対応 |
|---|---|---|
| RootのDraft管理 | RootがmarkDraftsを保持していた | Flutter版はRootをrouting専任とし、DraftはFeature側に移す |
| FuelDetail | MarkDetailのネスト状態として管理されていた | fuel_detailを独立したFeatureとして切り出す |
| SelectionFeature | ActionごとにEvent分岐が複雑だった | SelectionTypeで型安全に整理し、汎用BLocとして実装する |

---

# 17. EventDetail保存仕様

EventDetailの保存は **全タブ一括保存** とする。

## 仕様

- EventDetailはBasicInfo・MichiInfo・PaymentInfo・（Overview）のタブを持つ
- 保存操作はいずれかのタブから行われた場合でも、**すべてのタブのDraftを対象**にEventDomainを更新する
- タブ単独での保存（部分保存）は行わない

## 実装方針（未実装）

- 保存Eventは `EventDetailSaveRequested` として EventDetailBloc に持たせる
- EventDetailBlocは保存時に BasicInfoDraft・MichiInfoDraft・PaymentInfoDraft を参照してEventDomainを更新する
- 各子Blocから最新Draftを取得する方法は実装時に設計する（EventDetailBlocがDraftを内包するか、各子BlocのStateを参照するか）
- 現時点では保存機能は未実装。各タブBlocは編集Draftのみを管理し、Repositoryへの書き込みは行わない

---

# 19. 絶対原則

以下は変更不可の設計原則とする。

- Rootはroutingのみ
- DraftはFeature所有
- DomainはUIを知らない
- Projectionは表示専用
- Delegateは意図のみ

---

# End of Constitution
