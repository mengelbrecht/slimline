slimline::section::exit_status::render() {
  if (( slimline_last_exit_status == 0 )); then return; fi
  slimline::utils::expand "exit_status" "%F{red}|exit_status| ↵%f" \
      "exit_status" "${slimline_last_exit_status}"
}
