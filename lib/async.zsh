slimline::async::init() {
  if (( ${SLIMLINE_ENABLE_ASYNC_AUTOLOAD:-1} )) && ! slimline::utils::callable "async_init" && ! slimline::utils::callable "async_start_worker"; then
    source "${slimline_path}/zsh-async/async.zsh"
  fi

  slimline_async_tasks="${1}"
  slimline_render_prompt_callback="${2}"
  slimline_async_worker_name="prompt_slimline"

  async_init
  slimline::async::register_worker
}

slimline::async::register_worker() {
  async_start_worker "${slimline_async_worker_name}" -u
  async_register_callback "${slimline_async_worker_name}" slimline::async::callback
}

slimline::async::callback() {
  local job=${1}
  local return_code=${2}
  local stdout="${3}"
  local execution_time=${4}
  local stderr="${5}"
  local has_next=${6}

  if [[ "${job}" == "[async]" ]]; then
    if [[ $return_code -eq 2 ]]; then
      slimline::async::register_worker
      ${slimline_render_prompt_callback} "all_tasks_complete"
      return
    fi
  else
    local complete_function="${job}_complete"
    ${complete_function} ${return_code} "${stdout}" "${stderr}" ${execution_time}
  fi

  slimline_async_tasks_complete=$(( slimline_async_tasks_complete + 1 ))

  if (( ! has_next )); then
    ${slimline_render_prompt_callback} "task_complete"
  fi
}

slimline::async::start_tasks() {
  if (( ! ${#${=slimline_async_tasks}} )); then
    ${slimline_render_prompt_callback} "all_tasks_complete"
    return
  fi

  local event="${1}"
  if [[ "${event}" == "precmd" ]]; then
    if (( EPOCHREALTIME - ${slimline_async_last_call:-0} <= 0.5 )); then return; fi
    ${slimline_render_prompt_callback} "precmd"
  fi

  async_flush_jobs "${slimline_async_worker_name}"
  slimline_async_last_call=${EPOCHREALTIME}
  slimline_async_tasks_complete=0
  for task in ${=slimline_async_tasks}; do
    async_job "${slimline_async_worker_name}" "${task}" "$(builtin pwd)"
  done
}

slimline::async::all_tasks_complete() {
  (( slimline_async_tasks_complete == ${#${=slimline_async_tasks}} ))
}
