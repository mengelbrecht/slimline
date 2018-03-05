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

source "${prompt_slimline_path}/lib/section.zsh"

prompt_slimline_set_left_prompt() {
  local separator="${SLIMLINE_LEFT_PROMPT_SECTION_SEPARATOR:- }"
  prompt_slimline_get_section_output "${_prompt_slimline_left_prompt_sections}" "${separator}" "_prompt_slimline_left_prompt_sections_output" "$@"

  local format="|sections| "
  PROMPT="${${SLIMLINE_LEFT_PROMPT_FORMAT:-${format}}/|sections|/${_prompt_slimline_left_prompt_sections_output}}"
  unset _prompt_slimline_left_prompt_sections_output
}

prompt_slimline_set_right_prompt() {
  local separator="${SLIMLINE_RIGHT_PROMPT_SECTION_SEPARATOR:- }"
  prompt_slimline_get_section_output "${_prompt_slimline_right_prompt_sections}" "${separator}" "_prompt_slimline_right_prompt_sections_output" "$@"

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

prompt_slimline_set_prompts() {
  local event="${1}"
  prompt_slimline_set_left_prompt "${event}"
  prompt_slimline_set_right_prompt "${event}"
}

prompt_slimline_chpwd() {
  if (( ${#_prompt_slimline_async_tasks[@]} )); then
    prompt_slimline_async_tasks
  fi
}

prompt_slimline_precmd() {
  if (( EPOCHREALTIME - ${_prompt_slimline_last_async_call:-0} > 0.5 )); then
    # In case no tasks need to be executed signal the sections that all tasks are finished.
    if (( ${#_prompt_slimline_async_tasks[@]} )); then
      prompt_slimline_set_prompts "precmd"
      prompt_slimline_async_tasks
    else
      prompt_slimline_set_prompts "all_tasks_complete"
    fi
  fi
}

prompt_slimline_exit_status() {
  prompt_slimline_last_exit_status=$?
}

prompt_slimline_async_callback() {
  local job=${1}
  local has_next=${6}

  local complete_function="${job}_complete"
  ${complete_function} "$@"

  _prompt_slimline_async_tasks_complete=$(( _prompt_slimline_async_tasks_complete + 1 ))

  if (( ! has_next )); then
    local event=''
    if (( _prompt_slimline_async_tasks_complete == ${#_prompt_slimline_async_tasks} )); then
      event="all_tasks_complete"
    else
      event="task_complete"
    fi
    prompt_slimline_set_prompts "${event}"
    zle && zle .reset-prompt
  fi
}

prompt_slimline_async_tasks() {
  async_flush_jobs "prompt_slimline"
  _prompt_slimline_last_async_call=${EPOCHREALTIME}
  _prompt_slimline_async_tasks_complete=0
  for task in ${_prompt_slimline_async_tasks}; do
    async_job "prompt_slimline" "${task}" "$(builtin pwd)"
  done
}

prompt_slimline_async_init() {
  if (( ${SLIMLINE_ENABLE_ASYNC_AUTOLOAD:-1} && ! ${+functions[async_init]} && ! ${+functions[async_start_worker]} )); then
    source "${prompt_slimline_path}/zsh-async/async.zsh"
  fi
  async_init
  async_start_worker "prompt_slimline" -u
  async_register_callback "prompt_slimline" prompt_slimline_async_callback
}

prompt_slimline_setup() {
  if (( ${SLIMLINE_PROMPT_VERSION:-1} < 2 )); then
    source "${prompt_slimline_path}/lib/legacy_options.zsh"
    prompt_slimline_evaluate_legacy_options
  fi

  local left_prompt_sections="${SLIMLINE_LEFT_PROMPT_SECTIONS-user_host_info cwd symbol}"
  local right_prompt_sections="${SLIMLINE_RIGHT_PROMPT_SECTIONS-execution_time exit_status git aws_profile virtual_env nodejs}"

  prompt_opts=(cr percent subst)
  zmodload zsh/datetime
  zmodload zsh/zle

  autoload -Uz add-zsh-hook

  _prompt_slimline_async_tasks=()
  prompt_slimline_load_sections "${left_prompt_sections}" "_prompt_slimline_left_prompt_sections" "_prompt_slimline_async_tasks"
  prompt_slimline_load_sections "${right_prompt_sections}" "_prompt_slimline_right_prompt_sections" "_prompt_slimline_async_tasks"

  add-zsh-hook chpwd prompt_slimline_chpwd
  add-zsh-hook precmd prompt_slimline_precmd

  precmd_functions=("prompt_slimline_exit_status" ${precmd_functions[@]})

  prompt_slimline_async_init

  prompt_slimline_set_prompts "setup"
  prompt_slimline_set_spelling_prompt
}

prompt_slimline_setup "$@"
