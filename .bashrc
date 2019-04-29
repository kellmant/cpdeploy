#!/bin/bash 
#

#-------------------------------------------------------------
export EDITOR=vim
alias vi='vim'

#-------------------------------------------------------------
# File & strings related functions:
#-------------------------------------------------------------


# Local Variables:
# mode:shell-script
# sh-shell:bash
# End:
export CLICOLOR=1
export CLICOLOR_FORCE=G
#export LSCOLORS=ExFxBxDxCxegedabagacad
#export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
export HISTFILESIZE=8192
export HISTSIZE=4096
#export HISTIGNORE="ls:cd*:pwd:ll:la:history:h:exit:"
export HISTIGNORE="exit"
alias clearhistory='echo clear > ~/.bash_history'



# User specific aliases and functions

export TZ='America/Toronto'

alias cleanscreen='reset ; resize'

if [ ! -f $HOME/.vimrc ] ; then
    echo "Setting up code editor . . . "
    mkdir -p $HOME/.vim/autoload
    mkdir -p $HOME/.vim/bundle
    curl -o $HOME/.vim/autoload/pathogen.vim -L https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
cat > $HOME/.vimrc <<EOF
execute pathogen#infect()

filetype plugin indent on
syntax on
syntax enable
set background=dark
set term=screen-256color
EOF

cd $HOME/.vim/bundle
git clone https://github.com/plasticboy/vim-markdown 
git clone https://github.com/pangloss/vim-javascript
git clone https://github.com/klen/python-mode
git clone https://github.com/ekalinin/dockerfile.vim
git clone https://github.com/othree/html5.vim
git clone https://github.com/elzr/vim-json
git clone git://github.com/altercation/vim-colors-solarized.git

fi

echo "Starting human pre run interface" 
cat /etc/motd
echo 
echo "Interdimensional Portal starting $(hostname) container service for $BUDDY"
echo " . . . . . . . . . . . . . . . . . . . . . . . . . . "
echo "Active Sessions:"
echo " $(tmux -S /socket/$BUDDY list-sessions) "
echo
echo "Hit enter to attach. . . "
read junk
echo 
echo 
echo

tmux -S /socket/$BUDDY attach -t $BUDDY || { tmux -S /socket/$BUDDY new -A -s $BUDDY "bash -l" ; }
echo
echo
exit

