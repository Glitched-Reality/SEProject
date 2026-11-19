#!/bin/sh
set -eu

case "${1:-}" in
    '') composer_command=install ;;
    --update) composer_command=update ;;
    *) printf 'Usage: sh app/install.sh [--update]\n' >&2; exit 1 ;;
esac

if [ "$#" -gt 1 ]; then
    printf 'Usage: sh app/install.sh [--update]\n' >&2
    exit 1
fi

for command in php composer; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf '%s was not found. Install PHP 8.2 or newer and Composer, then ensure both are on PATH.\n' "$command" >&2
        exit 1
    fi
done

cd "$(dirname "$0")"

if [ ! -f .env ]; then
    cp .env.example .env
    printf 'Created .env from .env.example.\n'
fi

if ! grep -q '^[[:space:]]*APP_KEY[[:space:]]*=' .env; then
    printf 'APP_KEY is missing from .env. Add an empty APP_KEY= line and rerun the script.\n' >&2
    exit 1
fi

app_key=$(sed -n '/^[[:space:]]*APP_KEY[[:space:]]*=/ { s/^[[:space:]]*APP_KEY[[:space:]]*=[[:space:]]*//; s/[[:space:]]*$//; p; q; }' .env)
case "$app_key" in
    '""'|"''") app_key= ;;
esac

composer "$composer_command" --no-interaction --prefer-dist

if [ -z "$app_key" ]; then
    php artisan key:generate --no-interaction
fi

printf 'Setup complete. Configure the database in app/.env if needed, then run php artisan serve from the app directory.\n'