slimline::section::symbol() {
  local event=${1}
  local format_working="%F{red}∙%f"
  local format_ready="%F{white}∙%f"
  if [[ "${event}" == "all_tasks_complete" ]]; then
    echo "${SLIMLINE_SYMBOL_READY_FORMAT:-${format_ready}}"
  else
    echo "${SLIMLINE_SYMBOL_WORKING_FORMAT:-${format_working}}"
  fi
}
