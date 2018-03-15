slimline::section::virtualenv::render() {
  if [[ -z "${VIRTUAL_ENV}" ]]; then return; fi
  slimline::utils::expand "virtualenv" "%F{white}[VENV:%F{cyan}|basename|%F{white}]%f" \
      "basename" "${VIRTUAL_ENV##*/}"
}
