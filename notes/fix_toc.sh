#!/usr/bin/env bash
#
# process-tex-toc.sh
#
# A combined script to:
# 1. Find unnumbered section commands (\section*, \subsection*, \subsubsection*)
#    in a .tex file and automatically add an \addcontentsline command after them.
# 2. De-duplicate all \addcontentsline entries in the file to clean up repeats.
#
# USAGE:
# ./process-tex-toc.sh
#
# WARNING: This script is not a full LaTeX parser. It assumes that
# your section commands and their titles are on a single line
# and do not contain nested curly braces {}.
#

# --- Safety & Configuration ---
set -euo pipefail

FILE="vulkan_guide.tex"
BACKUP_DIR="bak"

# --- Safety Checks ---

# 1. Check if the file actually exists
if [ ! -f "$FILE" ]; then
    echo "Error: File not found at '$FILE'" >&2
    exit 1
fi

# 2. Check if sed is available
if ! command -v sed &> /dev/null; then
    echo "Error: 'sed' command not found. This script requires sed." >&2
    exit 1
fi

# 3. Check if awk is available
if ! command -v awk &> /dev/null; then
    echo "Error: 'awk' command not found. This script requires awk." >&2
    exit 1
fi

# --- Backup ---
# (Using the more robust backup method from script 2)

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Create timestamped backup inside bak/
timestamp="$(date +%Y%m%dT%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/${FILE}.bak.${timestamp}"
cp -p -- "$FILE" "$BACKUP_FILE"
echo "Backup of original file created at '$BACKUP_FILE'"

# --- Step 1: Add TOC Entries (from script 1) ---

echo "Processing '$FILE' to add TOC entries..."

# Run the 'sed' command to find and replace
# -i = edit file in-place
# -E = use extended regular expressions
sed -i -E \
    -e 's/\\(section\*)\{([^}]+)\}/\\\1{\2}\n\\addcontentsline{toc}{section}{\2}/g' \
    -e 's/\\(subsection\*)\{([^}]+)\}/\\\1{\2}\n\\addcontentsline{toc}{subsection}{\2}/g' \
    -e 's/\\(subsubsection\*)\{([^}]+)\}/\\\1{\2}\n\\addcontentsline{toc}{subsubsection}{\2}/g' \
    "$FILE"

echo "TOC entries added."

# --- Step 2: De-duplicate TOC Entries (from script 2) ---

echo "Running de-duplication on '$FILE'..."

# Run awk from a heredoc (editor-friendly)
# This processes the file modified in Step 1
awk -f - "$FILE" > "$FILE.tmp" <<'AWK'
function trim(s) { gsub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", s); return s }

{
  line = $0
  # match lines that begin with \addcontentsline{toc}{...}{...}
  if (line ~ /^[[:space:]]*\\addcontentsline\{toc\}\{[^}]*\}\{[^}]*\}/) {
    key = line
    gsub(/[ \t]+/, " ", key)
    key = trim(key)

    if (!(key in seen)) {
      seen[key] = 1
      print line
    } else {
      # This is a duplicate, skip printing it
      next
    }
  } else {
    # This is not a toc line, print it normally
    print line
  }
}
AWK

# Atomically replace the old file with the de-duplicated temp file
mv "$FILE.tmp" "$FILE"

echo "Deduplication complete."

# --- Completion ---

echo "Done. '$FILE' has been modified."
echo "Please re-compile your LaTeX document twice to see the updated Table of Contents."
