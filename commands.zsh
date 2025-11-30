# Basic commands for DumpsterPipe

dp::cmd_uninstall() {
    local pkg="$1"
    if [[ -z "$pkg" ]]; then
        echo "[DP] Usage: dumpsterpipe uninstall <package>"
        return 1
    fi

    echo "[DP] Removing $pkg …"

    # Remove venv
    rm -rf "$HOME/.dumpsterpipe/venvs/$pkg"

    # Remove shim
    rm -f "$HOME/.dumpsterpipe/bin/dp-$pkg"

    # Update registry
    dp::registry_remove "$pkg"

    echo "[DP] Uninstalled $pkg"
}

dp::cmd_list() {
    echo "[DP] Installed packages:"
    jq -r 'keys[]' "$DP_REGISTRY"
}

dp::cmd_cache() {
    case "$1" in
        update)
           echo "[DP] Updating PyPI cache (this takes ~15–25 seconds)…"
               local cache_file="$HOME/.dumpsterpipe/cache/pypi-packages.txt"
               mkdir -p "$(dirname "$cache_file")"
           
               if curl -sfL --max-time 40 https://pypi.org/simple/ > /tmp/pypi_simple.html; then
                   # Pure POSIX grep + sed — works on every Linux ever made
                   grep -o '<a href="/simple/[^"]*' /tmp/pypi_simple.html \
                       | sed 's|.*simple/||' \
                       | tr '[:upper:]' '[:lower:]' \
                       | sort -u > "$cache_file"
           
                   local count=$(wc -l < "$cache_file")
                   echo "[DP] Cache updated – $count packages ready for tab completion"
                   rm -f /tmp/pypi_simple.html
               else
                   echo "[DP] Failed to reach PyPI (network down or they’re being slow)"
                   return 1
               fi
        ;;
        *)
            echo "[DP] Usage: dumpsterpipe cache update"
        ;;
    esac
}

dp::cmd_path() {
    echo "$HOME/.dumpsterpipe/bin"
}
