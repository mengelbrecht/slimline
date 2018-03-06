slimline::section::cwd() {
  local -A variables=("path" "%3~")
  if [[ "$(builtin pwd)" == "/" ]]; then
    slimline::utils::expand "cwd_root" "%F{red}|path|%f" ${(kv)variables}
  else
    slimline::utils::expand "cwd" "%F{cyan}|path|%f" ${(kv)variables}
  fi
}
