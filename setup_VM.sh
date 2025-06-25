#!/bin/bash

# Script to setup enviroment in newly created VM
# See usage() below.
# Create an alias in your env and you can ommit -i, just put in device part of IP. E.g.:
#
# alias svm='/home/marpauli/code/setup_VM.sh -i'
#

# Function to display usage
usage() {
  echo "Usage: $0 [-i (required)] [-a] [-d]"
  echo "       -i Last three digits of VM IP address (device)"
  echo "       -a Copy .bash_aliases to VM root home"
  echo "       -d Copy PyCharm debugger to VM BASE_DIR"
  echo "If only -i is provided, everything will be copied!"
  exit 1
}

# Initialize variables
# flag for copying .bash_aliases
flag_a=false
# flag for copying PyCharm debugger
flag_d=false
# port number
port_number=""

# Parse CLI arguments
while getopts ":i:ad" opt; do
  case ${opt} in
    i )
      ip_device=$OPTARG
      ;;
    a )
      flag_a=true
      ;;
    d )
      flag_d=true
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      usage
      ;;
    : )
      echo "Invalid option: -$OPTARG requires an argument" 1>&2
      usage
      ;;
  esac
done
shift $((OPTIND -1))

if [ -z $ip_device ]; then
  echo "Error: -i argument is mandatory!"
  usage
fi

# setup variables
credentials="username@hostname_or_ip"
# here is example when port is always 13 and ip_device is last three digits of IP
port="13$ip_device"
# dir to put python debugger to
vm_base_dir="/some/directory/on/VM"
pycharm_debugger="/snap/pycharm-professional/393/debug-eggs/pydevd-pycharm.egg"

# copy functions
copy_aliases() {
  # copy .bash_aliases from sscript dir to VM
  scp -P $port .bash_aliases $credentials:~
}

copy_debugger() {
  # copy PyCharm debugger
  scp -P $port $pycharm_debugger $credentials:$vm_base_dir
}

# if no additional arguments were provided, copy everything
if [ $flag_a = false ] && [ $flag_d = false ]; then
  copy_aliases
  copy_debugger
  exit 0
fi
# else, copy according to provided arguments
if [ $flag_a = true ]; then
  copy_aliases
fi
if [ $flag_d = true ]; then
  copy_debugger
fi
