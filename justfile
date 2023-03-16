# https://just.systems/man/en

# load .env
set dotenv-load

# positional params
set positional-arguments

# set env var
export APP		    := `echo ${APP_NAME:-"cloud-conf"}`
export CONF		    := `echo ${CONF:-"cloud-init.yml"}`
export CWD          := `echo ${CWD:-"$(pwd)"}`
export CPU		    := `echo ${CPU:-"4"}`
export DISK		    := `echo ${DISK:-"5G"}`
export DOCKERFILE   := `echo ${DOCKERFILE:-"Dockerfile.redis"}`
export DRIVER       := `echo ${DRIVER:-"qemu"}`
export FILENAME	    := `echo ${FILENAME:-"cloud-init.yml"}`
export IMAGE        := `echo ${IMAGE:-"redis:7.0.9-bullseye"}`
export MEM		    := `echo ${MEM:-"4G"}`
export PLAY         := `echo ${PLAY:-"hardening.yml"}`
export SHELL        := "/bin/bash"
export TAG		    := `echo ${TAG:-"latest"}`
export VERSION      := `echo ${VERSION:-"latest"}`
export VM		    := `echo ${VM:-"testvm"}`

# x86_64/arm64
arch := `uname -m`

# # hostname
# host := `uname -n`

# # operating system
# os := `uname -s`

# # home directory
# home_dir := env_var('HOME')

# docker-compose / docker compose
# * https://docs.docker.com/compose/install/linux/#install-using-the-repository
docker-compose := if `command -v docker-compose; echo $?` == "0" {
	"docker-compose"
} else {
	"docker compose"
}

# [halp]     list available commands
default:
	just --list

# [deps]     update dependencies
update-deps args=CWD:
	#!/usr/bin/env bash
	# set -euxo pipefail
	args=$(realpath {{args}})
	find "${args}" -maxdepth 3 -name "pyproject.toml" -exec \
		echo "[{}]" \; -exec \
		echo "Clearing pypi cache..." \; -exec \
		poetry --directory "${args}" cache clear --all pypi --no-ansi \; -exec \
		poetry --directory "${args}" update --lock --no-ansi \;

# [deps]     export requirements.txt
export-reqs args=CWD: update-deps
	#!/usr/bin/env bash
	# set -euxo pipefail
	args=$(realpath {{args}})
	find "${args}" -maxdepth 3 -name "pyproject.toml" -exec \
		echo "[{}]" \; -exec \
		echo "Exporting requirements.txt..." \; -exec \
		poetry --directory "${args}" export --no-ansi --without-hashes --output requirements.txt \;

# [git]      update pre-commit hooks
pre-commit:
    @echo "To install pre-commit hooks:"
    @echo "pre-commit install -f"
    @echo "Updating pre-commit hooks..."
    pre-commit autoupdate

# [multi]    list multipass instances
list:
	multipass list

# [multi]    multipass instance info
info:
    multipass info --format yaml {{VM}}

# TODO: QA
# [multi]    multipass vm driver
driver:
    # multipass set local.passphrase
    # multipass authenticate
    multipass set local.driver={{DRIVER}}
    multipass get local.driver

# [multi]    launch multipass instance
launch:
	multipass launch -n {{VM}} \
	--cpus {{CPU}} \
	--memory {{MEM}} \
	--disk {{DISK}} \
	--cloud-init {{CONF}} \
	-v

# [multi]    start multipass instance
start: launch
	multipass start {{VM}}

# [multi]    shell into multipass instance
shell:
	multipass shell {{VM}}

# [multi]    stop multipass instance
stop-vm:
	multipass stop {{VM}}

# [multi]    delete multipass instance
delete: stop-vm
	multipass delete {{VM}}

# [multi]    purge multipass instance
purge: delete
	multipass purge

# [ansible]  run ansible playbook
ansible: start
	#!/usr/bin/env bash
	# set -euxo pipefail
	multipass exec {{VM}} -- \
	cd /home/ubuntu/git/ansible-role-hardening/tasks \
	&& ansible-playbook hardening.yml -i /etc/ansible/hosts

# [check]    validate cloud-init.yaml
check-ci args=FILENAME:
	#!/usr/bin/env bash
	# set -euxo pipefail
	docker run --rm -it \
	--name {{APP}} \
	-h ${HOST:-localhost} \
	-v $(pwd):/app \
	-w="/app" \
	{{APP}} \
	devel schema --config-file {{args}}

# [check]    validate instance-data.json
check-id args='/run/cloud-init/instance-data.json':
	#!/usr/bin/env bash
	# set -euxo pipefail
	docker run --rm -it \
	--name {{APP}} \
	-h ${HOST:-localhost} \
	-v $(pwd):/app \
	-v $(pwd)/cloud-init:/run/cloud-init \
	-v $(pwd)/instance:/var/lib/cloud/instance \
	-w="/app" \
	{{APP}} \
	query --list-keys {{args}}

# [docker]   build locally
build app=APP fn=DOCKERFILE:
	#!/usr/bin/env bash
	set -euxo pipefail
	if [[ {{arch}} == "arm64" ]]; then
		docker build -f {{fn}} -t {{app}} --build-arg CHIPSET_ARCH=aarch64-linux-gnu .
	else
		docker build -f {{fn}} --progress=plain -t {{app}} .
	fi

# [docker]   run container
run args=APP: build down
	#!/usr/bin/env bash
	# set -euxo pipefail
	docker run --rm -it \
		--name {{args}} \
		--entrypoint={{SHELL}} \
		-h ${HOST:-localhost} \
		-v $(pwd)/redis.conf:/data/redis.conf:rw \
		-p ${PORT:-6379}:${PORT:-6379/tcp} \
		{{args}}

# [docker]   login to registry (exit code 127 == 0)
login:
	#!/usr/bin/env bash
	# set -euxo pipefail
	echo "Log into ${REGISTRY_URL} as ${USER_NAME}. Please enter your password: "
	cmd=$(docker login --username ${USER_NAME} ${REGISTRY_URL})
	if [[ $("$cmd" >/dev/null 2>&1; echo $?) -ne 127 ]]; then
		echo 'Not logged into Docker. Exiting...'
		exit 1
	fi

# [docker]   tag image as latest
tag-latest:
	docker tag {{APP}}:latest {{IMAGE}}/{{APP}}:latest

# [docker]   tag latest image from VERSION file
tag-version:
	@echo "create tag {{APP}}:{{VERSION}} {{IMAGE}}/{{APP}}:{{VERSION}}"
	docker tag {{APP}} {{IMAGE}}/{{APP}}:{{VERSION}}

# [docker]   push latest image
push: login
	docker push {{IMAGE}}/{{APP}}:{{TAG}}

# [docker]   pull latest image
pull: login
	docker pull {{IMAGE}}/{{APP}}

# [docker]   start docker-compose container
up: build
	{{docker-compose}} up -d

# [docker]   get running container logs
logs:
	{{docker-compose}} logs -tf --tail="50" {{APP}}

# [docker]   ssh into container
exec:
	docker exec -it {{APP}} {{SHELL}}

# [docker]   stop docker-compose container
stop:
	{{docker-compose}} stop

# [docker]   remove docker-compose container(s) and networks
down: stop
	{{docker-compose}} down --remove-orphans
