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
  if type fcx >/dev/null 2>&1; then
    echo "fcx"
  fi
}

readonly key="$(get_tmux_option "@fcx-key" "m")"
readonly cmd="$(find_executable)"

if [ -z "$cmd" ]; then
  tmux display-message "Failed to load tmux-fcx: fcx was not found on the PATH"
else
  tmux bind-key "$key" capture-pane -J \\\; \
    save-buffer "${TMPDIR:-/tmp}/tmux-buffer" \\\; \
    delete-buffer \\\; \
    send-keys -t . " sh -c 'cat \"${TMPDIR:-/tmp}/tmux-buffer\" | fcx'" Enter
fi
