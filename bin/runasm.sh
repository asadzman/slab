#!/bin/zsh

set -e

SLAB="$HOME/dev/ju/slab"
DOSBOX_CONF="$SLAB/dosbox.conf"

if [[ $# -ne 1 ]]; then
    echo "Usage: runasm <file.asm>"
    exit 1
fi

FILE="$(realpath "$1")"

if [[ ! -f "$FILE" ]]; then
    echo "Error: file does not exist: $FILE"
    exit 1
fi

if [[ "$FILE" != "$SLAB/"* ]]; then
    echo "Error: file must be inside $SLAB"
    exit 1
fi

# Path relative to the mounted C: drive
REL="${FILE#$SLAB/}"

# DOS path
DOSFILE="${REL//\//\\}"

# Directory containing the source file
DOSDIR="${DOSFILE%\\*}"

# Filename only
FILENAME="${DOSFILE##*\\}"

# Remove .asm extension
EXENAME="${FILENAME%.[Aa][Ss][Mm]}.EXE"

# If the file is in the root of C:
if [[ "$DOSDIR" == "$DOSFILE" ]]; then
    DOSDIR="C:\\"
else
    DOSDIR="C:\\$DOSDIR"
fi

dosbox-x \
    -conf "$DOSBOX_CONF" \
    -c "cd $DOSDIR" \
    -c "ml $FILENAME" \
    -c "$EXENAME"
