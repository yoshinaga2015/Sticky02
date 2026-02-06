#!/bin/bash

# Sticky DMG作成スクリプト

set -e

# 設定
APP_NAME="Sticky"
APP_PATH="${1:-}"
DMG_NAME="${APP_NAME}"
DMG_TEMP="${DMG_NAME}-temp.dmg"
DMG_FINAL="${DMG_NAME}.dmg"
VOLUME_NAME="${APP_NAME}"
APP_DIR="/Applications"

# 引数チェック
if [ -z "$APP_PATH" ]; then
    echo "エラー: アプリケーションパスを指定してください"
    echo "使用方法: $0 /path/to/Sticky.app"
    echo "例: $0 ~/Desktop/Sticky.app"
    exit 1
fi

if [ ! -d "$APP_PATH" ]; then
    echo "エラー: アプリケーションフォルダが見つかりません: $APP_PATH"
    exit 1
fi

# 既存のDMGファイルを削除
if [ -f "$DMG_TEMP" ]; then
    rm "$DMG_TEMP"
fi

if [ -f "$DMG_FINAL" ]; then
    rm "$DMG_FINAL"
fi

echo "DMGを作成しています..."

# DMGのサイズを計算（アプリサイズ + 余裕）
APP_SIZE=$(du -sm "$APP_PATH" | cut -f1)
DMG_SIZE=$((APP_SIZE + 50))  # 50MBの余裕を追加

# 一時DMGを作成
hdiutil create -srcfolder "$APP_PATH" -volname "$VOLUME_NAME" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size ${DMG_SIZE}m "$DMG_TEMP"

# DMGをマウント
MOUNT_DIR="/Volumes/${VOLUME_NAME}"
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$DMG_TEMP" | egrep '^/dev/' | sed 1q | awk '{print $1}')

echo "DMGをマウントしました: $DEVICE"

# READMEファイルを作成
echo "READMEファイルを作成しています..."
cat > "$MOUNT_DIR/README.txt" <<EOF
Sticky インストール手順
=====================

1. $APP_NAME.app をアプリケーションフォルダにドラッグ&ドロップしてください

   - Finderのサイドバーから「アプリケーション」フォルダを開く
   - このDMGウィンドウから $APP_NAME.app をアプリケーションフォルダにドラッグ&ドロップ

   ※ DMGウィンドウが表示されない場合は、Finderのサイドバーから「$VOLUME_NAME」をクリックして開いてください

2. アプリケーションを起動

   - アプリケーションフォルダから $APP_NAME.app をダブルクリック

初回起動時のセキュリティ警告について
------------------------------------

このアプリは公証されていないため、初回起動時にmacOSがセキュリティ警告を表示します。

以下の手順で許可してください：

1. $APP_NAME.app を右クリック → 「開く」を選択
2. または、システム環境設定の「セキュリティとプライバシー」から「このまま開く」をクリック

システム要件
-----------

- macOS 13.5 以降
- Apple Silicon または Intel Mac
EOF

# ウィンドウ設定を行う
echo "DMGウィンドウの設定を行っています..."
osascript <<EOF
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        delay 2
        if exists container window then
            set theWindow to container window
            set current view of theWindow to icon view
            set toolbar visible of theWindow to false
            set statusbar visible of theWindow to false
            set the bounds of theWindow to {400, 100, 700, 380}
            set viewOptions to the icon view options of theWindow
            set arrangement of viewOptions to not arranged
            set icon size of viewOptions to 64
            delay 1
            close theWindow
        end if
    end tell
end tell
EOF

# DMGをアンマウント
echo "DMGをアンマウントしています..."
hdiutil detach "$DEVICE"

# 最終DMGを作成（読み取り専用、圧縮）
echo "最終DMGを作成しています..."
hdiutil convert "$DMG_TEMP" -format UDZO -imagekey zlib-level=9 -o "$DMG_FINAL"

# 一時DMGを削除
rm "$DMG_TEMP"

echo ""
echo "✅ DMGの作成が完了しました: $DMG_FINAL"
echo ""
