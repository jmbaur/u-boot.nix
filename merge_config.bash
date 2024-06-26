# shellcheck shell=bash

set -o errexit
set -o nounset
set -o pipefail

base_config=$1
extra_config=$2
mutable_config=$(mktemp)

# start with the base config
cp "$base_config" "$mutable_config"

truncate --size=0 .config

while read -r line; do
	# shellcheck disable=SC2001
	option=$(sed "s/^.*\(CONFIG_[A-Z0-9_]\+\)[=\ ].*$/\1/" <<<"$line")

	if grep --silent "${option}[=\ ]" "$mutable_config"; then
		echo "deleting ${option} from base config"
		sed -i "/${option}[=\ ]/d" "$mutable_config"
	fi

	echo "$line" >>.config
done <"$extra_config"

# use the rest of what is left from the base config
cat "$mutable_config" >>.config
