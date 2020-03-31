autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
	'%F{5}%b%F{3}|%F{1}%a%f '
zstyle ':vcs_info:*' formats       \
	'%F{5}%b%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}

PROMPT=' %F{10}%1~%f '
RPROMPT=$'$(vcs_info_wrapper)'
