#!/bin/bash

echo "📂 Copying complete home directory to SMB share..."
echo "================================================="

# Source and destination
SOURCE="/home/moawia"
DEST="/home/moawia/smb-mount"

echo "Source: $SOURCE"
echo "Destination: $DEST"
echo ""

# Copy everything except the smb-mount directory itself (to avoid recursion)
echo "🔄 Copying all files and directories..."
rsync -av --progress --exclude='smb-mount' "$SOURCE/" "$DEST/"

echo ""
echo "✅ Copy completed!"
echo ""
echo "📊 Verifying copy:"
echo "SMB share contents:"
ls -la "$DEST" | head -15
echo ""
echo "📈 SMB share size:"
du -sh "$DEST" 2>/dev/null
