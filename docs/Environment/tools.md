# 開発ツール一覧

最終更新: 2026-04-15

## OS・ハードウェア

| 項目 | バージョン |
|---|---|
| macOS | 26.3.1 (Build: 25D2128) |
| アーキテクチャ | Apple Silicon (arm64) |

## Xcode

| 項目 | バージョン |
|---|---|
| Xcode | 26.4 (Build: 17E192) |
| インストール先 | /Applications/Xcode.app |

## Flutter

| 項目 | バージョン |
|---|---|
| Flutter | 3.41.5 (stable) |
| インストール方法 | Homebrew Cask |

```bash
brew install --cask flutter
```

## Homebrew

### 直接インストールしたもの（brew leaves）

```
cocoapods
gh
node
```

### Formula（全インストール済み）

```
ada-url
brotli
c-ares
ca-certificates
cocoapods
fmt
gh
hdrhistogram_c
icu4c@78
libnghttp2
libnghttp3
libngtcp2
libuv
libyaml
llhttp
lz4
node
openssl@3
readline
ruby
simdjson
sqlite
uvwasi
xz
zstd
```

### Cask

```
flutter
```

## 各ツールバージョン

| ツール | バージョン | インストール方法 |
|---|---|---|
| Node.js | v25.8.1 | Homebrew (`brew install node`) |
| npm | 11.11.0 | Node.js に同梱 |
| GitHub CLI (gh) | 2.89.0 | Homebrew (`brew install gh`) |
| Ruby | 2.6.10p210 | macOS 同梱 (universal arm64e) |
| CocoaPods | 1.16.2 | Homebrew (`brew install cocoapods`) |
| Claude Code | 2.1.83 | npm (`npm install -g @anthropic-ai/claude-code`) |

## 再構築手順

```bash
# 1. Homebrew インストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 主要ツールインストール
brew install cocoapods gh node
brew install --cask flutter

# 3. Claude Code インストール
npm install -g @anthropic-ai/claude-code

# 4. Xcode は App Store からインストール
# 5. Flutter の初回セットアップ
flutter doctor
```
