# 🗑️ DumpsterPipe

**Meta package manager: Install tools from anywhere (PyPI, GitHub, soon crates/flatpak/etc.) without root or global pollution. Like pipx, but cursed and zsh-only.**

[![Stars](https://img.shields.io/github/stars/aScammer-Darkly/dumpsterpipe)](https://github.com/aScammer-Darkly/dumpsterpipe)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  
*(Add stars if it saves your ass. Fork if it doesn't.)*

Tired of `sudo apt install` nuking your env or pipx failing on non-Python tools? DumpsterPipe clones/installs into isolated `~/.dumpsterpipe/venvs/`, shims `dp-<tool>` bins to `~/.dumpsterpipe/bin`, and keeps everything userland. No deps beyond zsh/jq/sponge (from moreutils).

## 🚀 Quick Install 
```bash
mkdir -p ~/.dumpsterpipe && cd ~/.dumpsterpipe
git clone https://github.com/aScammer-Darkly/dumpsterpipe.git tmp && \
  rsync -a tmp/ . && rm -rf tmp  # Flattens without nesting
chmod +x bin/dumpsterpipe  # One-time only
ln -s bin/dumpsterpipe bin/dp  # Optional alias
```

**Add to ~/.zshrc** (for completions):
```zsh
export PATH="$HOME/.dumpsterpipe/bin:$PATH"
source "$HOME/.dumpsterpipe/dp.zsh"  # Completions
autoload -Uz compinit && compinit -C
```
Then `exec zsh`. Boom—tab-complete commands & pip pkgs.

*(Pro tip: Run `dp cache update` once for PyPI completions. Takes 15s.)*

## 📦 Usage

### Install from PyPI
```bash
dp install pip  # Or: dumpsterpipe install pip
```
- Creates `~/.dumpsterpipe/venvs/black/`, installs via venv/pip.
- Shims `dp-<package>` → actual binary.
- Output: `Installed → dp-<package> (<package>)`

### Install from GitHub
```bash
dp install gh user/repo  # Defaults to main/master
dp install gh user/repo#v1.2.3      # Specific ref/branch/tag
```
- Clones shallow into `venvs/<pkg>/`, auto-detects/builds:
  - Python? `pip install -e .` in venv.
  - Rust? `cargo install --path .`.
  - Go? `go build`.
  - Raw bin/script? Symlinks it.
- Shims `dp-<repo>` (e.g., `dp-commandline-tools`).
- Output: `SUCCESS → dp-commandline-tools (somebin)`

**Gotcha**: If detection fails (no pyproject.toml/Cargo.toml/etc.), it hunts executables. Multi-bin repos pick the first—file an issue if it sucks.

### Other Commands
| Command | Does |
|---------|------|
| `dp list` | Lists installed pkgs (e.g., `black`, `commandline-tools`). |
| `dp uninstall <pkg>` | Nukes venv/shim/registry entry. |
| `dp cache update` | Fetches PyPI index for completions (~20k pkgs). |
| `dp path` | Prints `~/.dumpsterpipe/bin` (add to $PATH). |
| `dp help` | ...kinda works. Man page soon™. |

Run `dp` with no args for a menu.

## 🛠️ How It Works (The Guts)
- **Registry**: `~/.dumpsterpipe/registry/installed.json` tracks pkg → {backend, entrypoint, source}.
- **Shims**: Symlinks in `bin/` point to isolated bins—`dp-<pkg> someargs` just works.
- **Isolation**: Per-pkg venvs/bins. No global pip/cargo/go pollution.
- **Backends**: Pip (now), GH (clones/builds). Coming: cargo, npm, flatpak (stubs in code).

## 🤷 Why Bother?
- Userland-only: No root, no system breakage.
- Cross-ecosystem: One command for Python/Rust/Go/raw bins.
- Zsh completions out-the-box (pip search is fuzzy-fast).
- Tiny: ~10 files, no bloat.

It's not production-ready (entry detection is iffy, no upgrades yet), but it *works* for 80% of CLI tools. Use at your own risk—forks welcome.

## 🐛 Bugs / Roadmap
- [ ] Fix multi-entrypoint detection (e.g., pick `black` over random script).
- [ ] `dp upgrade <pkg>` (pip -U or git pull).
- [ ] More backends (Go/crates/flatpak—stubs ready).
- [ ] Proper help/man page.
- [ ] Cached indexes for non-pip (GH trending?).
- Report issues: [New Issue](https://github.com/aScammer-Darkly/dumpsterpipe/issues/new).

## 🙏 Credits / License
Built on zsh/jq/sponge. MIT License—steal it, improve it, attribute if you feel like it.

*(If this saved you 5min today, star it. If it broke your machine, buy me a beer.)*
