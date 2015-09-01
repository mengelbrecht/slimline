#-------------------------------------------------------------------------------
# Slimlime
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
  (( elapsed > ${SLIMLINE_MAX_EXEC_TIME:-5} )) && \
    _prompt_slimline_cmd_exec_time="$(prompt_slimline_human_time $elapsed)"
}

prompt_slimline_reformat_git_radar() {
  ([[ "$1" =~ " git:\(([^)]+)\)(.*)" ]] && echo "$match[1]$match[2]") || echo "$1"
}

prompt_slimline_set_prompt() {
  local symbol_color=${1:-red}

  # clear prompt
  PROMPT=""

  # add ssh info
  (( ${SLIMLINE_DISPLAY_SSH_INFO:-1} )) && [[ "$SSH_TTY" != "" ]] && \
    PROMPT+="%F{red}%n%f@%F{yellow}%m%f "

  # add cwd
  PROMPT+="%F{cyan}%3~%f "

  # add prompt symbol
  PROMPT+="%F{$symbol_color}${SLIMLINE_PROMPT_SYMBOL:-∙}%f "
}

prompt_slimline_set_rprompt() {
  # clear prompt
  RPROMPT=""

  # add elapsed time if treshold is exceeded
  (( ${SLIMLINE_DISPLAY_EXEC_TIME:-1} )) && [[ "${_prompt_slimline_cmd_exec_time}" != "" ]] && \
    RPROMPT+="%F{yellow}${_prompt_slimline_cmd_exec_time}%f"

  # add exit status
  (( ${SLIMLINE_DISPLAY_EXIT_STATUS:-1} )) && \
    RPROMPT+="%(?::${RPROMPT:+ }%F{red}%? ↵%f)"

  # add git radar output
  RPROMPT+="${RPROMPT:+ }${_prompt_slimline_git_radar_output:-}"
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
  (( $+commands[git-radar] )) && {
    local parameters="--zsh"
    (( ${SLIMLINE_PERFORM_GIT_FETCH:-1} )) && parameters+=" --fetch"
    local output="$(git-radar ${=parameters})"
    local _prompt_slimline_git_radar_output="$(prompt_slimline_reformat_git_radar $output)"
    typeset -p _prompt_slimline_git_radar_output >! "$_prompt_slimline_async_data"
  }

  kill -WINCH $$ # Signal completion to parent process.
}

prompt_slimline_async_tasks() {
  # Kill the old process of slow commands if it is still running.
  (( __prompt_slimline_async_pid > 0 )) && kill -KILL "$_prompt_slimline_async_pid" &>/dev/null

  trap prompt_slimline_async_callback WINCH
  prompt_slimline_async_git_radar &!
  _prompt_slimline_async_pid=$!
}

prompt_slimline_async_callback() {
  (( _prompt_slimline_async_pid > 0 )) && {
    [[ -s "$_prompt_slimline_async_data" ]] && {
      alias typeset='typeset -g'
      source "$_prompt_slimline_async_data"
      unalias typeset
    }
    _prompt_slimline_async_pid=0
    prompt_slimline_set_prompt white
    prompt_slimline_set_rprompt
    zle && zle reset-prompt
  }
}

prompt_slimeline_async_init() {
  _prompt_slimline_async_pid=0
  _prompt_slimline_async_data="${TMPPREFIX}-prompt_slimline_data"
}

prompt_slimline_setup() {
  prompt_opts=(cr percent subst)

  autoload -Uz add-zsh-hook

  add-zsh-hook precmd prompt_slimline_precmd
  add-zsh-hook preexec prompt_slimline_preexec

  prompt_slimeline_async_init

  prompt_slimline_set_prompt
  prompt_slimline_set_rprompt
  prompt_slimline_set_sprompt
}

prompt_slimline_setup "$@"
