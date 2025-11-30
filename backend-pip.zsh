dp::pip_install() {
    local pkg="$1"
    local venv="$HOME/.dumpsterpipe/venvs/$pkg"
    local shim="$HOME/.dumpsterpipe/bin/dp-$pkg"

    # ─── Conflict check ───
    if [[ -e "$shim" ]]; then
        echo "[DP] ERROR: dp-$pkg already exists!"
        echo "    → Run 'dumpsterpipe uninstall $pkg' first, or use 'clone' to make a copy."
        return 1
    fi

    echo "[DP] Creating venv for $pkg …"
    mkdir -p "$venv"
    python3 -m venv "$venv"

    echo "[DP] Installing $pkg via pip …"
    "$venv/bin/pip" install --quiet "$pkg" || {
        echo "[DP] Failed to install $pkg"
        rm -rf "$venv"
        return 1
    }

    local entry=$(dp::detect_entrypoint "$venv")

    # Create the shim
    mkdir -p "$HOME/.dumpsterpipe/bin"
    ln -sf "$venv/bin/$entry" "$shim"
    chmod 755 "$shim"

    # Register
    dp::registry_add "$pkg" "pip" "$entry"

    echo "Installed → dp-$pkg  ($entry)"
}
