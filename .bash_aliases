# functions
e_err() {
  # print red bold text
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

docker_start_stop() {
    local cname="$1"
    if [ -z "$cname" ]; then
        e_info "Usage: docker_toggle <container_name_or_id>"
        return 1
    fi
    state=$(docker inspect -f '{{.State.Status}}' "$cname" 2>/dev/null)
    case $state in
        "running")
            docker stop "$cname"
            e_info "Container '$cname' stopped."
            ;;
        "exited")
            docker start "$cname"
            e_info "Container '$cname' started."
            ;;
        *)
            e_err "Container '$cname' not found or not in a valid state."
            return 1
            ;;
    esac
}

docker_stop_all() {
  for cont in $(docker ps -a --format {{.Names}}); do
    docker stop $cont > /dev/null
    e_info "Container $cont stopped."
  done
}

docker_remove() {
  container=$(docker rm $1)
  e_info "Container $container removed."
}

docker_remove_all() {
  for cont in $(docker ps -a --format {{.Names}}); do
    docker rm $cont > /dev/null
    e_info "Container $cont removed."
  done
}

docker_remove_all_images() {
  for img in $(docker image ls --format '{{.Repository}}:{{.Tag}}'); do
    docker image rm $img > /dev/null
    e_info "Image $img removed."
  done
}

show_ip() {
  ip addr show bridge0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1
}

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
  local padding=$(( (length - ${#string} - 2) / 2 ))
  local beg=$(printf "%${padding}s" | tr ' ' "$beg_char")
  local end=$(printf "%${padding}s" | tr ' ' "$end_char")
  printf "%s%s%s" "$beg" "" " $string " "$end" ""
  echo ""
}

# LINE LENGTH
line_length=60

fill_line() {
  local length="$1"
  local fill="$2"
  printf "%*s\n" "$length" | tr ' ' "$fill"
}

get_alias_descriptions() {
  # Sections must start with '### '. (With space!)
  # Alias descriptions must one line above alias declaration.
  # All comments above alias description are ignored.
  local file_path="$1"
  if [ -f "$file_path" ]; then
    echo "@ $file_path"
    local description=""
    while IFS= read -r line; do
      if [[ "$line" =~ ^### ]]; then
        fill_line_with_string "${line#'### '}" $line_length "-"
      elif [[ "$line" =~ ^# ]]; then
        description="${line#"# "}"
      elif [[ "$line" =~ ^alias ]]; then
        alias_name=$(printf "%5s" $(echo "$line" | cut -d'=' -f1 | awk '{print $2}'))
        echo "$alias_name :: $description"
      fi
    done < "$file_path"
  fi
}

# alias description
display_alias_descriptions() {
  echo ""
  fill_line_with_string "BASH ALIASES DESCRIPTIONS" $line_length " "
  get_alias_descriptions ~/.bash_aliases
  get_alias_descriptions ~/.local_aliases
  get_alias_descriptions ~/.custom_aliases
  fill_line $line_length "-"
}

#edit aliases help
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
    nano ~/.bash_aliases
  elif [ $# -gt 1 ]; then
    e_warn "Too many arguments!"
    ea_help
  else
    case "$1" in
      l)
        nano ~/.local_aliases
        ;;
      c)
        nano ~/.custom_aliases
        ;;
      h)
        ea_help
        ;;
      *)
        e_warn "Invalid option!"
        ea_help
        ;;
    esac  
  fi
}

### General aliases
# ll in human readable format
alias lh='ls -lah'
# du all items in folder, human readable
alias dh='du -chs *'
# print alias descriptions
alias h=display_alias_descriptions
# source ~/.bash_aliases
alias sa='source ~/.bash_aliases'
# edit aliases files ('ea h' for help)
alias ea=edit_aliases
### Development aliases
# journal controller, no hostname, follow
alias jvc='journalctl -f --no-hostname -u controller.service'
# full journal, no hostname, follow
alias j='journalctl -f --no-hostname'
# open file sqlite DB
alias dbc='sqlite3 -table /path/to/file.db'
# restart service target
alias rvt='systemctl restart service.target'
# show bridge0 IP address
alias sip=show_ip
### Docker aliases
# show docker containers
alias da='docker ps -a'
# start or stop docker <container>
alias ds=docker_start_stop
# stop all docker containers
alias dsa=docker_stop_all
# remove docker <container>
alias dr=docker_remove
# remove all docker containers
alias dra=docker_remove_all
# list docker images in 'repo:tag'
alias dia='docker image ls --format {{.Repository}}:{{.Tag}}'
# remove docker <image>
alias dri='docker image rm'
# remove all docker images
alias dria=docker_remove_all_images

# LOCAL/CUSTOM bash aliases
# You can create custom local aliases in .local_aliases file
# If you remotly update .bash_aliases from your machine using setup_VM.sh,
# it won't override local changes.
if [ -f ~/.local_aliases ]; then
    . ~/.local_aliases
fi
if [ -f ~/.custom_aliases ]; then
    . ~/.custom_aliases
fi

# alter bash prompt (no username, shorter hostname, host part of IP, top dir only, colors)
short_hostname=$(awk -F'-' '{print "S-" $4 "-" $NF}' <<< $(hostname))
ip_hostpart=$(show_ip | awk -F. '{print $NF}')

export PS1='\[\e[1;32m\]\[$(echo $short_hostname)\] \[\e[1;30m\](\[$(echo $ip_hostpart)\])\[\e[1;32m\]\[\e[0m\]:\[\e[1;34m\]\W\[\e[0m\]\$ '
