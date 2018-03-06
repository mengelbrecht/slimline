slimline::section::time() {
  local format="%F{white}|time|%f"
  slimline::utils::expand "${SLIMLINE_TIME_FORMAT:-${format}}" "time" "%D{%T}"
}
