#!/bin/bash

# Test Backend OAuth Redirect Script
# This script helps verify if the backend is properly configured for mobile redirects

echo "════════════════════════════════════════════════════════════════"
echo "Testing Backend OAuth Configuration"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BACKEND_URL="http://localhost:8080"

echo "Step 1: Testing if backend is running..."
echo "----------------------------------------"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL")

if [ "$HTTP_CODE" -eq "000" ]; then
    echo -e "${RED}✗ Backend is NOT running at $BACKEND_URL${NC}"
    echo ""
    echo "Please start your backend first:"
    echo "  cd /path/to/backend"
    echo "  ./mvnw spring-boot:run"
    echo "  # or"
    echo "  ./gradlew bootRun"
    exit 1
else
    echo -e "${GREEN}✓ Backend is running (HTTP $HTTP_CODE)${NC}"
fi

echo ""
echo "Step 2: Testing OAuth endpoint with platform=mobile..."
echo "--------------------------------------------------------"

# Make request and capture redirect location
REDIRECT_URL=$(curl -s -I "$BACKEND_URL/oauth2/authorization/google?platform=mobile" | grep -i "Location:" | tr -d '\r' | awk '{print $2}')

if [ -z "$REDIRECT_URL" ]; then
    echo -e "${RED}✗ No redirect location found${NC}"
    echo "The backend might not have OAuth configured"
    exit 1
fi

echo "Redirect URL: $REDIRECT_URL"
echo ""

# Check if it redirects to Google OAuth
if [[ "$REDIRECT_URL" == *"accounts.google.com"* ]]; then
    echo -e "${GREEN}✓ Backend correctly redirects to Google OAuth${NC}"
else
    echo -e "${RED}✗ Backend does not redirect to Google OAuth${NC}"
    echo "Expected: https://accounts.google.com/..."
    echo "Got: $REDIRECT_URL"
    exit 1
fi

# Extract redirect_uri parameter
CALLBACK_URI=$(echo "$REDIRECT_URL" | grep -o "redirect_uri=[^&]*" | cut -d= -f2- | python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))")

echo ""
echo "Step 3: Checking Google OAuth callback URI..."
echo "-----------------------------------------------"
echo "Callback URI: $CALLBACK_URI"

if [[ "$CALLBACK_URI" == *"/login/oauth2/code/google" ]]; then
    echo -e "${GREEN}✓ Google OAuth callback URI is correct${NC}"
else
    echo -e "${RED}✗ Google OAuth callback URI looks wrong${NC}"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Backend Configuration Status"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "✓ Backend is accessible"
echo "✓ OAuth endpoint exists"
echo "✓ Redirects to Google OAuth"
echo ""
echo -e "${YELLOW}⚠  IMPORTANT: The issue is AFTER Google authentication${NC}"
echo ""
echo "The problem occurs in the OAuth2AuthenticationSuccessHandler:"
echo "  • After Google redirects back to: $CALLBACK_URI"
echo "  • Backend should redirect to: poetry://app/auth/callback"
echo "  • Instead, backend tries to redirect to: http://localhost:8080/..."
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "What to Check in Backend Code"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "1. Add debug logging to OAuth2AuthenticationSuccessHandler:"
echo "   System.out.println(\"Platform: \" + session.getAttribute(\"oauth2_platform\"));"
echo "   System.out.println(\"Redirect URI: \" + redirectUri);"
echo ""
echo "2. Verify application.yaml has:"
echo "   app:"
echo "     oauth2:"
echo "       authorizedRedirectUris: poetry://app/auth/callback,http://localhost:3000/auth/callback"
echo ""
echo "3. Check if OAuth2PlatformCaptureFilter is registered"
echo ""
echo "4. Test the OAuth flow and check backend console logs"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Testing Instructions"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "1. Start the Flutter app:"
echo "   flutter run"
echo ""
echo "2. Tap 'Continue with Google'"
echo ""
echo "3. Complete Google authentication"
echo ""
echo "4. Check BACKEND console logs - you should see:"
echo "   - Platform captured: mobile"
echo "   - Selected redirect: poetry://app/auth/callback"
echo "   - Redirecting to: poetry://app/auth/callback?access_token=..."
echo ""
echo "5. Check MOBILE app logs - you should see:"
echo "   - 🔗 DEEP LINK RECEIVED!"
echo "   - Full URI: poetry://app/auth/callback?..."
echo ""
echo "If you don't see the deep link in mobile logs, the backend"
echo "is NOT redirecting to the poetry:// scheme!"
echo ""
echo "════════════════════════════════════════════════════════════════"
