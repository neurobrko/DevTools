# Development tips and tricks

**Few scripts, tools, tips and tricks that I use getting around daily repetitive tasks...**

author: *Marek Paulík*

> **DISCLAIMER:**\
> Most of these scripts are makeshift with some caveats and are not working 100% without error. They were mostly made in a rush and are constantly improved...

**Best way to utilize these scripts is to make some useful aliases on your local system.**

## ssh_to_VM.sh

Connect to VM by providing last number of IP address as only argument.\
If number has less than 3 digits, leading zeros are automatically added.

```
./ssh_to_vm.sh 123
```

## setup_VM.sh

Copy `.bash_aliases` and PyCharm debugger to VM.

```
./setup_VM.sh -i 123
./setup_VM.sh -i 123 -a
```

**-i** is mandatory and followed by host part of VM IP address (don't have to add leading zeros)\
If no other arguments are passed, script will copy both debugger and aliases.\
**-a** copies only `.bash_aliases`\
**-d** copies only debugger

## .bash_aliases

Contains a few handy aliases useful on remote VM.
For example, if you press `h`, you get aliases description:

```
                 BASH ALIASES DESCRIPTIONS                 
@ /root/.bash_aliases
--------------------- General aliases ---------------------
   lh :: ll in human readable format
   dh :: du all items in folder, human readable
  cdb :: cd to $BASE_DIR
  cdl :: cd to virl2 log dir
  cds :: cd to site_packages
   lw :: get single word from output
    h :: print alias descriptions
   sa :: source ~/.bash_aliases
   ea :: edit aliases files ('ea h' for help)
------------------- Development aliases -------------------
  jvc :: journal virl2 controller, no hostname, follow
    j :: full journal, no hostname, follow
  dbc :: open controller sqlite DB
  rvt :: restart virl2 target
  sip :: show bridge0 IP address
---------------------- Docker aliases ----------------------
   da :: show docker containers
   ds :: start or stop docker <container>
  dsa :: stop all docker containers
   dr :: remove docker <container>
  dra :: remove all docker containers
  dia :: list docker images in 'repo:tag'
  dri :: remove docker <image>
 dria :: remove all docker images
------------------------------------------------------------
```

There is also a alternative display of prompt (without username, hostname is shorted and host part of bridge0 IP is in parenthesis, displaying only top directory and some colors):
`S-7881-C0 (165):site-packages#`\
`gc` alias for `git checkout` also work with `TAB` completion!

**LOCAL/CUSTOM bash aliases**\
You can create custom local aliases in `.local_aliases` or `.custom_aliases` files.\
If you remotely update .bash_aliases from your machine using setup_VM.sh,
it won't override local changes.

## get_ip.sh

Shows the IP of interface put in script and copies it to clipboard.

## local_bash_aliases

As mentioned before, best way to use these scripts is to create some local aliases. This is a taste of aliases I use daily locally.

```
                 BASH ALIASES DESCRIPTIONS                 

@ /home/marpauli/.config/aliases/.aliases
--------------------- General aliases ---------------------
    ll :: ll
    lh :: ll in human readable format
    dh :: du all items in folder, human readable 
     g :: grep shorthand
    py :: python 3.12 interpreter/REPL
    sq :: sqlite3 with --table
    sa :: source ~/.config/aliases/.aliases
    ea :: edit aliases files ('ea h' for help)
    xc :: copy <text> to clipboard
     h :: print alias description
----------------------- Dev aliases -----------------------
    nv :: neovim (LazyVim)
   nvc :: cd to nvim config folder
   ape :: activate poetry environment
   r2r :: SyncSuite rsync to remote
   rfm :: SyncSuite file map
   tpc :: Test Path Convertor tool
   rmt :: run multiple tests silently from 'paths' file
  rmte :: edit 'paths' file for 'rmt'
    pc :: run pre-commit on changed files only
-------------------- Remote VM aliases --------------------
     s :: ssh to VM
   svm :: VM setup
    gp :: git profile

@ /home/marpauli/.config/aliases/.git_aliases
----------------------- Git aliases -----------------------
   gst :: git status
   gfa :: git fetch all
    gd :: git diff
   gdn :: git diff numbered (with filenum works only in repo root)
  gcpm :: git commit and push with message
   gco :: git checkout with tab completion
   gsu :: git submodule update
  gstm :: git stash with message
  gstl :: git stash list
  gstp :: git stash patch <#>
  gsta :: git stash apply <#>
  gstd :: gti stash drop <#>
-----------------------------------------------------------
