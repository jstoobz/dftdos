#!/bin/sh

# Exit if any following command exits with a non-zero status.
set -e

# echo "DIR_REL: $(dirname $0)"
# echo "DIR_REL: $(pwd -P)"
cd "$(dirname "$0")/.."
# Prints the actual path (as opposed to symbolic)
DOTFILES_ROOT=$(pwd -P)

GITHUB_REPOSITORY="jstoobz/dft"
# DOTFILES_ORIGIN="git@github.com:$GITHUB_REPOSITORY.git"
DOTFILES_TARBALL_URL="https://github.com/$GITHUB_REPOSITORY/tarball/master"
DF_HOME="${HOME}/.dotfiles"

# HOMEBREW_PREFIX="$(brew --prefix)"
# HOMEBREW_REPOSITORY="$(brew --repo)"

OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')
SW_BUILD=$(sw_vers -buildVersion)

banner(){
    cat << EOF
       _     _              _
      (_)___| |_ ___   ___ | |__ ____
      | / __| __/ _ \ / _ \| '_ \_  /
      | \__ \ || (_) | (_) | |_) / /
     _/ |___/\__\___/ \___/|_.__/___|
    |__/
	By James Stephens (jstoobz)
	
EOF
}

info() {
	# shellcheck disable=SC2059
	printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user() {
	# shellcheck disable=SC2059
	printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success() {
	# shellcheck disable=SC2059
	printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail() {
	# shellcheck disable=SC2059
	printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n\n"
	# exit
}

fancy_echo() {
  fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\\n$fmt\\n" "$@"
}

clr_screen(){
	# shellcheck disable=SC2059
	printf "\033c"
}

padding() {
	# shellcheck disable=SC2059
	printf "\n"
}

ask_for_sudo() {
	# Ask for the administrator password upfront
	sudo -v

	# Update existing `sudo` time stamp until the script has finished
	while true; do 
		sudo -n true 
		sleep 60 
		kill -0 "$$" || exit 
	done 2>/dev/null &
}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

extract() {
	archive="$1"
	outputDir="$2"

	command_exists "tar" && \
		tar -zxf "$archive" --strip-components 1 -C "$outputDir"
	
}

download() {
	url="$1"
	output="$2"

	if command_exists curl; then
		curl -LsSo "$output" "$url" >/dev/null 2>&1
		return $?
	elif command_exists wget; then
		wget -qO "$output" "$url" >/dev/null 2>&1
		return $?
	fi

	return 1
}

download_dotfiles() {
	info "Downloading and extracting archive..."
	tmpFile=""
	tmpFile="$(mktemp /tmp/XXXXX)"
	download "$DOTFILES_TARBALL_URL" "$tmpFile"

	# Add in verification to move a current .dotfiles directory
	# to a backup and install fresh
	[ ! -d "${DF_HOME}" ] && mkdir "$DF_HOME"

	info "Extracting archive"
	extract "$tmpFile" "$DF_HOME" 
	success "Extracted archive"
	cd "$DF_HOME"
	info "Current working directory: $(pwd -P)"
}

create_symlinks() {
	echo "symlinks"
}

install_cli_tools() {
	info "Checking for Xcode CLI tools..."

	if [ "$(xcode-select -p)" ]; then
		success "Xcode found"
		return
	fi

	info "Installing Xcode"
	xcode-select --install
	until [ "$(xcode-select -p)" ];
	do
		info "Sleeping..."
		sleep 5
	done
	success "Installed Xcode"
}

install_xcode() {
	info "Checking for Xcode CLI tools..."

	if [ "$(xcode-select -p)" ]; then
		success "Xcode found"
		return
	fi

	info "Installing Xcode"

	if [ "$OSX_VERS" -ge 9 ]; then
		# This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
		CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
		touch "${CLT_PLACEHOLDER}"
		PROD=$(softwareupdate -l | 
			grep "\*.*Command Line" |
			awk -F": " '{print $2}')
		
		info "Xcode CLI Tools Version: ${PROD}"

		echo "Installing Xcode CLI Tools..."
		softwareupdate -i "${PROD}" --verbose

		# echo "Successfully installed Xcode CLI Tools, now add xcodebuild license"
		
	else
		echo "OSX_VERS is le 9"
	fi

	# xcode-select --install
	until [ "$(xcode-select -p)" ];
	do
		info "Sleeping..."
		sleep 5
	done

	info "Removing temp file..."
	[ -f "${CLT_PLACEHOLDER}" ] && rm -rf "${CLT_PLACEHOLDER}"
	
	success "Installed Xcode"
}

install_homebrew() {
	info "Checking for Homebrew..."

	if command_exists brew; then
		success "You already have Homebrew installed"
		return
	fi

	info "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	brew update
	brew upgrade
	success "Homebrew was installed"
}

install_git() {
	info "Checking for git via brew..."

	if [ -x "$(brew --prefix)/bin/git" ]; then
		success "Git is already installed via brew"
		return
	fi

	info "Installing git..."
	brew install git
	success "Installed git"
}

test_tmp() {
	CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
	info "CLT_PLACEHOLDER: ${CLT_PLACEHOLDER}"
	touch "${CLT_PLACEHOLDER}"
	# touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

	[ -f "${CLT_PLACEHOLDER}" ] && info "CLT_PLACEHOLDER EXISTS"
	[ -f "${CLT_PLACEHOLDER}" ] && rm -rf "${CLT_PLACEHOLDER}"
	[ -f "${CLT_PLACEHOLDER}" ] || info "CLT_PLACEHOLDER DOES NOT EXIST"
}

main() {
	ask_for_sudo "$@"
	clr_screen "$@"
	padding "$@"
	banner "$@"
	info "MacOS Version: ${OSX_VERS}"
	info "MacOS SW Build: ${SW_BUILD}"
	# install_cli_tools "$@"
	install_xcode "$@"
	install_homebrew "$@"
	install_git "$@"
	download_dotfiles "$@"

	# create_directories
	# create_symbolic_links
	# create_local_config_files
	# install/main.sh
		# xcode.sh
			# install_xcode_command_line_tools
			# install_xcode
			# set_xcode_developer_directory
			# agree_with_xcode_license
		# homebrew.sh
		# bash.sh
		# git.sh
		# ..
		# 
		# 
	padding "$@"
	padding "$@"
	padding "$@"

	test_tmp "$@"

	# fancy_echo "Fancy Echo ..."
	# info "DIR_ACT: $(pwd -P)"

	padding "$@"
	padding "$@"
	padding "$@"
}

main "$@"