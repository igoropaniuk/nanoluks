# nanoluks

A simple command-line wrapper around LUKS/cryptsetup for creating,
mounting, and managing encrypted container files on Linux.

## Motivation

For years I relied on TrueCrypt to create encrypted file containers
for sensitive data. After TrueCrypt was discontinued, rather than
hunting for a replacement app that may or may not be available
through `apt` or `snap`, I decided to wrap the tools that already
ship with every Linux distribution - `cryptsetup`, `losetup`, and
`mount`. nanoluks turns a multi-step manual workflow into a single
command while using only standard Linux utilities under the hood.

## Usage

```
nanoluks create <path> [options]    Create a new encrypted container
nanoluks open   <path> [options]    Open and mount an existing container
nanoluks close  <path|mount|name>   Unmount, close, and detach a container
nanoluks close-all                  Close all active containers
nanoluks status [path]              Show status of containers
```

### Create options

| Option | Description | Default |
|---|---|---|
| `--size <size>` | Container size (e.g. `500M`, `2G`, `1T`) | `2G` |
| `--fs <type>` | Filesystem: `ext4`, `xfs`, `btrfs`, `exfat` | `ext4` |

### Open options

| Option | Description | Default |
|---|---|---|
| `--mount <path>` | Custom mount point | `/mnt/nanoluks/<name>` |

## Examples

### Create an encrypted container

```bash
nanoluks create ~/vault.img --size 4G --fs btrfs
```

This performs the full setup in one step: creates the file, attaches
a loop device, formats as LUKS, creates the filesystem, and tears
down cleanly. The container is left closed and ready to use.

### Open and mount

```bash
nanoluks open ~/vault.img
```

Opens the LUKS container and mounts it at `/mnt/nanoluks/vault`.
Use `--mount` for a custom location:

```bash
nanoluks open ~/vault.img --mount ~/private
```

### Close

All three forms are equivalent:

```bash
nanoluks close ~/vault.img           # by container file
nanoluks close /mnt/nanoluks/vault   # by mount point
nanoluks close vault                 # by mapper name
```

Unmounts the filesystem, closes the LUKS device, and detaches the loop device.

To close every active container in one go:

```bash
nanoluks close-all
```

### Check status

```bash
nanoluks status              # list all open nanoluks containers
nanoluks status ~/vault.img  # detailed status for a specific container
```

## Requirements

Standard Linux utilities (typically pre-installed):

- `cryptsetup`
- `losetup`
- `mount` / `umount`
- `mkfs.ext4` / `mkfs.xfs` / `mkfs.btrfs` / `mkfs.exfat` (for the chosen filesystem)
- `truncate`
- `bc`

## Install

```bash
sudo make install
```

Installs to `/usr/local/bin`. To uninstall:

```bash
sudo make uninstall
```

## Development

Two additional Makefile targets cover static analysis and an
end-to-end sanity check. Both are wired into CI and can be run
locally.

### Lint

```bash
make lint
```

Runs `shellcheck` against `nanoluks` and greps `nanoluks` and
`README.md` for non-ASCII bytes (the repo is kept strictly ASCII so
diffs stay portable across terminals and editors). Requires
`shellcheck` to be installed.

### Test

```bash
make test
```

Exercises the full `create` -> `open` -> write -> `close` lifecycle
against a 50M ext4 container at `/tmp/make-test-fixture.img`, mounted
under `/mnt/nanoluks/make-test-fixture` (names chosen to be
unambiguously internal so a `make test` run never touches a real
user vault). The recipe needs root because it mounts a real
filesystem, so it self-elevates with `sudo` if not already running
as root. It also relies on `setsid` from `util-linux` (normally
preinstalled) to feed the passphrase on stdin without a controlling
terminal. Cleans up any leftover mount, mapper, and image from a
previous run before starting, and fails if the mapper or mount
point is still present after `close`.

## License

MIT
