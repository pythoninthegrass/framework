#!/usr/bin/env bash

# SOURCES:
# https://ask.fedoraproject.org/t/recommendations-for-desktop-backup-application/22064/4
# https://fedoramagazine.org/automate-backups-with-restic-and-systemd/

logged_in_user=$(logname)
logged_in_home=$(eval echo ~$logged_in_user)

# read .env file
export $(grep -v '^#' "${logged_in_home}/.restic/.env" | xargs -d '\n')

# read comma separated paths from .env file
IFS=',' read -ra BACKUP_PATHS <<< "$BACKUP_PATHS"
# printf "%s\n" "${BACKUP_PATHS[@]}"

# stop docker containers (exclude `valheim-server`)
stop_containers() {
	cont=$(docker ps -aq)
	for i in $cont; do
	if [[ "$i" != "f253d2561405" ]]; then
		docker stop "$i"
	fi
	done
}

# run backup
restic_backup() {
	restic backup --force --verbose --one-file-system --tag systemd.timer $BACKUP_EXCLUDES $BACKUP_PATHS
}

# maintenance
restic_maintenance() {
	restic forget --verbose --tag systemd.timer --group-by "paths,tags" --keep-daily $RETENTION_DAYS --keep-weekly $RETENTION_WEEKS --keep-monthly $RETENTION_MONTHS --keep-yearly $RETENTION_YEARS
}

# restore (manual) (i.e., `cp /docker/containers /`)
# restic -r $RESTIC_REPOSITORY restore latest --target /

# start docker containers
start_containers() {
	docker start $(docker ps -aq)
}

main() {
	# stop_containers
	restic_backup
	restic_maintenance
	# start_containers
}
main
