#!/bin/bash

# Title: create_list.sh
# Description: Create individual population list files from a population mapping file,
#              expanding each sample into two haplotype IDs for ELAI analysis.
# Usage: bash create_list.sh <input_population_file.txt>

# --- Configuration ---
set -e

# --- Help function ---
usage() {
    echo "Usage: $0 <input_population_file.txt>"
    echo "  input_population_file.txt: Format - no header, two columns: sample_id  population_name"
    echo "  Output: list/all.list, list/population1.list, list/population2.list, etc."
    exit 1
}

# --- Check input arguments ---
if [ $# -ne 1 ]; then
    echo "Error: Missing input file argument!"
    usage
fi

INPUT_FILE="$1"

# --- Check if input file exists ---
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' does not exist!"
    exit 1
fi

# --- Create output directory ---
OUTPUT_DIR="list"
mkdir -p "$OUTPUT_DIR"
echo "--- Creating list files in directory: $OUTPUT_DIR ---"

# --- Remove old output files if they exist ---
ALL_LIST="$OUTPUT_DIR/all.list"
if [ -f "$ALL_LIST" ]; then
    rm "$ALL_LIST"
    echo "-> Removed old $ALL_LIST"
fi

# --- Process each line ---
echo "-> Processing input file..."

# First, truncate/empty all population files that will be created
# This ensures we don't append to old files
while read -r sample_id pop_name; do
    if [ -z "$sample_id" ] || [ -z "$pop_name" ]; then
        continue
    fi
    POP_LIST="$OUTPUT_DIR/${pop_name}.list"
    > "$POP_LIST"
done < "$INPUT_FILE"

# Now process each line and append
while read -r sample_id pop_name; do
    # Skip empty lines
    if [ -z "$sample_id" ] || [ -z "$pop_name" ]; then
        continue
    fi

    # 1. Add to all.list (one line per sample)
    echo "$sample_id" >> "$ALL_LIST"

    # 2. Add to population-specific list (two haplotypes: sample_1 and sample_2)
    POP_LIST="$OUTPUT_DIR/${pop_name}.list"
    echo "${sample_id}_1" >> "$POP_LIST"
    echo "${sample_id}_2" >> "$POP_LIST"

done < "$INPUT_FILE"

# --- Summary ---
echo "--- Done! ---"
echo "Created:"
echo "  $ALL_LIST  ($(wc -l < "$ALL_LIST") samples)"
for pop_file in "$OUTPUT_DIR"/*.list; do
    if [ "$(basename "$pop_file")" != "all.list" ]; then
        pop_name=$(basename "$pop_file" .list)
        num_lines=$(wc -l < "$pop_file")
        num_samples=$((num_lines / 2))
        echo "  $pop_file  ($num_samples samples, $num_lines haplotypes)"
    fi
done
