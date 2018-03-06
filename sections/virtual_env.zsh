slimline::section::virtual_env() {
  if [[ -z "${VIRTUAL_ENV}" ]]; then return; fi
  local format="%F{white}[VENV:%F{cyan}|basename|%F{white}]%f"
  slimline::utils::expand "${SLIMLINE_VIRTUAL_ENV_FORMAT:-${format}}" "basename" "${VIRTUAL_ENV##*/}"
}
