prompt_slimline_section_exit_status() {
  if (( prompt_slimline_last_exit_status == 0 )); then return; fi
  local exit_status=${prompt_slimline_last_exit_status}
  local format="%F{red}|exit_status| ↵%f"
  echo "${${SLIMLINE_EXIT_STATUS_FORMAT:-${format}}/|exit_status|/${exit_status}}"
}
