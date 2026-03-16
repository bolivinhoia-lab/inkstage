#!/bin/bash

# create_dmg.sh - Cria DMG profissional para Inkstage
# Uso: ./create_dmg.sh

set -e

# Configurações
APP_NAME="Inkstage"
APP_VERSION="1.0"
DMG_NAME="${APP_NAME}-v${APP_VERSION}.dmg"
VOLUME_NAME="${APP_NAME} ${APP_VERSION}"
SOURCE_APP="build/Inkstage.app"
ICONS_FILE="build/Inkstage.icns"

# Verifica se o app existe
if [ ! -d "$SOURCE_APP" ]; then
    echo "❌ Erro: $SOURCE_APP não encontrado!"
    echo "   Compile o app primeiro."
    exit 1
fi

# Verifica se create-dmg está instalado
if ! command -v create-dmg &> /dev/null; then
    echo "⚠️  create-dmg não encontrado. Instalando..."
    if command -v brew &> /dev/null; then
        brew install create-dmg
    else
        echo "❌ Homebrew não encontrado. Instale manualmente:"
        echo "   brew install create-dmg"
        exit 1
    fi
fi

# Remove DMG anterior se existir
if [ -f "$DMG_NAME" ]; then
    echo "🗑️  Removendo DMG anterior..."
    rm -f "$DMG_NAME"
fi

# Cria diretório temporário
TEMP_DIR=$(mktemp -d)
echo "📁 Diretório temporário: $TEMP_DIR"

# Copia o app
cp -R "$SOURCE_APP" "${TEMP_DIR}/"

# Remove atributos de quarentena e garante permissões
xattr -cr "${TEMP_DIR}/${APP_NAME}.app"
chmod +x "${TEMP_DIR}/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
echo "🔓 Atributos de quarentena removidos"

# Cria symlink para Applications
ln -s /Applications "${TEMP_DIR}/Applications"

echo "🎨 Criando DMG profissional..."

# Cria a DMG com create-dmg (usando --skip-jenkins para ambientes sem UI)
create-dmg \
    --volname "$VOLUME_NAME" \
    --volicon "$ICONS_FILE" \
    --background "build/dmg-background.png" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 100 \
    --icon "Inkstage.app" 150 190 \
    --hide-extension "Inkstage.app" \
    --app-drop-link 450 190 \

    --skip-jenkins \
    --format UDZO \
    "$DMG_NAME" \
    "$TEMP_DIR"

# Limpa diretório temporário
rm -rf "$TEMP_DIR"

if [ -f "$DMG_NAME" ]; then
    SIZE=$(du -h "$DMG_NAME" | cut -f1)
    echo ""
    echo "✅ DMG criada com sucesso!"
    echo "   📦 Arquivo: $DMG_NAME"
    echo "   📊 Tamanho: $SIZE"
    echo "   📍 Local: $(pwd)/$DMG_NAME"
    echo ""
    echo "🧪 Testando DMG..."
    hdiutil verify "$DMG_NAME" | grep "checksum"
else
    echo "❌ Falha ao criar DMG"
    exit 1
fi
