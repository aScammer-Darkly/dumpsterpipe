#compdef dumpsterpipe dp

_dp_complete() {
  local -a cmds=(install uninstall upgrade clone list cache path info run help)
  local -a installed
  installed=($(jq -r 'keys[]' ~/.dumpsterpipe/registry/installed.json 2>/dev/null))

  # Command completion
  if (( CURRENT == 2 )); then
    _describe 'command' cmds
    return
  fi

  case $words[2] in
    install)
      if (( CURRENT == 3 )); then
        _values 'backend' 'pip'
      elif (( CURRENT >= 4 )); then
        if [[ -f ~/.dumpsterpipe/cache/pypi-packages.txt ]]; then
          local matches
          matches=(${(f)"$(grep -i "^${words[CURRENT]}" ~/.dumpsterpipe/cache/pypi-packages.txt 2>/dev/null | head -n 50)"})
          [[ -n $matches ]] && _describe 'package' matches
        fi
      fi
      ;;
    uninstall|upgrade|clone|info|run)
      _describe 'installed' installed
      ;;
    cache)
      (( CURRENT == 3 )) && _values 'action' 'update'
      ;;
  esac
}

# Force registration for both names
compdef _dp_complete dumpsterpipe
compdef _dp_complete dp
