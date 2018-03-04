prompt_slimline_section_nodejs() {
  if [[ ! -f "package.json" && ! -d "node_modules" ]]; then return; fi
  local version="$(node -v 2>/dev/null)"
  local format="%F{white}[%F{green}⬢ |version|%F{white}]%f"
  echo "${${SLIMLINE_NODE_FORMAT:-${format}}/|version|/${version}}"
}
