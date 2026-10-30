#!/usr/bin/env bash
# Run actions-remaker-dev on each build URL in a builds file

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"
if [[ $# -lt 2 ]]; then
    echo "Usage: bash run_remaker.sh <builds_file> <output_folder>"
    exit 1
fi
BUILDS_FILE="$1"
LOG_DIR="$2"
REMAKER_DIR="${PROJECT_DIR}/actions-remaker-dev"
VENV="${REMAKER_DIR}/venv/bin/activate"

if [[ ! -f "${VENV}" ]]; then
    echo "ERROR: venv not found at ${REMAKER_DIR}/venv — run: python3.8 -m venv ${REMAKER_DIR}/venv && source it && pip install -e ."
    exit 1
fi

if [[ ! -f "${BUILDS_FILE}" ]]; then
    echo "ERROR: builds file not found: ${BUILDS_FILE}"
    exit 1
fi

source "${VENV}"
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

    owner="${repo%%/*}"
    repo_name="${repo##*/}"
    out_dir="${LOG_DIR}/${lang}/${status}/${repo_name}_${job_id}/out"
    mkdir -p "${out_dir}"

    count=$((count + 1))
    echo "[${count}/${total}] repo=${repo} job_id=${job_id}"

    (
        cd "${REMAKER_DIR}"
        bash run.sh -r "${repo}" -j "${job_id}"
    ) && echo "  -> OK" || {
        echo "  -> FAILED"
        failed=$((failed + 1))
    }

    # Copy output files from reproducer
    output_base="${REMAKER_DIR}/reproducer/output/tasks/task/${owner}/${repo_name}"
    dockerfile=$(find "${output_base}" -name "${job_id}-Dockerfile" 2>/dev/null | head -1)
    runsh=$(find "${output_base}" -path "*/${job_id}/run.sh" 2>/dev/null | head -1)
    repolog=$(find "${output_base}" -name "${job_id}.log" 2>/dev/null | head -1)
    [[ -n "${dockerfile}" ]] && cp "${dockerfile}" "${out_dir}/${job_id}-Dockerfile"
    [[ -n "${runsh}" ]]      && cp "${runsh}"      "${out_dir}/run.sh"
    [[ -n "${repolog}" ]]    && cp "${repolog}"    "${out_dir}/log.txt" || touch "${out_dir}/log.txt"

    orig_log="${REMAKER_DIR}/reproducer/intermediates/orig_logs/${job_id}-orig.log"
    [[ -f "${orig_log}" ]] && cp "${orig_log}" "${out_dir}/${repo_name}-${job_id}.log"

    echo "  -> Output: ${out_dir}"

    rm -rf \
        "${REMAKER_DIR}/intermediates/tmp/${owner}-${repo_name}" \
        "${REMAKER_DIR}/reproducer/intermediates/project_repos/${owner}/${repo_name}" \
        "${REMAKER_DIR}/reproducer/intermediates/workspace/${job_id}" \
        "${REMAKER_DIR}/reproducer/output/"*

    docker rmi "job_id:${job_id}" 2>/dev/null || true

done < "${BUILDS_FILE}"

echo ""
echo "Done: $((count - failed))/${count} succeeded, ${failed} failed."
echo "Logs in: ${LOG_DIR}"
