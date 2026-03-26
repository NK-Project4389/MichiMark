# MichiMark Architecture Diagram

Platform: **Flutter / Dart**（SwiftUI版とは別ドキュメント）
Purpose: MichiMark FlutterアプリのアーキテクチャをAIおよび開発者が正しく理解するための図。

> **注意**: 本ドキュメントはFlutter実装専用のアーキテクチャ図である。
> SwiftUIソースコード（`MichiMark/` ディレクトリ）とは別の構成を持つ。

---

# 1. Global Architecture

依存方向

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

依存は**上から下のみ許可**

逆方向は禁止

---

# 2. BLoC Architecture

```
[User Action]
    ↓
  Event
    ↓
  Bloc  ←→  Draft
    ↓          ↓
  State      Adapter
    ↓          ↓
 Widget     Domain
              ↓
          Repository
```

---

# 3. Navigation Architecture

NavigationはRootがgo_routerで管理する。

```
Router（Root）
  ↓
go_router
  ↓
Route定義
```

FeatureはDelegateで遷移意図を通知する。
Navigator / context.go() の直接呼び出しは禁止。

---

# 4. Feature Internal Structure

```
Event
  ↓
Bloc
  ├── Draft更新
  ├── Adapter呼び出し
  └── Delegate発火
        ↓
      State
        ↓
     Projection
        ↓
      Widget
```

Featureが行ってはいけないこと

- Navigation管理
- Root状態変更
- Repository直接呼び出し

---

# 5. Draft Ownership

DraftはFeatureが所有する。

```
各Feature
  └── 専用Draft（例: EventDetailDraft, MarkDetailDraft）
```

RootはDraftを

- 生成
- 破棄
- 受け渡し

のみ可能。編集は禁止。

---

# 6. Data Flow（Edit）

```
ユーザー入力
  ↓
Widget
  ↓
Event（Bloc）
  ↓
Draft更新
  ↓
Adapter
  ↓
Domain
  ↓
Repository
```

---

# 7. Data Flow（Display）

```
Repository
  ↓
Domain
  ↓
Adapter
  ↓
Projection
  ↓
Widget
```

---

# 8. Feature Communication

Feature間通信はDelegateのみ。

```
ChildFeature
  ↓ delegate（State経由）
ParentFeature or Root
  ↓ （必要に応じて）
Root Navigation（go_router）
```

---

# 9. Navigation Structure

```
Root（go_router）
  ├── /                     → EventListPage
  ├── /event/:id            → EventDetailPage（タブ: basicInfo / michiInfo / paymentInfo）
  │     ├── /mark/:id       → MarkDetailPage
  │     ├── /link/:id       → LinkDetailPage
  │     ├── /payment/:id    → PaymentDetailPage
  │     └── /fuel/:id       → FuelDetailPage
  ├── /selection            → SelectionPage（汎用選択）
  └── /settings             → SettingsPage
        ├── /trans           → TransSettingPage
        │     └── /create   → TransSettingCreatePage
        ├── /member          → MemberSettingPage
        │     └── /create   → MemberSettingCreatePage
        ├── /tag             → TagSettingPage
        │     └── /create   → TagSettingCreatePage
        └── /action          → ActionSettingPage
              └── /create   → ActionSettingCreatePage
```

---

# 10. Folder Structure

```
lib/
  ├── app/
  │   ├── router.dart                    # go_router定義（Root）
  │   └── app.dart
  ├── features/
  │   ├── event_list/
  │   │   ├── bloc/
  │   │   │   ├── event_list_bloc.dart
  │   │   │   ├── event_list_event.dart
  │   │   │   └── event_list_state.dart
  │   │   ├── draft/
  │   │   │   └── event_list_draft.dart
  │   │   ├── projection/
  │   │   │   └── event_list_projection.dart
  │   │   └── view/
  │   │       └── event_list_page.dart
  │   ├── event_detail/
  │   │   ├── bloc/ draft/ projection/ view/
  │   ├── basic_info/
  │   │   ├── bloc/ draft/ projection/ view/
  │   ├── michi_info/
  │   │   ├── bloc/ draft/ projection/ view/
  │   ├── mark_detail/
  │   │   ├── bloc/ draft/ projection/ view/
  │   ├── link_detail/
  │   │   ├── bloc/ draft/ projection/ view/
  │   ├── fuel_detail/
  │   │   ├── bloc/ draft/ projection/ view/
  │   ├── payment_detail/
  │   │   ├── bloc/ draft/ projection/ view/
  │   ├── payment_info/
  │   │   ├── bloc/ draft/ projection/ view/
  │   ├── selection/
  │   │   ├── bloc/ draft/ projection/ view/
  │   └── settings/
  │       ├── trans_setting/
  │       ├── member_setting/
  │       ├── tag_setting/
  │       └── action_setting/
  ├── domain/
  │   ├── transaction/               # イベント単位で生成・削除されるデータ
  │   │   ├── event/
  │   │   │   └── event_domain.dart
  │   │   ├── mark_link/
  │   │   │   └── mark_link_domain.dart
  │   │   └── payment/
  │   │       └── payment_domain.dart
  │   └── master/                    # Settings画面で管理する長期存在データ
  │       ├── member/
  │       │   └── member_domain.dart
  │       ├── trans/
  │       │   └── trans_domain.dart
  │       ├── tag/
  │       │   └── tag_domain.dart
  │       └── action/
  │           └── action_domain.dart
  ├── adapter/
  │   ├── event_adapter.dart
  │   ├── mark_link_adapter.dart
  │   ├── payment_adapter.dart
  │   └── settings_adapter.dart
  └── repository/
      ├── event_repository.dart
      ├── member_repository.dart
      ├── trans_repository.dart
      ├── tag_repository.dart
      └── action_repository.dart
```

---

# 11. Layer Responsibilities

| レイヤー | 責務 | 禁止 |
|---|---|---|
| Widget | UI表示のみ | ビジネスロジック / Domain参照 |
| Projection | 表示専用データ | Domain変更 / 状態保持 |
| Draft | 編集状態 / 未確定データ | 永続化 |
| Adapter | Draft↔Domain変換 / Projection生成 | Repository呼び出し |
| Domain | ビジネスロジック | UIを知ること |
| Repository | 永続化（drift） | ビジネスロジック |

---

# 12. Persistence Architecture（drift）

```
Domain
  ↓（Mapper）
drift Table（DB Model）
  ↓
SQLite（ローカルDB）
```

- EventテーブルはMarkLink・Paymentとリレーション（cascade delete）
- Member・Trans・Tag・ActionはEventと多対多（junction table）
- 論理削除（`isDeleted`）を維持する

---

# 13. Selection Feature Architecture

```
親Feature（例: BasicInfoBloc）
  ↓ Delegate（SelectionRequestedDelegate）
Root
  ↓ go_router
SelectionPage
  ↓ Delegate（SelectionCompletedDelegate）
Root
  ↓ go_router（pop）+ result渡し
親Feature
  ↓ DraftUpdated Event
親Bloc → Draft更新
```

---

# 14. AI Safety Rules

AI実装時の禁止事項

- RootからDomain変更
- WidgetからDomain変更
- DraftをRootが編集
- dynamic型の使用
- !（null assertion）の乱用
- BuildContextをasync gapをまたいで使用（mountedチェック必須）
- build()内にビジネスロジック
- switchにdefaultを追加してコンパイルを通す

---

# 15. Key Architecture Principles

- Rootはrouting layer
- DraftはFeature所有
- Projectionは表示専用
- Delegateは意図のみ
- DomainはUIを知らない

---

# End of Architecture Diagram
