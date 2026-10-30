#!/bin/bash

FILE=$1
MODEL=${2:-claude-haiku-4-5-20251001}
TOKEN_LIMIT=${3:-100000}
OUT_BASE=${4:-output/claude_cli_backup}


if [ -z "$FILE" ]; then
  echo "Usage: $0 <links_file> [model] [token_limit] [out_base]"
  echo "  links_file  : text file with one GitHub Actions job URL per line"
  echo "  model       : claude model (default: claude-haiku-4-5-20251001)"
  echo "  token_limit : max total tokens per run, 0=disabled (default: 100000)"
  echo "  out_base    : base output directory (default: output/claude_cli_backup)"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "Error: File '$FILE' not found."
  exit 1
fi

FAILED_LINKS=()

cleanup() {
  local repo_name=$1
  local job_id=$2
  local image_name="${repo_name,,}_${job_id}:latest"
  echo "[CLEANUP] Removing image: $image_name"
  docker rmi -f "$image_name" 2>/dev/null || true
  # Remove any stopped containers that might pin images
  docker ps -a --filter "status=exited" -q | xargs -r docker rm -f 2>/dev/null || true
  # Remove dangling images from failed/intermediate builds
  docker image prune -f 2>/dev/null || true
}

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  LINK=$(echo "$line"   | awk '{print $1}')
  STATUS=$(echo "$line" | awk '{print $2}')
  LANG=$(echo "$line"   | awk '{print $3}')

  REPO_NAME=$(echo "$LINK" | cut -d'/' -f5)
  JOB_ID=$(echo "$LINK"    | cut -d'/' -f10)

  # Support raw URL lines (no status/lang fields)
  if [[ -z "$STATUS" || -z "$LANG" ]]; then
    OUT_DIR="${OUT_BASE}/${REPO_NAME}_${JOB_ID}/out"
  else
    OUT_DIR="${OUT_BASE}/${LANG}/${STATUS}/${REPO_NAME}_${JOB_ID}/out"
  fi

  echo "=================================================="
  echo "Processing : $LINK"
  echo "Repo       : $REPO_NAME"
  echo "Job ID     : $JOB_ID"
  echo "Output     : $OUT_DIR"
  echo "Lang       : $LANG"
  echo "Status     : $STATUS"
  echo "Model      : $MODEL"
  echo "Token limit: $TOKEN_LIMIT"
  echo "=================================================="

  python claude_cli.py \
    "$LINK" \
    --out         "$OUT_DIR" \
    --model       "$MODEL" \
    --token_limit "$TOKEN_LIMIT"

  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    echo "FAILED (exit code $EXIT_CODE): $LINK"
    FAILED_LINKS+=("$LINK")
  fi

  cleanup "$REPO_NAME" "$JOB_ID"
  rm -rf "claude_workdir/${REPO_NAME}_${JOB_ID}/repo" 2>/dev/null || true
  rm -rf $HOME/.cache/pip $HOME/.cache/npm 2>/dev/null || true
  rm -rf $HOME/.docker/buildx/activity/* 2>/dev/null || true
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
