slimline::async::init() {
  if (( ${SLIMLINE_ENABLE_ASYNC_AUTOLOAD:-1} && ! ${+functions[async_init]} && ! ${+functions[async_start_worker]} )); then
    source "${slimline_path}/zsh-async/async.zsh"
  fi

  slimline_async_tasks="${1}"
  slimline_async_callback_complete="${2}"
  slimline_async_worker_name="prompt_slimline"

  async_init
  async_start_worker "${slimline_async_worker_name}" -u
  async_register_callback "${slimline_async_worker_name}" slimline::async::callback
}

slimline::async::callback() {
  local job=${1}
  local has_next=${6}

  local complete_function="${job}_complete"
  ${complete_function} "$@"

  slimline_async_tasks_complete=$(( slimline_async_tasks_complete + 1 ))

  if (( ! has_next )); then
    if (( slimline_async_tasks_complete == ${#${=slimline_async_tasks}} )); then
      ${slimline_async_callback_complete} "all_tasks_complete"
    else
      ${slimline_async_callback_complete} "task_complete"
    fi
  fi
}

slimline::async::start_tasks() {
  if (( ! ${#${=slimline_async_tasks}} )); then
    ${slimline_async_callback_complete} "all_tasks_complete"
    return
  fi

  local event="${1}"
  if [[ "${event}" == "precmd" ]]; then
    if (( EPOCHREALTIME - ${slimline_async_last_call:-0} <= 0.5 )); then return; fi
    ${slimline_async_callback_complete} "precmd"
  fi

  async_flush_jobs "${slimline_async_worker_name}"
  slimline_async_last_call=${EPOCHREALTIME}
  slimline_async_tasks_complete=0
  for task in ${=slimline_async_tasks}; do
    async_job "${slimline_async_worker_name}" "${task}" "$(builtin pwd)"
  done
}
