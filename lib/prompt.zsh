slimline::prompt::set_left() {
  local sections="${1}"
  local separator="${SLIMLINE_LEFT_PROMPT_SECTION_SEPARATOR:- }"
  shift 1
  slimline::section::get_output "${sections}" "${separator}" "slimline_left_prompt_sections_output" "$@"

  local format="|sections| "
  PROMPT="${${SLIMLINE_LEFT_PROMPT_FORMAT:-${format}}/|sections|/${slimline_left_prompt_sections_output}}"
  unset slimline_left_prompt_sections_output
}

slimline::prompt::set_right() {
  local sections="${1}"
  local separator="${SLIMLINE_RIGHT_PROMPT_SECTION_SEPARATOR:- }"
  shift 1
  slimline::section::get_output "${sections}" "${separator}" "slimline_right_prompt_sections_output" "$@"

  local format="|sections|"
  RPROMPT="${${SLIMLINE_RIGHT_PROMPT_FORMAT:-${format}}/|sections|/${slimline_right_prompt_sections_output}}"
  unset slimline_right_prompt_sections_output
}

slimline::prompt::set_spelling() {
  local from="%R"
  local to="%r"
  local format="zsh: correct %F{red}|from|%f to %F{green}|to|%f [nyae]? "
  local selected="${SLIMLINE_AUTOCORRECT_FORMAT:-${format}}"
  SPROMPT="${${selected/|from|/${from}}/|to|/${to}}"
}

slimline::prompt::set() {
  local sections_left="${1}"
  local sections_right="${2}"
  local event="${3}"
  slimline::prompt::set_left "${sections_left}" "${event}"
  slimline::prompt::set_right "${sections_right}" "${event}"
}
