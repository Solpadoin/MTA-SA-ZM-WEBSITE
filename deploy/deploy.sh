#!/usr/bin/env bash
set -Eeuo pipefail

STAGING_DIR="${1:?usage: deploy.sh STAGING_DIR}"
MTA_ROOT="/opt/mta-zombie-rpg"
MTA_RESOURCES="${MTA_ROOT}/mods/deathmatch/resources"
MTA_CONFIG="${MTA_ROOT}/mods/deathmatch/mtaserver.conf"
MTA_ACL="${MTA_ROOT}/mods/deathmatch/acl.xml"
BACKEND_TARGET="/usr/local/bin/mta_status_api.py"
NGINX_SITE="/etc/nginx/sites-available/zm-web-backend"
NGINX_FASTDL_SITE="/etc/nginx/sites-available/zombie-rpg"
BACKUP_ROOT="${MTA_ROOT}/backups"
BACKUP_DIR="${BACKUP_ROOT}/deploy-$(date -u +%Y%m%dT%H%M%SZ)"
RESOURCES=(zombieRPG ZSolp zmrpg_telemetry)

install -d -m 0750 "${BACKUP_DIR}/resources"
cp -a "${MTA_CONFIG}" "${BACKUP_DIR}/mtaserver.conf"
cp -a "${MTA_ACL}" "${BACKUP_DIR}/acl.xml"
cp -a "${NGINX_SITE}" "${BACKUP_DIR}/nginx-zm-web-backend"
cp -a "${NGINX_FASTDL_SITE}" "${BACKUP_DIR}/nginx-zombie-rpg"
if [[ -f "${BACKEND_TARGET}" ]]; then
    cp -a "${BACKEND_TARGET}" "${BACKUP_DIR}/mta_status_api.py"
fi

for resource in "${RESOURCES[@]}"; do
    if [[ -d "${MTA_RESOURCES}/${resource}" ]]; then
        touch "${BACKUP_DIR}/.had-${resource}"
        cp -a "${MTA_RESOURCES}/${resource}" "${BACKUP_DIR}/resources/${resource}"
    fi
done

rollback() {
    local exit_code=$?
    trap - ERR
    echo "Deployment failed; restoring ${BACKUP_DIR}" >&2
    cp -a "${BACKUP_DIR}/mtaserver.conf" "${MTA_CONFIG}"
    cp -a "${BACKUP_DIR}/acl.xml" "${MTA_ACL}"
    cp -a "${BACKUP_DIR}/nginx-zm-web-backend" "${NGINX_SITE}"
    cp -a "${BACKUP_DIR}/nginx-zombie-rpg" "${NGINX_FASTDL_SITE}"
    if [[ -f "${BACKUP_DIR}/mta_status_api.py" ]]; then
        cp -a "${BACKUP_DIR}/mta_status_api.py" "${BACKEND_TARGET}"
    fi
    for resource in "${RESOURCES[@]}"; do
        rm -rf "${MTA_RESOURCES:?}/${resource}"
        if [[ -f "${BACKUP_DIR}/.had-${resource}" ]]; then
            cp -a "${BACKUP_DIR}/resources/${resource}" "${MTA_RESOURCES}/${resource}"
        fi
    done
    nginx -t >/dev/null 2>&1 && systemctl reload nginx || true
    systemctl restart mta-zombie-web-api.service || true
    systemctl restart mta-zombie-rpg.service || true
    exit "${exit_code}"
}
trap rollback ERR

systemctl stop mta-zombie-rpg.service

for resource in "${RESOURCES[@]}"; do
    install -d "${MTA_RESOURCES}/${resource}"
    cp -a "${STAGING_DIR}/server/resources/${resource}/." "${MTA_RESOURCES}/${resource}/"
done

install -m 0755 "${STAGING_DIR}/backend/mta_status_api.py" "${BACKEND_TARGET}"
install -d -o www-data -g www-data -m 0750 /var/lib/mta-zombie-web

python3 "${STAGING_DIR}/deploy/apply_config.py" "${MTA_CONFIG}" "${MTA_ACL}"
python3 "${STAGING_DIR}/deploy/apply_nginx.py" "${NGINX_SITE}" "${NGINX_FASTDL_SITE}"

nginx -t
systemctl restart mta-zombie-web-api.service
systemctl reload nginx
systemctl restart mta-zombie-rpg.service

sleep 4
systemctl is-active --quiet mta-zombie-web-api.service
systemctl is-active --quiet mta-zombie-rpg.service
curl --fail --silent --show-error http://127.0.0.1:18080/health >/dev/null
curl --fail --silent --show-error \
    --header "Host: 141.105.130.229" \
    http://127.0.0.1/mta-download/models/models/m4.dff \
    --output /dev/null

trap - ERR
echo "Deployment complete. Backup: ${BACKUP_DIR}"
