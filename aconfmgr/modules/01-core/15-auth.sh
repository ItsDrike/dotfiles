###############################################################################
# Local account state
###############################################################################

# Temporary lock file - prevents concurrent edits to account database files
IgnorePath '/etc/.pwd.lock'

# Local account databases
IgnorePath '/etc/passwd'
IgnorePath '/etc/group'
IgnorePath '/etc/shadow'
IgnorePath '/etc/gshadow'
IgnorePath '/etc/subuid'
IgnorePath '/etc/subgid'

# Account database backup files
IgnorePath '/etc/passwd-'
IgnorePath '/etc/group-'
IgnorePath '/etc/shadow-'
IgnorePath '/etc/gshadow-'
IgnorePath '/etc/subuid-'
IgnorePath '/etc/subgid-'

# Login/accounting databases
IgnorePath '/var/lib/lastlog'

###############################################################################
# PAM authentication policy
###############################################################################

# Allow eight consecutive authentication failures before pam_faillock locks an
# account. Other lockout timing defaults remain those provided by pambase.
CopyFile /etc/security/faillock.conf

# Disallow empty passwords for PAM authentication and password changes.
#
# Allowing empty passwords for authentication can increase the attack surface,
# e.g. see CVE-2020-27780, or dirtyfrag (CVE-2026-43284 , CVE-2026-43500) - a
# manipulated /etc/shadow with a present nullok option from pam_unix.
CopyFile /etc/pam.d/system-auth

# Allow only wheel members to use su for root access.
CopyFile /etc/pam.d/su

###############################################################################
# Sudo
###############################################################################

AddPackage sudo

# Sudo's runtime state (holds e.g. authentication timestamps)
IgnorePath '/var/db/sudo'

# Sudo config
CopyFile /etc/sudoers.d/10-wheel 440
CopyFile /etc/sudoers.d/20-passwd-tries 440
CopyFile /etc/sudoers.d/99-insults 440
