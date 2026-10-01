###############################################################################
# Secure Boot
###############################################################################

AddPackage sbctl # Secure Boot key manager
AddPackage efitools # Tools for manipulating UEFI Secure Boot platforms

# sbctl's machine-specific Secure Boot key material and signing database.
IgnorePath '/var/lib/sbctl'

# Locally signed copy of the package-provided systemd-boot EFI binary.
IgnorePath '/usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed'
