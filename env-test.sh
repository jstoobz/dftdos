#!/bin/sh

## Functions

function mkcd() { mkdir -p "$@" && cd "$_"; }

function gac() { git add . && git commit -m "$@" }
function gcl() { git clone "$@".git }
function gclr() { git clone "$@".git && clear }

function blg() { brew list | grep "$@" }

## Aliases

alias ebf="code ~/env.sh"
alias sbf="source ~/.zshrc"

alias woke="caffeinate -d"
alias cwoke="clear && caffeinate -d"

alias h="cd ~"
alias c="clear;"
alias cpwd="pwd|pbcopy"

alias ..c='cd ../.. && clear'
alias ...c='cd ../../.. && clear'
alias ....c='cd ../../../.. && clear'

## FROM: https://medium.com/@devmount/9-evil-bash-commands-explained-709412e92bd7
alias rm='rm -i'
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'

alias gis="git status"
alias gic="git init && git add . && git commit -m 'initial commit'"
alias gpc="git push && clear"

alias iexps='iex -S mix phx.server;'
alias ciexps='clear && iex -S mix phx.server;'
alias iexsm='iex -S mix'
alias mpr='mix phx.routes'
alias mf="mix format"
alias mfc="mix format && c"
alias mt="mix test"
alias cmt="clear && mix test"

alias figstoobz='printf "\e[92m" && figlet -f standard "jstoobz"'
alias cfigstoobz='clear &&printf "\e[92m" && figlet -f standard "jstoobz"'

alias cshb='clear && ./bootstrap.sh'
alias cshc='clear && shellcheck ./bootstrap.sh'
