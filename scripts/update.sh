#!/bin/bash
set -euo pipefail

mkdir -p .local
LOCKFILE=.local/update.lock

if [[ -f "${LOCKFILE}" ]] && kill -0 "$(cat "${LOCKFILE}" || true)" 2>/dev/null; then
	echo Still running
	exit 1
fi

echo $$ > "${LOCKFILE}"

git pull --rebase

git_commit_message() {
	local all_changed_files
	all_changed_files=$(git status --porcelain)

	local num_files
	num_files=$(echo "${all_changed_files}" | wc -l)

	local non_c_files
	non_c_files=$(echo "${all_changed_files}" | grep -v "^.. c/")

	local file_list
	file_list=$(echo "${non_c_files}" | awk '{print $2}' | xargs -r -n1 basename | sed '{:q;N;s/\n/, /g;t q}')

	echo "${num_files} files${file_list:+ | ${file_list}}"
}

SECRETS_FILE=.local/secrets.json
SECRETS=$(cat ${SECRETS_FILE})
EMAIL=$(echo ${SECRETS} | jq -r '.email')
PASSWORD=$(echo ${SECRETS} | jq -r '.password')
DOCKER_LOGIN=$(echo ${SECRETS} | jq -r '.docker_login')
DOCKER_TOKEN=$(echo ${SECRETS} | jq -r '.docker_token')

PREHOOK_FILE=.local/pre.sh
POSTHOOK_FILE=.local/post.sh

if [[ -f "${PREHOOK_FILE}" ]]; then
	bash ${PREHOOK_FILE}
fi

echo ${DOCKER_TOKEN} | docker login ghcr.io -u ${DOCKER_LOGIN} --password-stdin
docker pull ghcr.io/carlsmei/tarkovdata-deployer:latest
docker run -it --rm -v .:/app/data ghcr.io/carlsmei/tarkovdata-deployer:latest -e ${EMAIL} -p ${PASSWORD} -o data -c data/.cache

node scripts/remove.js

if [[ -f "${POSTHOOK_FILE}" ]]; then
	bash ${POSTHOOK_FILE}
fi

KEY_FILE=.cache/metadata_key.txt
KEY=$(cat ${KEY_FILE})

# Decrypt metadata file
# docker run -it --rm -v .:/app/data ghcr.io/carlsmei/tarkovdata-deployer:latest dm -i data/.cache/global-metadata.dat -o data/global-metadata.decrypted.dat -k ${KEY}

git add -A
MESSAGE=$(git_commit_message)
git commit -a -m "${MESSAGE}" || true
git push

# Thanks to xPaw
# Original: https://github.com/SteamDatabase/SteamTracking
