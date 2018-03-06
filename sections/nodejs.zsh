slimline_section_nodejs_precmd() {
  unset slimline_section_nodejs_output
}

slimline_section_nodejs_async_task() {
  echo "$(node -v 2>/dev/null)"
}

slimline_section_nodejs_async_task_complete() {
  local output="${3}"
  slimline_section_nodejs_output="${output}"
}

slimline_section_nodejs() {
  if [[ ! -f "package.json" && ! -d "node_modules" ]]; then return; fi
  if [[ -z "${slimline_section_nodejs_output}" ]]; then return; fi
  local version="${slimline_section_nodejs_output}"
  local format="%F{white}[%F{green}⬢ |version|%F{white}]%f"
  echo "${${SLIMLINE_NODE_FORMAT:-${format}}/|version|/${version}}"
}
