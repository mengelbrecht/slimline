# turns seconds into human readable time
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
# Copyright (c) Sindre Sorhus <sindresorhus@gmail.com> (sindresorhus.com)
# MIT License
# See https://github.com/sindresorhus/pretty-time-zsh/blob/1176d39364c584134e1532309c43fae44c6f4069/license
slimline::utils::pretty_time() {
  local human total_seconds=$1
  local days=$(( total_seconds / 60 / 60 / 24 ))
  local hours=$(( total_seconds / 60 / 60 % 24 ))
  local minutes=$(( total_seconds / 60 % 60 ))
  local seconds=$(( total_seconds % 60 ))

  (( days > 0 )) && human+="${days}d "
  (( hours > 0 )) && human+="${hours}h "
  (( minutes > 0 )) && human+="${minutes}m "
  human+="${seconds}s"

  echo "$human"
}

slimline::utils::callable() {
  (( $+commands[$1] || $+functions[$1] ))
}

slimline::utils::expand() {
  local format_name="SLIMLINE_${1:u}_FORMAT"
  local default_format="${2}"
  local template="${(P)format_name:-${default_format}}"
  for (( i=3; i < $# ; i+=2 )) ; do
    template="${template/|${@[i]}|/${@[i + 1]}}"
  done
  echo "${template}"
}

slimline::utils::error() {
  print -P "%F{red}slimline%f: ${1}"
}

slimline::utils::warning() {
  print -P "%F{yellow}slimline%f: ${1}"
}

slimline::utils::info() {
  print -P "%F{blue}slimline%f: ${1}"
}
