slimline::section::aws_profile::render() {
  if [[ -z "${AWS_PROFILE}" ]]; then return; fi
  slimline::utils::expand "aws_profile" "%F{white}[AWS:%F{blue}|profile|%F{white}]%f" \
      "profile" "${AWS_PROFILE}"
}
