# Open Remote Desktop

Open Remote Desktop is a small macOS-to-macOS remote desktop helper built around the tools Apple already ships:

- Screen Sharing over an SSH tunnel
- drag-and-drop file copy from the local Mac to the remote Mac
- drag-and-drop file copy from the remote Mac back to the local Mac
- optional microphone forwarding through SSH into BlackHole on the remote Mac
- compact top-right progress popups for file transfers
- safe update scripts that preserve local configuration

The repository contains app source and scripts only. Your machine names, Tailscale IPs, SSH aliases, usernames, keys, and local preferences live in config files under `~/Library/Application Support/Open Remote Desktop/config/` and are not committed.

## Requirements

Both Macs:

- macOS with Screen Sharing or Remote Management enabled on the remote Mac
- SSH access between the Macs
- SSH host keys already trusted in `~/.ssh/known_hosts`

Optional microphone forwarding:

- local Mac: `ffmpeg`
- remote Mac: BlackHole 2ch, SoX, and SwitchAudioSource

Homebrew can install the common audio dependencies:

```sh
brew install ffmpeg sox switchaudio-osx blackhole-2ch
```

## Local Install

Clone the repository on the local/primary Mac:

```sh
git clone https://github.com/TheMakerOfWorlds/open-remote-desktop.git
cd open-remote-desktop
./scripts/install-local.sh
```

Then edit:

```sh
open -e "$HOME/Library/Application Support/Open Remote Desktop/config/local.conf"
```

Set at least:

```sh
REMOTE_NAME="Remote Mac"
REMOTE_SSH_ALIAS="remote-mac"
REMOTE_USER="admin"
```

`REMOTE_SSH_ALIAS` should be an SSH alias from `~/.ssh/config` or a hostname/IP that already works with:

```sh
ssh remote-mac
```

After setup, click `~/Desktop/Open Remote Desktop.app`. The app shows a notification that it is opening the protected SSH tunnel, then opens Screen Sharing through `localhost`.

Drop files or folders onto `Open Remote Desktop.app` to copy them to the remote Mac's `~/Downloads` by default.

## Remote Reverse Transfer Install

From the local checkout, install the reverse copy app onto the remote Mac:

```sh
./scripts/install-remote.sh --ssh remote-mac
```

Then SSH into the remote Mac and edit:

```sh
open -e "$HOME/Library/Application Support/Open Remote Desktop/config/remote.conf"
```

Set at least:

```sh
LOCAL_NAME="Primary Mac"
LOCAL_HOST="primary-mac-or-tailscale-ip"
LOCAL_USER="your-local-username"
```

On the remote Mac, drop files or folders onto `~/Desktop/Copy to Primary Mac.app` to copy them back to the local Mac's `~/Downloads` by default.

Reverse transfers stream normal large files directly from the remote Mac and extract into a hidden temp directory on the destination first. Completed files are moved into Downloads only after the stream succeeds, so failed transfers do not leave corrupt visible files behind.

## Updating

Updates are designed to preserve user configuration. The installer creates config files only if they do not already exist, and `update.sh` calls the installer without overwriting config.

From a checkout:

```sh
./scripts/update.sh
```

After local install, this wrapper is also available:

```sh
open-remote-desktop-update
```

If you are using Codex, you can say:

> Update Open Remote Desktop from GitHub without overwriting my config.

The update flow should:

1. Pull the latest repository code.
2. Rebuild and re-sign the local app.
3. Preserve `~/Library/Application Support/Open Remote Desktop/config/local.conf`.
4. Leave SSH keys, known hosts, and user config untouched.

Remote app updates can be re-run safely:

```sh
./scripts/install-remote.sh --ssh remote-mac
```

That preserves the remote `remote.conf` if it already exists.

## Configuration Safety

Committed files:

- `config/local.conf.example`
- `config/remote.conf.example`

Ignored files:

- `config/local.conf`
- `config/remote.conf`
- local build products

Installed private files:

- `~/Library/Application Support/Open Remote Desktop/config/local.conf`
- `~/Library/Application Support/Open Remote Desktop/config/remote.conf`

Run the repository secret scan before publishing:

```sh
./scripts/check-no-secrets.sh
```

## Useful Commands

Build local app without installing:

```sh
./scripts/build-local-app.sh "/tmp/Open Remote Desktop.app"
```

Build reverse app without installing:

```sh
./scripts/build-reverse-app.sh "/tmp/Copy to Primary Mac.app"
```

Check mic relay status:

```sh
remote-mic-control status
```

Stop mic relay:

```sh
remote-mic-control stop
```

## Notes

- This project intentionally relies on SSH instead of storing passwords.
- SSH strict host-key checking is enabled.
- File transfer logs are permission-restricted, but they can still contain filenames.
- The apps are ad-hoc codesigned locally with `codesign --sign -`.
- This is currently Mac-to-Mac focused.
