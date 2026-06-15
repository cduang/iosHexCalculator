#!/bin/bash
# 构建 HexCalculator 并打包为 TrollStore 可用的 .tipa 文件
# 需要在 macOS 上运行，并安装 Xcode 命令行工具

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
PROJECT_NAME="HexCalculator"
SCHEME="HexCalculator"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
EXPORT_DIR="$BUILD_DIR/export"
TIPA_NAME="${PROJECT_NAME}.tipa"

echo "=========================================="
echo " HexCalculator → .tipa 打包脚本"
echo "=========================================="

# 清理旧构建
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "[1/4] 正在编译 Release 版本..."

xcodebuild \
    -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    archive \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    AD_HOC_CODE_SIGNING_ALLOWED=YES \
    | xcpretty 2>/dev/null || cat

APP_PATH="$ARCHIVE_PATH/Products/Applications/$PROJECT_NAME.app"

if [ ! -d "$APP_PATH" ]; then
    echo "错误: 找不到编译产物 $APP_PATH"
    exit 1
fi

echo "[2/4] 可选: 使用 ldid 签名 (若已安装)..."

if command -v ldid &> /dev/null; then
    ENTITLEMENTS="$PROJECT_DIR/HexCalculator.entitlements"
    if [ -f "$ENTITLEMENTS" ]; then
        ldid -S"$ENTITLEMENTS" "$APP_PATH/$PROJECT_NAME"
        echo "  已使用 entitlements 签名"
    else
        ldid -S "$APP_PATH/$PROJECT_NAME"
        echo "  已使用 ad-hoc 签名"
    fi
else
    echo "  跳过 ldid (未安装，TrollStore 通常仍可安装)"
fi

echo "[3/4] 打包 IPA..."

PAYLOAD_DIR="$BUILD_DIR/Payload"
mkdir -p "$PAYLOAD_DIR"
cp -r "$APP_PATH" "$PAYLOAD_DIR/"

IPA_PATH="$BUILD_DIR/$PROJECT_NAME.ipa"
cd "$BUILD_DIR"
zip -qr "$IPA_PATH" Payload

echo "[4/4] 生成 .tipa..."

TIPA_PATH="$BUILD_DIR/$TIPA_NAME"
cp "$IPA_PATH" "$TIPA_PATH"

echo ""
echo "✅ 打包完成!"
echo "   输出文件: $TIPA_PATH"
echo ""
echo "安装方式:"
echo "  1. 将 $TIPA_NAME 传输到 iPhone"
echo "  2. 用 TrollStore 打开并安装"
echo ""
