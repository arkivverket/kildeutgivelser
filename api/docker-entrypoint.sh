#!/bin/sh
# vim:sw=4:ts=4:et

set -e

if [ "$1" = "uwsgi" ]; then
    if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null; then
        find "/docker-entrypoint.d/" -follow -type f -print | sort -n | while read -r f; do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        "$f"
                    fi
                    ;;
            esac
        done
    fi
fi

exec "$@"
