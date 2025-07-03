#!/bin/bash

# Script to change current git credentials

# credentials are stored in external file in script directory
# content:
#
#   declare -A profiles
#   profiles[0]="alias;username;user@example.com"
#   profiles[1]="alias;username;user@example.com"
#   ...
#
source .git_profiles.sh

# Usage display
usage() {
  echo "Usage: $0 [-c] [-p] [-s <profile_key>]"
  echo "       -c show current credentials"
  echo "       -p show stored profiles"
  echo "       -s set credentials (requires profile key)"
  exit 1
}

show_credentials() {
  echo "*** Current GIT credentials ***"
  local g_user
  g_user=$(git config --get user.name)
  local g_email
  g_email=$(git config --get user.email)
  echo "Username: ${g_user}"
  echo "E-mail:   ${g_email}"
  exit 0
}

show_profiles() {
  local g_alias
  local g_user
  local g_email
  echo "*** GIT credential porfiles ***"
  echo "[#] | alias | username | email"
  for key in $(printf "%s\n" "${!profiles[@]}" | sort); do
    IFS=";" read -r g_alias g_user g_email <<< "${profiles[$key]}"
    echo "[$key] | ${g_alias} | ${g_user} | ${g_email}"
  done
  exit 0
}

set_profile() {
  if [[ ! -v profiles[$1] ]]; then
    echo "Invalid profile! Use '-p' to list profiles."
    exit 1
  fi
  local g_alias
  local g_user
  local g_email
  IFS=";" read -r g_alias g_user g_email <<< "${profiles[$1]}"
  git config --global user.name "$g_user"
  git config --global user.email "$g_email"
  echo "*** GIT profile '$g_alias' was set ***"
  exit 0
}

while getopts ":s:cp" opt; do
  case ${opt} in
    c )
      show_credentials
      ;;
    p )
      show_profiles
      ;;
    s )
      set_profile "$OPTARG"
      ;;
    \? )
      echo "Invaild option: -$OPTARG" 1>&2
      usage
      ;;
    : )
      echo "Invalid option: -$OPTARG requires an argument" 1>&2
      usage
      ;;
  esac
done
