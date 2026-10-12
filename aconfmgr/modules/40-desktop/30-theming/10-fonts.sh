# Fontconfig discovers installed fonts and applies the generic-family defaults
# in /etc/fonts/local.conf.
AddPackage fontconfig
CopyFile /etc/fonts/local.conf

###############################################################################
# General desktop coverage
###############################################################################

# Primary sans-serif and serif families, with broad Latin, Cyrillic, Greek, and
# many other-script coverage.
AddPackage noto-fonts

# Noto families for Chinese, Japanese, and Korean text.
AddPackage noto-fonts-cjk

# Color emoji family used as the default emoji fallback.
AddPackage noto-fonts-emoji

# Broad, established fallback family for applications or documents that request
# DejaVu explicitly.
AddPackage ttf-dejavu

# Arial, Times New Roman, and Courier New metric-compatible families for
# document and web-layout compatibility.
AddPackage ttf-liberation

###############################################################################
# Programming and icon glyphs
###############################################################################

# Programming superfamily used as the generic monospace default. Krypton is the
# selected Monaspace coding variant.
AddPackage otf-monaspace

# Monospace Nerd Font icon glyphs for terminal and CLI fallbacks, without
# installing dozens of patched copies of unrelated programming fonts.
AddPackage ttf-nerd-fonts-symbols-mono
