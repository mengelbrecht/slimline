slimline::section::exit_status() {
  if (( slimline_last_exit_status == 0 )); then return; fi
  local format="%F{red}|exit_status| ↵%f"
  slimline::utils::expand "${SLIMLINE_EXIT_STATUS_FORMAT:-${format}}" "exit_status" "${slimline_last_exit_status}"
}
