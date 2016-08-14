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

prompt_slimline_path="$(dirname $0:A:H)"

# turns seconds into human readable time
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
prompt_slimline_human_time() {
  local tmp=$1
  local days=$(( tmp / 60 / 60 / 24 ))
  local hours=$(( tmp / 60 / 60 % 24 ))
  local minutes=$(( tmp / 60 % 60 ))
  local seconds=$(( tmp % 60 ))
  (( $days > 0 )) && echo -n "${days}d "
  (( $hours > 0 )) && echo -n "${hours}h "
  (( $minutes > 0 )) && echo -n "${minutes}m "
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

prompt_slimline_set_prompt() {
  local symbol_color=${1:-red}

  # clear prompt
  PROMPT=""

  # add ssh info
  if (( ${SLIMLINE_DISPLAY_SSH_INFO:-1} )) && [[ -n "$SSH_TTY" ]]; then
    PROMPT+="%F{red}%n%f@%F{yellow}%m%f "
  fi

  # add cwd
  PROMPT+="%F{cyan}%3~%f "

  # add prompt symbol
  PROMPT+="%F{$symbol_color}${SLIMLINE_PROMPT_SYMBOL:-∙}%f "
}

prompt_slimline_set_rprompt() {
  # clear prompt
  RPROMPT=""

  # add elapsed time if threshold is exceeded
  if (( ${SLIMLINE_DISPLAY_EXEC_TIME:-1} )) && [[ -n "${_prompt_slimline_cmd_exec_time}" ]]; then
    RPROMPT+="%F{yellow}${_prompt_slimline_cmd_exec_time}%f"
  fi

  # add exit status
  if (( ${SLIMLINE_DISPLAY_EXIT_STATUS:-1} )); then
    RPROMPT+="%(?::${RPROMPT:+ }%F{red}%? ${SLIMLINE_EXIT_STATUS_SYMBOL:-↵}%f)"
  fi

  # add git radar output
  if [[ -n "${_prompt_slimline_git_radar_output:-}" ]]; then
    RPROMPT+="${RPROMPT:+ }${_prompt_slimline_git_radar_output}"
  fi
}

prompt_slimline_set_sprompt() {
  SPROMPT="zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? "
}

prompt_slimline_precmd() {
  prompt_slimline_check_cmd_exec_time

  unset _prompt_slimline_cmd_timestamp
  unset _prompt_slimline_git_radar_output

  prompt_slimline_set_prompt
  prompt_slimline_set_rprompt

  prompt_slimline_async_tasks
}

prompt_slimline_preexec() {
  _prompt_slimline_cmd_timestamp=$EPOCHSECONDS
}

prompt_slimline_async_git_radar() {
  local _prompt_slimline_git_radar_output=""
  if (( ${SLIMLINE_ENABLE_GIT_RADAR:-1} )); then
    local parameters="--zsh"
    (( ${SLIMLINE_PERFORM_GIT_FETCH:-1} )) && parameters+=" --fetch"
    _prompt_slimline_git_radar_output="$(${_prompt_slimline_git_radar_executable} ${=parameters})"
  fi
  typeset -p _prompt_slimline_git_radar_output >! "$_prompt_slimline_async_data"

  kill -WINCH $$ # Signal completion to parent process.
}

prompt_slimline_async_callback() {
  if (( _prompt_slimline_async_pid == 0 )); then
    return
  fi

  if [[ -s "$_prompt_slimline_async_data" ]]; then
    alias typeset='typeset -g'
    source "$_prompt_slimline_async_data"
    unalias typeset
  fi
  _prompt_slimline_async_pid=0
  prompt_slimline_set_prompt white
  prompt_slimline_set_rprompt
  zle && zle .reset-prompt
}

prompt_slimline_async_tasks() {
  # Kill the old process of slow commands if it is still running.
  if (( __prompt_slimline_async_pid > 0 )); then
    kill -KILL "$_prompt_slimline_async_pid" &>/dev/null
  fi

  trap prompt_slimline_async_callback WINCH
  prompt_slimline_async_git_radar &!
  _prompt_slimline_async_pid=$!
}

prompt_slimline_async_init() {
  _prompt_slimline_async_pid=0
  _prompt_slimline_async_data="${TMPPREFIX}-prompt_slimline_data"
}

prompt_slimline_setup() {
  prompt_opts=(cr percent subst)

  zmodload zsh/datetime
  zmodload zsh/zle

  autoload -Uz add-zsh-hook

  add-zsh-hook precmd prompt_slimline_precmd
  add-zsh-hook preexec prompt_slimline_preexec

  _prompt_slimline_git_radar_executable="$prompt_slimline_path/git-radar/git-radar"

  if [[ -z "$GIT_RADAR_FORMAT" ]]; then
    export GIT_RADAR_FORMAT="%{remote: }%{branch}%{ :local}%{ :changes}%{ :stash}"
  fi

  prompt_slimline_async_init

  prompt_slimline_set_prompt
  prompt_slimline_set_rprompt
  prompt_slimline_set_sprompt
}

prompt_slimline_setup "$@"
