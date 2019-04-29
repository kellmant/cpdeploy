#!/bin/bash 
#
set -a

if [ -f "$HOME/.sessionkey" ] ; then 
        SESSIONKEY=$(cat ~/.sessionkey)
fi

token () {< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-64};echo;}

function msgctrl {
    msgin="$@"
    tstamp=$(date +"%a %r")
    tsecs=$(date +"%s")
    mhost=$(hostname)
    kstoreput="curl -s -XPUT http://keystore:2379/v2/keys"
    kstoreget="curl -s -L http://keystore:2379/v2/keys"
    msgout="$mhost | $tstamp | $msgin [ $$ ]"
$kstoreput/stream -d value="${msgout}"
}
    
function recordme {
    tstamp=$(date +"%Y%m%d-%H%M%S")
    TermRecord -b script -c "/bin/bash -l" -o ~/capture-${BUDDY}-${tstamp}.html
    return 0
}

# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC='\e[m'               # Color Reset


ALERT=${BWhite}${On_Red} # Bold White on red background
CLEANPS=${BGreen} # Bold White on red background


# set connection type:
    CNX=${BCyan}        # Connected on local machine.

# Test user type:
if [[ ${USER} == "root" ]]; then
    SU=${BRed}           # User is root.
elif [[ ${USER} == "ctrl" ]]; then
    SU=${Green}          # User is not login user.
elif [[ ${USER} == "kellman" ]]; then
    SU=${BBlue}          # User is not login user.
else
    SU=${BYellow}         # User is normal (well ... most of us are).
fi



# Returns a color according to running/suspended jobs.
function job_color()
{
    if [ $(jobs -s | wc -l) -gt "0" ]; then
        echo -en ${BRed}
    elif [ $(jobs -r | wc -l) -gt "0" ] ; then
        echo -en ${BCyan}
    fi
}

#============================================================
promptls () {
    if [ "$PWD" != "$HOME" ] ; then
	    cntls=$(ls -xtF1 "$PWD" | wc -l)
    pmptls=$(ls -xtF1 --color=always "$PWD" | tr '\n' ' ' | cut -c -96) 
    echo -en "${pmptls[@]} (...$cntls items)"
    fi
}

promptcf () {
    pmptcf=$(ls -xF1 --color=always "$HOME/cfg" | tr '\n' ' ') 
    echo -en "(${pmptcf[@]})"
}

promptcr () {
    pmptcr=$(ls -xF1 --color=always "$HOME/create" | tr '\n' ' ') 
    echo -en "(${pmptcr[@]})"
}

promptde () {
    pmptde=$(ls -xF1 --color=always "$HOME/destroy" | tr '\n' ' ') 
    echo -en "(${pmptde[@]})"
}

promptpwd () {
    prmptwd=$(pwd | tr -d '\n')
    echo -en "${prmptwd[@]}"
}

promptsys () {
  uname -n | tr -d '\n'
}

prompthist () {
  #history 1 | cut -d ' ' -f 4- | tr -d '\n'
  history 1 | awk '{print $2}' | tr -d '\n'
}

promptscore () {
    score=$(etcdctl get /score 2>/dev/null) 
    scoreout=$(echo $score | tr -d '\n')
     echo -en "\$$score "
}

promptcfg () {
    cfgstat=($(etcdctl ls ctrl/cfg/mg 2> /dev/null)) || cfgstat="X"
    if [[ "${cfgstat[@]}" == "X" ]] ; then
    echo -en "none "
    else
        for c in "${cfgstat[@]}" ; do
    cfgout=$(echo ${c} | cut -d '/' -f 5 | tr '\n' ' ')
    echo -en "$cfgout "
        done
    fi
}

promptrun () {
    runstat=($(etcdctl ls ctrl/create/mg 2> /dev/null)) || runstat="X"
    if [[ "${runstat[@]}" == "X" ]] ; then
    echo -n "none "
    else
        for r in "${runstat[@]}" ; do
    runout=$(echo ${r} | cut -d '/' -f 5 | tr '\n' ' ')
    echo -en "$runout "
done
fi
}

promptgit () {
    if [ -d .git ] ; then
    gitstat=$(git status | tail -n 1 | tr -d '\n')
        echo -en "${On_Red}${BCyan}Git Status:${NC} ${BCyan}$gitstat"
        echo -en "${NC} $(git status --porcelain -z -s)"
    #git status -s -z
    else
    pmptls=$(ls -xF1 --color=always "$PWD" | tr '\n' ' ') 
    echo -en "${pmptls[@]}"
    #   echo -n " " 
   fi
}

promptsession () {
  if [ -f $HOME/.sessionkey ] ; then
  cat $HOME/.sessionkey | cut -d '-' -f 3 | tr -d '\n'
  else
      echo -n "boot/session-create"
  fi
}

promptmsg () {
        echo -ne "${Green} $(etcdctl get stream)${NC}" || echo -n "no messages"
 }

timer_start () {
  timer=${timer:-$SECONDS}
}

timer_stop () {
  timer_show=$(($SECONDS - $timer))
let hours=timer_show/3600
let minutes=(timer_show/60)%60
let seconds=timer_show%60
let millis=0
if [ "$timer_show" -lt 1 ]; then
clock_show=$(printf %s "$millis second")
else
	if [ "$timer_show" -eq 1 ]; then
clock_show=$(printf "%0d second" $seconds)
else
	if [ "$timer_show" -lt 10 ]; then
clock_show=$(printf "%0d seconds" $seconds)
else
	if [ "$timer_show" -le 59 ]; then
clock_show=$(printf "%02d seconds" $seconds)
else
	if [ "$timer_show" -lt 3600 ]; then
clock_show=$(printf "%02d minutes, and %02d seconds" $minutes $seconds)
	else
clock_show=$(printf "%02d hours, %02d minutes and %02d seconds" $hours $minutes $seconds)
	fi
	fi
	fi
	fi
fi	
  unset timer
}


#-------------------
# Personnal Aliases
#-------------------
alias showdebug='cd $HOME/debug'
alias what='cat /etc/motd'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
# -> Prevents accidentally clobbering files.
alias mkdir='mkdir -p'

alias h='history'
alias j='jobs -l'
alias which='type -a'
alias ..='cd ..'

# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'


alias du='du -h'    # Makes a more readable output.
alias df='df -h'

#-------------------------------------------------------------
# The 'ls' family (this assumes you use a recent GNU ls).
#-------------------------------------------------------------
# Add colors for filetype and  human-readable sizes by default on 'ls':
alias ls='ls -h --color=auto'
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.

# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll='ls -hl --color=auto'
alias lm='ll | more'        #  Pipe through 'more'
alias lt='ll -tr'         #  Sort by date, most recent last.
alias lr='ll -R'           #  Recursive ls.
alias la='ll -A'           #  Show hidden files.
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...


#-------------------------------------------------------------
# Spelling typos - highly personnal and keyboard-dependent :-)
#-------------------------------------------------------------

alias xs='cd'
alias vf='cd'
alias moer='more'
alias moew='more'
alias kk='ll'


#-------------------------------------------------------------
# A few fun ones
#-------------------------------------------------------------
export EDITOR=vim
alias vi='vim'

#-------------------------------------------------------------

#-------------------------------------------------------------
# construct the prompt:
#-------------------------------------------------------------

# Now we construct the prompt.
PROMPT_COMMAND=""
#if [ -n "$STY" ] ; then
#    sysback="${On_Green}"
#	systype="SCREEN"
    systype="svc:"
	sysback="${On_Red}"

trap 'timer_start' DEBUG

if [ "$PROMPT_COMMAND" == "" ]; then
  PROMPT_COMMAND="timer_stop"
else
  PROMPT_COMMAND="$PROMPT_COMMAND; timer_stop"
fi

checkexit () {
if [ $? -eq 0 ]
then
printf ${CLEANPS}
else
printf ${ALERT}
fi
}
PS1=""

	# mark last output
PS1=${PS1}"\[${Purple}\]\[${On_White}\]<=\[${On_Black}\]\[${BYellow}\][\$(checkexit)\$(prompthist)\[${NC}\]\[${BYellow}\]][runtime:\[${BWhite}\]\${clock_show}\[${BYellow}\]]\[${NC}\]"
        # Start with time of day
	# put some user and host info in.
#        PS1=${PS1}"\n\[${Yellow}\][\[${BCyan}\]\u\[${NC}\]@\[${BBlack}\]\[${On_Cyan}\]\h\[${Yellow}\]]\[${NC}\]"
	PS1=${PS1}"\[${Yellow}\][\[${NC}\]\@ \d\[${Yellow}\]]\[${NC}\]"
PS1=${PS1}"\[${Yellow}\][${systype}\[${BYellow}\]\[${sysback}\]\$(promptsys)\[${Yellow}\] role:\[${SU}\]\u\[${Yellow}\]]\[${NC}\]"
        PS1=${PS1}":\[${Yellow}\][cmd:\[${BRed}\]\#\[${Yellow}\] done:\[${Green}\]\!\[${Yellow}\]]\nsession:\[${BCyan}\]\$(promptsession)\[${NC}\]"
        PS1=${PS1}"\[${Yellow}\] - configured:\[${BBlue}\]\$(promptcfg)\[${Yellow}\] - created:\[${BGreen}\]\$(promptrun)\[${Yellow}\] - cost:\[${BRed}\]\$(promptscore)\[${NC}\]"
	# place directory we are working in above the prompt
	# set the prompt
    	PS1=${PS1}"\n\[${Yellow}\]|_/[\[${BWhite}\]cfg/\[${NC}\]\$(promptcf)\[${Yellow}\]]"
    	PS1=${PS1}"\n\[${Yellow}\]|_/[\[${BWhite}\]create/\[${NC}\]\$(promptcr)\[${Yellow}\]]"
    	PS1=${PS1}"\n\[${Yellow}\]|_/[\[${BRed}\]destroy${BWhite}/\[${NC}\]\$(promptde)\[${Yellow}\]]"
    	PS1=${PS1}"\n\[${Yellow}\]|_/DIR[\[${BCyan}\]\$(promptpwd)\[${Yellow}\]] \[${NC}\$(promptls)"
	PS1=${PS1}"\n\[${Purple}\]\[${On_White}\]=>\[${NC}\] "
        # Set title of current xterm:
        #PS1=${PS1}"\[\e]0;[\u@\h] \w\a\]"



# Local Variables:
# mode:shell-script
# sh-shell:bash
# End:
export CLICOLOR=1
export CLICOLOR_FORCE=G
LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS
export LSCOLORS=ExFxBxDxCxegedabagacad
#export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
export HISTFILESIZE=8192
export HISTSIZE=4096
export HISTIGNORE="ls:cd*:pwd:ll:la:history:h:exit:"
#export HISTIGNORE="exit:history:h"
alias clearhistory='echo clear > ~/.bash_history'



# User specific aliases and functions

export TZ='America/Toronto'

alias fwa='ssh admin@fwa.seclab.cloud'
alias fwb='ssh admin@fwb.seclab.cloud'
alias opbmg='ssh admin@opbstage.seclab.cloud'
alias deploy='cd ~/bin'
alias dev='cd ~/bin'
alias blog='cd /ctrl/sysblog/source/_posts/'
alias mybin='cd ~/bin'
alias run='ssh -tq core'

alias cleanscreen='reset ; resize'
alias setme='sed -i \"s/BUDDY/${BUDDY}/g\" ${1}'
alias helpme='tree --dirsfirst -A $HOME'
alias ctrl='cd ~'
alias cfg='skey ctrl/cfg'
alias create='skey ctrl/create'
alias destroy='ls $HOME/names | cut -d '.' -f 2 | grep -v md'

reset
resize

if [[ -v $SSH_AGENT_PID ]] || [[ ! -f $HOME/.ssh/${SESSIONKEY}.pem ]] ; then
echo "ssh agent not applied to this session."
else
eval $(ssh-agent)
eval $(ssh-add ~/.ssh/${SESSIONKEY}.pem)
trap 'ssh-agent -k; exit' 0 1
fi

# User specific aliases and functions
export PAGER=more
export PATH=~/bin:/node/bin:$PATH
#export NODE_PATH=/usr/lib/node_modules:~/node_modules:$NODE_PATH
#export PYTHONPATH=$PYTHONPATH:/ctrl/cp_mgmt_api_python_sdk/

echo " "


if [ ! -f ~/.aws/credentials ] ; then
#echo "no credentials found for cloud service, requesting keys."
#echo 
echo "No AWS credentials configured."
#aws configure
#echo 
fi
echo "Starting human interface" 
cd ~
# let the trap go
#trap SIGHUP
#trap SIGINT
#trap SIGTERM
#resize &>/dev/null
msgctrl "$(hostname) shell is live and running for $TSOCK "
echo 
echo " $0 from profile load for $TSOCK session."
cat /etc/motd
echo
echo
if [ ! -f ~/.sessionkey ] ; then
echo "no session found for cloud service, run boot/session-create <optional name>"
#echo 
fi
