# aconfmgr

[Aconfmgr][aconfmgr] is a configuration manager for Arch Linux. It can track,
manage, and restore the system-wide config (it does not manage per-user
configuration).

Aconfmgr tracks the explicitly installed packages (not their dependencies), and
is able to track them.

It also manages configuration files, which it does by going over all of the
files (which weren't explicitly ignored) on the system that could contain
configuration, and checks them against the package defaults. If they are
package owned, and match the package default, it leaves it alone, if the file
differs, or isn't owned by any installed package, it will track it.

Aconfmgr's configuration is a set of bash scripts in the `~/.config/aconfmgr`
directory, which it loads (without recursion) in alphabetical order. This
allows for conditional logic like branching per-host or per-hardware decisions.

## Setup

I'm using aconfmgr with a pretty particular structure in mind:

- I symlink this directory (from dotfiles repo) to `~/.config/aconfmgr`
- A small set of alphabetically ordered root scripts provides the entry points:
  `00-helpers.sh` defines shared helpers, `10-modules.sh` loads default
  modules, and `20-host.sh` selects the host composition.
- The `modules/` directory contains shared configuration grouped by domain.
  Numeric directory and file prefixes define ordering only where it matters.
- There is a `hosts/` directory with `${HOSTNAME}.sh` files for each host,
  containing host-specific composition and configuration. `20-host.sh` selects
  one based on `$HOSTNAME` and fails for unrecognised hosts.
- The `files/` directory holds the tracked system configuration, mirroring the
  root filesystem (aconfmgr creates these automatically with `aconfmgr save`).
- I have a special `files/hosts/` directory in the file tree, with
  sub-directories named by `$HOSTNAME`, containing host-specific files.
- I have a `profiles/` directory, which contains configurations that should
  only be included when a host explicitly requests them with `SourceProfile`.
- I have various custom helper functions in `00-helpers.sh`, including:
  - `Persist`: a function that will create a systemd `.mount` unit from given
    source path to given target (e.g. `Persist /persist/etc/hostname
    /etc/hostname`). It can be used for both directories and files. This will
    also mark the target path as ignored by aconfmgr.
  - `SourceModules`: recursively loads every `modules/**/*.sh` file in
    deterministic lexical path order. These modules define the shared default
    configuration for every host.
  - `SourceProfile PROFILE`: loads an explicitly selected profile relative to
    `profiles/`, such as `SourceProfile containers/docker.sh`.
  - `SourceHost HOST`: loads a host declaration relative to `hosts/`.
- The `99-unsorted.sh` is generated discovery output from `aconfmgr save`. It
  is intentionally git ignored, configuration in it should be moved into other,
  more permanent and structured places.

## Usage

- `aconfmgr save`: Generate `~/.config/aconfmgr/99-unsorted.sh`, with any
  changes from the existing configuration state.
- `aconfmgr diff /`: Show a diff between the existing system state and the
  configured state. You can easily review changes aconfmgr would have made
  before applying them in this way.
- `aconfmgr apply --paranoid`: Apply the configuration, prompting for a yes/no
  confirmation on every change decision. (You can also drop the `--paranoid`,
  but I'm often paranoid).

[aconfmgr]: https://github.com/CyberShadow/aconfmgr
