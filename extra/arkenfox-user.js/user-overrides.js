user_pref("browser.shell.checkDefaultBrowser", false);  // 0101 Enable default browser check
user_pref("network.dns.disableIPv6", false);            // 0701 Some VPNs leak IPv6, mine doesn't so don't disable it
user_pref("keyword.enabled", true);                     // 0801 Enable searching from location bar (I trust my search engine)
user_pref("network.http.referer.XOriginPolicy", 0);     // 1601 Allow cross origin referrers, with Smart Referer (this breaks too much)
user_pref("privacy.clearOnShutdown.sessions", true);    // 2811 Retain HTTP Basic Auth on shutdown
user_pref("signon.rememberSignons", false);             // 5003 Disable saving passwords to FF, there's Bitwarden
user_pref("security.nocertdb", true);                   // 5005 Don't cache certificates (stores them session-only)
user_pref("browser.download.folderList", 1);            // 5016 Use Downloads folder, not previous folder for download location

/* override recipe: enable session restore ***/
user_pref("browser.startup.page", 3);                   // 0102 Enable session restore
user_pref("privacy.clearOnShutdown.history", false);    // 2811 Don't clear history on exit
user_pref("privacy.cpd.history", false);                // 2812 To match when you use Ctrl-Shift-Del
user_pref("places.history.enabled", false);             // 5013 Disable browsing and download history (allows no history with session restore)
