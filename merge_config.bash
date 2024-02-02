# shellcheck shell=bash

base_config=$1
extra_config=$2
final_config=$(pwd)/.config

# start with the base config
cp "$base_config" "$final_config"

while read -r line; do
	# shellcheck disable=SC2001
	option=$(sed "s/^.*\(CONFIG_[A-Z0-9_]\+\)[=\ ].*$/\1/" <<<"$line")

	if line_nr=$(grep -n "$option" "$final_config" | cut -f1 -d:); then
		sed "${line_nr}d" "$final_config"
		echo "$line" >>"$final_config"
	fi
done <"$extra_config"
