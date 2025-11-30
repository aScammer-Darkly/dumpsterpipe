# Registry and helper utilities for DumpsterPipe

DP_REGISTRY="$HOME/.dumpsterpipe/registry/installed.json"

# Ensure registry file exists
if [[ ! -f "$DP_REGISTRY" ]]; then
    echo "{}" > "$DP_REGISTRY"
fi

# Add entry to registry
dp::registry_add() {
    local pkg="$1" backend="$2" entry="$3" source="${4:-pip}" ref="${5:-}"

    jq --arg pkg "$pkg" \
       --arg backend "$backend" \
       --arg entry "$entry" \
       --arg source "$source" \
       --arg ref "$ref" \
       '.[$pkg] = {backend: $backend, entry: $entry, source: $source, ref: ($ref // null)}' \
       "$DP_REGISTRY" | sponge "$DP_REGISTRY"
}

dp::registry_remove() {
    local pkg="$1"
    jq "del(.$pkg)" "$DP_REGISTRY" | sponge "$DP_REGISTRY"
}
# List entries
dp::registry_list() {
    jq 'keys' "$DP_REGISTRY"
}
