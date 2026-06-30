# Codex Update Prompt

Use this prompt when asking Codex to update an installed copy from GitHub:

```text
Update Open Remote Desktop from GitHub. Preserve my config files under
~/Library/Application Support/Open Remote Desktop/config/. Do not overwrite
SSH keys, known_hosts, or machine-specific settings. Rebuild and re-sign the
local app, then verify shell syntax, codesign, and the no-secrets check.
```

For a remote app update, add:

```text
Also rerun scripts/install-remote.sh for my configured remote SSH alias and
verify the remote app signature. Do not restart or close any current remote
desktop session.
```
