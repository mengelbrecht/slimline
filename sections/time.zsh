slimline_section_time() {
  local time_str="%D{%T}"
  local format="%F{white}|time_str|%f"
  echo "${${SLIMLINE_TIME_FORMAT:-${format}}/|time_str|/${time_str}}"
}
