#!/bin/bash

# alias neovim, so it can be used in .bash_aliases straight away
# and won't mess aliases help
alias nv='/home/marpauli/data/soft/nvim-linux-x86_64/bin/nvim'

#functions
e_err() {
  # print red bold test
  echo -e "\e[1;31m$1\e[0m"
}

e_info() {
  # print blue bold text
  echo -e "\e[1;34m$1\e[0m"
}

e_succ() {
  # print green bold text
  echo -e "\e[1;32m$1\e[0m"
}

e_warn() {
  # print orange bold text
  echo -e "\e[1;38;5;208m$1\e[0m"
}

# empty function to create fake aliases fro description
function fake_alias() {
  :
}

# FILL LINE FUNCTIONS
fill_line_with_string() {
  local string="$1"
  local length="$2"
  local fill="${3:- }"
  if [[ ${#fill} -eq 1 ]]; then
    beg_char=$fill
    end_char=$fill
  fi
  if [[ ${#fill} -eq 2 ]]; then
    beg_char="${fill:0:1}"
    end_char="${fill:1:1}"
  fi
  if [[ ${#fill} -gt 2 ]]; then
    beg_char="${fill:0:1}"
    end_char="${fill:0:1}"
  fi
  local padding=$(((length - ${#string} - 2) / 2))
  local beg
  beg=$(printf "%${padding}s" | tr ' ' "$beg_char")
  local end
  end=$(printf "%${padding}s" | tr ' ' "$end_char")
  printf "%s%s%s" "$beg" " $string " "$end"
  echo ""
}

fill_line() {
  local length="$1"
  local fill="$2"
  printf "%*s\n" "$length" "" | tr ' ' "$fill"
}

# ALIAS DESCRIPTIONS
line_length=59

get_alias_descriptions() {
  # Sections must start with '### '. (With space!)
  # Alias descriptions must one line above alias declaration.
  # All comments above alias description are ignored.
  local file_path="$1"
  if [ -f "$file_path" ]; then
    echo ""
    echo "@ $file_path"
    local description=""
    while IFS= read -r line; do
      if [[ "$line" =~ ^### ]]; then
        fill_line_with_string "${line#'### '}" "$line_length" "-"
      elif [[ "$line" =~ ^# ]]; then
        description="${line#"# "}"
      elif [[ "$line" =~ ^(alias|fake_alias) ]]; then
        alias_name=$(printf "%6s" "$(echo "$line" | cut -d'=' -f1 | awk '{print $2}')")
        echo "$alias_name :: $description"
      fi
    done <"$file_path"
  fi
}

# alias description
display_alias_descriptions() {
  echo ""
  fill_line_with_string "BASH ALIASES DESCRIPTIONS" "$line_length" " "
  get_alias_descriptions ~/.bash_aliases
  get_alias_descriptions ~/.local_aliases
  get_alias_descriptions ~/.custom_aliases
  fill_line "$line_length" "-"
}

# edit aliases help
ea_help() {
  e_info "Usage: ea [c|l|h]"
  echo "Edit ~/.bash_aliases file when used without arguments"
  echo "Args: c :: edit ~/.custom_aliases"
  echo "      l :: edit ~/.local_aliases"
  echo "      h :: print help"
}

# edit aliases files
edit_aliases() {
  if [ $# -eq 0 ]; then
    nv ~/.bash_aliases
  elif [ $# -gt 1 ]; then
    e_err "Too many arguments!"
    ea_help
  else
    case "$1" in
    l)
      nv ~/.local_aliases
      ;;
    c)
      nv ~/.custom_aliases
      ;;
    h)
      ea_help
      ;;
    *)
      e_err "Invalid option!"
      ea_help
      ;;
    esac
  fi
}
# GIT FUNCTIONS
# git diff with optional filename from git diff --names-only | nl
git_diff_numbered() {
  if [ $# -eq 0 ]; then
    git diff
  elif [ $# -eq 1 ]; then
    if [[ $1 =~ ^[0-9]+$ ]]; then
      local file
      file=$(git diff --name-only | nl | awk -v num="$1" '$1 == num {print $2}')
      git diff "$file"
    elif [[ $1 == "n" ]]; then
      git diff --name-only | nl
    fi
  fi
}

# git checkout with tab completion
gc() {
  git checkout "$@"
}
# Enable git completion if available
if [ -f /usr/share/bash-completion/completions/git ]; then
  . /usr/share/bash-completion/completions/git
fi
# Enable git branch completion for gc
if type __git_complete &>/dev/null; then
  __git_complete gc _git_checkout
fi

# git add untracked files, commit and push
git_commit_push() {
  if [ -z "$1" ]; then
    e_err "No commit message provided!"
    return 1
  else
    local message="$*"
    git add .
    git commit -m "$message"
    git push
    e_succ -e "\nCommit '$message' succesfully pushed to branch: '$(git branch --show-current)'."
  fi
}

# git create stast with message
git_stash_msg() {
  if [ -z "$1" ]; then
    e_warn "Stash changes with message! Don't be lazy..."
  else
    local msg="$*"
    git stash -m "$msg"
    e_succ "Succesfully stashed changes as '$msg' on branch '$(git branch --show-current)'."
  fi
}

# git apply stash by number
git_apply_stash() {
  if [ $# -eq 0 ]; then
    e_warn "Please specify stash number!"
    return 1
  elif [ $# -gt 1 ]; then
    e_warn "Please specify only one stash number!"
    return 1
  else
    git stash apply stash@"{$1}"
  fi
}

# git echo stasth diff by number
# useful combined with '| xc'
git_stash_patch() {
  if [ $# -eq 0 ]; then
    e_warn "Please specify a stash number!"
    return 1
  elif [ $# -gt 1 ]; then
    e_warn "Please specify only one stash number!"
    return 1
  else
    git stash show -p stash@"{$1}"
  fi
}

# drop stash by number with confirmation
# I accidentally dropped stashes, because I mix up gsp and gsd
git_stash_drop() {
  if [ $# -eq 0 ]; then
    e_warn "Please specify a stash number!"
    return 1
  elif [ $# -gt 1 ]; then
    e_warn "Please specify only one stash number!"
    return 1
  else
    read -rp "Are you sure you want to drop stash #$1? (y/N): " confirm
    if [[ "$confirm" =~ ^[yY]$ ]]; then
      git stash drop stash@"{$1}"
    fi
    e_warn "Stash #$1 not dropped."
    return 0
  fi
}

# OTHER FUNCTIONS
activate_poetry_env() {
  local env
  env=$(poetry env info -p 2>/dev/null)
  if [[ -z "$env" ]]; then
    e_err "No poetry envirionment in current directory!"
  else
    source "$env/bin/activate"
  fi
}
