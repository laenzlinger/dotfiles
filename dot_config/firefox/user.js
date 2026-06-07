// Firefox user preferences
// Managed via chezmoi — applied by run_onchange_firefox-user-js.sh

// --- Performance ---
user_pref("media.ffmpeg.vaapi.enabled", true);

// --- Privacy ---
user_pref("privacy.trackingprotection.enabled", true);
user_pref("dom.security.https_only_mode", true);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("extensions.pocket.enabled", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.enabled", false);

// --- UI ---
user_pref("browser.startup.homepage", "about:blank");
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.startup.page", 3);
user_pref("browser.tabs.warnOnClose", false);

// --- Wayland / Desktop integration ---
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);

// --- Search ---
user_pref("browser.search.defaultenginename", "DuckDuckGo");
user_pref("browser.urlbar.placeholderName", "DuckDuckGo");
