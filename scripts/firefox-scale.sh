#!/bin/bash
FIREFOX_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default*" | head -1)
if [ -z "$FIREFOX_PROFILE" ]; then
    echo "Firefox profile not found"
    exit 1
fi

sed -i '/layout.css.devPixelsPerPx/d' "$FIREFOX_PROFILE/prefs.js"

echo 'user_pref("layout.css.devPixelsPerPx", "1.0");' >> "$FIREFOX_PROFILE/prefs.js"
echo "Firefox scale set to 1.0. Adjust in about:config if needed."
echo "Higher values make things bigger. Try 1.25, 1.5, etc."
