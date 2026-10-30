#!/bin/bash

FILE=$1
MODEL=$2
OUTPUT=${3:-output}

if [ -z "$FILE" ] || [ -z "$MODEL" ]; then
  echo "Usage: $0 <links_file> <model> [output_folder]"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "Error: File '$FILE' not found."
  exit 1
fi

FAILED_LINKS=()

while IFS= read -r LINE; do
  # skip empty lines or commented lines
  [[ -z "$LINE" || "$LINE" =~ ^# ]] && continue

  LINK=$(echo "$LINE"   | awk '{print $1}')
  STATUS=$(echo "$LINE" | awk '{print $2}')
  LANG=$(echo "$LINE"   | awk '{print $3}')

  # Build output folder: <base>/<lang>/<status> — pipeline appends model name inside
  OUT_DIR="${OUTPUT}/${LANG}/${STATUS}"

  echo "Processing link: $LINK [$LANG/$STATUS] -> $OUT_DIR"

  python llm4build-pipeline.py --task historical_build --link "$LINK" --output_folder "$OUT_DIR" --model "$MODEL"
  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    echo "FAILED (exit code $EXIT_CODE): $LINK"
    FAILED_LINKS+=("$LINK")
  fi

  # Clean up stale repo clone between runs
  REPO_NAME=$(echo "$LINK" | cut -d'/' -f5)
  docker images --format "{{.Repository}}:{{.Tag}}" | grep "^${REPO_NAME,,}_" | xargs -r docker rmi -f 2>/dev/null || true
  docker image prune -f
  rm -rf "project_path/$REPO_NAME"
  rm -rf $HOME/.cache/pip $HOME/.cache/npm 2>/dev/null || true
  rm -rf $HOME/.docker/buildx/activity/* 2>/dev/null || true
  rm -rf $HOME/.cache/act 2>/dev/null || true

  echo "---------------------------------------------------"
done < "$FILE"

if [ ${#FAILED_LINKS[@]} -gt 0 ]; then
  echo ""
  echo "=== FAILED LINKS (${#FAILED_LINKS[@]}) ==="
  for L in "${FAILED_LINKS[@]}"; do
    echo "  $L"
  done
  exit 1
fi