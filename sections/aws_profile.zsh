slimline::section::aws_profile() {
  if [[ -z "${AWS_PROFILE}" ]]; then return; fi
  local format="%F{white}[AWS:%F{blue}|profile|%F{white}]%f"
  slimline::utils::expand "${SLIMLINE_AWS_PROFILE_FORMAT:-${format}}" "profile" "${AWS_PROFILE}"
}
