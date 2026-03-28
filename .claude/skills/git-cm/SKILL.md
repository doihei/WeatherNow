---
name: git-cm
description: git add からコミットまでを自動化。lint・format チェック後、変更を適切な粒度でコミットにまとめる。
disable-model-invocation: true
---

# git-cm: スマート Git コミット

## 手順

1. **ワーキングツリーの確認**
   `git status` と `git diff`（未追跡ファイル含む）を実行し、すべての変更を把握する。

2. **lint チェック**
   `Tools/.build/release/swiftlint lint .` を実行する。
   - バイナリが存在しない場合は `make bootstrap` を実行してから再試行する。
   - エラーがあればコミットを中断し、ユーザーに報告して終了する。
   - warning のみであれば内容を表示した上で続行する。

3. **フォーマット確認**
   `Tools/.build/release/swiftformat --lint .` を実行する（ドライラン）。
   - 差分がある場合はファイル名を列挙してユーザーに報告し、`Tools/.build/release/swiftformat .` で自動修正してから続行する。

4. **変更のグループ化**
   関連するファイルをロジカルなコミット単位にまとめる。1コミット = 1つの関心事。無関係な変更を同一コミットに混在させない。

5. **グループごとにステージ & コミット**
   各グループについて：
   - 対象ファイルのみをステージ（`git add <files>`）
   - 以下の規約に従いコミットメッセージを作成
   - `git commit -m` でコミット

6. **結果表示**
   すべてのコミット完了後、`git log --oneline -10` を実行してコミット一覧をユーザーに表示する。

## コミットメッセージ規約

```
type(scope): short summary in English (imperative mood)
```

**type 一覧:**
| type | 使いどころ |
|------|-----------|
| `feat` | 新機能・新しい振る舞い |
| `fix` | バグ修正 |
| `refactor` | 振る舞いを変えないリファクタリング |
| `docs` | ドキュメントのみの変更 |
| `test` | テストの追加・更新 |
| `chore` | ビルド設定・SPM マニフェスト・プロジェクト設定 |

**scope（モジュール/レイヤー名を使用）:**
`CoreModels`, `CoreNetwork`, `CoreUI`, `WeatherDomain`, `WeatherFeatureMVVM`, `WeatherFeatureTCA`, `App`

複数スコープにまたがる場合は最上位スコープを使うか省略する。

**ルール:**
- サマリーは英語、命令形（"add", "fix", "remove" — "added" や "fixes" は NG）
- サマリーは72文字以内
- 末尾にピリオド不要
- ユーザーから明示的な指示がない限り、本文や `Co-Authored-By` トレーラーは付けない

**例:**
```
feat(CoreModels): add WeatherCode enum for WMO code mapping
fix(CoreNetwork): handle HTTP 429 in APIClient
chore(WeatherFeatureTCA): add TCA dependency to Package.swift
refactor(WeatherDomain): extract location permission logic into service
```

## 安全ルール

- `git add -A` / `git add .` は使わず、常に対象ファイルを明示してステージする
- `--no-verify` は使わない
- 既存コミットの amend は行わない
- コミットするものがなければその旨を伝えて終了する
