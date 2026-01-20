#!/bin/bash

# Google Sign-In Configuration Checker
# This script verifies Google Sign-In configuration for Android

echo "=========================================="
echo "Google Sign-In Configuration Checker"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the frontend directory
if [ ! -d "android" ]; then
    echo -e "${RED}Error: This script must be run from the frontend directory${NC}"
    exit 1
fi

echo "1. Checking Package Name..."
PACKAGE_NAME=$(grep -oP 'applicationId\s*=\s*"\K[^"]+' android/app/build.gradle.kts)
if [ -z "$PACKAGE_NAME" ]; then
    echo -e "${RED}   ✗ Could not find package name in build.gradle.kts${NC}"
else
    echo -e "${GREEN}   ✓ Package name: $PACKAGE_NAME${NC}"
fi
echo ""

echo "2. Checking Google Client ID..."
CLIENT_ID=$(grep -oP 'googleClientId\s*=\s*"\K[^"]+' lib/core/constants/app_constants.dart)
if [ -z "$CLIENT_ID" ]; then
    echo -e "${RED}   ✗ Could not find Google Client ID in app_constants.dart${NC}"
else
    echo -e "${GREEN}   ✓ Client ID found: $CLIENT_ID${NC}"
    
    # Validate format
    if [[ $CLIENT_ID == *".apps.googleusercontent.com"* ]]; then
        echo -e "${GREEN}   ✓ Client ID format looks correct${NC}"
    else
        echo -e "${YELLOW}   ⚠ Client ID format may be incorrect (should end with .apps.googleusercontent.com)${NC}"
    fi
fi
echo ""

echo "3. Getting SHA-1 Fingerprint..."
cd android
if [ -f "gradlew" ]; then
    echo "   Running gradlew signingReport..."
    ./gradlew signingReport > /tmp/gradle_output.txt 2>&1
    
    SHA1=$(grep -A 2 "Variant: debug" /tmp/gradle_output.txt | grep -oP 'SHA1:\s*\K[0-9A-F:]+' | head -1)
    
    if [ -z "$SHA1" ]; then
        echo -e "${YELLOW}   ⚠ Could not extract SHA-1 from gradle output${NC}"
        echo "   Full output saved to /tmp/gradle_output.txt"
        echo "   Please check manually:"
        echo "   cd android && ./gradlew signingReport"
    else
        echo -e "${GREEN}   ✓ SHA-1 Fingerprint: $SHA1${NC}"
    fi
    rm -f /tmp/gradle_output.txt
else
    echo -e "${RED}   ✗ gradlew not found. Please run this script from the frontend directory${NC}"
fi
cd ..
echo ""

echo "4. Verification Checklist:"
echo "   Please verify the following in Google Cloud Console:"
echo "   https://console.cloud.google.com/apis/credentials"
echo ""
echo "   [ ] OAuth client type is 'Android' (not 'Web' or 'Installed')"
if [ ! -z "$PACKAGE_NAME" ]; then
    echo "   [ ] Package name matches exactly: $PACKAGE_NAME"
fi
if [ ! -z "$SHA1" ]; then
    echo "   [ ] SHA-1 fingerprint is added: $SHA1"
fi
if [ ! -z "$CLIENT_ID" ]; then
    echo "   [ ] Client ID matches: $CLIENT_ID"
fi
echo "   [ ] Wait 5-10 minutes after making changes in Google Cloud Console"
echo ""

echo "5. Common Issues:"
echo "   - If SignInHubActivity opens and closes immediately:"
echo "     → Check SHA-1 fingerprint is correct"
echo "     → Verify package name matches exactly (case-sensitive)"
echo "     → Ensure OAuth client type is 'Android'"
echo "     → Wait 5-10 minutes after updating Google Cloud Console"
echo ""
echo "   - Error code 10 (DEVELOPER_ERROR):"
echo "     → SHA-1 fingerprint mismatch"
echo "     → Package name mismatch"
echo "     → Wrong Client ID"
echo ""

echo "=========================================="
echo "Check complete!"
echo "=========================================="

