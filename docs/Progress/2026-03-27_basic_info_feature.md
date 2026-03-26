# 2026-03-27 basic_info Feature 実装

## 完了した作業

### 設計憲章更新
- `docs/Architecture/MichiMark_Design_Constitution.md` に **#17 EventDetail保存仕様** を追記
  - EventDetailの保存は全タブ（BasicInfo・MichiInfo・PaymentInfo・Overview）の一括保存とする
  - 現時点では未実装。各タブBlocはDraft管理のみ行い、Repositoryへの書き込みは行わない

### basic_info Feature 実装
| ファイル | 内容 |
|---|---|
| `flutter/lib/features/basic_info/draft/basic_info_draft.dart` | SelectedXXXパターン（selectedTrans/selectedMembers/selectedTags/selectedPayMember）でマスター系をDomainオブジェクトとして保持 |
| `flutter/lib/features/basic_info/bloc/basic_info_event.dart` | イベント名変更・選択画面遷移要求など sealed Events |
| `flutter/lib/features/basic_info/bloc/basic_info_state.dart` | Loading/Loaded/Error + sealed Delegate（Trans/Members/Tags/PayMember選択） |
| `flutter/lib/features/basic_info/bloc/basic_info_bloc.dart` | Draft編集管理（保存はTODO・将来EventDetailBlocが全タブ一括保存） |
| `flutter/lib/features/basic_info/view/basic_info_view.dart` | TextField・選択行UIをBlocConsumerで実装。Delegateで選択画面への遷移意図を通知（TODO: 選択画面は未実装） |

### EventDetailPage 更新
- `flutter/lib/features/event_detail/view/event_detail_page.dart`
  - `_EventDetailScaffold` に `BlocProvider<BasicInfoBloc>` を追加
  - basicInfo タブで `BasicInfoView` を表示（プレースホルダー `_BasicInfoTabView` を削除）

---

## 未完了・次回やること

| 優先度 | Feature | 内容 |
|---|---|---|
| 高 | `selection` | 汎用選択画面（BasicInfoの交通手段・メンバー・タグ・支払者ボタン先） |
| 高 | `michi_info` | マーク/リンク一覧タブ Bloc/View 実装 |
| 高 | `mark_detail` | マーク詳細編集 Feature |
| 中 | `link_detail` | リンク詳細編集 Feature |
| 中 | `payment_detail` | 支払詳細編集 Feature |
| 中 | `payment_info` | 支払情報タブ Bloc/View 実装 |
| 低 | drift実装 | EventRepository 等の永続化実装（get_it DIセットアップ含む） |

---

## 設計上の重要メモ

- **BasicInfo保存**: 現時点では保存機能なし。将来 `EventDetailSaveRequested` イベントで全タブのDraftを参照し一括保存する設計
- **BasicInfoDraftのSelectedXXXパターン**: マスター選択結果はIDではなくDomainオブジェクトをそのまま保持する
- **選択画面（selection Feature）が未実装**: BasicInfoViewの各編集ボタンはDelegateを発火するが、router.dartに選択画面ルートが未登録のため現状はナビゲーション先なし
