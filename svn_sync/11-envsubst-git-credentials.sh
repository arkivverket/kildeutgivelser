#!/bin/sh
# vim:sw=4:ts=4:et

set -e

ME=$(basename $0)

auto_envsubst() {
	local defined_envs
	defined_envs=$(printf '${%s} ' $(env | cut -d= -f1))
	envsubst "$defined_envs" < /credentials.template > ~/.config/git/credentials
}

auto_envsubst

exit 0
