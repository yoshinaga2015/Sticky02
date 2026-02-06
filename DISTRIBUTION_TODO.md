# Sticky アプリ配布手順（公証なし・無料版）

## 概要
Apple Developer Programへの有料登録なしで、公証なしの直接配布を行う手順です。

**重要**: 
- Xcodeの「Archive」機能は有料登録が必要なため、この手順では使用しません
- 代わりに、直接ビルドした.appファイルを使用します
- この方法では、ユーザーが初回起動時にセキュリティ警告を受け取り、手動で許可する必要があります

---

## 事前準備チェックリスト

### 必須項目
- [ ] アプリが正常にビルドできることを確認
- [ ] アプリが正常に動作することを確認
- [ ] アプリアイコンが設定されている
- [ ] バージョン番号が適切（現在: 1.0）
- [ ] Bundle Identifierが一意（現在: `yuki.Sticky`）

### 推奨項目
- [ ] アプリの説明文を準備
- [ ] インストール手順の説明文を準備（セキュリティ警告への対応方法を含む）
- [ ] 配布用のDMGまたはZIPファイルの準備

---

## 配布手順

**重要**: Archive機能はApple Developer Programへの有料登録が必要です。
無料で配布する場合は、以下の方法で直接ビルドした.appファイルを使用します。

### ステップ1: Releaseビルドの作成

1. Xcodeでプロジェクトを開く
   ```bash
   open Sticky.xcodeproj
   ```

2. ビルド設定を確認
   - メニューバー: `Product` → `Scheme` → `Sticky` が選択されていることを確認
   - メニューバー: `Product` → `Destination` → `Any Mac` を選択

3. ビルド構成をReleaseに変更
   - Xcodeの上部ツールバーで、現在のスキームの横にある「Edit Scheme」をクリック
   - または、メニューバー: `Product` → `Scheme` → `Edit Scheme...`
   - 左側の「Run」を選択
   - 「Build Configuration」を **「Release」** に変更
   - 「Close」をクリック

4. Releaseビルドを実行
   - メニューバー: `Product` → `Build` (⌘B)
   - または、メニューバー: `Product` → `Build For` → `Running`
   - ビルドが完了するまで待つ

### ステップ2: ビルドされたアプリの取得

1. ビルドフォルダを開く
   - メニューバー: `Product` → `Show Build Folder in Finder`
   - または、Xcodeの左側のナビゲーターで「Report Navigator」（⌘9）を開き、最新のビルドを右クリック → 「Show in Finder」

2. ビルドフォルダ内で.appファイルを探す
   - パス例: `~/Library/Developer/Xcode/DerivedData/Sticky-[ハッシュ]/Build/Products/Release/Sticky.app`
   - または、ビルドフォルダ内の `Products/Release/` フォルダを探す

3. `Sticky.app` をコピー
   - 見つけた `Sticky.app` をデスクトップや任意のフォルダにコピー
   - これが配布用のアプリファイルです
   
   **ターミナルでコピーする場合**:
   ```bash
   # デスクトップにコピーする例
   cp -R "/Users/uxman/Library/Developer/Xcode/DerivedData/Sticky-efgoelnqxtcummetmpabjloxwmtm/Build/Products/Release/Sticky.app" ~/Desktop/
   ```
   
   **注意**: パスは実際のビルドフォルダのパスに置き換えてください。

### ステップ3: 署名の確認（オプション）

Xcodeでビルドしたアプリは、通常自動的に署名されています。確認してみましょう：

1. ターミナルで以下を実行して署名を確認
   ```bash
   codesign -dv --verbose=4 "/Users/uxman/Library/Developer/Xcode/DerivedData/Sticky-efgoelnqxtcummetmpabjloxwmtm/Build/Products/Release/Sticky.app"
   ```
   
   **注意**: パスは実際のビルドフォルダのパスに置き換えてください。
   - ビルドフォルダのパスは、Xcodeの「Product」→「Show Build Folder in Finder」で確認できます
   - または、`find ~/Library/Developer/Xcode/DerivedData -name "Sticky.app" -type d` で検索できます

2. 署名が確認できた場合
   - 「Authority=Apple Development」と表示されていれば、無料アカウントでも署名されています
   - この状態で配布可能です（ただし公証はされていないため、セキュリティ警告が表示されます）

3. 署名されていない場合のみ、以下のコマンドで署名
   ```bash
   codesign --force --deep --sign - "/path/to/Sticky.app"
   ```
   **注意**: 
   - `/path/to/Sticky.app` を実際のパスに置き換えてください
   - この署名は公証されていないため、セキュリティ警告が表示されます

### ステップ4: 配布用パッケージの作成

#### オプションA: ZIPファイルで配布

1. エクスポートされた `Sticky.app` を右クリック
2. 「圧縮」を選択
3. `Sticky.zip` が作成される

#### オプションB: DMGファイルで配布（推奨）

**ディスクユーティリティとは？**
- macOSに標準でインストールされているアプリです
- DMGファイル（ディスクイメージ）を作成・編集するために使用します
- DMGファイルは、アプリを配布する際によく使われる形式です

**ディスクユーティリティの開き方：**
1. **Spotlight検索で開く（推奨）**
   - `⌘ + Space`（Command + スペース）を押す
   - 「ディスクユーティリティ」と入力してEnter
   
2. **Finderから開く**
   - Finderを開く
   - メニューバー: 「移動」→「ユーティリティ」
   - 「ディスクユーティリティ」をダブルクリック
   
3. **Launchpadから開く**
   - Launchpadを開く（F4キー、またはトラックパッドで4本指でピンチ）
   - 「その他」フォルダを開く
   - 「ディスクユーティリティ」をクリック

**DMGファイルの作成手順：**

1. ディスクユーティリティを開く（上記の方法で）
2. メニューバー: 「ファイル」→「新規イメージ」→「空のイメージ」
3. 設定:
   - **名前**: `Sticky`（**重要**: この名前がFinderのサイドバーに表示されます）
   - サイズ: 100MB以上推奨
   - フォーマット: `Mac OS 拡張（ジャーナリング）`
   - 暗号化: なし
   - パーティション: 単一パーティション - GUID パーティションマップ
4. 「作成」をクリック
   - DMGファイルが作成され、**自動的にマウント**されます
   - Finderのサイドバーに「Sticky」と表示されるはずです

**「名称未設定」と表示される場合の対処法：**

もし「名称未設定」と表示されている場合は、以下の方法で名前を変更できます：

**方法1: マウントされたDMGの名前を変更**
1. Finderのサイドバーで「名称未設定」をクリック
2. ウィンドウが開いたら、ウィンドウの上部（タイトルバー）にある「名称未設定」の部分をクリック
3. 「Sticky」と入力してEnterキーを押す
4. または、サイドバーの「名称未設定」を右クリック → 「名前を変更」→「Sticky」と入力

**方法2: ディスクユーティリティで名前を変更**
1. ディスクユーティリティで、左側のリストから「名称未設定」を選択
2. 上部の「名前を変更」ボタンをクリック（または右クリック → 「名前を変更」）
3. 「Sticky」と入力してEnterキーを押す

**方法3: 新しくDMGを作り直す**
- 上記の手順で、名前フィールドに必ず「Sticky」と入力してから「作成」をクリックしてください
   
**「マウントされたDMG」とは？**
- DMGファイルを開いて、仮想的なディスクとして認識させることを「マウント」と言います
- DMGファイルをダブルクリックすると、自動的にマウントされます
- マウントされると、**通常のフォルダのように開いて使える**ようになります

**マウントされたDMGはどこに表示される？**
1. **Finderのサイドバー**
   - Finderを開くと、左側のサイドバーに「Sticky」という名前で表示されます（正しく設定されていれば）
   - 「名称未設定」と表示される場合は、上記の対処法を参照してください
   - 外付けディスクやUSBメモリと同じように表示されます
   
2. **デスクトップ**
   - デスクトップに「Sticky」というアイコンが表示される場合があります
   - （設定によっては表示されない場合もあります）
   
3. **Finderのウィンドウ**
   - マウントされたDMGをクリックすると、Finderのウィンドウが開きます
   - このウィンドウ内にファイルをドラッグ&ドロップできます

5. マウントされたDMG（Finderのサイドバーまたはデスクトップに表示されている「Sticky」または「名称未設定」）に `Sticky.app` をドラッグ&ドロップ
   - 名前が「名称未設定」の場合は、上記の対処法で「Sticky」に変更してから作業を続けてください
6. 必要に応じて、アプリケーションへのショートカットも追加
   - アプリケーションフォルダ（`/Applications`）へのエイリアス（ショートカット）を作成して追加することもできます
   
7. DMGをアンマウント（保存）
   - マウントされたDMGのウィンドウを閉じる
   - Finderのサイドバーで「Sticky」（または「名称未設定」）を右クリック → 「取り出す」を選択
   - または、デスクトップのアイコンを右クリック → 「取り出す」を選択
   - これでDMGファイルに変更が保存されます
8. DMGファイルを右クリック → 「圧縮」でZIP化（オプション）

### ステップ5: 配布用説明文の作成

ユーザー向けに以下の情報を含むREADMEまたは説明文を準備：

```
# Sticky インストール手順

## 初回起動時のセキュリティ警告について

このアプリは公証されていないため、初回起動時にmacOSがセキュリティ警告を表示します。
以下の手順で許可してください：

1. アプリをダウンロード後、ZIPファイルを展開
2. `Sticky.app` をダブルクリック
3. 「Stickyは開発元を確認できないため、開けません」という警告が表示された場合：
   - 「システム環境設定」を開く
   - 「セキュリティとプライバシー」を開く
   - 「このまま開く」ボタンをクリック
   - または、`Sticky.app` を右クリック → 「開く」を選択

## システム要件

- macOS 13.5 以降
- Apple Silicon または Intel Mac

## インストール方法

1. ダウンロードしたファイルを展開
2. `Sticky.app` を「アプリケーション」フォルダにドラッグ&ドロップ
3. アプリケーションを起動
```

---

## 配布後の確認事項

- [ ] ダウンロードしたファイルが正常に展開できる
- [ ] アプリが起動する（セキュリティ警告後の手動許可を含む）
- [ ] アプリの基本機能が動作する
- [ ] 説明文が分かりやすい

---

## トラブルシューティング

### エラー: "Team is not enrolled in the Apple Developer Program"
- **原因**: Archive機能やDistribute App機能は有料登録が必要です
- **解決策**: この手順ではArchiveを使わず、直接ビルドした.appファイルを使用してください（上記のステップ1-2を参照）

### エラー: "No signing certificate found"
- Xcodeの「Preferences」→「Accounts」でApple IDが追加されているか確認
- 「Download Manual Profiles」をクリック
- 無料アカウントでも基本的な署名は可能ですが、公証はされません

### エラー: "Bundle identifier is already in use"
- Bundle Identifierを変更する必要がある場合があります
- Xcodeでプロジェクト設定を開き、Bundle Identifierを変更

### ビルドフォルダが見つからない
- メニューバー: `Product` → `Show Build Folder in Finder` を使用
- または、Xcodeの「Report Navigator」（⌘9）で最新のビルドを右クリック → 「Show in Finder」

### アプリが起動しない
- セキュリティ警告を手動で許可したか確認
- システム環境設定の「セキュリティとプライバシー」で確認
- ターミナルで以下を実行して確認：
  ```bash
  spctl --assess --verbose /path/to/Sticky.app
  ```

---

## 配布先の選択肢

1. **GitHub Releases**
   - リリースページで配布
   - バージョン管理が容易

2. **個人Webサイト**
   - ダウンロードページを作成
   - 説明文と一緒に配布

3. **クラウドストレージ**
   - Google Drive、Dropboxなど
   - 共有リンクで配布

---

## 今後の改善案

- [ ] Apple Developer Programへの登録を検討（$99/年）
- [ ] App Store配布への移行を検討
- [ ] 公証付き配布への移行を検討

---

## 参考リンク

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Xcode User Guide](https://developer.apple.com/xcode/)
- [macOS App Distribution](https://developer.apple.com/distribute/)

---

**最終更新**: 2025年1月
**配布方法**: 公証なし直接配布（無料）
**対象バージョン**: Sticky 1.0
