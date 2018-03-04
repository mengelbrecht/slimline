prompt_slimline_section_cwd() {
  local path="%3~"
  local format_root="%F{red}|path|%f"
  local format="%F{cyan}|path|%f"
  local selected=''
  if [[ "$(builtin pwd)" == "/" ]]; then
    selected="${SLIMLINE_CWD_ROOT_FORMAT:-${format_root}}"
  else
    selected="${SLIMLINE_CWD_FORMAT:-${format}}"
  fi
  echo "${selected/|path|/${path}}"
}
