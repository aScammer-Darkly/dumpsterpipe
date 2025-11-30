# Load helper modules
source "$DP_ROOT/helpers.zsh"
source "$DP_ROOT/entrypoints.zsh"
source "$DP_ROOT/commands.zsh"
# Load backends
source "$DP_ROOT/backend-pip.zsh"
source "$DP_ROOT/backend-gh.zsh"

dp::main() {
    local cmd="$1"; shift

    case "$cmd" in
        install)   dp::cmd_install "$@" ;;
        uninstall) dp::cmd_uninstall "$@" ;;
        list)      dp::cmd_list ;;
        cache)     dp::cmd_cache "$@" ;;
        path)      dp::cmd_path ;;
        help|--help|-h|"") dp::help ;;
        *)
            echo "[DumpsterPipe] Unknown command: $cmd"
            dp::help
        ;;
    esac
}
source "$DP_ROOT/command-install.zsh"
