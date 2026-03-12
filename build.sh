#!/bin/bash

# build.sh - Script para compilar o Inkstage

echo "🔨 Building Inkstage..."

# Diretórios
SRC_DIR="src/Inkstage"
BUILD_DIR="build"
APP_NAME="Inkstage"

# Criar diretório de build se não existir
mkdir -p "$BUILD_DIR"

# Encontrar todos os arquivos Swift
SWIFT_FILES=$(find "$SRC_DIR" -name "*.swift")

echo "📄 Swift files found:"
echo "$SWIFT_FILES"
echo ""

# Compilar
echo "⚙️  Compiling..."
swiftc \
    -o "$BUILD_DIR/$APP_NAME" \
    -I /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib \
    -L /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib \
    -framework AppKit \
    -framework SwiftUI \
    -framework Combine \
    -framework CoreML \
    -framework Vision \
    -framework PencilKit \
    $SWIFT_FILES

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Assinar o binário
    codesign --force --deep --sign - "$BUILD_DIR/$APP_NAME"
    
    # Atualizar o app bundle
    cp "$BUILD_DIR/$APP_NAME" "$BUILD_DIR/$APP_NAME.app/Contents/MacOS/"
    
    echo "🎉 App bundle updated at: $BUILD_DIR/$APP_NAME.app"
else
    echo "❌ Build failed"
    exit 1
fi
