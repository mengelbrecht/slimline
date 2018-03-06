slimline::section::aws_profile() {
  if [[ -z "${AWS_PROFILE}" ]]; then return; fi
  local profile="${AWS_PROFILE}"
  local format="%F{white}[AWS:%F{blue}|profile|%F{white}]%f"
  echo "${${SLIMLINE_AWS_PROFILE_FORMAT:-${format}}/|profile|/${profile}}"
}
