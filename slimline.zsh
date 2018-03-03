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
  # add AWS profile info
  if (( ! ${SLIMLINE_DISPLAY_AWS_INFO:-0} )) || [[ -z "${AWS_PROFILE}" ]]; then return; fi
  echo "%F{${SLIMLINE_AWS_COLOR:-blue}}${AWS_PROFILE}%f"
}

prompt_slimline_section_user_host_info() {
  if (( ! ${SLIMLINE_DISPLAY_USER_HOST_INFO:-1} )); then return; fi
  if [[ -z "$SSH_TTY" && "${USER}" == "${prompt_slimline_default_user}" ]]; then return; fi

  local user_color=''
  if [[ $UID -eq 0 ]]; then
    user_color="${SLIMLINE_USER_ROOT_COLOR:-red}"
  else
    user_color="${SLIMLINE_USER_COLOR:-green}"
  fi
  echo "%F{${user_color}}%n%f@%F{${SLIMLINE_HOST_COLOR:-yellow}}%m%f"
}

prompt_slimline_section_cwd() {
  local cwd_color=''
  if [[ "$(builtin pwd)" == "/" ]]; then
    cwd_color="${SLIMLINE_CWD_ROOT_COLOR:-red}"
  else
    cwd_color="${SLIMLINE_CWD_COLOR:-cyan}"
  fi
  echo "%F{${cwd_color}}%3~%f"
}

prompt_slimline_section_symbol() {
  local stage=${1}
  local symbol_color=''
  if [[ "${stage}" == "async_callback" ]]; then
    symbol_color=${SLIMLINE_PROMPT_SYMBOL_COLOR_READY:-white}
  else
    symbol_color=${SLIMLINE_PROMPT_SYMBOL_COLOR_WORKING:-red}
  fi
  echo "%F{$symbol_color}${SLIMLINE_PROMPT_SYMBOL:-∙}%f"
}

prompt_slimline_section_execution_time() {
  # add elapsed time if threshold is exceeded
  if (( ! ${SLIMLINE_DISPLAY_EXEC_TIME:-1} )) || [[ -z "${_prompt_slimline_cmd_exec_time}" ]]; then return; fi
  echo "%F{${SLIMLINE_EXEC_TIME_COLOR:-yellow}}${_prompt_slimline_cmd_exec_time}%f"
}

prompt_slimline_section_exit_status() {
  if (( ! ${SLIMLINE_DISPLAY_EXIT_STATUS:-1} )); then return; fi
  if (( _prompt_slimline_last_exit_status == 0 )); then return; fi
  echo "%F{${SLIMLINE_EXIT_STATUS_COLOR:-red}}${_prompt_slimline_last_exit_status} ${SLIMLINE_EXIT_STATUS_SYMBOL:-↵}%f"
}

prompt_slimline_section_git() {
  if [[ -z "${_prompt_slimline_git_output}" ]]; then return; fi
  echo "${_prompt_slimline_git_output}"
}

prompt_slimline_section_virtualenv() {
  if (( ! ${SLIMLINE_DISPLAY_VIRTUALENV:-1} )) || [[ -z $VIRTUAL_ENV ]]; then return; fi

  local parens_color="${SLIMLINE_VIRTUALENV_PARENS_COLOR:-white}"
  local virtualenv_color="${SLIMLINE_VIRTUALENV_COLOR:-cyan}"
  echo "%F{$parens_color}(%f%F{$virtualenv_color}$(basename "${VIRTUAL_ENV}")%f%F{$parens_color})%f"
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

prompt_slimline_set_prompt() {
  local separator="${SLIMLINE_PROMPT_SECTION_SEPARATOR:- }"
  prompt_slimline_get_sections "_prompt_slimline_prompt_sections_output" "${_prompt_slimline_prompt_sections}" "${separator}" "$*"

  PROMPT="${_prompt_slimline_prompt_sections_output} "
  unset _prompt_slimline_prompt_sections_output
}

prompt_slimline_set_rprompt() {
  local separator="${SLIMLINE_RPROMPT_SECTION_SEPARATOR:- }"
  prompt_slimline_get_sections "_prompt_slimline_rprompt_sections_output" "${_prompt_slimline_rprompt_sections}" "${separator}" "$*"

  RPROMPT="${_prompt_slimline_rprompt_sections_output}"
  unset _prompt_slimline_rprompt_sections_output
}

prompt_slimline_set_sprompt() {
  SPROMPT="zsh: correct %F{${SLIMLINE_AUTOCORRECT_MISSPELLED_COLOR:-red}}%R%f to %F{${SLIMLINE_AUTOCORRECT_PROPOSED_COLOR:-green}}%r%f [nyae]? "
}

prompt_slimline_chpwd() {
  prompt_slimline_async_tasks
}

prompt_slimline_precmd() {
  prompt_slimline_check_cmd_exec_time

  unset _prompt_slimline_cmd_timestamp
  unset _prompt_slimline_git_output

  if (( EPOCHREALTIME - ${_prompt_slimline_last_async_call:-0} > 0.5 )); then
    prompt_slimline_set_prompt "precmd"
    prompt_slimline_set_rprompt "precmd"

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
      prompt_slimline_set_prompt "async_callback"
      prompt_slimline_set_rprompt "async_callback"
    ;;
  esac

  if (( ! has_next )); then
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
  local prompt_sections=(user_host_info cwd aws_profile symbol)
  local rprompt_sections=(execution_time exit_status git virtualenv)
  SLIMLINE_PROMPT_SECTIONS="${(j: :)prompt_sections}"
  SLIMLINE_RPROMPT_SECTIONS="${(j: :)rprompt_sections}"
}

prompt_slimline_check_git_support() {
  if (( ${=_prompt_slimline_prompt_sections[(I)git]} || ${=_prompt_slimline_rprompt_sections[(I)git]} )); then
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

  _prompt_slimline_prompt_sections="${SLIMLINE_PROMPT_SECTIONS-user_host_info cwd aws_profile symbol}"
  _prompt_slimline_rprompt_sections="${SLIMLINE_RPROMPT_SECTIONS-execution_time exit_status git virtualenv}"
  prompt_slimline_check_git_support
  prompt_slimline_expand_sections "_prompt_slimline_prompt_sections"
  prompt_slimline_expand_sections "_prompt_slimline_rprompt_sections"

  prompt_opts=(cr percent subst)

  zmodload zsh/datetime
  zmodload zsh/zle

  autoload -Uz add-zsh-hook

  add-zsh-hook chpwd prompt_slimline_chpwd
  add-zsh-hook precmd prompt_slimline_precmd
  add-zsh-hook preexec prompt_slimline_preexec

  precmd_functions=("prompt_slimline_exit_status" ${precmd_functions[@]})

  prompt_slimline_async_init

  prompt_slimline_set_prompt "setup"
  prompt_slimline_set_rprompt "setup"
  prompt_slimline_set_sprompt
}

prompt_slimline_setup "$@"
