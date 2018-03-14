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

    local section_namespace="slimline::section::${section}"
    local render_function="${section_namespace}::render"
    if ! slimline::utils::callable "${render_function}"; then
      slimline::utils::error "'${section}' is not a valid section!"
      continue
    fi

    local init_function="${section_namespace}::init"
    if slimline::utils::callable "${init_function}"; then
      if ! ${init_function}; then continue; fi
    fi

    local async_task_function="${section_namespace}::async_task"
    if slimline::utils::callable "${async_task_function}"; then
      local async_task_complete_function="${async_task_function}_complete"
      if ! slimline::utils::callable "${async_task_complete_function}"; then
        slimline::utils::error "The async task of section '${section}' has no complete function!"
        continue
      fi
      async_tasks+="${async_task_function}"
    fi

    local preexec_function="${section_namespace}::preexec"
    if slimline::utils::callable "${preexec_function}"; then
      add-zsh-hook preexec "${preexec_function}"
    fi

    local precmd_function="${section_namespace}::precmd"
    if slimline::utils::callable "${precmd_function}"; then
      add-zsh-hook precmd "${precmd_function}"
    fi

    expanded_sections+="${render_function}"
  done

  typeset -g "${section_var}"="${(j: :)expanded_sections}"
  typeset -g "${async_tasks_var}"="${(j: :)async_tasks}"
}
