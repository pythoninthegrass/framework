.DEFAULT_GOAL	:= help
export SHELL 	:= $(shell which bash)
export UNAME 	:= $(shell uname -s)

# Source /etc/os-release if it exists
ifneq (,$(wildcard /etc/os-release))
	include /etc/os-release
endif

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: all

all: ansible sanity-check git help homebrew just install xcode

# TODO: QA on macOS; Linux (Debian/Ubuntu)
# * cf. `distrobox create --name i-use-arch-btw --image archlinux:latest && distrobox enter i-use-arch-btw`
# * || `distrobox create --name debby --image debian:stable && distrobox enter debby`

sanity-check:  ## output environment variables
	@echo "Checking environment..."
	@echo "UNAME: ${UNAME}"
	@echo "SHELL: ${SHELL}"
	@echo "ID: ${ID}"

xcode: ## install xcode command line tools
	@echo "Installing Xcode command line tools..."
	if [[ "${UNAME}" == "Darwin" ]]; then \
		xcode-select --install; \
	fi

homebrew: ## install homebrew
	@echo "Installing Homebrew..."
	if [[ "${UNAME}" == "Darwin" ]]; then \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
		echo "Unsupported OS"; \
	fi

git: ## install git
	@echo "Installing Git..."
	if [[ "${UNAME}" == "Darwin" ]] && [[ "$(command -v brew; echo $?)" -eq 0 ]]; then \
		brew install git; \
	elif [[ "${ID}" == "ubuntu" ]]; then \
		sudo apt install -y git; \
	elif [[ "${ID}" == "fedora" ]]; then \
		sudo dnf install -y git; \
	elif [[ "${ID}" == "arch" ]]; then \
		yes | sudo pacman -S git; \
	else \
		echo "Unsupported OS"; \
	fi

python: ## install python
	@echo "Installing Python..."
	if [[ "${UNAME}" == "Darwin" ]]; then \
		brew install python; \
	elif [[ "${ID}" == "ubuntu" ]]; then \
		sudo apt install -y python3; \
	elif [[ "${ID}" == "fedora" ]]; then \
		sudo dnf install -y python3; \
	elif [[ "${ID}" == "arch" ]]; then \
		yes | sudo pacman -S python; \
	else \
		echo "Unsupported OS"; \
	fi

pip: python ## install pip
	@echo "Installing Pip..."
	if [[ "${UNAME}" == "Darwin" ]]; then \
		brew install pip; \
	elif [[ "${ID}" == "ubuntu" ]]; then \
		sudo apt install -y python3-pip; \
	elif [[ "${ID}" == "fedora" ]]; then \
		sudo dnf install -y python3-pip; \
	elif [[ "${ID}" == "arch" ]]; then \
		yes | sudo pacman -S python-pip; \
	else \
		echo "Unsupported OS"; \
	fi

ansible: pip ## install ansible
	@echo "Installing Ansible..."
	if [[ "${UNAME}" == "Darwin" ]]; then \
		brew install ansible ansible-lint; \
	else \
		python3 -m pip install ansible ansible-lint; \
		sudo touch /var/log/ansible.log; \
		sudo chmod 666 /var/log/ansible.log; \
	fi

just: ## install justfile
	@echo "Installing Justfile..."
	if [[ "${UNAME}" == "Darwin" ]]; then \
		brew install just; \
	elif [[ "${ID}" == "ubuntu" ]]; then \
		sudo apt install -y just; \
	elif [[ "${ID}" == "fedora" ]]; then \
		sudo dnf install -y just; \
	elif [[ "${ID}" == "arch" ]]; then \
		yes | sudo pacman -S just; \
	else \
		echo "Unsupported OS"; \
	fi

install: sanity-check xcode homebrew git python pip ansible just  ## install all dependencies

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
