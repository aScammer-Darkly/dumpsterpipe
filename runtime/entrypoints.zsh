dp::detect_entrypoint() {
    local venv="$1"
    local dist_info

    # Find the first .dist-info or .egg-info directory
    dist_info=$(find "$venv/lib" -maxdepth 3 -type d -name "*.dist-info" -print -quit 2>/dev/null)
    [[ -z "$$ dist_info" ]] && dist_info= $$(find "$venv/lib" -maxdepth 3 -type d -name "*.egg-info" -print -quit 2>/dev/null)

    # 1. Parse [console_scripts] properly
    if [[ -f "$dist_info/entry_points.txt" ]]; then
        local ep
        ep=$(awk -F ' = ' '
            /^$$ console_scripts $$/ { in_section=1; next }
            in_section && /^$/ { exit }
            in_section && NF && $1 !~ /^#/ { print $1; exit }
        ' "$dist_info/entry_points.txt")

        if [[ -n "$ep" && -x "$venv/bin/$ep" ]]; then
            echo "$ep"
            return 0
        fi
    fi

    # 2. Fallback: first executable that isn't python/pip/wheel
    local candidates=("$venv/bin/"*)
    for bin in "${candidates[@]}"; do
        local name=$(basename "$bin")
        # Skip python, pip, wheel, and any .dist-info junk
        [[ "$name" == python* || "$name" == pip* || "$name" == wheel* || "$name" == .* ]] && continue
        [[ -x "$bin" ]] || continue
        echo "$name"
        return 0
    done

    # 3. Absolute nuclear option
    echo "python"
}
