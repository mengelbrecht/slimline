slimline::section::git::precmd() {
  unset slimline_section_git_output
}

slimline::section::git::async_task() {
  command python "${slimline_path}/gitline/gitline.py" --shell=zsh "$*"
}

slimline::section::git::async_task_complete() {
  local output="${2}"
  slimline_section_git_output="${output}"
}

slimline::section::git::init() {
  # If python or git are not installed, disable the git functionality.
  if slimline::utils::callable "python" && slimline::utils::callable "git"; then
    return 0
  fi

  slimline::utils::warning "python and/or git not installed or not in PATH, disabling git section"
  return 1
}

slimline::section::git::render() {
  if [[ -z "${slimline_section_git_output}" ]]; then return; fi
  slimline::utils::expand "git" "|output|" "output" "${slimline_section_git_output}"
}
