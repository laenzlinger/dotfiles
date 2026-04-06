#!/usr/bin/env bash
set -euo pipefail
command -v python3 >/dev/null || { echo "python3 required" >&2; exit 1; }

prefs="$HOME/.config/vivaldi/Default/Preferences"
colors_css="$HOME/.config/waybar/colors.css"

[ -f "$prefs" ] || exit 0
[ -f "$colors_css" ] || exit 0

# Parse base16 colors
declare -A c
while IFS= read -r line; do
    if [[ "$line" =~ @define-color\ (base[0-9A-Fa-f]+)\ (#[0-9a-fA-F]+)\; ]]; then
        c[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
    fi
done < "$colors_css"

# Detect dark/light from base00 luminance
is_dark=$(python3 -c "
r,g,b = int('${c[base00]}'[1:3],16), int('${c[base00]}'[3:5],16), int('${c[base00]}'[5:7],16)
print('true' if (0.299*r + 0.587*g + 0.114*b) < 128 else 'false')
")

if [[ "$is_dark" == "true" ]]; then
    theme_id="base16-dark"
    theme_name="Base16 Dark"
else
    theme_id="base16-light"
    theme_name="Base16 Light"
fi

theme_json=$(python3 -c "
import json
print(json.dumps({
    'accentFromPage': False, 'accentOnWindow': True, 'accentSaturationLimit': 1,
    'alpha': 1, 'backgroundImage': '', 'backgroundPosition': 'stretch', 'blur': 0,
    'colorAccentBg': '${c[base01]}', 'colorBg': '${c[base00]}',
    'colorFg': '${c[base05]}', 'colorHighlightBg': '${c[base0D]}',
    'colorWindowBg': '${c[base01]}',
    'contrast': 0, 'dimBlurred': False, 'engineVersion': 1,
    'id': '$theme_id', 'name': '$theme_name',
    'preferSystemAccent': False, 'radius': 8, 'simpleScrollbar': True,
    'transparencyTabBar': False, 'transparencyTabs': False, 'url': '', 'version': 1,
}))
")

# --- Live update via CDP (preferred when Vivaldi is running) ---
CDP_PORT=9222
if curl -s "http://localhost:${CDP_PORT}/json" >/dev/null 2>&1; then
    ws_url=$(curl -s "http://localhost:${CDP_PORT}/json" | \
        jq -r '[.[] | select(.url | endswith("window.html"))][0].webSocketDebuggerUrl')

    if [[ -n "$ws_url" && "$ws_url" != "null" ]]; then
        python3 - "$ws_url" "$theme_id" "$theme_json" << 'PYEOF'
import asyncio, json, sys, websockets

ws_url, theme_id, theme_json = sys.argv[1:4]

async def update():
    async with websockets.connect(ws_url) as ws:
        js = f"""
(async function() {{
    var theme = {theme_json};
    var userThemes = await new Promise(r => vivaldi.prefs.get('vivaldi.themes.user', r));
    if (!Array.isArray(userThemes)) userThemes = [];
    userThemes = userThemes.filter(t => t.id !== '{theme_id}');
    userThemes.push(theme);
    vivaldi.prefs.set({{ path: 'vivaldi.themes.user', value: userThemes }});
    vivaldi.prefs.set({{ path: 'vivaldi.theme.schedule.enabled', value: 'off' }});
    vivaldi.prefs.set({{ path: 'vivaldi.themes.current', value: '{theme_id}' }});
    return 'ok';
}})()
"""
        msg = json.dumps({"id": 1, "method": "Runtime.evaluate",
                          "params": {"expression": js, "awaitPromise": True}})
        await ws.send(msg)
        resp = json.loads(await asyncio.wait_for(ws.recv(), timeout=5))
        if resp.get("result", {}).get("result", {}).get("value") == "ok":
            print("Vivaldi theme updated live")
        else:
            print(f"CDP error: {json.dumps(resp)[:300]}", file=sys.stderr)

asyncio.run(update())
PYEOF
        exit 0
    fi
fi

# --- Fallback: update Preferences file (Vivaldi not running or no CDP) ---
python3 - "$prefs" "$theme_id" "$theme_json" << 'PYEOF'
import json, sys, shutil

prefs_path, theme_id, theme_json = sys.argv[1:4]
theme = json.loads(theme_json)

with open(prefs_path) as f:
    prefs = json.load(f)

viv = prefs.setdefault("vivaldi", {})
themes = viv.setdefault("themes", {})
user = themes.setdefault("user", [])
user[:] = [t for t in user if t.get("id") != theme_id]
user.append(theme)

viv.setdefault("theme", {}).setdefault("schedule", {})["enabled"] = "off"
themes["current"] = theme_id

shutil.copy2(prefs_path, prefs_path + ".bak")
with open(prefs_path, "w") as f:
    json.dump(prefs, f, separators=(",", ":"))
PYEOF
