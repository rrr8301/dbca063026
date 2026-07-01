#!/bin/bash

FILE=$1
MODEL=${2:-gpt-4o}
TOKEN_LIMIT=${3:-100000}
OUT_BASE=${4:-output/appserver_backup}
# Hard cost ceiling per run (USD). Kept low because the project has a fixed cost
# budget; override with the 5th arg if a repo needs more to finish its tests.
COST_LIMIT=${5:-1.0}

# Allow "none"/"off"/"unlimited"/"disabled" as aliases for no token limit (0).
case "${TOKEN_LIMIT,,}" in
  none|off|unlimited|disabled|no) TOKEN_LIMIT=0 ;;
esac

# Normalize common model-name typos (e.g. the "gpt4o" folder label) to valid
# OpenAI model ids so they don't reach the API and trigger model_not_found.
case "${MODEL,,}" in
  gpt4o)    MODEL="gpt-4o" ;;
  gpt4omini|gpt-4o-mini) MODEL="gpt-4o-mini" ;;
esac

if [ -z "$FILE" ]; then
  echo "Usage: $0 <links_file> [model] [token_limit] [out_base] [cost_limit]"
  echo "  links_file  : text file with one GitHub Actions job URL per line"
  echo "  model       : codex model (default: gpt-4o)"
  echo "  token_limit : max total tokens per run (default: 150000)"
  echo "                use 0 / none / off / unlimited to run with no limit"
  echo "  out_base    : base output directory (default: output/appserver_backup)"
  echo "  cost_limit  : max API cost in USD per run (default: 1.0)"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "Error: File '$FILE' not found."
  exit 1
fi

FAILED_LINKS=()

# Avoid shell snapshot syntax errors from nvm bash functions
unset NVM_DIR
unset -f nvm 2>/dev/null || true

cleanup() {
  local repo_name=$1
  local job_id=$2
  local image_name="${repo_name,,}_${job_id}:latest"
  echo "[CLEANUP] Removing image: $image_name"
  docker rmi "$image_name" 2>/dev/null || true
}

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  LINK=$(echo "$line"   | awk '{print $1}')
  STATUS=$(echo "$line" | awk '{print $2}')
  LANG=$(echo "$line"   | awk '{print $3}')

  REPO_NAME=$(echo "$LINK" | cut -d'/' -f5)
  JOB_ID=$(echo "$LINK"    | cut -d'/' -f10)
  OUT_DIR="${OUT_BASE}/${LANG}/${STATUS}/${REPO_NAME}_${JOB_ID}/out"

  echo "=================================================="
  echo "Processing : $LINK"
  echo "Repo       : $REPO_NAME"
  echo "Job ID     : $JOB_ID"
  echo "Output     : $OUT_DIR"
  echo "Lang       : $LANG"
  echo "Status     : $STATUS"
  echo "Model      : $MODEL"
  echo "Token limit: $([ "$TOKEN_LIMIT" -eq 0 ] && echo "disabled" || echo "$TOKEN_LIMIT")"
  echo "Cost limit : \$$COST_LIMIT"
  echo "=================================================="

  # Kill any leftover codex processes to avoid SQLite DB lock
  pkill -f "codex app-server" 2>/dev/null || true
  sleep 1

  python codex_appserver_cli.py \
    "$LINK" \
    --out         "$OUT_DIR" \
    --model       "$MODEL" \
    --token_limit "$TOKEN_LIMIT" \
    --cost_limit  "$COST_LIMIT"

  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    echo "FAILED (exit code $EXIT_CODE): $LINK"
    FAILED_LINKS+=("$LINK")
  fi

  cleanup "$REPO_NAME" "$JOB_ID"
  echo ""

done < "$FILE"

if [ ${#FAILED_LINKS[@]} -gt 0 ]; then
  echo ""
  echo "=== FAILED LINKS (${#FAILED_LINKS[@]}) ==="
  for L in "${FAILED_LINKS[@]}"; do
    echo "  $L"
  done
  exit 1
fi
