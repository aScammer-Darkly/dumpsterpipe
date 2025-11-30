dp::gh_install() {
    local full="$1"
    local pkg user repo ref venv shim entry

    # Parse user/repo#ref
    if [[ "$full" =~ ^([a-zA-Z0-9_-]+/[a-zA-Z0-9._-]+)(#(.+))?$ ]]; then
        pkg="${full%%#*}"
        pkg="${pkg##*/}"
        user="${full%%/*}"
        repo="${full#*/}"; repo="${repo%%#*}"
        ref="${full#*#}"
        [[ "$ref" == "$full" ]] && ref="master"
    else
        echo "[DP] Invalid format: use user/repo or user/repo#ref"
        return 1
    fi

    venv="$HOME/.dumpsterpipe/venvs/$pkg"
    shim="$HOME/.dumpsterpipe/bin/dp-$pkg"

    [[ -e "$shim" ]] && { echo "[DP] dp-$pkg already exists"; return 1; }

    echo "[DP] Cloning $user/$repo @ $ref → $pkg"
    rm -rf "$venv"
    mkdir -p "$venv"

    git clone --depth 1 --branch "$ref" "https://github.com/$user/$repo.git" "$venv" 2>/dev/null || \
    git clone --depth 1 --branch "${ref/master/main}" "https://github.com/$user/$repo.git" "$venv" 2>/dev/null || \
    git clone --depth 1 "https://github.com/$user/$repo.git" "$venv" || {
        echo "[DP] Clone failed"
        rm -rf "$venv"
        return 1
    }

    cd "$venv" || return 1
    echo "[DP] Detecting build method..."

    # === PYTHON PROJECTS (MOST COMMON) ===
    if [[ -f pyproject.toml || -f setup.py || -f requirements.txt ]]; then
        echo "[DP] Python project → building in .venv"
        python3 -m venv .venv
        source .venv/bin/activate
        pip install -q . 2>/dev/null || pip install -q -e . 2>/dev/null

        # Find the actual binary in .venv/bin/
        entry=$(find .venv/bin -type f -executable ! -name "python*" ! -name "pip*" ! -name "wheel*" | head -n1)
        [[ -z "$entry" ]] && { echo "[DP] No binary found"; return 1; }
        entry="${entry#.venv/bin/}"

        # LINK TO .venv/bin/<binary>
        mkdir -p "$HOME/.dumpsterpipe/bin"
        ln -sf "$venv/.venv/bin/$entry" "$shim"
        chmod 755 "$shim"

    # === CARGO ===
    elif [[ -f Cargo.toml ]]; then
        echo "[DP] Rust → cargo install"
        cargo install --path . --root "$venv" --locked >/dev/null || return 1
        entry=$(ls "$venv/bin/" | head -n1)
        ln -sf "$venv/bin/$entry" "$shim"
        chmod 755 "$shim"

    # === GO ===
    elif [[ -f go.mod ]]; then
        echo "[DP] Go → building"
        go build -o "$venv/bin/$pkg" . || return 1
        ln -sf "$venv/bin/$pkg" "$shim"
        chmod 755 "$shim"
        entry="$pkg"

    # === RAW BINARY ===
    else
        entry=$(find . -maxdepth 2 -type f -executable \( -name "$pkg" -o -name "binwalk" -o -name "*.sh" \) | head -n1)
        [[ -z "$entry" ]] && { echo "[DP] No executable found"; return 1; }
        entry="${entry#./}"
        ln -sf "$venv/$entry" "$shim"
        chmod 755 "$shim"
    fi

    dp::registry_add "$pkg" "gh" "$entry" "github" "$user/$repo#$ref"
    echo "SUCCESS → dp-$pkg ($entry)"
}
