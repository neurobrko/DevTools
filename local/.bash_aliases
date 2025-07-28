# shellcheck source=/home/marpauli/.functions.sh
. ~/.functions.sh

### General aliases
# ll in human readable format
alias lh='ls -lAh'
# du all items in folder, human readable
alias dh='du -chs *'
# grep shorthand
alias g='grep'
# python 3.12 interpreter/REPL
alias py='python3.12'
# sqlite3 with --table
alias sq='sqlite3 --table'
# source ~/.bash aliases
alias sa='source ~/.bash_aliases'
# edit aliases files ('ea h' for help)
alias ea=edit_aliases
# copy <text> to clipboard
alias xc='xclip -sel clip'
# print alias description
alias h='display_alias_descriptions'
### Dev aliases
# neovim (LazyVim)
fake_alias nv
# cd to nvim config folder
alias nvc='cd ~/.config/nvim'
# activate poetry environment
alias ape=activate_poetry_env
# SyncSuite rsync to remote
alias r2r='/home/marpauli/code/elvis/SyncSuite/rsync_to_remote.py -cd /home/marpauli/code/sync_config/cml'
# SyncSuite file map
alias rfm='/home/marpauli/code/elvis/SyncSuite/file_map.py -cd /home/marpauli/code/sync_config/cml'
# Test Path Convertor tool
alias tpc='/home/marpauli/.cache/pypoetry/virtualenvs/test-path-converter-1xglui3r-py3.12/bin/python3 /home/marpauli/code/TestPathConverter/test_path_converter.py'
# run multiple tests silently from 'paths' file
alias rmt='for path in $(~/code/TestPathConverter/get_multiple_paths.py paths); do echo "$path"; pytest -qq --disable-warnings --tb=no "$path"; done'
# edit 'paths' file from 'rmt'
alias rmte='nv ~/code/TestPathConverter/paths'
# run pre-commit on changed files only
alias pc='pre-commit run --files $(git diff --name-only)'
### Remote VM aliases
# ssh to VM
alias s='/home/marpauli/code/DevTools/ssh_to_vm.sh'
# VM setup
alias svm=setup_VM
### Git aliases
# git profile
alias gp='/home/marpauli/code/elvis/DevTools/git_credentials.sh'
# git status
alias gi='git status'
# git diff (n files with #, <#> single file)
alias gd=git_diff_numbered
# git fetch all
alias gf='git fetch --all'
# git checkout with tab completion
fake_alias gc
# git commit and push with message
alias gcp=git_commit_push
# git submodule update
alias gsu='git submodule update'
# git stash with message
alias gsm=git_stash_msg
# git stash list
alias gsl='git stash list'
# git stash patch <#>
alias gsp=git_stash_patch
# git stash apply <#>
alias gsa=git_apply_stash
# gti stash drop <#>
alias gsd=git_stash_drop

# LOCAL/CUSTOM bash aliases
# You can create custom local aliases in .local_aliases
# or .custom_aliases file for some temporary aliases
if [ -f ~/.local_aliases ]; then
  . ~/.local_aliases
fi
if [ -f ~/.custom_aliases ]; then
  . ~/.custom_aliases
fi
