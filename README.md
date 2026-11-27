# dotfiles + workflows

Declarative, idempotent machine sync for an Arch/Hyprland setup. One command up,
one command down, no `mv`-based destruction and no 30 MB binaries in git.

```
dots push          # snapshot this machine → git
dots pull          # make this machine match the repo
dots status        # what is tracked / dirty / missing
dots diff          # package drift
dots doctor        # secrets, big files, symlinks, hooks
dots secrets push  # encrypted auth bundle
dots secrets pull
dots bootstrap git@github.com:XinlinProtoWu/dotfiles.git   # brand-new machine
```

`syncDots.sh` and `restore.sh` still work; they are thin wrappers around
`dots push` / `dots pull`.

> The repo is the source of truth. `dots pull` deploys `~/.dotfiles/.local/bin/dots`
> over `~/.local/bin/dots`, so edit the script in the repo (or `dots push` first)
> if you are changing it.

Everything is configured in **`dots.conf`** — file lists, exclusions, vault
roots, external installers. Edit that, not the scripts.

## Layout

| Repo path            | Deployed to                     | Notes                                  |
| -------------------- | ------------------------------- | -------------------------------------- |
| `.config/`           | `~/.config/`                    | mirrors, with heavy/secret excludes    |
| `.local/bin/`        | `~/.local/bin/`                 | scripts only (no symlinks/binaries)    |
| `home/`              | `~/`                            | `.bashrc`, `.gitconfig`, …             |
| `agents/`            | `~/.agents/`                    | pi skills (`~/.agents/skills`)         |
| `pi/`                | `~/.pi/agent/`                  | settings, keybindings, mcp, skills, …  |
| `vaults/<rel>/`      | `$HOME/<rel>/`                  | Obsidian notes + config + plugins      |
| `etc/`               | `/etc`                          | only with `dots pull --system`         |
| `manifests/`         | —                               | package + dependency manifests         |
| `profiles/<host>/`   | overlay applied last            | machine-specific overrides             |
| `hooks/*.sh`         | executed by push/pull           | `pre-pull`, `post-pull`, `pre-push`    |
| `secrets/`           | age/gpg bundle                  | plaintext is git-ignored               |

## What is captured automatically

* **System packages** — `pacman -Qenq` (repo) and `pacman -Qemq` (AUR).
* **Language/tool deps** — `pipx list`, global npm, `cargo install --list`,
  `go install` modules (from binary metadata), flatpak apps.
* **External installers** — `pi`, oh-my-posh, devkitPro, pspdev (`EXTERNALS` in
  `dots.conf`); `dots pull` checks each and offers to install what is missing.
* **Workflows**
  * LazyVim: `~/.config/nvim` incl. `lazy-lock.json`; `pull` runs
    `nvim --headless "+Lazy! restore" +qa`.
  * Pi: agent settings/keybindings/MCP/extensions + `~/.agents/skills`; then
    `pi install npm:…` for every package in `manifests/pi-packages.txt`.
  * Obsidian: every vault under `VAULT_ROOTS` — notes, attachments and the
    `.obsidian` configuration (hotkeys, community plugins, themes, snippets).
    Build artefacts, nested `.git` repos, `.trash`, caches and files above
    `VAULT_MAX_FILE_MB` (25 MB) stay local and are reported by `dots push`.
    Set `VAULT_SYNC_NOTES=0` to version only the vault settings.
  * systemd user units that are enabled.

## Machine-specific stuff

Anything in `HOST_OVERLAY_FILES` (by default `~/.config/hypr/machine.lua`) is:

* excluded from the shared `.config` tree,
* stored in `profiles/<hostname>/overlay/…` on `dots push`,
* re-applied on `dots pull` **after** the shared configs.

`~/.config/hypr/hyprland.lua` loads `machine.lua` last via
`pcall(dofile, …)`, so monitor names, scaling, wallpapers and input devices can
differ per machine without touching the shared config.

Per-host extras are also supported:

```
profiles/<host>/packages.repo.txt   # extra pacman packages
profiles/<host>/packages.aur.txt    # extra AUR packages
profiles/<host>/pre-pull.sh         # executable hooks
profiles/<host>/post-pull.sh
```

## Daily sync

Think of `~/.dotfiles` as a shared, git-backed view of every machine.

```bash
# machine A, end of work
dots push

# machine B, start of work
dots pull
dots status        # optional: what changed locally since the last push
```

`push` = snapshot this machine → `git add/commit` → `git pull --rebase` →
`git push`. `pull` = `git pull` → install missing packages → overwrite configs
(backups kept) → restore LazyVim/pi/Obsidian. Both are idempotent; running them
twice is harmless.

When two machines edited the **same** file, the rebase in `push` stops with a
conflict instead of silently dropping work:

```bash
cd ~/.dotfiles
git status                 # files in conflict
# edit, then:
git add <file> && git rebase --continue
git push
```

`dots pull` never deletes destination files, so notes/configs created locally
survive a pull; `push` mirrors deletions from the machine you push from.

## Safety guarantees

* `push` refuses to mirror a tree that would delete more than 25 files / 30 % of
  the repo copy (override with `--force`).
* `push` scans staged content for API keys, JWTs and private keys and aborts
  unless `--force`.
* files > `MAX_FILE_MB` (2 MB), ELF binaries, symlinks and anything matched by
  `.gitignore` are removed from the index automatically.
* `pull` never deletes files on the destination; every overwritten file is
  backed up to `~/.local/state/dots/backups/<run>/…`.
* `pi/agent/auth.json`, pulse cookies and Moonlight certs never enter git; use
  `dots secrets push` (age, or gpg as fallback) to move them encrypted.

## Rewritten history (2026-11)

History was rewritten to remove a 33 MB binary (`.local/bin/omp`), the Obsidian
Electron cache (24 MB `asar` + cookies) and credential files (pulse cookie,
Moonlight client key). A pre-rewrite mirror is kept at
`~/.dotfiles-history-backup-*.git`; delete it once you are happy.

**Other machines that already cloned this repo must re-sync their history:**

```bash
cd ~/.dotfiles
git fetch origin
git reset --hard origin/main
# or: rm -rf ~/.dotfiles && ~/.dotfiles/bootstrap.sh
```

GitHub may keep unreachable objects reachable by old commit SHA for a while —
if the repo is public, rotate anything that was exposed and/or ask GitHub
support to run their garbage collection.

## Fresh machine

```bash
git clone git@github.com:XinlinProtoWu/dotfiles.git ~/.dotfiles
~/.dotfiles/bootstrap.sh              # = dots pull --yes
# optional: system files, initramfs, grub, and API keys
~/.dotfiles/bootstrap.sh --system --with-secrets
```

`dots` is deployed into `~/.local/bin/dots` by the pull itself, so later runs
are just `dots push` / `dots pull`.
