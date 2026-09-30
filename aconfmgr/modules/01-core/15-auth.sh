AddPackage sudo # Give certain users the ability to run some commands as root

# Sudo config
CopyFile /etc/sudoers.d/10-wheel 440
CopyFile /etc/sudoers.d/20-passwd-tries 440
CopyFile /etc/sudoers.d/99-insults 440

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
