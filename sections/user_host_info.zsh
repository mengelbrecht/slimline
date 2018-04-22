slimline::section::user_host_info::init() {
  slimline_section_user_host_info_default_user="${SLIMLINE_USER_HOST_INFO_DEFAULT_USER:-${USER}}"
}

slimline::section::user_host_info::render() {
  if (( ! ${SLIMLINE_ALWAYS_SHOW_USER_HOST_INFO:-0} )) && \
      [[ -z "${SSH_TTY}" && "${USER}" == "${slimline_section_user_host_info_default_user}" ]]; then
    return;
  fi

  local -A variables=("user" "%n" "host" "%m")
  if [[ ${UID} -eq 0 ]]; then
    slimline::utils::expand "user_host_info_root" "%F{red}|user|%F{white}@%F{yellow}|host|%f" ${(kv)variables}
  else
    slimline::utils::expand "user_host_info" "%F{green}|user|%F{white}@%F{yellow}|host|%f" ${(kv)variables}
  fi
}
