# Central install dispatcher — backend-agnostic
dp::cmd_install() {
    local backend="$1"; shift
    local package="$1"; shift

    if [[ -z "$backend" || -z "$package" ]]; then
        echo "[DP] Usage: dp install <backend> <package>"
        return 1
    fi

    case "$backend" in
        pip)  dp::pip_install  "$package" ;;
        gh)   dp::gh_install   "$package" ;;
        flatpak|cargo|npm|raw) 
              echo "[DP] Backend '$backend' not loaded yet — coming soon™" 
              return 1 
              ;;
        *)    echo "[DP] Unknown backend: $backend"; return 1 ;;
    esac
}
