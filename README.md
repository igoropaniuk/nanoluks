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

## License

MIT
