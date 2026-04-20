---
date: 2026-04-20
task: HOTFIX-2 T-620 Share.share() sharePositionOrigin修正
status: DONE
---

# HOTFIX-2: Share.share() sharePositionOrigin 修正

## 完了した作業

### T-620: Share.share() 呼び出し箇所調査・sharePositionOrigin 修正

**修正ファイル**
- `flutter/lib/features/invite_link_share/view/widgets/result_view.dart`
  - `_share()` メソッド（123〜128行目）に `sharePositionOrigin` 追加

**修正内容**
```dart
// 修正前
Share.share(shareText);

// 修正後
final box = context.findRenderObject() as RenderBox?;
final rect = box != null
    ? box.localToGlobal(Offset.zero) & box.size
    : null;
Share.share(shareText, sharePositionOrigin: rect);
```

**調査結果**
- Navigator.pop() 後に Share.share() を呼ぶ問題はなかった（構造上、問題なし）
- 根本原因は `sharePositionOrigin` が未指定だったこと

**dart analyze**: エラー0件

## 未完了

なし（手動デバイステスト推奨：Share シートが正しく表示されることを確認）

## 次回セッションで最初にやること

- T-611 BRAND-1 デザイン案（v2）のユーザーフィードバック確認 → 確定後 T-612 Figmaファイル作成へ
- T-428 SNS用バナー・投稿ビジュアル作成（T-425承認後）
