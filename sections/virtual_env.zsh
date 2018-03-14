slimline::section::virtual_env::render() {
  if [[ -z "${VIRTUAL_ENV}" ]]; then return; fi
  slimline::utils::expand "virtual_env" "%F{white}[VENV:%F{cyan}|basename|%F{white}]%f" \
      "basename" "${VIRTUAL_ENV##*/}"
}
