#!/usr/bin/env bash
# Run act_runner.py on each build URL in a builds file

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ $# -lt 2 ]]; then
    echo "Usage: bash run_act.sh <builds_file> <output_folder>"
    exit 1
fi
BUILDS_FILE="$1"
LOG_DIR="$2"

if [[ ! -f "${BUILDS_FILE}" ]]; then
    echo "ERROR: builds file not found: ${BUILDS_FILE}"
    exit 1
fi

if ! command -v act &>/dev/null; then
    echo "ERROR: 'act' not found in PATH."
    echo "Install with: curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s -- -b ~/.local/bin"
    exit 1
fi

# Pre-configure act with medium image to avoid interactive prompt on first run
ACT_CONFIG="${HOME}/.config/act/actrc"
if [[ ! -f "${ACT_CONFIG}" ]]; then
    mkdir -p "$(dirname "${ACT_CONFIG}")"
    echo "-P ubuntu-latest=catthehacker/ubuntu:act-latest" > "${ACT_CONFIG}"
    echo "Configured act to use medium image (catthehacker/ubuntu:act-latest)"
fi

mkdir -p "${LOG_DIR}"

total=$(grep -c . "${BUILDS_FILE}" || true)
count=0
failed=0

while IFS= read -r line || [[ -n "${line}" ]]; do
    [[ -z "${line}" || "${line}" == \#* ]] && continue

    url=$(echo "${line}"    | awk '{print $1}')
    status=$(echo "${line}" | awk '{print $2}')
    lang=$(echo "${line}"   | awk '{print $3}')

    # Parse: https://github.com/<owner>/<repo>/actions/runs/<run_id>/job/<job_id>
    repo=$(echo "${url}" | sed -E 's|https://github.com/([^/]+/[^/]+)/actions/.*|\1|')
    job_id=$(echo "${url}" | sed -E 's|.*/job/([0-9]+).*|\1|')

    if [[ "${repo}" == "${url}" || "${job_id}" == "${url}" ]]; then
        echo "[SKIP] Could not parse URL: ${url}"
        continue
    fi

    repo_name="${repo##*/}"
    # act_runner.py now writes directly to <run_dir>/<repo>_<job_id>/out/
    run_dir="${LOG_DIR}/${lang}/${status}"
    mkdir -p "${run_dir}"

    count=$((count + 1))
    echo "[${count}/${total}] repo=${repo} job_id=${job_id}"

    tmp_input=$(mktemp)
    echo "${repo} ${job_id}" > "${tmp_input}"

    python3 "${SCRIPT_DIR}/../act_runner.py" "${tmp_input}" "${run_dir}" \
        && echo "  -> OK" || {
        echo "  -> FAILED"
        failed=$((failed + 1))
    }

    rm -f "${tmp_input}"

    # Remove all act containers (running and stopped), images and volumes to free disk space
    docker ps -a --filter "name=act-" -q | xargs -r docker rm -f 2>/dev/null || true
    docker volume ls -q | grep "^act-" | xargs -r docker volume rm -f 2>/dev/null || true
    docker image prune -f 2>/dev/null || true
    docker rmi -f catthehacker/ubuntu:act-latest 2>/dev/null || true
    rm -rf $HOME/.docker/buildx/activity/* 2>/dev/null || true
    rm -rf $HOME/.cache/act 2>/dev/null || true

    echo "  -> Output: ${run_dir}/${repo_name}_${job_id}/out"

done < "${BUILDS_FILE}"

echo ""
echo "Done: $((count - failed))/${count} succeeded, ${failed} failed."
echo "Logs in: ${LOG_DIR}"
