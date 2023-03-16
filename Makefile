.DEFAULT_GOAL	:= help
SHELL 			:= $(shell which bash)
UNAME 			:= $(shell uname -s)

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: all

all: ansible check git help homebrew just install xcode

# TODO: QA on macOS and Linux

check:  ## set environment variables
	@echo "Checking environment..."
	@echo "UNAME: ${UNAME}"
	@echo "SHELL: ${SHELL}"
	if [[ "${UNAME}" == "Linux" ]] \
		. /etc/os-release; \
	fi

xcode: ## install xcode command line tools
	@echo "Installing Xcode command line tools..."
	if [[ "${UNAME}" == "Darwin" ]]; then \
		xcode-select --install; \
	fi

homebrew: ## install homebrew
	@echo "Installing Homebrew..."
	if [[ "${UNAME}" == "Darwin" ]]; then \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi

git: check ## install git
	@echo "Installing Git..."
	if [[ "${UNAME}" == "Darwin" ]] && [[ $(command -v brew; echo $?) -eq 0 ]]; then \
		brew install git; \
	elif [[ "$${ID}" == "ubuntu" ]]; then \
		sudo apt install git; \
	elif [[ "$${ID}" == "fedora" ]]; then \
		sudo dnf install git; \
	elif [[ "$${ID}" == "arch" ]]; then \
		sudo pacman -S git; \
	else \
		echo "Unsupported OS"; \
	fi

ansible: check ## install ansible
	@echo "Installing Ansible..."
	if [[ "${UNAME}" == "Darwin" ]]; then \
		brew install ansible ansible-lint; \
	else \
		python3 -m pip install ansible ansible-lint; \
	fi

just: check ## install justfile
	@echo "Installing Justfile..."
	if [[ "${UNAME}" == "Darwin" ]]; then \
		brew install just; \
	elif [[ "$${ID}" == "ubuntu" ]]; then \
		sudo apt install just; \
	elif [[ "$${ID}" == "fedora" ]]; then \
		sudo dnf install just; \
	elif [[ "$${ID}" == "arch" ]]; then \
		sudo pacman -S just; \
	else \
		echo "Unsupported OS"; \
	fi

install: xcode homebrew git ansible just  ## install all dependencies

help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '    ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)
