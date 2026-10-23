# I'm not the greatest typist
alias sl='ls'
alias mdkir='mkdir'
alias soruce='source'
alias souce='source'
alias suod='sudo '
alias sduo='sudo '

# Directory changing
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'

# Terminal vim-like exits, for when I think the terminal is vim
alias :q='exit'
alias :q!='exit'
alias :wq='exit'
alias :wq!='exit'

# File/Directory utilities
alias md='mkdir -p'
mkd() { target="$1"; test -n "$target" || return 2; mkdir -p "$target" && cd "$target" }

# Directory listing aliases, defaults to exa, if aviable
if command -v eza > /dev/null; then
    alias ls='eza'
    alias l='eza -glah --classify'
    alias ll='eza -glah --classify -s=size --group-directories-first -r'
    alias tree='eza -Tlagh'
else
    alias ls='ls --color=auto'
    alias l='ls -lahX --classify'
    alias ll='ls -lahX --classify --group-directories-first'
fi

# Fallbacks
command -v hd > /dev/null || alias hd='hexdump -C' # Cannonical hex dump; some systems have this symlinked
command -v md5sum > /dev/null || alias md5sum='md5' # Fallback from `md5sum` to `md5`
command -v sha1sum > /dev/null || alias sha1sum='shasum' # Fallback from `sha1sum` to `shasum`
command -v vim > /dev/null && alias vi='vim' # Let vim take precedence over vi
command -v nvim > /dev/null && alias vi='nvim' && alias vim='nvim' # Let nvim take precedence over vi/vim
command -v vimtutor > /dev/null || alias vimtutor='nvim -c Tutor'  # Let vimtutor fallback to nvim's tutor

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  # Wayland clipboard
  alias pbcopy="wl-copy"
  alias pbpaste="wl-paste"
else
  # X11 clipboard (either using xclip or xsel, xsel takes precedence if both)
  command -v xclip > /dev/null && alias pbcopy='xclip -selection clipboard'
  command -v xclip > /dev/null && alias pbpaste='xclip -selection clipboard -o'
  command -v xsel > /dev/null && alias pbcopy='xsel --clipboard --input'
  command -v xsel > /dev/null && alias pbpaste='xsel --clipboard --output'
fi

# File validation and manipulation
alias yamlcheck='python -c "import sys, yaml as y; y.safe_load(open(sys.argv[1]))"' # Validate YAML
alias jsoncheck='jq "." >/dev/null <' # Validate JSON
alias urlencode='python2 -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"' # Encode strings as URLs (space->%20, etc.)

# Regular expressions
alias reg_email='echo "[a-Z0-9._%-]+@[a-Z0-9.-]+\.[a-Z]{2,10}"'
alias reg_mac='echo "([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}"'
alias reg_ipv4='echo "([0-9]{1,3}\.){3}[0-9]{1,3}"'
alias reg_ipv6='echo "\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*"' # Also catches loopbacks (::1), (for valid matching, it needs to be this long...)
alias reg_ip='echo "(`reg_ipv4`|`reg_ipv6`)"' # Match both IPv4 and IPv6

# Grep aliases
alias grep_email='grep -E `reg_email`'
alias grep_ip='grep -E `reg_ip`'
alias grep_mac='grep -E `reg_mac`'
alias massgrep='grep -RHIni'

# Network
alias ip-show='curl https://ifconfig.me' # Get global IP address
alias ips="ifconfig -a | grep -oE \"inet6? (addr:)?s?\`reg_ip\`\" | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
alias ports='netstat -tulanp'
alias ssh-list='ss | grep ssh' # List all SSH connections
alias serve='python -m http.server'  # Serve current directorty as HTTP

# System actions
alias pacnew="find / -name '*.pacnew' 2>/dev/null" # Search for all new configurations after pacman update
alias backup="rsync -avHAXS --delete --filter='dir-merge /.rsync-filter'" # Make full rsync backup, respecting .rsync-filter files for exclusions
#alias upload='curl -F "f:1=<-" ix.io' # ix.io was offline for about 10 months now...
#alias upload='curl -F "sprunge=<-" http://sprunge.us' # sprunge.us was offline for a few weeks now, not sure why
alias upload='curl -F "file=@-" https://hardfiles.org' # hardfiles.org works, but has 24-hour expiry
alias cpu-stress='for i in $(seq $(getconf _NPROCESSORS_ONLN)); do yes > /dev/null & done' # Run `yes > /dev/null` on all cores as stress test
alias nvidia='__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia' # Run app with nvidia (on hybrid mode with optimus)

# Git aliases
alias g='git'
alias gp='git push'
alias gs='git status --short --branch'
alias gss='git status'
alias ga='git add'
alias gap='git add -p'
alias gc='git commit'
alias gcm='git commit -m'
alias gch='git checkout'
alias gchb='git checkout -b'
alias gd='git diff'
alias gdc='git diff --cached'
alias gundo='git reset --soft HEAD~'
alias gredo='git reset HEAD@{1}'

# Enable aliases to be expanded when using sudo
alias sudo='sudo '

# Other things
bw() { BW_SESSION="$(pass show system/bitwarden/session)" command bw "$@" }
