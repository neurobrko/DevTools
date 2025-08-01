#!/bin/zsh

# alias neovim, so it can be used in .aliases straight away
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
  get_alias_descriptions ~/.config/aliases/.aliases
  if [ -n "$BASH_VERSION" ]; then
    get_alias_descriptions ~/.config/aliases/.git_aliases
  fi
  get_alias_descriptions ~/.config/aliases/.local_aliases
  get_alias_descriptions ~/.config/aliases/.custom_aliases
  fill_line "$line_length" "-"
}

#edit aliases help
ea_help() {
  e_info "Usage: ea [c|l|h]"
  echo "Edit ~/.config/aliases/.aliases file when used without arguments"
  echo "Args: c :: edit ~/.config/aliases/.custom_aliases"
  echo "      l :: edit ~/.config/aliases/.local_aliases"
  echo "      f "" edit ~/.config/aliases/.functions.sh"
  echo "      h :: print help"
}

# edit aliases files
edit_aliases() {
  if [ $# -eq 0 ]; then
    nv ~/.config/aliases/.aliases
  elif [ $# -gt 1 ]; then
    e_err "Too many arguments!"
    ea_help
  else
    case "$1" in
    l)
      nv ~/.config/aliases/.local_aliases
      ;;
    c)
      nv ~/.config/aliases/.custom_aliases
      ;;
    f)
      nv ~/.config/aliases/.functions.sh
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
