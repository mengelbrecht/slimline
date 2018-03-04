prompt_slimline_section_git_precmd() {
  unset _prompt_slimline_git_output
}

prompt_slimline_section_git_async_task() {
  command python "${prompt_slimline_path}/gitline/gitline.py" --shell=zsh "$*"
}

prompt_slimline_section_git_async_task_complete() {
  local output=${3}
  _prompt_slimline_git_output="${output}"
}

prompt_slimline_section_git_init() {
  # If python or git are not installed, disable the git functionality.
  if (( ${+commands[python]} && ${+commands[git]} )); then
      return 0
  fi

  print -P "%F{red}slimline%f: python and/or git not installed or not in PATH, disabling git information"
  return 1
}

prompt_slimline_section_git() {
  if [[ -z "${_prompt_slimline_git_output}" ]]; then return; fi
  local output="${_prompt_slimline_git_output}"
  local format="|output|"
  echo "${${SLIMLINE_GIT_FORMAT:-${format}}/|output|/${output}}"
}
