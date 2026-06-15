#!/bin/bash
# 构建 HexCalculator 并打包为 TrollStore 可用的 .tipa 文件
# 无需代码签名，适用于 TrollStore 安装

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
PROJECT_NAME="HexCalculator"
SCHEME="HexCalculator"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
TIPA_NAME="${PROJECT_NAME}.tipa"

echo "=========================================="
echo " HexCalculator → .tipa 打包脚本"
echo "=========================================="

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "[1/3] 正在编译 Release 版本（无签名）..."

xcodebuild \
    -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    archive \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    AD_HOC_CODE_SIGNING_ALLOWED=NO \
    | xcpretty 2>/dev/null || cat

APP_PATH="$ARCHIVE_PATH/Products/Applications/$PROJECT_NAME.app"

if [ ! -d "$APP_PATH" ]; then
    echo "错误: 找不到编译产物 $APP_PATH"
    exit 1
fi

echo "[2/3] 打包 IPA..."

PAYLOAD_DIR="$BUILD_DIR/Payload"
mkdir -p "$PAYLOAD_DIR"
cp -r "$APP_PATH" "$PAYLOAD_DIR/"

IPA_PATH="$BUILD_DIR/$PROJECT_NAME.ipa"
cd "$BUILD_DIR"
zip -qr "$IPA_PATH" Payload

echo "[3/3] 生成 .tipa..."

TIPA_PATH="$BUILD_DIR/$TIPA_NAME"
cp "$IPA_PATH" "$TIPA_PATH"

echo ""
echo "✅ 打包完成!"
echo "   输出文件: $TIPA_PATH"
echo ""
