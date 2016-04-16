# Auto-completion
# ---------------
[[ $- =~ i && -f /usr/share/bash-completion/completions/fzf ]] \
  && source /usr/share/bash-completion/completions/fzf

# Key bindings
# ------------
__fzf_select__() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . \\( -path '*/\\.*' -o -fstype 'dev' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | sed 1d | cut -b3-"}"
  eval "$cmd" | fzf -m | while read item; do
    printf '%q ' "$item"
  done
  echo
}

if [[ $- =~ i ]]; then

__fzfcmd() {
  [ ${FZF_TMUX:-1} -eq 1 ] && echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

__fzf_select_tmux__() {
  local height
  height=${FZF_TMUX_HEIGHT:-40%}
  if [[ $height =~ %$ ]]; then
    height="-p ${height%\%}"
  else
    height="-l $height"
  fi

  tmux split-window $height "cd $(printf %q "$PWD"); FZF_DEFAULT_OPTS=$(printf %q "$FZF_DEFAULT_OPTS") PATH=$(printf %q "$PATH") FZF_CTRL_T_COMMAND=$(printf %q "$FZF_CTRL_T_COMMAND") bash -c 'source \"${BASH_SOURCE[0]}\"; tmux send-keys -t $TMUX_PANE \"\$(__fzf_select__)\"'"
}

__fzf_select_tmux_auto__() {
  if [ ${FZF_TMUX:-1} -ne 0 -a ${LINES:-40} -gt 15 ]; then
    __fzf_select_tmux__
  else
    tmux send-keys -t $TMUX_PANE "$(__fzf_select__)"
  fi
}

__fzf_cd__() {
  local cmd dir
  cmd="${FZF_ALT_C_COMMAND:-"command find -L . \\( -path '*/\\.*' -o -fstype 'dev' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | sed 1d | cut -b3-"}"
  dir=$(eval "$cmd" | $(__fzfcmd) +m) && printf 'cd %q' "$dir"
}

__fzf_history__() (
  local line
  shopt -u nocaseglob nocasematch
  line=$(
    HISTTIMEFORMAT= history |
    $(__fzfcmd) +s --tac +m -n2..,.. --tiebreak=index --toggle-sort=ctrl-r |
    \grep '^ *[0-9]') &&
    if [[ $- =~ H ]]; then
      sed 's/^ *\([0-9]*\)\** .*/!\1/' <<< "$line"
    else
      sed 's/^ *\([0-9]*\)\** *//' <<< "$line"
    fi
)

__use_tmux=0
__use_tmux_auto=0
if [ -n "$TMUX_PANE" ]; then
  [ ${FZF_TMUX:-1} -ne 0 -a ${LINES:-40} -gt 15 ] && __use_tmux=1
  [ $BASH_VERSINFO -gt 3 ] && __use_tmux_auto=1
fi

if [ -z "$(set -o | \grep '^vi.*on')" ]; then
  # Required to refresh the prompt after fzf
  bind '"\er": redraw-current-line'
  bind '"\e^": history-expand-line'

  # CTRL-T - Paste the selected file path into the command line
  if [ $__use_tmux_auto -eq 1 ]; then
    bind -x '"\C-t": "__fzf_select_tmux_auto__"'
  elif [ $__use_tmux -eq 1 ]; then
    bind '"\C-t": " \C-u \C-a\C-k$(__fzf_select_tmux__)\e\C-e\C-y\C-a\C-d\C-y\ey\C-h"'
  else
    bind '"\C-t": " \C-u \C-a\C-k$(__fzf_select__)\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\er \C-h"'
  fi

  # CTRL-R - Paste the selected command from history into the command line
  bind '"\C-r": " \C-e\C-u$(__fzf_history__)\e\C-e\e^\er"'

  # ALT-C - cd into the selected directory
  bind '"\ec": " \C-e\C-u$(__fzf_cd__)\e\C-e\er\C-m"'
else
  bind '"\C-x\C-e": shell-expand-line'
  bind '"\C-x\C-r": redraw-current-line'
  bind '"\C-x^": history-expand-line'

  # CTRL-T - Paste the selected file path into the command line
  # - FIXME: Selected items are attached to the end regardless of cursor position
  if [ $__use_tmux_auto -eq 1 ]; then
    bind -x '"\C-t": "__fzf_select_tmux_auto__"'
  elif [ $__use_tmux -eq 1 ]; then
    bind '"\C-t": "\e$a \eddi$(__fzf_select_tmux__)\C-x\C-e\e0P$xa"'
  else
    bind '"\C-t": "\e$a \eddi$(__fzf_select__)\C-x\C-e\e0Px$a \C-x\C-r\exa "'
  fi
  bind -m vi-command '"\C-t": "i\C-t"'

  # CTRL-R - Paste the selected command from history into the command line
  bind '"\C-r": "\eddi$(__fzf_history__)\C-x\C-e\C-x^\e$a\C-x\C-r"'
  bind -m vi-command '"\C-r": "i\C-r"'

  # ALT-C - cd into the selected directory
  bind '"\ec": "\eddi$(__fzf_cd__)\C-x\C-e\C-x\C-r\C-m"'
  bind -m vi-command '"\ec": "i\ec"'
fi

unset -v __use_tmux __use_tmux_auto

fi
