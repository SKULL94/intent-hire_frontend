#!/usr/bin/env bash
# Launch the Flutter app with the dart-defines it needs, read from .env.
#
# Usage:
#   ./run.sh                        # flutter run -d chrome
#   ./run.sh --device macos         # desktop
#   ./run.sh --web-port 9000        # web dev server port (default 8787, pinned
#                                   # so the browser keeps your login session)
#   ./run.sh --device emulator-5554 # Android emulator (see note on API_BASE_URL)
#   ./run.sh --release              # release build
#   ./run.sh --build                # `flutter build` instead of `run`
#   ./run.sh --list                 # show available devices and exit
#   ./run.sh --dry-run              # print the flutter command, run nothing
#   ./run.sh -- --verbose           # anything after `--` goes to flutter verbatim
#
# Why this script exists: lib/core/constants/app_constants.dart reads config via
# String.fromEnvironment, which is resolved at COMPILE time. Flutter does not
# read .env on its own (no flutter_dotenv in pubspec.yaml), so a plain
# `flutter run` leaves SUPABASE_URL empty, initSupabase() throws a StateError
# before runApp(), and you get a blank white page with the error only in the
# console.

set -euo pipefail

DEVICE='chrome'
WEB_PORT=8787
RELEASE=0
BUILD=0
LIST=0
DRY_RUN=0
ENV_FILE='.env'
FLUTTER_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --device)   DEVICE="$2";   shift 2 ;;
        --web-port) WEB_PORT="$2"; shift 2 ;;
        --release)  RELEASE=1;     shift ;;
        --build)    BUILD=1;       shift ;;
        --list)     LIST=1;        shift ;;
        --dry-run)  DRY_RUN=1;     shift ;;
        --env-file) ENV_FILE="$2"; shift 2 ;;
        --)         shift; [[ $# -gt 0 ]] && FLUTTER_ARGS+=("$@"); break ;;
        -h|--help)  sed -n '2,16p' "$0"; exit 0 ;;
        *)          echo "unknown option: $1" >&2; exit 1 ;;
    esac
done

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$root"

say()  { printf '\033[36m> %s\033[0m\n' "$*"; }
warn() { printf '\033[33m! %s\033[0m\n' "$*"; }
ok()   { printf '\033[32m+ %s\033[0m\n' "$*"; }
die()  { printf '\033[31mx %s\033[0m\n' "$*"; exit 1; }

# A deliberate whitelist, not "everything in .env". Every dart-define is baked
# into the compiled output; on web that output is JS the browser downloads, so
# anything passed here is readable by anyone opening the page. .env also holds
# backend-only secrets (SUPABASE_SERVICE_KEY, DATABASE_URL, SUPABASE_JWT_SECRET,
# ANTHROPIC_API_KEY, GITHUB_TOKEN) that must never ship in a client build.
# That is why `--dart-define-from-file=.env` is the wrong tool here.
REQUIRED=(SUPABASE_URL SUPABASE_ANON_KEY)
OPTIONAL_KEYS=(API_BASE_URL)
OPTIONAL_DEFAULTS=('http://localhost:8000')

# Parallel arrays — bash 3.2 on macOS has no associative arrays.
ENV_KEYS=()
ENV_VALS=()
DEFINE_KEYS=()
DEFINE_VALS=()

env_get() {
    local key="$1" i
    for i in "${!ENV_KEYS[@]}"; do
        [[ "${ENV_KEYS[$i]}" == "$key" ]] && { printf '%s' "${ENV_VALS[$i]}"; return 0; }
    done
    return 1
}

define_get() {
    local key="$1" i
    for i in "${!DEFINE_KEYS[@]}"; do
        [[ "${DEFINE_KEYS[$i]}" == "$key" ]] && { printf '%s' "${DEFINE_VALS[$i]}"; return 0; }
    done
    return 1
}

load_env() {
    local path="$1" line key value quote rest
    [[ -r "$path" ]] || die "cannot read $path"
    while IFS= read -r line || [[ -n "$line" ]]; do
        # strip CR (handles CRLF files copied from Windows)
        line="${line%$'\r'}"
        # trim leading whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        [[ -z "$line" || "${line:0:1}" == '#' ]] && continue
        [[ "$line" != *=* ]] && continue

        key="${line%%=*}"
        value="${line#*=}"
        # trim whitespace around key, tolerate `export FOO=bar`
        key="${key%"${key##*[![:space:]]}"}"
        [[ "$key" == export\ * ]] && key="${key#export }"
        key="${key#"${key%%[![:space:]]*}"}"

        # trim leading whitespace on value
        value="${value#"${value%%[![:space:]]*}"}"

        if [[ "${value:0:1}" == '"' || "${value:0:1}" == "'" ]]; then
            # Quoted. Take only what's between the quotes: a '#' inside is data,
            # anything after the closing quote is a comment.
            quote="${value:0:1}"
            rest="${value:1}"
            if [[ "$rest" == *"$quote"* ]]; then
                value="${rest%%${quote}*}"
            else
                # Unbalanced opening quote: drop it, keep the rest literally.
                value="$rest"
                value="${value%"${value##*[![:space:]]}"}"
            fi
        else
            # Unquoted: ' # ...' is a trailing comment.
            value="${value%% #*}"
            value="${value%"${value##*[![:space:]]}"}"
        fi

        ENV_KEYS+=("$key")
        ENV_VALS+=("$value")
    done < "$path"
}

# Show enough to confirm the right value loaded, not enough to leak it.
mask() {
    local v="$1"
    if [[ "${#v}" -le 24 ]]; then
        printf '%s' "$v"
    else
        printf '%s... (%d chars)' "${v:0:18}" "${#v}"
    fi
}

# --- preflight ---
command -v flutter >/dev/null 2>&1 || die 'flutter is not on PATH.'

if [[ "$LIST" -eq 1 ]]; then
    exec flutter devices
fi

if [[ "$ENV_FILE" = /* ]]; then
    env_path="$ENV_FILE"
else
    env_path="$root/$ENV_FILE"
fi
[[ -f "$env_path" ]] || die "No env file at $env_path. Copy .env from the backend repo, or pass --env-file <path>."

load_env "$env_path"

missing=()
for k in "${REQUIRED[@]}"; do
    v="$(env_get "$k" || true)"
    [[ -z "$v" ]] && missing+=("$k")
done
if [[ "${#missing[@]}" -gt 0 ]]; then
    die "$ENV_FILE is missing a value for: ${missing[*]}"
fi

for k in "${REQUIRED[@]}"; do
    DEFINE_KEYS+=("$k")
    DEFINE_VALS+=("$(env_get "$k")")
done
for i in "${!OPTIONAL_KEYS[@]}"; do
    k="${OPTIONAL_KEYS[$i]}"
    default="${OPTIONAL_DEFAULTS[$i]}"
    if v="$(env_get "$k")" && [[ -n "$v" ]]; then
        DEFINE_KEYS+=("$k")
        DEFINE_VALS+=("$v")
    else
        DEFINE_KEYS+=("$k")
        DEFINE_VALS+=("$default")
        warn "$k not set in $ENV_FILE - defaulting to $default"
    fi
done

say "Config from $ENV_FILE"
for i in "${!DEFINE_KEYS[@]}"; do
    printf '    %-18s %s\n' "${DEFINE_KEYS[$i]}" "$(mask "${DEFINE_VALS[$i]}")"
done

api_base="$(define_get API_BASE_URL)"
web_devices=(chrome edge web-server)
host_devices=(chrome edge web-server windows macos linux)

is_local_api=0
if [[ "$api_base" =~ ^https?://(localhost|127\.0\.0\.1|\[::1\]) ]]; then
    is_local_api=1
fi
is_host_device=0
for d in "${host_devices[@]}"; do [[ "$d" == "$DEVICE" ]] && is_host_device=1; done
is_web_device=0
for d in "${web_devices[@]}";  do [[ "$d" == "$DEVICE" ]] && is_web_device=1; done

# A localhost backend is unreachable from an Android/iOS device: there,
# localhost is the device itself. The ngrok tunnel in the backend repo is what
# that case wants.
if [[ "$is_local_api" -eq 1 && "$is_host_device" -eq 0 ]]; then
    warn "API_BASE_URL is $api_base but you are targeting '$DEVICE'."
    warn 'On a device/emulator localhost is the device itself - point it at the ngrok URL.'
fi

# If the API is local, say up front whether it's actually answering, so an
# empty matches list is not mistaken for "no matches".
if [[ "$is_local_api" -eq 1 ]]; then
    if curl -sf -m 3 "$api_base/health" >/dev/null 2>&1; then
        ok "Backend is up at $api_base"
    else
        warn "Backend is not answering at $api_base/health."
        warn 'Start it with:  ../hiresignal_backend/restart.sh --detach'
    fi
fi

if [[ "$RELEASE" -eq 1 && "$is_web_device" -eq 1 ]]; then
    warn 'Release web build: these defines end up readable in the shipped JS.'
fi

# --- assemble the flutter command ---
cmd=()
if [[ "$BUILD" -eq 1 ]]; then
    # `flutter build` takes a target platform, not a device id.
    target="$DEVICE"
    [[ "$is_web_device" -eq 1 ]] && target='web'
    cmd+=(build "$target")
    what="build $target"
else
    cmd+=(run -d "$DEVICE")
    what="run -d $DEVICE"
fi

# Pin the web port. Without it flutter picks a random one each launch, and the
# browser keys localStorage by origin (scheme+host+PORT) — a new port is a new
# origin with empty storage, which is why the Supabase session is gone every
# run. A fixed port keeps the session (and anything else stored locally).
if [[ "$BUILD" -eq 0 && "$is_web_device" -eq 1 ]]; then
    cmd+=("--web-port=$WEB_PORT")
fi
[[ "$RELEASE" -eq 1 ]] && cmd+=(--release)
for i in "${!DEFINE_KEYS[@]}"; do
    cmd+=("--dart-define=${DEFINE_KEYS[$i]}=${DEFINE_VALS[$i]}")
done
if [[ "${#FLUTTER_ARGS[@]}" -gt 0 ]]; then
    cmd+=("${FLUTTER_ARGS[@]}")
fi

say "flutter $what  (+ ${#DEFINE_KEYS[@]} dart-defines)"

if [[ "$DRY_RUN" -eq 1 ]]; then
    # Values masked: this output tends to end up pasted into chats.
    for arg in "${cmd[@]}"; do
        if [[ "$arg" == --dart-define=* ]]; then
            pair="${arg#--dart-define=}"
            printf '    --dart-define=%s=%s\n' "${pair%%=*}" "$(mask "${pair#*=}")"
        else
            printf '    %s\n' "$arg"
        fi
    done
    ok 'Dry run - nothing launched.'
    exit 0
fi

[[ "$BUILD" -eq 0 ]] && say "Press 'r' to hot reload, 'q' to quit"
exec flutter "${cmd[@]}"
