prompt_slimline_section_virtual_env() {
  if [[ -z "${VIRTUAL_ENV}" ]]; then return; fi

  local virtual_env="${VIRTUAL_ENV##*/}"
  local format="%F{white}[VENV:%F{cyan}|virtual_env|%F{white}]%f"
  echo "${${SLIMLINE_VIRTUAL_ENV_FORMAT:-${format}}/|virtual_env|/${virtual_env}}"
}
