#!/usr/bin/env bash

export BASEDIR="$(cd $(dirname ${BASH_SOURCE[0]}) >/dev/null 2>&1 && pwd)"

TELEGRAM_TOKEN="$1"
TELEGRAM_ID=($2)
SHELL_BOT_API_URL="https://github.com/shellscriptx/shellbot.git"
SHELL_BOT_PATH=${BASEDIR}/shellbot

helper.get_api() {
  echo "[INFO] Providing the API for the bot's project folder"
  ls ${SHELL_BOT_PATH} > /dev/null 2>&1 || git clone ${SHELL_BOT_API_URL} ${SHELL_BOT_PATH} > /dev/null 2>&1
}

bot.cardano_check_latest_version() {
    #it will return 0 if latest version (from releases raw page)
    # is greater than the current version installed in the server
    versions=( \
        "$(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name)" \
        "$(cardano-node --version | awk '{ print $2 }' | head -1)" \
    )
    test "$(echo "${versions[@]}" | tr " " "\n" | sort -V | head -n 1)" != "${versions[0]}"
}