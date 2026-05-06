#!/bin/bash

# --- Usage ---
usage() {
  echo "Usage: $0 -c CONF -s CONF_SHORT -y YEARS"
  echo "  or:  $0 CONF CONF_SHORT YEAR1 YEAR2 ..."
  echo ""
  echo "  -c  Conference name (e.g. NLP)"
  echo "  -s  Conference short name (e.g. N)"
  echo "  -y  Comma-separated years (e.g. 15,17,23)"
  echo ""
  echo "Examples:"
  echo "  $0 -c NLP -s N -y 15,17,23"
  echo "  $0 NLP N 15 17 23"
  exit 1
}

# --- Parse flags ---
while getopts "c:s:y:" opt; do
  case $opt in
    c) CONF="$OPTARG" ;;
    s) CONF_SHORT="$OPTARG" ;;
    y) IFS=',' read -ra YEARS <<< "$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

# --- Fall back to positional args if flags not used ---
if [[ -z "$CONF" && $# -ge 3 ]]; then
  CONF="$1"
  CONF_SHORT="$2"
  shift 2
  YEARS=("$@")
fi

# --- Validate ---
if [[ -z "$CONF" || -z "$CONF_SHORT" || ${#YEARS[@]} -eq 0 ]]; then
  echo "Error: missing arguments."
  usage
fi

# --- Main logic ---
shopt -s nullglob  # unmatched globs expand to empty, not literal string

for year in "${YEARS[@]}"; do
  dir="20${year}/${CONF}"
  echo "==> Processing year 20${year}..."
  mkdir -p "$dir"

  files=("../MetaDataExtractor/output/20${year}.${CONF}"*)
  if [[ ${#files[@]} -gt 0 ]]; then
    mv -v "${files[@]}" "$dir/"
  else
    echo "    No files matched: 20${year}.${CONF}*"
  fi

  files=("../MetaDataExtractor/output/${CONF_SHORT}${year}"*)
  if [[ ${#files[@]} -gt 0 ]]; then
    mv -v "${files[@]}" "$dir/"
  else
    echo "    No files matched: ${CONF_SHORT}${year}*"
  fi
done