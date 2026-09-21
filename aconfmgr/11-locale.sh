# Time zone
CreateLink /etc/localtime /usr/share/zoneinfo/CET

# Enable generating localizations for the languages below:
# - en_US: Primary locale for English messages and general formatting.
# - en_DK: English with Danish regional conventions, used for ISO-style
#          dates, 24-hour time, Monday-first weeks, A4 paper, and metric units.
f="$(GetPackageOriginalFile glibc /etc/locale.gen)"
sed -i 's/^#\(en_US.UTF-8\)/\1/g' "$f"
sed -i 's/^#\(en_DK.UTF-8\)/\1/g' "$f"

cat > "$(CreateFile /etc/locale.conf)" <<'EOF'
LANG=en_US.UTF-8
LC_TIME=en_DK.UTF-8
LC_PAPER="en_DK.UTF-8"
LC_MEASUREMENT="en_DK.UTF-8"
EOF
