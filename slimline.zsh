#-------------------------------------------------------------------------------
# Slimlime
# Minimal and fast ZSH prompt
# by Markus Engelbrecht
# https://github.com/mgee/slimline
#
# Credits
# * pure (https://github.com/sindresorhus/pure)
# * sorin theme (https://github.com/sorin-ionescu/prezto)
#
# MIT License
#-------------------------------------------------------------------------------

set_prompt() {
  local symbol_color=${1:-red}

  # clear prompt
  PROMPT=""

  # add ssh info
  if [[ "${SLIMLINE_DISPLAY_SSH_INFO:-YES}" == "YES" ]]; then
    if [[ "$SSH_TTY" != '' ]]; then
      PROMPT+="%F{red}%n%f@%F{yellow}%m%f "
    fi
  fi

  # add cwd
  PROMPT+="%F{cyan}%3~%f "

  # add prompt symbol
  PROMPT+="%F{$symbol_color}${SLIMLINE_PROMPT_SYMBOL:-∙}%f "
}

set_rprompt() {
  # clear prompt
  RPROMPT=""

  # add exit status
  if [[ "${SLIMLINE_DISPLAY_EXIT_STATUS:-YES}" == "YES" ]]; then
     RPROMPT+="%(?::%F{red}%? ↵%f )"
  fi

  # add git radar output
  RPROMPT+="${git_radar_output:-}"
}

set_sprompt() {
  SPROMPT="zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? "
}

prompt_slimline_precmd() {
  unset git_radar_output

  set_prompt
  set_rprompt

  prompt_slimline_async_tasks
}

prompt_slimline_async_git_radar() {
  if (( $+commands[git-radar] )); then
    cd $1
    echo "$(git-radar --zsh --fetch)"
  fi
}

prompt_slimline_async_tasks() {
  ((!${prompt_slimline_async_init:-0})) && {
    async_start_worker "prompt_slimline" -u -n
    async_register_callback "prompt_slimline" prompt_slimline_async_callback
    prompt_slimline_async_init=1
  }

  async_job "prompt_slimline" prompt_slimline_async_git_radar $PWD
}

prompt_slimline_async_callback() {
  local job=$1
  local output=$3

  case "${job}" in
    prompt_slimline_async_git_radar)
      git_radar_output="$output"
      set_prompt white
      set_rprompt
      zle && zle reset-prompt
      ;;
  esac
}

prompt_slimline_setup() {
  prompt_opts=(cr percent subst)

  autoload -Uz add-zsh-hook
  autoload -Uz async && async

  add-zsh-hook precmd prompt_slimline_precmd

  set_prompt
  set_rprompt
  set_sprompt
}

prompt_slimline_setup "$@"
