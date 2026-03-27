# 2026-03-27 Selection Feature 実装

## 完了した作業

### 設計憲章更新
- `docs/Architecture/MichiMark_Design_Constitution.md` §9 に **go と push の使い分け** を追記
  - `context.go()` ── 一方向遷移（戻り値なし）
  - `context.push()` ── 結果を受け取るモーダル遷移（`await` + `mounted` チェック必須）
  - `context.push` を await する Widget は StatefulWidget とする

### InMemory Repository スタブ実装
| ファイル | 内容 |
|---|---|
| `repository/impl/in_memory/in_memory_event_repository.dart` | EventRepository のInMemory実装 |
| `repository/impl/in_memory/in_memory_trans_repository.dart` | TransRepository のInMemory実装 |
| `repository/impl/in_memory/in_memory_member_repository.dart` | MemberRepository のInMemory実装 |
| `repository/impl/in_memory/in_memory_tag_repository.dart` | TagRepository のInMemory実装 |
| `repository/impl/in_memory/in_memory_action_repository.dart` | ActionRepository のInMemory実装 |

### Selection Feature 実装
| ファイル | 内容 |
|---|---|
| `features/selection/selection_args.dart` | SelectionType enum・SelectionMode enum・SelectionArgs（router extra用） |
| `features/selection/selection_result.dart` | sealed SelectionResult（Trans/Members/Tags/Actions） |
| `features/selection/draft/selection_draft.dart` | 選択中IDのSet・toggle() |
| `features/selection/projection/selection_projection.dart` | SelectionProjection・SelectionItemProjection |
| `features/selection/bloc/selection_event.dart` | Started / ItemToggled / Confirmed / Dismissed |
| `features/selection/bloc/selection_state.dart` | Loading/Loaded/Error + sealed Delegate |
| `features/selection/bloc/selection_bloc.dart` | SelectionTypeに応じてRepository呼び出し・結果生成 |
| `adapter/selection_adapter.dart` | Domain → SelectionProjection 変換 |
| `features/selection/view/selection_page.dart` | ListTileベースのチェックリストUI |

### アプリ統合
- `app/app.dart` — MultiRepositoryProvider で全Repository を提供
- `app/router.dart` — `/selection` ルート追加
- `features/basic_info/view/basic_info_view.dart` — StatefulWidget化・`await context.push` + `mounted` チェック

---

## 未完了・次回やること

| 優先度 | Feature | 内容 |
|---|---|---|
| 高 | `michi_info` | マーク/リンク一覧タブ Bloc/View 実装 |
| 高 | `mark_detail` | マーク詳細編集 Feature |
| 中 | `link_detail` | リンク詳細編集 Feature |
| 中 | `payment_detail` | 支払詳細編集 Feature |
| 中 | `payment_info` | 支払情報タブ Bloc/View 実装 |
| 低 | テストデータ投入 | ※下記メモ参照 |
| 低 | drift実装 | EventRepository 等の永続化実装 |

---

## 設計上の重要メモ

- **InMemory スタブは空リスト**: 現状は選択画面を開いても「選択肢がありません」と表示される。Settings Feature（Trans/Member/Tag/Action の追加画面）を実装するとデータが入り選択が機能するようになる
- **テストデータ投入（将来タスク）**: リリース前に InMemory スタブ（または専用のフィクスチャ）にテストデータを事前投入し、アプリ起動直後から各設定（Trans/Member/Tag/Action/Event）に任意データが入った状態でテストできるようにする。内容はリリース前に見直す。
