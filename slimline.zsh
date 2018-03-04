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

prompt_slimline_get_sections() {
  local var=${1}
  local sections=${2}
  local separator=${3}
  shift 3

  local outputs=()
  for section in ${=sections}; do
    local output="$(${section} "$@")"
    if [[ -n ${output} ]]; then
      outputs+=("${output}")
    fi
  done

  typeset -g "${var}"="${(epj:${separator}:)outputs}"
}

prompt_slimline_set_left_prompt() {
  local separator="${SLIMLINE_LEFT_PROMPT_SECTION_SEPARATOR:- }"
  prompt_slimline_get_sections "_prompt_slimline_left_prompt_sections_output" "${_prompt_slimline_left_prompt_sections}" "${separator}" "$@"

  local format="|sections| "
  PROMPT="${${SLIMLINE_LEFT_PROMPT_FORMAT:-${format}}/|sections|/${_prompt_slimline_left_prompt_sections_output}}"
  unset _prompt_slimline_left_prompt_sections_output
}

prompt_slimline_set_right_prompt() {
  local separator="${SLIMLINE_RIGHT_PROMPT_SECTION_SEPARATOR:- }"
  prompt_slimline_get_sections "_prompt_slimline_right_prompt_sections_output" "${_prompt_slimline_right_prompt_sections}" "${separator}" "$@"

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

prompt_slimline_load_sections() {
  local var=${1}
  local expanded_sections=()
  for section in ${=${(P)var}}; do
    local section_file="${prompt_slimline_path}/sections/${section}.zsh"
    if [[ -f "${section_file}" ]]; then
      source "${section_file}"
    fi

    local section_function="prompt_slimline_section_${section}"
    if (( ! ${+functions[${section_function}]} )); then
      print -P "%F{red}slimline%f: '${section}' is not a valid section!"
      continue
    fi

    local section_init_function="${section_function}_init"
    if (( ${+functions[${section_init_function}]} )); then
      if ! ${section_init_function}; then continue; fi
    fi

    local section_async_task_function="${section_function}_async_task"
    if (( ${+functions[${section_async_task_function}]} )); then
      local section_async_task_complete_function="${section_async_task_function}_complete"
      if (( ! ${+functions[${section_async_task_complete_function}]} )); then
        print -P "%F{red}slimline%f: The async task of section '${section}' has no complete function!"
        continue
      fi
      _prompt_slimline_async_tasks+=("${section_async_task_function}")
    fi

    local section_preexec_function="${section_function}_preexec"
    if (( ${+functions[${section_preexec_function}]} )); then
      add-zsh-hook preexec "${section_preexec_function}"
    fi

    local section_precmd_function="${section_function}_precmd"
    if (( ${+functions[${section_precmd_function}]} )); then
      add-zsh-hook precmd "${section_precmd_function}"
    fi

    expanded_sections+=("${section_function}")
  done

  typeset -g "${var}"="${(j: :)expanded_sections}"
}

prompt_slimline_setup() {
  if (( ${SLIMLINE_PROMPT_VERSION:-1} < 2 )); then
    source "${prompt_slimline_path}/lib/legacy_options.zsh"
    prompt_slimline_evaluate_legacy_options
  fi

  _prompt_slimline_left_prompt_sections="${SLIMLINE_LEFT_PROMPT_SECTIONS-user_host_info cwd symbol}"
  _prompt_slimline_right_prompt_sections="${SLIMLINE_RIGHT_PROMPT_SECTIONS-execution_time exit_status git aws_profile virtual_env nodejs}"

  prompt_opts=(cr percent subst)
  zmodload zsh/datetime
  zmodload zsh/zle

  autoload -Uz add-zsh-hook

  _prompt_slimline_async_tasks=()
  prompt_slimline_load_sections "_prompt_slimline_left_prompt_sections"
  prompt_slimline_load_sections "_prompt_slimline_right_prompt_sections"

  add-zsh-hook chpwd prompt_slimline_chpwd
  add-zsh-hook precmd prompt_slimline_precmd

  precmd_functions=("prompt_slimline_exit_status" ${precmd_functions[@]})

  prompt_slimline_async_init

  prompt_slimline_set_prompts "setup"
  prompt_slimline_set_spelling_prompt
}

prompt_slimline_setup "$@"
