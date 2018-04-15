slimline::section::vi_mode::init() {
  editor_info() { slimline_render_prompt "editor_info"; }
  zle-line-init() { editor_info; }
  zle-keymap-select() { editor_info; }
  vi-replace() { zle .vi-replace; editor_info; }
  zle -N zle-line-init
  zle -N zle-keymap-select
  zle -N vi-replace
}

slimline::section::vi_mode::render() {
  if [[ ! "$(bindkey)" =~ "vi-quoted-insert" ]]; then return; fi

  if [[ "${KEYMAP}" == "vicmd" ]]; then
    slimline::utils::expand "vi_mode_normal" "%F{white}[%F{blue}N%F{white}]%f"
  else
    if [[ "${ZLE_STATE}" == *overwrite* ]]; then
      slimline::utils::expand "vi_mode_replace" "%F{white}[%F{red}R%F{white}]%f"
    else
      slimline::utils::expand "vi_mode_insert" "%F{white}[%F{yellow}I%F{white}]%f"
    fi
  fi
}
