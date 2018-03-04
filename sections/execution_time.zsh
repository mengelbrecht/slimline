# turns seconds into human readable time
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
prompt_slimline_human_time() {
  local tmp=$1
  local days=$(( tmp / 60 / 60 / 24 ))
  local hours=$(( tmp / 60 / 60 % 24 ))
  local minutes=$(( tmp / 60 % 60 ))
  local seconds=$(( tmp % 60 ))
  (( days > 0 )) && echo -n "${days}d "
  (( hours > 0 )) && echo -n "${hours}h "
  (( minutes > 0 )) && echo -n "${minutes}m "
  echo "${seconds}s"
}

prompt_slimline_section_execution_time_preexec() {
  _prompt_slimline_cmd_timestamp=$EPOCHSECONDS
}

prompt_slimline_section_execution_time_precmd() {
  local integer elapsed
  (( elapsed = EPOCHSECONDS - ${_prompt_slimline_cmd_timestamp:-$EPOCHSECONDS} ))
  _prompt_slimline_cmd_exec_time=
  if (( elapsed > ${SLIMLINE_MAX_EXEC_TIME:-5} )); then
    _prompt_slimline_cmd_exec_time="$(prompt_slimline_human_time $elapsed)"
  fi

  unset _prompt_slimline_cmd_timestamp
}

prompt_slimline_section_execution_time() {
  # add elapsed time if threshold is exceeded
  if [[ -z "${_prompt_slimline_cmd_exec_time}" ]]; then return; fi
  local exec_time="${_prompt_slimline_cmd_exec_time}"
  local format="%F{yellow}|exec_time|%f"
  echo "${${SLIMLINE_EXECUTION_TIME_FORMAT:-${format}}/|exec_time|/${exec_time}}"
}
