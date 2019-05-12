#!/usr/bin/env bash

get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z $option_value ]; then
    echo $default_value
  else
    echo $option_value
  fi
}

find_executable() {
  local cmd=$1
  if type $1 >/dev/null 2>&1; then
    echo "$1"
  fi
}

readonly key="$(get_tmux_option "@cg-key" "Enter")"
readonly cmd="$(get_tmux_option "@cg-cmd" "cg-fzf")"
readonly exe="$(find_executable "$cmd")"

if [ -z "$exe" ]; then
  tmux display-message "Failed to load tmux-cg: $cmd was not found on the PATH"
else
  tmux bind-key "$key" capture-pane -J \\\; \
    save-buffer "${TMPDIR:-/tmp}/tmux-buffer" \\\; \
    delete-buffer \\\; \
    send-keys -t . " sh -c 'cat \"${TMPDIR:-/tmp}/tmux-buffer\" | $exe'" Enter
fi
