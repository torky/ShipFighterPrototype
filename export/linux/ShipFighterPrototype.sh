#!/bin/sh
echo -ne '\033c\033]0;ShipFighterPrototype\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/ShipFighterPrototype.x86_64" "$@"
