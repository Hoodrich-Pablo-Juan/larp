#!/bin/bash
FIREFOX_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default*" | head -1)
if [ -z "$FIREFOX_PROFILE" ]; then
    echo "Firefox profile not found"
    exit 1
fi

mkdir -p "$FIREFOX_PROFILE/chrome"
git clone https://github.com/akkva/gwfox /tmp/gwfox 2>/dev/null
cp -r /tmp/gwfox/* "$FIREFOX_PROFILE/chrome/"
rm -rf /tmp/gwfox

if ! grep -q "toolkit.legacyUserProfileCustomizations.stylesheets" "$FIREFOX_PROFILE/prefs.js" 2>/dev/null; then
    echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$FIREFOX_PROFILE/prefs.js"
fi

if ! grep -q "svg.context-properties.content.enabled" "$FIREFOX_PROFILE/prefs.js" 2>/dev/null; then
    echo 'user_pref("svg.context-properties.content.enabled", true);' >> "$FIREFOX_PROFILE/prefs.js"
fi

if ! grep -q "widget.gtk.rounded-bottom-corners.enabled" "$FIREFOX_PROFILE/prefs.js" 2>/dev/null; then
    echo 'user_pref("widget.gtk.rounded-bottom-corners.enabled", true);' >> "$FIREFOX_PROFILE/prefs.js"
fi

echo "gwfox theme installed and configured. Restart Firefox."
