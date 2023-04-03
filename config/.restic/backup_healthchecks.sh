#!/usr/bin/env bash

logged_in_user=$(logname)
logged_in_home=$(eval echo ~$logged_in_user)

# read .env file
export $(grep -v '^#' "${logged_in_home}/.restic/.env" | xargs -d '\n')

"${logged_in_home}/.restic/backup.sh" && curl -fsS -m 10 --retry 5 -o /dev/null "$HEALTHCHECKS_URL"
