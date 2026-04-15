# sync-rules: 変更を両プロジェクトに反映する

NomikaiShare と MichiMark の `.claude/rules/` または `.claude/agents/` に加えた変更を、もう一方のプロジェクトにも反映する。

## プロジェクトパス

```
NS = /Users/kurosakinobuyuki/ClaudeCode/App/NomikaiShare
MM = /Users/kurosakinobuyuki/ClaudeCode/App/MichiMark
```

## 手順

1. `$ARGUMENTS` に反映したい内容・対象ファイルが書かれている場合はそれを使う。なければ直前の会話から何を反映するか判断する。
2. **現在のプロジェクトで変更済みのファイル**を Read して内容を確認する。
3. **もう一方のプロジェクトの対応ファイル**を Read する。
4. 同じ変更内容を適用する。このとき以下の文字列を置換する：

| NS 側の文字列 | MM 側の文字列 |
|---|---|
| `NomikaiShare` | `MichiMark` |
| `NomikaiShare_Design_Constitution` | `MichiMark_Design_Constitution` |
| `NomikaiShare_Architecture_Diagram` | `MichiMark_Architecture_Diagram` |

5. 変更内容を簡潔に報告する（「〇〇に△△を追加しました」レベルでOK）。

## 注意

- 変更箇所以外は絶対に触らない。ファイル全体のフォーマットや他の内容は変えない。
- CLAUDE.md・settings.json・settings.local.json は対象外（明示的に指示された場合のみ）。
- 置換が不要な内容（共通ルール本文など）はそのままコピーする。
