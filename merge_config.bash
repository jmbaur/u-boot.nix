# shellcheck shell=bash

base_config=$1
extra_config=$2
mutable_config=$(mktemp)

# start with the base config
cp "$base_config" "$mutable_config"

while read -r line; do
	# shellcheck disable=SC2001
	option=$(sed "s/^.*\(CONFIG_[A-Z0-9_]\+\)[=\ ].*$/\1/" <<<"$line")

	if line_nr=$(grep -n "$option" "$mutable_config" | cut -f1 -d:); then
		sed "${line_nr}d" "$mutable_config"
		echo "$line"
	fi
done <"$extra_config"

# use the rest of what is left from the base config
cat "$mutable_config"
