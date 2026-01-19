#!/bin/bash

# Bitmap Package - Version Compatibility Checker
# This script checks if your environment is compatible with Bitmap 1.0.1

echo "================================================"
echo "Bitmap Package - Compatibility Checker"
echo "Version: 1.0.1"
echo "================================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if all checks pass
ALL_CHECKS_PASSED=true

# Check Flutter version
echo "Checking Flutter version..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | grep "Flutter" | awk '{print $2}')
    echo "  Found: Flutter $FLUTTER_VERSION"
    
    # Extract major.minor version
    FLUTTER_MAJOR=$(echo $FLUTTER_VERSION | cut -d'.' -f1)
    FLUTTER_MINOR=$(echo $FLUTTER_VERSION | cut -d'.' -f2)
    
    if [ "$FLUTTER_MAJOR" -ge 3 ] && [ "$FLUTTER_MINOR" -ge 27 ]; then
        echo -e "  ${GREEN}✓ Flutter version is compatible (≥3.27.0)${NC}"
    else
        echo -e "  ${RED}✗ Flutter version is too old (need ≥3.27.0)${NC}"
        ALL_CHECKS_PASSED=false
    fi
else
    echo -e "  ${RED}✗ Flutter not found in PATH${NC}"
    ALL_CHECKS_PASSED=false
fi
echo ""

# Check Dart version
echo "Checking Dart version..."
if command -v dart &> /dev/null; then
    DART_VERSION=$(dart --version 2>&1 | grep "Dart SDK" | awk '{print $4}')
    echo "  Found: Dart $DART_VERSION"
    
    # Extract major.minor version
    DART_MAJOR=$(echo $DART_VERSION | cut -d'.' -f1)
    DART_MINOR=$(echo $DART_VERSION | cut -d'.' -f2)
    
    if [ "$DART_MAJOR" -ge 3 ] && [ "$DART_MINOR" -ge 6 ]; then
        echo -e "  ${GREEN}✓ Dart version is compatible (≥3.6.0)${NC}"
    else
        echo -e "  ${RED}✗ Dart version is too old (need ≥3.6.0)${NC}"
        ALL_CHECKS_PASSED=false
    fi
else
    echo -e "  ${RED}✗ Dart not found in PATH${NC}"
    ALL_CHECKS_PASSED=false
fi
echo ""

# Check Java version
echo "Checking Java version..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo "  Found: Java $JAVA_VERSION"
    
    # Extract major version
    JAVA_MAJOR=$(echo $JAVA_VERSION | cut -d'.' -f1)
    
    if [ "$JAVA_MAJOR" -ge 17 ]; then
        echo -e "  ${GREEN}✓ Java version is compatible (≥17)${NC}"
    else
        echo -e "  ${RED}✗ Java version is too old (need ≥17)${NC}"
        echo -e "  ${YELLOW}  Download Java 17 from: https://adoptium.net/${NC}"
        ALL_CHECKS_PASSED=false
    fi
else
    echo -e "  ${RED}✗ Java not found in PATH${NC}"
    echo -e "  ${YELLOW}  Download Java 17 from: https://adoptium.net/${NC}"
    ALL_CHECKS_PASSED=false
fi
echo ""

# Check if Android project exists
echo "Checking Android configuration..."
if [ -f "android/build.gradle" ]; then
    echo "  Found: android/build.gradle"
    
    # Check AGP version
    AGP_VERSION=$(grep "com.android.tools.build:gradle" android/build.gradle | awk -F':' '{print $3}' | tr -d "'" | tr -d '"' | tr -d ' ')
    if [ ! -z "$AGP_VERSION" ]; then
        echo "  Android Gradle Plugin: $AGP_VERSION"
        
        AGP_MAJOR=$(echo $AGP_VERSION | cut -d'.' -f1)
        AGP_MINOR=$(echo $AGP_VERSION | cut -d'.' -f2)
        
        if [ "$AGP_MAJOR" -ge 8 ]; then
            echo -e "  ${GREEN}✓ AGP version is compatible (≥8.0)${NC}"
        else
            echo -e "  ${YELLOW}⚠ AGP version should be updated to 8.9.1${NC}"
        fi
    fi
    
    # Check Kotlin version
    KOTLIN_VERSION=$(grep "ext.kotlin_version" android/build.gradle | awk -F'=' '{print $2}' | tr -d "'" | tr -d ' ')
    if [ ! -z "$KOTLIN_VERSION" ]; then
        echo "  Kotlin version: $KOTLIN_VERSION"
        
        KOTLIN_MAJOR=$(echo $KOTLIN_VERSION | cut -d'.' -f1)
        KOTLIN_MINOR=$(echo $KOTLIN_VERSION | cut -d'.' -f2)
        
        if [ "$KOTLIN_MAJOR" -ge 2 ] || ([ "$KOTLIN_MAJOR" -ge 1 ] && [ "$KOTLIN_MINOR" -ge 9 ]); then
            echo -e "  ${GREEN}✓ Kotlin version is compatible (≥1.9.0)${NC}"
        else
            echo -e "  ${YELLOW}⚠ Kotlin version should be updated to 2.1.0${NC}"
        fi
    fi
    
    # Check Gradle wrapper
    if [ -f "android/gradle/wrapper/gradle-wrapper.properties" ]; then
        GRADLE_VERSION=$(grep "distributionUrl" android/gradle/wrapper/gradle-wrapper.properties | awk -F'-' '{print $(NF-1)}')
        if [ ! -z "$GRADLE_VERSION" ]; then
            echo "  Gradle version: $GRADLE_VERSION"
            
            GRADLE_MAJOR=$(echo $GRADLE_VERSION | cut -d'.' -f1)
            GRADLE_MINOR=$(echo $GRADLE_VERSION | cut -d'.' -f2)
            
            if [ "$GRADLE_MAJOR" -ge 8 ]; then
                echo -e "  ${GREEN}✓ Gradle version is compatible (≥8.0)${NC}"
            else
                echo -e "  ${YELLOW}⚠ Gradle version should be updated to 8.11.1${NC}"
            fi
        fi
    fi
    
    # Check minSdkVersion
    if [ -f "android/app/build.gradle" ]; then
        MIN_SDK=$(grep -E "minSdk(Version)?\s+" android/app/build.gradle | head -1 | awk '{print $2}' | tr -d ',')
        if [ ! -z "$MIN_SDK" ]; then
            echo "  Min SDK: $MIN_SDK"
            
            if [ "$MIN_SDK" -ge 24 ]; then
                echo -e "  ${GREEN}✓ Min SDK is compatible (≥24)${NC}"
            else
                echo -e "  ${YELLOW}⚠ Min SDK should be updated to 24${NC}"
                echo -e "  ${YELLOW}  This will drop support for Android 4.1-6.0${NC}"
            fi
        fi
    fi
else
    echo -e "  ${YELLOW}⚠ No Android project found${NC}"
fi
echo ""

# Final summary
echo "================================================"
if [ "$ALL_CHECKS_PASSED" = true ]; then
    echo -e "${GREEN}✓ All required checks passed!${NC}"
    echo ""
    echo "Your environment is compatible with Bitmap 1.0.1"
    echo ""
    echo "Next steps:"
    echo "  1. Update your pubspec.yaml with the new bitmap package"
    echo "  2. Run 'flutter pub get'"
    echo "  3. Update Android Gradle files (see UPGRADE_GUIDE.md)"
    echo "  4. Run 'flutter clean && flutter build apk'"
else
    echo -e "${RED}✗ Some checks failed${NC}"
    echo ""
    echo "Please fix the issues above before upgrading."
    echo "See UPGRADE_GUIDE.md for detailed instructions."
fi
echo "================================================"
