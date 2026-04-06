# 進捗記録: MichiInfo タイムラインUI Canvas/Path 再設計

- 作成日: 2026-04-07
- セッション: MichiInfo Canvas/Path カスタム描画レイアウト実装

---

## 実装内容

### feat: MichiInfo タイムラインUI Canvas/Path ベースに全面再設計（68af4a1）

#### MichiTimelineRowView.swift（全面書き換え）

- `import ComposableArchitecture` を削除（未使用）
- `HStack(spacing: 8)` で左列（Canvas 44pt）と右列（Button + カード）を並べる構成に変更
- `private enum TimelineLayout` で定数を一元管理
  - `cardHeight: CGFloat = 72`
  - `leftColumnWidth: CGFloat = 44`
  - `dotRadius: CGFloat = 6`
  - `thickLineWidth: CGFloat = 4`
  - `thinLineWidth: CGFloat = 1.5`
  - `axisX: CGFloat = 20`
- Canvas に `.allowsHitTesting(false)` を付与

**Mark行のCanvas描画 (`drawMarkTimeline`)**:
- 上の細線: `isFirst == false` のとき (axisX, 0) → ドット上端 (.secondary 細線)
- 下の細線: `isLast == false` のとき ドット下端 → (axisX, size.height) (.secondary 細線)
- ドット: (axisX, midY) 中心、radius=6、`.primary` 色
- 右向き三角形: ドット右隣、高さ16pt、`.systemGray5` 色
- 水平接続線: 三角形右端 → Canvas右端 (.secondary 細線)

**Link行のCanvas描画 (`drawLinkTimeline`)**:
- 太い縦線（区間線）: axisX位置、`.green` 色、lineWidth=4
  - isFirst: midY から開始 / isLast: midY で終了
- 水平接続線: (axisX, midY) → Canvas右端 (.secondary 細線)

#### MichiMarkCardView.swift
- `minHeight: 80` → `minHeight: 72` に変更
- 重複 `import SwiftUI` を削除

#### MichiLinkCardView.swift
- `minHeight: 60` → `minHeight: 72` に変更

---

## 完了した作業

- feat: MichiInfo Canvas/Path 全面再設計 (68af4a1)
- reviewer: PASS 確認済み

---

## 未完了

- 実機/シミュレータでの目視確認（要件書・Spec定義のとおり描画されているかチェック）

---

## 次回セッションで最初にやること

1. **動作確認**: MichiInfo タブの Canvas 描画が実機/シミュレータで意図通りに表示されるか確認
2. **Drift実装への切り替え**: InMemory から Drift Repository への切り替え（未完了タスク継続）
