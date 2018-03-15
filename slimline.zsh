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

slimline_path="${0:A:h}"

source "${slimline_path}/lib/async.zsh"
source "${slimline_path}/lib/prompt.zsh"
source "${slimline_path}/lib/sections.zsh"
source "${slimline_path}/lib/utils.zsh"

slimline_precmd_async_tasks() {
  slimline::async::start_tasks "precmd"
}

slimline_precmd_exit_status() {
  slimline_last_exit_status=$?
}

slimline_async_task_complete() {
  local event="${1}"
  slimline::prompt::set "${slimline_left_prompt_sections}" "${slimline_right_prompt_sections}" "${event}"
  zle && zle .reset-prompt
}

slimline_setup() {
  if (( ${SLIMLINE_PROMPT_VERSION:-2} < 2 )); then
    source "${slimline_path}/lib/legacy.zsh"
    slimline::legacy::evaluate_options
  fi

  local left_prompt_sections="${SLIMLINE_LEFT_PROMPT_SECTIONS-user_host_info cwd symbol}"
  local right_prompt_sections="${SLIMLINE_RIGHT_PROMPT_SECTIONS-execution_time exit_status git aws_profile virtualenv nodejs}"

  prompt_opts=(cr percent subst)
  zmodload zsh/datetime
  zmodload zsh/zle

  autoload -Uz add-zsh-hook

  slimline::sections::load "${left_prompt_sections}" "slimline_left_prompt_sections" "slimline_left_prompt_async_tasks"
  slimline::sections::load "${right_prompt_sections}" "slimline_right_prompt_sections" "slimline_right_prompt_async_tasks"

  add-zsh-hook precmd slimline_precmd_async_tasks

  precmd_functions=("slimline_precmd_exit_status" ${precmd_functions[@]})

  slimline::async::init "${slimline_left_prompt_async_tasks} ${slimline_right_prompt_async_tasks}" "slimline_async_task_complete"
  unset slimline_left_prompt_async_tasks
  unset slimline_right_prompt_async_tasks

  slimline::prompt::set "${slimline_left_prompt_sections}" "${slimline_right_prompt_sections}" "setup"
  slimline::prompt::set_spelling
}

slimline_setup "$@"
