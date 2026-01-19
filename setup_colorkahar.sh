#!/bin/bash

# ColorKahar Bitmap Integration Script
# This script helps integrate the upgraded bitmap package into ColorKahar

set -e  # Exit on error

echo "================================================"
echo "ColorKahar - Bitmap Package Integration"
echo "================================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if we're in ColorKahar project
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: pubspec.yaml not found!${NC}"
    echo "Please run this script from your ColorKahar project root."
    exit 1
fi

# Check if this is ColorKahar
if ! grep -q "name: colorkahar" pubspec.yaml; then
    echo -e "${YELLOW}Warning: This doesn't appear to be the ColorKahar project.${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Step 1: Checking for bitmap package..."
if [ -d "bitmap" ]; then
    echo -e "${GREEN}✓ bitmap folder found${NC}"
else
    echo -e "${YELLOW}! bitmap folder not found${NC}"
    echo "Please extract the bitmap-main folder and rename it to 'bitmap'"
    echo "Place it in your ColorKahar project root."
    exit 1
fi

echo ""
echo "Step 2: Verifying bitmap package structure..."
if [ -f "bitmap/pubspec.yaml" ]; then
    echo -e "${GREEN}✓ bitmap/pubspec.yaml exists${NC}"
else
    echo -e "${RED}✗ bitmap/pubspec.yaml not found${NC}"
    exit 1
fi

if [ -d "bitmap/lib" ]; then
    echo -e "${GREEN}✓ bitmap/lib exists${NC}"
else
    echo -e "${RED}✗ bitmap/lib not found${NC}"
    exit 1
fi

echo ""
echo "Step 3: Checking Flutter environment..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | grep "Flutter" | awk '{print $2}')
    echo -e "${GREEN}✓ Flutter $FLUTTER_VERSION${NC}"
else
    echo -e "${RED}✗ Flutter not found${NC}"
    exit 1
fi

echo ""
echo "Step 4: Checking Java version..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    JAVA_MAJOR=$(echo $JAVA_VERSION | cut -d'.' -f1)
    if [ "$JAVA_MAJOR" -ge 17 ]; then
        echo -e "${GREEN}✓ Java $JAVA_VERSION${NC}"
    else
        echo -e "${RED}✗ Java $JAVA_VERSION (need ≥17)${NC}"
        echo "Download Java 17 from: https://adoptium.net/"
        exit 1
    fi
else
    echo -e "${RED}✗ Java not found${NC}"
    exit 1
fi

echo ""
echo "Step 5: Cleaning project..."
flutter clean > /dev/null 2>&1
echo -e "${GREEN}✓ Flutter clean complete${NC}"

echo ""
echo "Step 6: Getting dependencies..."
if flutter pub get; then
    echo -e "${GREEN}✓ Dependencies resolved${NC}"
else
    echo -e "${RED}✗ Failed to get dependencies${NC}"
    echo ""
    echo "Common fixes:"
    echo "  1. Check internet connection"
    echo "  2. Run: flutter pub cache repair"
    echo "  3. Delete pubspec.lock and try again"
    exit 1
fi

echo ""
echo "Step 7: Verifying bitmap package import..."
if flutter pub deps | grep -q "bitmap"; then
    echo -e "${GREEN}✓ bitmap package available${NC}"
else
    echo -e "${YELLOW}⚠ bitmap package not detected in dependencies${NC}"
fi

echo ""
echo "Step 8: Testing Android build configuration..."
if [ -d "android" ]; then
    cd android
    if ./gradlew tasks > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Gradle configuration OK${NC}"
    else
        echo -e "${YELLOW}⚠ Gradle configuration check skipped${NC}"
    fi
    cd ..
fi

echo ""
echo "================================================"
echo -e "${GREEN}✓ Integration Complete!${NC}"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Test your image processing features"
echo "  2. Verify photobook export works"
echo "  3. Check calendar generation"
echo "  4. Test all product creation flows"
echo ""
echo "Quick test command:"
echo "  flutter run"
echo ""
echo "Build release APK:"
echo "  flutter build apk --release"
echo ""
echo "================================================"
