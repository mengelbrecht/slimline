prompt_slimline_section_user_host_info() {
  if (( ! ${SLIMLINE_ALWAYS_SHOW_USER_HOST_INFO:-0} )) && [[ -z "${SSH_TTY}" && "${USER}" == "${prompt_slimline_default_user}" ]]; then return; fi

  local user="%n"
  local host="%m"
  local format_root="%F{red}|user|%F{white}@%F{yellow}|host|%f"
  local format="%F{green}|user|%F{white}@%F{yellow}|host|%f"
  local selected=''
  if [[ ${UID} -eq 0 ]]; then
    selected="${SLIMLINE_USER_HOST_INFO_ROOT_FORMAT:-${format_root}}"
  else
    selected="${SLIMLINE_USER_HOST_INFO_FORMAT:-${format}}"
  fi
  echo "${${selected/|user|/${user}}/|host|/${host}}"
}
