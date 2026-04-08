# 開発ルール

## Spec駆動開発

全Featureの実装は必ず **Specを先に用意してから** 行う。

- Spec格納場所: `docs/Spec/Features/`
- `architect` がSpecを作成・更新する
- `flutter-dev` はSpecを参照して実装する
- Specが存在しない・曖昧な場合は実装を停止し `architect` に差し戻す

## 要件定義

- 追加要件が発生した場合 `product-manager` が要件書を作成する（格納: `docs/Requirements/`）
- `architect` は要件書をもとにFeature Specを作成する
- Flutter移行タスクは要件書の要否をユーザーと都度相談する

## 要件 vs バグ修正の判断

依頼が要件か バグ修正か曖昧な場合は、必ずユーザーに確認してから進める。

| 種別 | フロー |
|---|---|
| 要件（機能追加・変更） | product-manager（要件書）→ architect（Spec）→ 実装 |
| バグ修正 | flutter-dev（修正）→ reviewer → tester |

## バグ修正中に想定外動作を発見した場合

| 状況 | 対応 |
|---|---|
| 明らかにバグ（仕様矛盾・クラッシュ・データ破損） | 合わせて修正する |
| 仕様かバグか判断が難しい | 修正せずユーザーに報告する |
