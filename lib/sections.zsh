slimline::sections::get_output() {
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

slimline::sections::load() {
  local sections="${1}"
  local section_var="${2}"
  local async_tasks_var="${3}"

  local expanded_sections=()
  local async_tasks=()
  for section in ${=sections}; do
    local section_file="${slimline_path}/sections/${section}.zsh"
    if [[ -f "${section_file}" ]]; then
      source "${section_file}"
    fi

    local section_function="slimline::section::${section}"
    if ! slimline::utils::callable "${section_function}"; then
      slimline::utils::error "'${section}' is not a valid section!"
      continue
    fi

    local section_init_function="${section_function}::init"
    if slimline::utils::callable "${section_init_function}"; then
      if ! ${section_init_function}; then continue; fi
    fi

    local section_async_task_function="${section_function}::async_task"
    if slimline::utils::callable "${section_async_task_function}"; then
      local section_async_task_complete_function="${section_async_task_function}_complete"
      if ! slimline::utils::callable "${section_async_task_complete_function}"; then
        slimline::utils::error "The async task of section '${section}' has no complete function!"
        continue
      fi
      async_tasks+="${section_async_task_function}"
    fi

    local section_preexec_function="${section_function}::preexec"
    if slimline::utils::callable "${section_preexec_function}"; then
      add-zsh-hook preexec "${section_preexec_function}"
    fi

    local section_precmd_function="${section_function}::precmd"
    if slimline::utils::callable "${section_precmd_function}"; then
      add-zsh-hook precmd "${section_precmd_function}"
    fi

    expanded_sections+="${section_function}"
  done

  typeset -g "${section_var}"="${(j: :)expanded_sections}"
  typeset -g "${async_tasks_var}"="${(j: :)async_tasks}"
}
