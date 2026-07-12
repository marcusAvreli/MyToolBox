#!/usr/bin/env bash
#manage script located in /usr/local/sbin/tomcat
set -Eeuo pipefail

# ==================================================
# Arguments
# ==================================================

UPLOAD_WAR="${1:-}"
APPLICATION_NAME="${2:-}"
HEALTH_URL="${3:-}"
HEALTH_TIMEOUT="${4:-90}"
BACKUPS_KEEP="${5:-10}"

# ==================================================
# Tomcat configuration
# ==================================================

TOMCAT_HOME="/usr/local/tomcat9"
TOMCAT_WEBAPPS="${TOMCAT_HOME}/webapps"
TOMCAT_SERVICE="tomcat"

BACKUP_ROOT="/var/backups/tomcat9"
BACKUP_DIR="${BACKUP_ROOT}/${APPLICATION_NAME}"

TARGET_WAR="${TOMCAT_WEBAPPS}/${APPLICATION_NAME}.war"
EXPLODED_APP="${TOMCAT_WEBAPPS}/${APPLICATION_NAME}"
TOMCAT_CONTROL="/usr/local/sbin/tomcat"
#SERVICE_COMMAND="/usr/sbin/service"

TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
BACKUP_WAR="${BACKUP_DIR}/${APPLICATION_NAME}-${TIMESTAMP}.war"

HAD_PREVIOUS_WAR="false"
DEPLOYMENT_COMPLETED="false"

# ==================================================
# Logging
# ==================================================

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

fail() {
    log "ERROR: $*"
    exit 1
}

# ==================================================
# Validation
# ==================================================

[[ -n "$UPLOAD_WAR" ]] ||
    fail "Missing uploaded WAR path."

[[ -n "$APPLICATION_NAME" ]] ||
    fail "Missing application name."

[[ -n "$HEALTH_URL" ]] ||
    fail "Missing health URL."

[[ "$APPLICATION_NAME" =~ ^[A-Za-z0-9._-]+$ ]] ||
    fail "Invalid application name: ${APPLICATION_NAME}"

[[ "$HEALTH_TIMEOUT" =~ ^[0-9]+$ ]] ||
    fail "Health timeout must be numeric."

[[ "$BACKUPS_KEEP" =~ ^[0-9]+$ ]] ||
    fail "Backup count must be numeric."

[[ -f "$UPLOAD_WAR" ]] ||
    fail "Uploaded WAR does not exist: ${UPLOAD_WAR}"

[[ -s "$UPLOAD_WAR" ]] ||
    fail "Uploaded WAR is empty: ${UPLOAD_WAR}"

[[ -d "$TOMCAT_WEBAPPS" ]] ||
    fail "Tomcat webapps directory does not exist: ${TOMCAT_WEBAPPS}"

command -v curl >/dev/null 2>&1 ||
    fail "curl is not installed."

# Check that the upload looks like a ZIP/WAR archive
unzip -tq "$UPLOAD_WAR" >/dev/null ||
    fail "Uploaded file is not a valid WAR/ZIP archive."

# ==================================================
# Rollback
# ==================================================

rollback() {
    local exit_code=$?

    if [[ "$DEPLOYMENT_COMPLETED" == "true" ]]; then
        exit "$exit_code"
    fi

    log "Deployment failed. Starting rollback."

    "$TOMCAT_CONTROL" stop >/dev/null 2>&1 || true

    rm -rf "$EXPLODED_APP"
    rm -f "$TARGET_WAR"

    if [[ "$HAD_PREVIOUS_WAR" == "true" && -f "$BACKUP_WAR" ]]; then
        log "Restoring previous WAR from ${BACKUP_WAR}"

        install \
            --owner=root \
            --group=tomcat \
            --mode=0640 \
            "$BACKUP_WAR" \
            "$TARGET_WAR"
    else
        log "No previous WAR was available for rollback."
    fi

    "$TOMCAT_CONTROL" start >/dev/null 2>&1 || true

    rm -f "$UPLOAD_WAR"

    exit "$exit_code"
}

trap rollback ERR INT TERM

# ==================================================
# Deployment
# ==================================================

mkdir -p "$BACKUP_DIR"

chown root:root "$BACKUP_ROOT" "$BACKUP_DIR"
chmod 0750 "$BACKUP_ROOT" "$BACKUP_DIR"

log "Stopping ${TOMCAT_SERVICE}."

"$TOMCAT_CONTROL" stop

if [[ -f "$TARGET_WAR" ]]; then
    HAD_PREVIOUS_WAR="true"

    log "Backing up current WAR to ${BACKUP_WAR}."

    install \
        --owner=root \
        --group=root \
        --mode=0640 \
        "$TARGET_WAR" \
        "$BACKUP_WAR"
fi

# Remove previous exploded deployment to prevent stale files
if [[ -d "$EXPLODED_APP" ]]; then
    log "Removing old exploded application directory."

    rm -rf "$EXPLODED_APP"
fi

log "Installing new WAR as ${TARGET_WAR}."

install \
    --owner=root \
    --group=tomcat \
    --mode=0640 \
    "$UPLOAD_WAR" \
    "$TARGET_WAR"

rm -f "$UPLOAD_WAR"

log "Starting ${TOMCAT_SERVICE}."

"$TOMCAT_CONTROL" start

# ==================================================
# Health verification
# ==================================================

log "Waiting up to ${HEALTH_TIMEOUT} seconds for ${HEALTH_URL}."

deadline=$((SECONDS + HEALTH_TIMEOUT))

while (( SECONDS < deadline )); do
    if curl \
        --fail \
        --silent \
        --show-error \
        --max-time 5 \
        "$HEALTH_URL" \
        >/dev/null 2>&1; then

        DEPLOYMENT_COMPLETED="true"

        log "Application health check succeeded."

        break
    fi

    sleep 2
done

if [[ "$DEPLOYMENT_COMPLETED" != "true" ]]; then
    fail "Application did not become healthy within ${HEALTH_TIMEOUT} seconds."
fi

# ==================================================
# Backup retention
# ==================================================

if (( BACKUPS_KEEP > 0 )); then
    mapfile -t old_backups < <(
        find "$BACKUP_DIR" \
            -maxdepth 1 \
            -type f \
            -name "${APPLICATION_NAME}-*.war" \
            -printf '%T@ %p\n' |
        sort -rn |
        tail -n "+$((BACKUPS_KEEP + 1))" |
        cut -d' ' -f2-
    )

    if (( ${#old_backups[@]} > 0 )); then
        log "Removing ${#old_backups[@]} old backup(s)."
        rm -f -- "${old_backups[@]}"
    fi
fi

trap - ERR INT TERM

log "Deployment completed successfully."
log "Installed WAR: ${TARGET_WAR}"
