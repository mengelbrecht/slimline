slimline_section_exit_status() {
  if (( slimline_last_exit_status == 0 )); then return; fi
  local exit_status=${slimline_last_exit_status}
  local format="%F{red}|exit_status| ↵%f"
  echo "${${SLIMLINE_EXIT_STATUS_FORMAT:-${format}}/|exit_status|/${exit_status}}"
}
