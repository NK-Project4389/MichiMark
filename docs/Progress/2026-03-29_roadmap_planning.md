# 2026-03-29 ロードマップ・戦略計画

## 完了した作業

- プロダクトビジョン言語化・ロードマップ全体設計（Phase 1〜5）
- マネタイズ戦略確定・公開タイムライン策定
- CLAUDE.md にコンテキスト消費削減ルール追記
- WebSearch / WebFetch 権限を `~/.claude/settings.json` に追加

---

## 確定した主要決定事項

### マネタイズモデル（確定版）

| プラン | 単価 | 台数 | 主な有料機能 |
|---|---|---|---|
| 無料 | ¥0 | 1台 | 記録無制限・直近7日サマリー・イベントOverview |
| 個人プラン | ¥300/月 | 1台 | 月次・任意期間サマリー・CSVエクスポート |
| チームプラン | ¥500/台/月 | 2〜5台 | 管理者ダッシュボード・車両管理 |
| 法人プラン | ¥400/台/月 | 6〜20台 | ボリューム割引 |

- 年払い：2ヶ月分割引
- 転換ポイント：1ヶ月後の月次サマリーアクセスでサブスク案内
- 旅費精算は集客・広告代わりの入口として位置づけ（本丸は訪問作業系）
- 20台超は運行管理システムの領域としてスコープ外
- 運行管理法対応（点呼等）はスコープ外

### スコープ定義

- 対象：自社車両の管理（自社ドライバー × 自社車両）
- 対象外：受託・外注関係 / 運行管理法対応

### ターゲット

- 本丸：訪問作業系（電気・配管・設備工事・ハウスクリーニング等）
- 市場規模：SAM 約100〜130億円/年、SOM 約1〜4億円/年（推計）

### drift実装前の設計考慮事項

| 項目 | 内容 |
|---|---|
| UUIDへの変更 | 全エンティティIDを UUID（String）に変更 |
| Organization / Vehicle エンティティ追加 | ドメインモデルに追加 |
| Event に user_id / vehicle_id 追加 | nullable フィールドとして追加 |
| Repository インターフェース抽象化 | クラウド同期前提のI/F設計 |
| AuthContext の DI 確保 | userId / organizationId / role を持たせる場所を確保 |

---

## 次回やること

### 優先タスク（技術）

1. セッション再起動後に Milelog の競合調査（WebSearch 権限有効化済み）
2. 設定系 Feature 完成（現在実装中）
3. drift実装前に architect がドメインモデル見直し（UUID化・Organization/Vehicle追加）
4. EventDetail 全タブ一括保存（§17）
5. InMemory スタブ seed data 投入
6. drift Repository 実装（UUID設計で）
7. get_it DI セットアップ（AuthContext確保込み）

### 優先タスク（要件書）

1. Topic_Requirements.md 作成
2. ActionTime_Requirements.md 作成
3. Aggregation_Requirements.md 作成
