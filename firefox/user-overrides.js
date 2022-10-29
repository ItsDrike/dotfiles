/* --------------- PERSONAL ARKENFOX OVERRIDES --------------- ***/
user_pref("_overrides.parrot", "Custom: Arkenfox overrides");

/* Re-enabled single perf features ***/
user_pref("keyword.enabled", true);                     // 0801 Enable searching from location bar (I trust my search engine)
// user_pref("browser.search.suggest.enabled", true);      // 0804 Enable search suggestions
// user_pref("browser.urlbar.suggest.searches", true);     // 0804 Enables search suggestions in the url-bar
user_pref("network.http.referer.XOriginPolicy", 0);     // 1601 Allow cross origin referrers (disabling breaks too much), I use Smart Referer extension instead
user_pref("privacy.clearOnShutdown.sessions", true);    // 2811 Retain HTTP Basic Auth on shutdown
user_pref("signon.rememberSignons", false);             // 5003 Disable saving passwords to FF, there's Bitwarden
user_pref("security.nocertdb", true);                   // 5005 Don't cache certificates (stores them session-only)
user_pref("browser.download.folderList", 1);            // 5016 Always use default downloads folder, not previous folder for download location

/* override recipe: enable session restore ***/
user_pref("browser.startup.page", 3);                   // 0102 Enable session restore
user_pref("privacy.clearOnShutdown.history", false);    // 2811 Don't clear history on exit
user_pref("privacy.cpd.history", false);                // 2812 To match when you use Ctrl-Shift-Del
user_pref("places.history.enabled", false);             // 5013 Disable browsing and download history (allows no history with session restore)

/* --------------- PERSONAL PRIVACY RULES --------------- ***/
user_pref("_overrides.parrot", "Custom: Privacy rules");

/* Deny some permission requests by default (prevent ask popups) ***/
user_pref("permissions.default.microphone", 2);                 // Microphone
user_pref("permissions.default.desktop-notification", 2);       // Notifications
user_pref("permissions.default.geo", 2);                        // Location

/* Disable safebrowsing (sends data to google) ***/
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.safebrowsing.malware.enabled", false);

/* Javascript hardening (might cause slowdowns/breakage) ***/
// user_pref("javascript.options.ion", false);             // Might cause slowdowns/breakage
// user_pref("javascript.options.asmjs", false);           // Might cause slowdowns/breakage
// user_pref("javascript.options.wasm", false);            // Completely disables WASM, for the security gain and speed benefit
// user_pref("javascript.options.baselinejit", false);     // Disable JIT compilation - usually breaks sites with a lot of javascript but is a huge security gain

/* Mark Quad9 as trusted recursive resolver (TRR) for DNS over HTTPS (DoH) ***/
user_pref("network.trr.mode", 2);                                         // Use TRR first, and only if the secure resolution fails use the operating system resolver.
user_pref("network.trr.uri", "https://dns.quad9.net:5053/dns-query");     // Resolver we want to use
user_pref("network.trr.bootstrapAddress", "9.9.9.9");                     // Address to lookup the quad9 DoH address (only used once for this lookup)

/* Other Privacy hardenings ***/
user_pref("geo.enabled", false);                            // Fully disable location access
user_pref("media.hardwaremediakeys.enabled", false);        // Disable control via media keys (some websites might be stealing these)
user_pref("dom.webaudio.enabled",false);                    // Old, mostly unused API, likely utilized for fingerprinting, hasn't broken anything FOR ME

/* --------------- PERSONAL NON-PRIVACY RULES --------------- ***/
user_pref("_overrides.parrot", "Custom: Non-privacy rules");

/* Annoyances ***/
user_pref("browser.tabs.firefox-view", false);          // Don't show firefox view tab
user_pref("extensions.pocket.enabled", false);          // Disable pocket
user_pref("extensions.abuseReport.enabled", false);     // Disable report extension to mozilla
user_pref("identity.fxaccounts.enabled", false);        // Disable sync entirely

/* Urlbar suggestions ***/
user_pref("browser.urlbar.suggest.openpage", false);        // Disable suggestions of open pages
user_pref("browser.urlbar.suggest.engines", false);         // Disable suggestions of search engines
user_pref("browser.urlbar.suggest.topsites", false);        // Disable suggestions of top sites

/* Styling changes ***/
user_pref("browser.fullscreen.autohide", false);                                // Don't auto-hide tabs when firefox is in fullscreen
user_pref("browser.toolbars.bookmarks.visibility", "always");                   // Always show bookmarks toolbar
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);         // Enable profile customization with userChrome.css and userContent.css
user_pref("ui.systemUsesDarkTheme", 1);                                         // Enables `prefers-color-scheme` CSS media feature

/* Other changes ***/
user_pref("browser.preferences.experimental", true);      // Show experimental options in about:preferences
user_pref("browser.urlbar.suggest.calculator", true);     // Calculator in urlbar
user_pref("layout.spellcheckDefault", 2);                 // Enable spellcheck by default for all inputs
user_pref("browser.quitShortcut.disabled", true);         // Disable Ctrl+Q browser quit shortcut

/* --------------- END --------------- ***/
user_pref("_overrides.parrot", "Custom: success");
