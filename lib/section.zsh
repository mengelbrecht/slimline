slimline::section::get_output() {
  local sections="${1}"
  local separator="${2}"
  local var="${3}"
  shift 3

  local outputs=()
  for section in ${=sections}; do
    local output="$(${section} "$@")"
    if [[ -n ${output} ]]; then
      outputs+="${output}"
    fi
  done

  typeset -g "${var}"="${(epj:${separator}:)outputs}"
}

slimline::section::load() {
  local sections="${1}"
  local section_var="${2}"
  local async_tasks_var="${3}"

  local expanded_sections=()
  local async_tasks=()
  for section in ${=sections}; do
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
      async_tasks+="${section_async_task_function}"
    fi

    local section_preexec_function="${section_function}_preexec"
    if (( ${+functions[${section_preexec_function}]} )); then
      add-zsh-hook preexec "${section_preexec_function}"
    fi

    local section_precmd_function="${section_function}_precmd"
    if (( ${+functions[${section_precmd_function}]} )); then
      add-zsh-hook precmd "${section_precmd_function}"
    fi

    expanded_sections+="${section_function}"
  done

  typeset -g "${section_var}"="${(j: :)expanded_sections}"
  : ${(PA)=async_tasks_var::=${(P)async_tasks_var} ${async_tasks}}
}
