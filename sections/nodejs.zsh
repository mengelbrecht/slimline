slimline::section::nodejs::precmd() {
  unset slimline_section_nodejs_output
}

slimline::section::nodejs::async_task() {
  builtin cd "${1}"
  if [[ ! -f "package.json" && ! -d "node_modules" ]]; then return; fi
  command node -v 2>/dev/null
}

slimline::section::nodejs::async_task_complete() {
  local output="${2}"
  slimline_section_nodejs_output="${output}"
}

slimline::section::nodejs::render() {
  if [[ -z "${slimline_section_nodejs_output}" ]]; then return; fi
  slimline::utils::expand "nodejs" "%F{white}[%F{green}⬢ |version|%F{white}]%f" \
      "version" "${slimline_section_nodejs_output}"
}
