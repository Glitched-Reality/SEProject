#!/bin/sh
set -eu

case "${1:-install}" in
    install|update|start|stop|status) action=${1:-install} ;;
    --update) action=update ;;
    *) printf 'Usage: sh app/install.sh [install|update|start|stop|status]\n' >&2; exit 1 ;;
esac

if [ "$#" -gt 1 ]; then
    printf 'Usage: sh app/install.sh [install|update|start|stop|status]\n' >&2
    exit 1
fi

cd "$(dirname "$0")"
app_dir=$(pwd -P)
pid_file=storage/logs/dev-server.pid
log_file=storage/logs/dev-server.log

server_running() {
    [ -f "$pid_file" ] || return 1
    server_pid=$(sed -n '1p' "$pid_file")
    server_start=$(sed -n '2p' "$pid_file")
    case "$server_pid" in ''|*[!0-9]*) return 1 ;; esac
    [ -n "$server_start" ] || return 1
    current_start=$(ps -p "$server_pid" -o lstart= 2>/dev/null) || return 1
    [ "$current_start" = "$server_start" ] || return 1
    server_args=$(ps -p "$server_pid" -o args= 2>/dev/null) || return 1
    printf '%s\n' "$server_args" | grep -F -- "-S 127.0.0.1:8000 -t $app_dir/public" >/dev/null
}

case "$action" in
    status)
        if server_running; then
            printf 'Development server is running at http://127.0.0.1:8000 (PID %s).\n' "$server_pid"
        else
            printf 'Development server is not running.\n'
            exit 1
        fi
        exit 0 ;;
    stop)
        if server_running; then
            kill "$server_pid"
            rm -f "$pid_file"
            printf 'Development server stopped.\n'
        else
            printf 'No managed development server is running.\n'
        fi
        exit 0 ;;
    start)
        if server_running; then
            printf 'Development server is already running at http://127.0.0.1:8000 (PID %s).\n' "$server_pid"
            exit 0
        fi
        if ! command -v php >/dev/null 2>&1; then
            printf 'php was not found. Install PHP 8.2 or newer and ensure it is on PATH.\n' >&2
            exit 1
        fi
        if [ ! -f vendor/autoload.php ] || [ ! -f .env ]; then
            printf 'Install the application first with sh app/install.sh install.\n' >&2
            exit 1
        fi
        mkdir -p storage/logs
        nohup php -S 127.0.0.1:8000 -t "$app_dir/public" >"$log_file" 2>&1 </dev/null &
        server_pid=$!
        server_start=$(ps -p "$server_pid" -o lstart= 2>/dev/null) || {
            printf 'Server could not start. Check %s.\n' "$log_file" >&2
            exit 1
        }
        printf '%s\n%s\n' "$server_pid" "$server_start" >"$pid_file"
        printf 'Development server launched at http://127.0.0.1:8000. Check %s if it fails to start.\n' "$log_file"
        exit 0 ;;
esac

for command in php composer; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf '%s was not found. Install PHP 8.2 or newer and Composer, then ensure both are on PATH.\n' "$command" >&2
        exit 1
    fi
done

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

composer "$action" --no-interaction --prefer-dist

if [ -z "$app_key" ]; then
    php artisan key:generate --no-interaction
fi

printf 'Setup complete. Configure the database in app/.env if needed, then run sh app/install.sh start.\n'