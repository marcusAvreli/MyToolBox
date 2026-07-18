#!/usr/bin/env bash
# Deployment script: /usr/local/sbin/deploy-tomcat9-war.sh
# Tomcat control script: /usr/local/sbin/tomcat
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
# Last successfully deployed WAR, stored outside webapps
CURRENT_WAR="${BACKUP_DIR}/${APPLICATION_NAME}-current.war"

# Timestamped backup of the previous successful WAR
BACKUP_WAR="${BACKUP_DIR}/${APPLICATION_NAME}-${TIMESTAMP}.war"

# Temporary candidate retained until health verification succeeds
CANDIDATE_WAR="${BACKUP_DIR}/.${APPLICATION_NAME}-${TIMESTAMP}.candidate.war"

# Temporary extraction directory
STAGING_APP="${TOMCAT_WEBAPPS}/.${APPLICATION_NAME}.deploy.$$"

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
# Application extraction
# ==================================================

extract_application() {
    local war_file="$1"
    local destination="$2"

    log "Extracting ${war_file} into staging directory ${STAGING_APP}."

    [[ -f "$war_file" ]] ||
        fail "WAR file does not exist: ${war_file}"

    rm -rf "$STAGING_APP"

    install \
        --directory \
        --owner=root \
        --group=tomcat \
        --mode=0750 \
        "$STAGING_APP"

    unzip -q "$war_file" -d "$STAGING_APP"

    chown -R root:tomcat "$STAGING_APP"

    find "$STAGING_APP" \
        -type d \
        -exec chmod 0750 {} \;

    find "$STAGING_APP" \
        -type f \
        -exec chmod 0640 {} \;

    # Tomcat is stopped, so replacing the directory is safe
    rm -rf "$destination"
    mv "$STAGING_APP" "$destination"

    log "Application extracted successfully into ${destination}."
}

# ==================================================
# Validation
# ==================================================
command -v curl >/dev/null 2>&1 ||
    fail "curl is not installed."

command -v unzip >/dev/null 2>&1 ||
    fail "unzip is not installed."
	
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



trap rollback ERR INT TERM

rollback() {
    local exit_code=$?

    # Prevent rollback failures from triggering rollback recursively
    trap - ERR INT TERM

    if [[ "$DEPLOYMENT_COMPLETED" == "true" ]]; then
        exit "$exit_code"
    fi

    log "Deployment failed. Starting rollback."

    "$TOMCAT_CONTROL" stop >/dev/null 2>&1 || true

    rm -rf "$STAGING_APP"
    rm -rf "$EXPLODED_APP"
    rm -f "$TARGET_WAR"
    rm -f "$CANDIDATE_WAR"
    rm -f "$UPLOAD_WAR"

    if [[ -f "$CURRENT_WAR" ]]; then
        log "Restoring previous application from ${CURRENT_WAR}."

        if extract_application "$CURRENT_WAR" "$EXPLODED_APP"; then
            "$TOMCAT_CONTROL" start >/dev/null 2>&1 || true
            log "Previous application restored."
        else
            log "ERROR: Rollback extraction failed."
        fi
    else
        log "No previous successful WAR exists for rollback."
    fi

    log "Rollback finished."

    exit "$exit_code"
}


# ==================================================
# Deployment
# ==================================================

mkdir -p "$BACKUP_DIR"

chown root:root "$BACKUP_ROOT" "$BACKUP_DIR"
chmod 0750 "$BACKUP_ROOT" "$BACKUP_DIR"

trap rollback ERR INT TERM

log "Stopping ${TOMCAT_SERVICE}."

if "$TOMCAT_CONTROL" status >/dev/null 2>&1; then
    "$TOMCAT_CONTROL" stop
else
    log "Tomcat is already stopped."
fi

# Support migration from the previous deployment model where
# the WAR was retained inside webapps.
if [[ ! -f "$CURRENT_WAR" && -f "$TARGET_WAR" ]]; then
    log "Saving existing webapps WAR as the current rollback artifact."

    install \
        --owner=root \
        --group=root \
        --mode=0640 \
        "$TARGET_WAR" \
        "$CURRENT_WAR"
fi

if [[ -f "$CURRENT_WAR" ]]; then
    HAD_PREVIOUS_WAR="true"
fi

log "Installing uploaded WAR temporarily as ${TARGET_WAR}."

install \
    --owner=root \
    --group=tomcat \
    --mode=0640 \
    "$UPLOAD_WAR" \
    "$TARGET_WAR"

# Retain the candidate outside webapps until verification succeeds
install \
    --owner=root \
    --group=root \
    --mode=0640 \
    "$TARGET_WAR" \
    "$CANDIDATE_WAR"

# Manually expand because unpackWARs=false
extract_application "$TARGET_WAR" "$EXPLODED_APP"

# WAR is no longer required inside webapps
log "Removing WAR from Tomcat webapps after extraction."

rm -f "$TARGET_WAR"
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

      log "Application health check succeeded."

# Archive the previous successful release
if [[ -f "$CURRENT_WAR" ]]; then
    install \
        --owner=root \
        --group=root \
        --mode=0640 \
        "$CURRENT_WAR" \
        "$BACKUP_WAR"
fi

# Promote the new candidate as the current successful release
install \
    --owner=root \
    --group=root \
    --mode=0640 \
    "$CANDIDATE_WAR" \
    "$CURRENT_WAR"

rm -f "$CANDIDATE_WAR"

DEPLOYMENT_COMPLETED="true"
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
log "Exploded application: ${EXPLODED_APP}"
log "Rollback WAR: ${CURRENT_WAR}"