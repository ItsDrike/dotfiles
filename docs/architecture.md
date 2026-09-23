# Architecture

## Scope

This project configures personal Arch Linux machines and documents the setup
for others to adapt. It continues to use Arch repositories, pacman, paru,
systemd, Btrfs, and UKIs. It is not an Arch-derived distribution.

The repository owns personal policy. A separate future tool will own reusable
generation and runtime mechanics. `orca` is the primary implementation target;
the existing VM is retained only for clean-system and destructive validation of
bootstrap or boot-lifecycle work before it reaches the laptop.

## Current Baseline

`orca` is a physical laptop installed from the Arch ISO. Its baseline includes:

- Manual disk partitioning and LUKS-over-Btrfs setup from the Arch ISO.
- Btrfs subvolumes for bootstrap root, data, persistence, snapshots,
  generations, runtimes, and swap.
- systemd-boot, UKIs, Secure Boot, systemd initramfs, TPM unlocking, and
  an IOMMU-enabled kernel command line.
- A conventional writable root and home directory while aconfmgr and chezmoi
  are evaluated.

The current root is `@bootstrap-root`. Generation publication, runtime
replacement, selected persistence mappings, hibernation resume, and TPM
signed-PCR policy remain future work.

The repository checkout used to author this configuration need not be `orca`.
Target state is established only by explicit operation on the target, not by
inspection of the authoring workspace.

## Configuration Managers

`aconfmgr` is the current system configuration manager under evaluation. Its
configuration is handwritten from a small baseline, with `save` used as a
deliberate discovery tool rather than as an import of a fully configured system.

It owns explicit packages and selected intentional system files. Generated
artifacts and mutable state are ignored selectively. In particular, kernel
images and generated UKIs are never configuration sources.

The aconfmgr layout has an unconditional `10-base.sh`, host declarations
selected from `/etc/hostname`, purpose-oriented optional profiles, and a
`files/` tree mirroring target filesystem paths. `99-unsorted.sh` is local
discovery output and is not tracked.

`chezmoi` is being evaluated independently for user configuration. Its
eventual host/profile relationship to aconfmgr is intentionally open.

## Storage Model

The lifecycle root filesystem is Btrfs and initially contains:

```text
@bootstrap-root
@data
@persist
@snapshots
@generations
@runtimes
@swap                 # when swap is enabled
```

Btrfs top level is mounted at `/.btrfs` for administration. `/data` and
`/persist` are mounted from the first boot. `/data` may be a local subvolume
or a separately mounted encrypted Btrfs filesystem per host; it is not
required to share a disk with the lifecycle filesystem.

Snapshot retention is independent by purpose:

- `@data` has longer periodic recovery snapshots.
- `@persist` has shorter periodic recovery snapshots.
- Future runtimes have frequent short-term recovery snapshots only.
- The last three complete runtime roots are retained independently of periodic
  snapshots.

Systemd timers with `Persistent=true` schedule periodic snapshots. These are
local recovery copies, not substitutes for external backups.

## Future Runtime Model

After the conventional bootstrap phase, a clean snapshot becomes read-only
generation 1. A per-generation UKI contains an opaque signed identifier, for
example `rd.generation=gen-000001`. At a cold boot, a tool-provided systemd
initramfs unit reads that parameter after LUKS unlock and before `sysroot.mount`.
When a generation UKI is selected on a cold boot, it snapshots the selected
read-only generation into `@runtimes/current`.

The stable runtime path is used as root:

```text
UKI rootflags: subvol=/@runtimes/current
fstab root:    subvol=/@runtimes/current
```

The generation identifier tells the initrd which immutable generation to copy
into that stable runtime path. Hibernation resume is not a cold boot: it must
preserve the active runtime and skip runtime rotation and cleanup.

Soft reboot is a separate activation path. It bypasses firmware, boot loader,
kernel, and initrd, so it cannot change `rd.generation`. The deployment tool
instead validates a published generation, creates a new writable runtime,
mounts it at `/run/nextroot`, and invokes `systemctl soft-reboot`. The new root
identifies its generation from immutable metadata within that generation. A
soft-reboot runtime need not physically be `@runtimes/current`; a later normal
boot returns to the initrd-selected `@runtimes/current` path. Kernel, module,
initrd, microcode, firmware, or UKI changes require a normal reboot.

### On-Demand Replacement MVP

The initial lifecycle mode may use one writable `@runtimes/current` root that
normally persists across reboots. Its maintenance UKI is the default entry and
uses `rd.runtime=preserve`; the initrd still unlocks LUKS but leaves the runtime
unchanged. A selected generation UKI uses `rd.generation=gen-...` together with
`rd.runtime=replace`; on a genuine cold boot, the initrd retains the current
runtime for recovery and replaces it with a fresh writable snapshot of that
published generation. Hibernation resume always preserves the active runtime.

This is on-demand runtime replacement, not per-boot impermanence. A maintenance
UKI boots only `@runtimes/current`; after replacement it cannot boot a retained
historical runtime without a distinct recovery selection path. Both paths use
the initrd; no entry bypasses it.

The smallest publication path is a staging snapshot of a published generation.
Clean `pacstrap` reconstruction is an intended later publication mode for
reproducibility and junk removal, once the bootstrap closure and staging
persistence contract are implemented. That bootstrap closure must configure
the CachyOS repositories, keyring, and mirror configuration before installing
and applying aconfmgr; CachyOS is intentionally an aconfmgr prerequisite, not
an aconfmgr conversion profile.

The future tool requires Btrfs, systemd initramfs, and per-generation UKIs.
`orca` currently uses systemd-boot. The future tool must not depend on a
specific boot manager, but it requires direct signed-UKI booting, one-shot
selection, boot assessment, and fallback. Limine is a future VM-only evaluation
candidate because it can hierarchically group generation and kernel entries
while chainloading signed UKIs. Its generated configuration integrity,
measured-boot PCR model, and boot-assessment integration must be validated
before it could replace systemd-boot. Secure Boot signing and TPM PCR-policy
details remain to be designed and tested.

## Persistence Boundary

The future tool will manage `/persist`-backed persistence through ordered
systemd bind mounts. It treats `/persist` as an already mounted path and does
not need to know whether it comes from a local subvolume, another disk, NFS,
or removable storage.

Persistence mappings use a machine-readable, tool-defined configuration format.
aconfmgr manages that host policy, while the future tool consumes the same
mapping data to mount persistence into staging roots and to generate boot-time
systemd `.mount` units. The tool must not infer mappings by parsing generated
unit files.

Before `arch-chroot` enters a staging root, the tool mounts `/persist` inside
that root and applies every declared bind mapping. This makes persistent state
available to clean reconstruction and snapshot-derived builds alike. Required
sources must exist; a missing persistent mapping is a build and boot failure,
not a fallback to the underlying generation file.

Persisted account databases are a special adoption mapping. The coherent set
is `/etc/passwd`, `/etc/group`, `/etc/shadow`, `/etc/gshadow`, `/etc/subuid`,
and `/etc/subgid`. A clean `pacstrap` root supplies only hidden bind-mount
targets; persistent copies are canonical. Staging must reconcile package-defined
system accounts against the mounted persistent database before publication.

Adding a mapping for non-empty data requires an explicit adoption operation;
boot and deployment must never silently copy, merge, move, or overwrite data.
Removing a mapping leaves backing data as a reported orphan until explicitly
cleaned up.

`/data` remains ordinary host storage. Bind mounts from `/data` into user home
paths are normal systemd configuration managed by aconfmgr, not a responsibility
of the future impermanence tool.

## Safety Properties

- A runtime is never an ancestor of a published generation.
- New generations are built from a clean generation through staging.
- Published generations are immutable.
- The initial generation-retention default is three, configurable per host.
- A new unconfirmed generation never replaces the last protected confirmed-good
  fallback.
- Boot assessment and fallback are required for the personal setup.
- Secrets normally live only in encrypted persistent storage, outside Git.
  Encrypted Git-tracked secrets are an exception to evaluate later, with GPG as
  the intended trust root.

## Open Design Work

- Continue evaluating aconfmgr and chezmoi on `orca`.
- Determine the default read-only and controlled read-write staging access to
  persistence from evidence, not assumption.
- Define retained-runtime recovery selection and the promotion/cleanup ordering
  for on-demand runtime replacement.
- Design UKI signing/publication ordering and TPM PCR-policy compatibility.
- Evaluate Limine in the VM once multiple signed generation UKIs exist, before
  considering any boot-manager change on `orca`.
- Decide exact bootstrap scripts, snapshot retention values, and the future
  tool's name and configuration format.
