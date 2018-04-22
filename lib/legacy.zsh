slimline::legacy::evaluate_options() {
  local left_prompt_sections=()
  local right_prompt_sections=()

  if (( ${SLIMLINE_DISPLAY_USER_HOST_INFO:-1} )); then
    SLIMLINE_USER_HOST_INFO_ROOT_FORMAT="%F{${SLIMLINE_USER_ROOT_COLOR:-red}}|user|%f@%F{${SLIMLINE_HOST_COLOR:-yellow}}|host|%f"
    SLIMLINE_USER_HOST_INFO_FORMAT="%F{${SLIMLINE_USER_COLOR:-green}}|user|%f@%F{${SLIMLINE_HOST_COLOR:-yellow}}|host|%f"
    left_prompt_sections+=("user_host_info")
  fi

  SLIMLINE_CWD_ROOT_FORMAT="%F{${SLIMLINE_CWD_ROOT_COLOR:-red}}|path|%f"
  SLIMLINE_CWD_FORMAT="%F{${SLIMLINE_CWD_COLOR:-cyan}}|path|%f"
  left_prompt_sections+=("cwd")

  if (( ${SLIMLINE_DISPLAY_AWS_INFO:-0} )); then
    SLIMLINE_AWS_PROFILE_FORMAT="%F{${SLIMLINE_AWS_COLOR:-blue}}|profile|%f"
    left_prompt_sections+=("aws_profile");
  fi

  SLIMLINE_SYMBOL_READY_FORMAT="%F{${SLIMLINE_PROMPT_SYMBOL_COLOR_READY:-white}}${SLIMLINE_PROMPT_SYMBOL:-∙}%f"
  SLIMLINE_SYMBOL_WORKING_FORMAT="%F{${SLIMLINE_PROMPT_SYMBOL_COLOR_WORKING:-red}}${SLIMLINE_PROMPT_SYMBOL:-∙}%f"
  left_prompt_sections+=("symbol")

  if (( ${SLIMLINE_DISPLAY_EXEC_TIME:-1} )); then
    SLIMLINE_EXECUTION_TIME_FORMAT="%F{${SLIMLINE_EXEC_TIME_COLOR:-yellow}}|time|%f"
    right_prompt_sections+=("execution_time")
  fi

  if (( ${SLIMLINE_DISPLAY_EXIT_STATUS:-1} )); then
    SLIMLINE_EXIT_STATUS_FORMAT="%F{${SLIMLINE_EXIT_STATUS_COLOR:-red}}|exit_status| ${SLIMLINE_EXIT_STATUS_SYMBOL:-↵}%f"
    right_prompt_sections+=("exit_status")
  fi

  if (( ${SLIMLINE_ENABLE_GIT:-1} )); then
    SLIMLINE_GIT_FORMAT="|output|"
    right_prompt_sections+=("git")
  fi

  if (( ${SLIMLINE_DISPLAY_VIRTUALENV:-1} )); then
    local parens_color="${SLIMLINE_VIRTUALENV_PARENS_COLOR:-white}"
    SLIMLINE_VIRTUALENV_FORMAT="%F{$parens_color}(%f%F{${SLIMLINE_VIRTUALENV_COLOR:-cyan}}|basename|%f%F{$parens_color})%f"
    right_prompt_sections+=("virtualenv")
  fi

  SLIMLINE_AUTOCORRECT_FORMAT="zsh: correct %F{${SLIMLINE_AUTOCORRECT_MISSPELLED_COLOR:-red}}|from|%f to %F{${SLIMLINE_AUTOCORRECT_PROPOSED_COLOR:-green}}|to|%f [nyae]? "

  SLIMLINE_LEFT_PROMPT_SECTIONS="${(j: :)left_prompt_sections}"
  SLIMLINE_RIGHT_PROMPT_SECTIONS="${(j: :)right_prompt_sections}"
}
