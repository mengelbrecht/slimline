#-------------------------------------------------------------------------------
# Slimline
# Minimal, fast and elegant ZSH prompt
# by Markus Engelbrecht
# https://github.com/mgee/slimline
#
# Credits
# * pure (https://github.com/sindresorhus/pure)
# * sorin theme (https://github.com/sorin-ionescu/prezto)
#
# MIT License
#-------------------------------------------------------------------------------

prompt_slimline_path="${0:A:h}"
prompt_slimline_default_user="${SLIMLINE_DEFAULT_USER:-${USER}}"

# turns seconds into human readable time
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
prompt_slimline_human_time() {
  local tmp=$1
  local days=$(( tmp / 60 / 60 / 24 ))
  local hours=$(( tmp / 60 / 60 % 24 ))
  local minutes=$(( tmp / 60 % 60 ))
  local seconds=$(( tmp % 60 ))
  (( days > 0 )) && echo -n "${days}d "
  (( hours > 0 )) && echo -n "${hours}h "
  (( minutes > 0 )) && echo -n "${minutes}m "
  echo "${seconds}s"
}

prompt_slimline_check_cmd_exec_time() {
  local integer elapsed
  (( elapsed = EPOCHSECONDS - ${_prompt_slimline_cmd_timestamp:-$EPOCHSECONDS} ))
  _prompt_slimline_cmd_exec_time=
  if (( elapsed > ${SLIMLINE_MAX_EXEC_TIME:-5} )); then
    _prompt_slimline_cmd_exec_time="$(prompt_slimline_human_time $elapsed)"
  fi
}

prompt_slimline_section_aws_profile() {
  if [[ -z "${AWS_PROFILE}" ]]; then return; fi
  local profile="${AWS_PROFILE}"
  local format="%F{white}(%f%F{blue}|profile|%f%F{white})%f"
  echo "${${SLIMLINE_AWS_PROFILE_FORMAT:-${format}}/|profile|/${profile}}"
}

prompt_slimline_section_user_host_info() {
  if [[ -z "${SSH_TTY}" && "${USER}" == "${prompt_slimline_default_user}" ]]; then return; fi

  local user="%n"
  local host="%m"
  local format_root="%F{red}|user|%f@%F{yellow}|host|%f"
  local format="%F{green}|user|%f@%F{yellow}|host|%f"
  local selected=''
  if [[ ${UID} -eq 0 ]]; then
    selected="${SLIMLINE_USER_HOST_INFO_ROOT_FORMAT:-${format_root}}"
  else
    selected="${SLIMLINE_USER_HOST_INFO_FORMAT:-${format}}"
  fi
  echo "${${selected/|user|/${user}}/|host|/${host}}"
}

prompt_slimline_section_cwd() {
  local path="%3~"
  local format_root="%F{red}|path|%f"
  local format="%F{cyan}|path|%f"
  local selected=''
  if [[ "$(builtin pwd)" == "/" ]]; then
    selected="${SLIMLINE_CWD_ROOT_FORMAT:-${format_root}}"
  else
    selected="${SLIMLINE_CWD_FORMAT:-${format}}"
  fi
  echo "${selected/|path|/${path}}"
}

prompt_slimline_section_symbol() {
  local stage=${1}
  local format_working="%F{red}∙%f"
  local format_ready="%F{white}∙%f"
  if [[ "${stage}" == "async_callback" ]]; then
    echo "${SLIMLINE_SYMBOL_READY_FORMAT:-${format_ready}}"
  else
    echo "${SLIMLINE_SYMBOL_WORKING_FORMAT:-${format_working}}"
  fi
}

prompt_slimline_section_execution_time() {
  # add elapsed time if threshold is exceeded
  if [[ -z "${_prompt_slimline_cmd_exec_time}" ]]; then return; fi
  local exec_time="${_prompt_slimline_cmd_exec_time}"
  local format="%F{yellow}|exec_time|%f"
  echo "${${SLIMLINE_EXECUTION_TIME_FORMAT:-${format}}/|exec_time|/${exec_time}}"
}

prompt_slimline_section_exit_status() {
  if (( _prompt_slimline_last_exit_status == 0 )); then return; fi
  local exit_status=${_prompt_slimline_last_exit_status}
  local format="%F{red}|exit_status| ↵%f"
  echo "${${SLIMLINE_EXIT_STATUS_FORMAT:-${format}}/|exit_status|/${exit_status}}"
}

prompt_slimline_section_git() {
  if [[ -z "${_prompt_slimline_git_output}" ]]; then return; fi
  echo "${_prompt_slimline_git_output}"
}

prompt_slimline_section_virtual_env() {
  if [[ -z "${VIRTUAL_ENV}" ]]; then return; fi

  local virtual_env="${VIRTUAL_ENV##*/}"
  local format="%F{white}(%f%F{cyan}|virtual_env|%f%F{white})%f"
  echo "${${SLIMLINE_VIRTUAL_ENV_FORMAT:-${format}}/|virtual_env|/${virtual_env}}"
}

prompt_slimline_get_sections() {
  local var=${1}
  local sections=${2}
  local separator=${3}
  shift 3

  outputs=()
  for section in ${=sections}; do
    local output="$(${section} "$*")"
    if [[ -n ${output} ]]; then
      outputs+=("${output}")
    fi
  done

  typeset -g "${var}"="${(epj:${separator}:)outputs}"
}

prompt_slimline_set_left_prompt() {
  local separator="${SLIMLINE_LEFT_PROMPT_SECTION_SEPARATOR:- }"
  prompt_slimline_get_sections "_prompt_slimline_left_prompt_sections_output" "${_prompt_slimline_left_prompt_sections}" "${separator}" "$*"

  local format="|sections| "
  PROMPT="${${SLIMLINE_LEFT_PROMPT_FORMAT:-${format}}/|sections|/${_prompt_slimline_left_prompt_sections_output}}"
  unset _prompt_slimline_left_prompt_sections_output
}

prompt_slimline_set_right_prompt() {
  local separator="${SLIMLINE_RIGHT_PROMPT_SECTION_SEPARATOR:- }"
  prompt_slimline_get_sections "_prompt_slimline_right_prompt_sections_output" "${_prompt_slimline_right_prompt_sections}" "${separator}" "$*"

  local format="|sections|"
  RPROMPT="${${SLIMLINE_RIGHT_PROMPT_FORMAT:-${format}}/|sections|/${_prompt_slimline_right_prompt_sections_output}}"
  unset _prompt_slimline_right_prompt_sections_output
}

prompt_slimline_set_spelling_prompt() {
  local from="%R"
  local to="%r"
  local format="zsh: correct %F{red}|from|%f to %F{green}|to|%f [nyae]? "
  local selected="${SLIMLINE_AUTOCORRECT_FORMAT:-${format}}"
  SPROMPT="${${selected/|from|/${from}}/|to|/${to}}"
}

prompt_slimline_chpwd() {
  prompt_slimline_async_tasks
}

prompt_slimline_precmd() {
  prompt_slimline_check_cmd_exec_time

  unset _prompt_slimline_cmd_timestamp
  unset _prompt_slimline_git_output

  if (( EPOCHREALTIME - ${_prompt_slimline_last_async_call:-0} > 0.5 )); then
    prompt_slimline_set_left_prompt "precmd"
    prompt_slimline_set_right_prompt "precmd"

    prompt_slimline_async_tasks
  fi
}

prompt_slimline_preexec() {
  _prompt_slimline_cmd_timestamp=$EPOCHSECONDS
}

prompt_slimline_exit_status() {
  _prompt_slimline_last_exit_status=$?
}

prompt_slimline_async_git() {
  if (( ! _prompt_slimline_enable_git_task )); then return; fi
  command python "${prompt_slimline_path}/gitline/gitline.py" --shell=zsh "$*"
}

prompt_slimline_async_callback() {
  local job=${1}
  local output=${3}
  local has_next=${6}

  case "${job}" in
    prompt_slimline_async_git)
      _prompt_slimline_git_output="${output}"
    ;;
  esac

  if (( ! has_next )); then
    prompt_slimline_set_left_prompt "async_callback"
    prompt_slimline_set_right_prompt "async_callback"
    zle && zle .reset-prompt
  fi
}

prompt_slimline_async_tasks() {
  _prompt_slimline_last_async_call=${EPOCHREALTIME}
  async_flush_jobs "prompt_slimline"
  async_job "prompt_slimline" prompt_slimline_async_git "$(builtin pwd)"
}

prompt_slimline_async_init() {
  if (( ${SLIMLINE_ENABLE_ASYNC_AUTOLOAD:-1} && !$+functions[async_init] && !$+functions[async_start_worker] )); then
    source "${prompt_slimline_path}/zsh-async/async.zsh"
  fi
  async_init
  async_start_worker "prompt_slimline" -u
  async_register_callback "prompt_slimline" prompt_slimline_async_callback
}

prompt_slimline_evaluate_legacy_options() {
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
    SLIMLINE_EXECUTION_TIME_FORMAT="%F{${SLIMLINE_EXEC_TIME_COLOR:-yellow}}|exec_time|%f"
    right_prompt_sections+=("execution_time")
  fi

  if (( ${SLIMLINE_DISPLAY_EXIT_STATUS:-1} )); then
    SLIMLINE_EXIT_STATUS_FORMAT="%F{${SLIMLINE_EXIT_STATUS_COLOR:-red}}|exit_status| ${SLIMLINE_EXIT_STATUS_SYMBOL:-↵}%f"
    right_prompt_sections+=("exit_status")
  fi

  if (( ${SLIMLINE_ENABLE_GIT:-1} )); then
    right_prompt_sections+=("git")
  fi

  if (( ${SLIMLINE_DISPLAY_VIRTUALENV:-1} )); then
    local parens_color="${SLIMLINE_VIRTUALENV_PARENS_COLOR:-white}"
    SLIMLINE_VIRTUAL_ENV_FORMAT="%F{$parens_color}(%f%F{${SLIMLINE_VIRTUALENV_COLOR:-cyan}}|virtual_env|%f%F{$parens_color})%f"
    right_prompt_sections+=("virtual_env")
  fi

  SLIMLINE_AUTOCORRECT_FORMAT="zsh: correct %F{${SLIMLINE_AUTOCORRECT_MISSPELLED_COLOR:-red}}|from|%f to %F{${SLIMLINE_AUTOCORRECT_PROPOSED_COLOR:-green}}|to|%f [nyae]? "

  SLIMLINE_LEFT_PROMPT_SECTIONS="${(j: :)left_prompt_sections}"
  SLIMLINE_RIGHT_PROMPT_SECTIONS="${(j: :)right_prompt_sections}"
}

prompt_slimline_check_git_support() {
  if (( ${=_prompt_slimline_left_prompt_sections[(I)git]} || ${=_prompt_slimline_right_prompt_sections[(I)git]} )); then
    # If python or git are not installed, disable the git functionality.
    if (( $+commands[python] && $+commands[git] )); then
      _prompt_slimline_enable_git_task=1
    else
      print -P "%F{red}slimline%f: python and/or git not installed or not in PATH, disabling git information"
      _prompt_slimline_enable_git_task=0
    fi
  else
    _prompt_slimline_enable_git_task=0
  fi
}

prompt_slimline_expand_sections() {
  local var=${1}
  local expanded_sections=()
  for section in ${=${(P)var}}; do
    local function_name="prompt_slimline_section_${section}"
    if (( ! $+functions[${function_name}] )); then
      print -P "%F{red}slimline%f: '${section}' is not a valid section!"
      continue
    fi
    expanded_sections+=("${function_name}")
  done

  typeset -g "${var}"="${(j: :)expanded_sections}"
}

prompt_slimline_setup() {
  if (( ${SLIMLINE_PROMPT_VERSION:-1} < 2 )); then
    prompt_slimline_evaluate_legacy_options
  fi

  _prompt_slimline_left_prompt_sections="${SLIMLINE_LEFT_PROMPT_SECTIONS-user_host_info cwd aws_profile symbol}"
  _prompt_slimline_right_prompt_sections="${SLIMLINE_RIGHT_PROMPT_SECTIONS-execution_time exit_status git virtual_env}"
  prompt_slimline_check_git_support
  prompt_slimline_expand_sections "_prompt_slimline_left_prompt_sections"
  prompt_slimline_expand_sections "_prompt_slimline_right_prompt_sections"

  prompt_opts=(cr percent subst)

  zmodload zsh/datetime
  zmodload zsh/zle

  autoload -Uz add-zsh-hook

  add-zsh-hook chpwd prompt_slimline_chpwd
  add-zsh-hook precmd prompt_slimline_precmd
  add-zsh-hook preexec prompt_slimline_preexec

  precmd_functions=("prompt_slimline_exit_status" ${precmd_functions[@]})

  prompt_slimline_async_init

  prompt_slimline_set_left_prompt "setup"
  prompt_slimline_set_right_prompt "setup"
  prompt_slimline_set_spelling_prompt
}

prompt_slimline_setup "$@"
