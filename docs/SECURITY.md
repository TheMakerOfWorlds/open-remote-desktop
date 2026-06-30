# Security Model

Open Remote Desktop does not store passwords or private keys. It relies on the user's existing SSH configuration and macOS security model.

## What Is Protected

- SSH strict host-key checking is enabled.
- Known hosts are read from `~/.ssh/known_hosts`.
- User configuration lives outside the repository under `~/Library/Application Support/Open Remote Desktop/config/`.
- Config files are created with owner-only permissions.
- Logs are created with owner-only permissions.
- Reverse file transfers extract into a hidden destination temp directory and commit completed items only after the stream succeeds.
- Transfer progress popups time out if their state file disappears.

## What Is Not Protected

- Logs may include filenames and transfer errors.
- Ad-hoc codesigning verifies local bundle integrity but does not provide Apple notarization.
- A user with access to your macOS account can read your local config and logs.
- SSH access, Tailscale access, Screen Sharing, and Remote Management must be secured separately.

## Safe Update Policy

The updater must not overwrite:

- `local.conf`
- `remote.conf`
- SSH keys
- `known_hosts`
- user-created SSH config

Installers copy example config only when no config exists. If `--force-config` is used, the previous config is backed up first.

## Before Publishing

Run:

```sh
./scripts/check-no-secrets.sh
git status --short
```

Do not publish generated user config or machine-specific logs.
