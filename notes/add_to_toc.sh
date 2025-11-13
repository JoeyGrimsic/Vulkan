#!/bin/bash
#
# add-toc-entries.sh
#
# A simple script to find unnumbered section commands (\section*, \subsection*,
# \subsubsection*) in a .tex file and automatically add an \addcontentsline
# command after them to include them in the Table of Contents.
#
# USAGE:
# ./add-toc-entries.sh your-file.tex
#
# WARNING: This script is not a full LaTeX parser. It assumes that
# your section commands and their titles are on a single line
# and do not contain nested curly braces {}.
#

# --- Safety Checks ---

# 1. Check if a file argument was provided	UPDATE: commented out and hardcode file
# if [ $# -eq 0 ]; then
#     echo "Usage: $0 yourfile.tex"
#     echo "Error: No .tex file specified."
#     exit 1
# fi

FILE="vulkan_guide.tex"
BACKUP_FILE="${FILE}.bak"

# 2. Check if the file actually exists
if [ ! -f "$FILE" ]; then
    echo "Error: File not found at '$FILE'"
    exit 1
fi

# 3. Check if sed is available
if ! command -v sed &> /dev/null; then
    echo "Error: 'sed' command not found. This script requires sed to run."
    exit 1
fi

# --- Script Execution ---

echo "Processing '$FILE'..."

# Create a backup just in case
cp "$FILE" "$BACKUP_FILE"
echo "Backup of original file created at '$BACKUP_FILE'"

# Run the 'sed' command to find and replace
# -i = edit file in-place
# -E = use extended regular expressions
#
# We chain three expressions, one for each section level:
# 1. s/\\(section\*)\{([^}]+)\}/.../g
#    Finds \section*{}
#    \1 captures "section*"
#    \2 captures the title (e.g., "My Title")
#    Replaces it with the original line, a newline (\n),
#    and the \addcontentsline command.
#
sed -i -E \
    -e 's/\\(section\*)\{([^}]+)\}/\\\1{\2}\n\\addcontentsline{toc}{section}{\2}/g' \
    -e 's/\\(subsection\*)\{([^}]+)\}/\\\1{\2}\n\\addcontentsline{toc}{subsection}{\2}/g' \
    -e 's/\\(subsubsection\*)\{([^}]+)\}/\\\1{\2}\n\\addcontentsline{toc}{subsubsection}{\2}/g' \
    "$FILE"

echo "Done. '$FILE' has been modified."
echo "Please re-compile your LaTeX document twice to see the updated Table of Contents."
