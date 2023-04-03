#!/usr/bin/env bash

cat << 'DESCRIPTION' >/dev/null
Deletes snapshots that no longer exist in the repository
or are damaged.

Sample standard error:
	could not load snapshot aab6a324: load <snapshot/aab6a3240f>: invalid data returned
DESCRIPTION

# Set $IFS to eliminate whitespace in pathnames
IFS="$(printf '\n\t')"

logged_in_user=$(logname)
logged_in_home=$(eval echo ~$logged_in_user)

# read .env file
export $(grep -v '^#' "${logged_in_home}/.restic/.env" | xargs -d '\n')

out=($(restic snapshots 2>&1 >/dev/null | awk '{print $5}' | tr -d ':'))

if [[ -z "$out" ]]; then
	echo "no snapshots to remove"
	exit 0
fi

snaps_dir="${RESTIC_REPOSITORY}/snapshots"

for i in "${out[@]}"; do
	if [[ -f $(ls "$snaps_dir/$i"*) ]]; then
		echo "snapshot $i exists"
		rm -rf "${snaps_dir}/${i:?}"*
	else
		echo "snapshot $i does not exist"
	fi
done
