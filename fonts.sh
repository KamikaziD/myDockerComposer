#!/bin/bash

GREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
WHITE='\033[0;36m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
ENDCOLOR='\033[0;29m'

NORMAL=0
BOLD=1
FAINT=2
ITALIC=3
UNDERLINE=4

BOLDRED=$(echo $RED|sed -e "s/\[./\[${BOLD}/")
BOLDBLUE=$(echo $BLUE|sed -e "s/\[./\[${BOLD}/")
BOLDYELLOW=$(echo $YELLOW|sed -e "s/\[./\[${BOLD}/")
UNDERLINEYELLOW=$(echo $YELLOW|sed -e "s/\[./\[${UNDERLINE}/")
ITALICBLUE=$(echo $BLUE|sed -e "s/\[./\[${ITALIC}/")
FAINTRED=$(echo $RED|sed -e "s/\[./\[${FAINT}/")


print_banner() {
  echo
  echo -e "${BOLDBLUE}  ##      ## ########     ########   #######   ######      ######   #######  ##     ##
  ##  ##  ## ##     ##    ##     ## ##     ## ##    ##    ##    ## ##     ## ###   ###
  ##  ##  ## ##     ##    ##     ## ##     ## ##          ##       ##     ## #### ####
  ##  ##  ## ########     ##     ## ##     ## ##          ##       ##     ## ## ### ##
  ##  ##  ## ##           ##     ## ##     ## ##          ##       ##     ## ##     ##
  ##  ##  ## ##           ##     ## ##     ## ##    ##    ##    ## ##     ## ##     ##
   ###  ###  ##           ########   #######   ######      ######   #######  ##     ##"
  echo
}