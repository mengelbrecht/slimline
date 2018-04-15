slimline::section::symbol::render() {
  if slimline::async::all_tasks_complete; then
    slimline::utils::expand "symbol_ready" "%F{white}∙%f"
  else
    slimline::utils::expand "symbol_working" "%F{red}∙%f"
  fi
}
