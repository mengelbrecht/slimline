slimline::section::git::precmd() {
  unset slimline_section_git_output
}

slimline::section::git::async_task() {
  command python "${slimline_path}/gitline/gitline.py" --shell=zsh "$*"
}

slimline::section::git::async_task_complete() {
  local output=${3}
  slimline_section_git_output="${output}"
}

slimline::section::git::init() {
  # If python or git are not installed, disable the git functionality.
  if (( ${+commands[python]} && ${+commands[git]} )); then
      return 0
  fi

  print -P "%F{red}slimline%f: python and/or git not installed or not in PATH, disabling git information"
  return 1
}

slimline::section::git() {
  if [[ -z "${slimline_section_git_output}" ]]; then return; fi
  local output="${slimline_section_git_output}"
  local format="|output|"
  echo "${${SLIMLINE_GIT_FORMAT:-${format}}/|output|/${output}}"
}
