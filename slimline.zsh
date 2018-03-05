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

source "${prompt_slimline_path}/lib/async.zsh"
source "${prompt_slimline_path}/lib/prompt.zsh"
source "${prompt_slimline_path}/lib/section.zsh"

prompt_slimline_precmd() {
  slimline::async::start_tasks "precmd"
}

prompt_slimline_exit_status() {
  prompt_slimline_last_exit_status=$?
}

prompt_slimline_async_task_complete() {
  local event="${1}"
  slimline::prompt::set "${event}" "${slimline_left_prompt_sections}" "${slimline_right_prompt_sections}"
  zle && zle .reset-prompt
}

prompt_slimline_setup() {
  if (( ${SLIMLINE_PROMPT_VERSION:-1} < 2 )); then
    source "${prompt_slimline_path}/lib/legacy.zsh"
    slimline::legacy::evaluate_options
  fi

  local left_prompt_sections="${SLIMLINE_LEFT_PROMPT_SECTIONS-user_host_info cwd symbol}"
  local right_prompt_sections="${SLIMLINE_RIGHT_PROMPT_SECTIONS-execution_time exit_status git aws_profile virtual_env nodejs}"

  prompt_opts=(cr percent subst)
  zmodload zsh/datetime
  zmodload zsh/zle

  autoload -Uz add-zsh-hook

  slimline::section::load "${left_prompt_sections}" "slimline_left_prompt_sections" "slimline_left_prompt_async_tasks"
  slimline::section::load "${right_prompt_sections}" "slimline_right_prompt_sections" "slimline_right_prompt_async_tasks"

  add-zsh-hook precmd prompt_slimline_precmd

  precmd_functions=("prompt_slimline_exit_status" ${precmd_functions[@]})

  slimline::async::init "${slimline_left_prompt_async_tasks} ${slimline_right_prompt_async_tasks}" "prompt_slimline_async_task_complete"

  slimline::prompt::set "setup" "${slimline_left_prompt_sections}" "${slimline_right_prompt_sections}"
  slimline::prompt::set_spelling
}

prompt_slimline_setup "$@"
