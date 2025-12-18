#!/bin/bash

# Configuration
REGRESSION_RESULTS='resources/location_error_prediction_REGRESSION_20211004_230611_main'
CLASSIFICATION_RESULTS='resources/location_error_prediction_CLASSIFICATION_20211004_230611_main'

# Function to extract metadata from filename
# Pattern: perm_(\d+)_bld_(\d+)_floor_(\d+)_log.txt
get_building_stat() {
    local filepath="$1"
    local filename=$(basename "$filepath")

    # Use sed to extract groups
    # Returns: permutation building floor
    echo "$filename" | sed -E 's/perm_([0-9]+)_bld_([0-9]+)_floor_([0-9]+)_log\.txt/\1 \2 \3/'
}

# Function to process an individual file and output a CSV row
process_file() {
    local txt_path="$1"
    local pdf_path="${txt_path/log.txt/results_summary.pdf}"

    # Extract metadata
    read -r perm bld floor <<< "$(get_building_stat "$txt_path")"

    # Ensure metadata was found
    if [[ -z "$perm" ]]; then return; fi

    # Get file stats (Access, Modify, Change timestamps)
    # Using 'stat' - format varies by OS (Linux/GNU vs macOS/BSD)
    # This version is for Linux (GNU stat)
    if stat --version >/dev/null 2>&1; then
        txt_atime=$(stat -c %X "$txt_path")
        txt_mtime=$(stat -c %Y "$txt_path")
        txt_ctime=$(stat -c %Z "$txt_path")

        if [[ -f "$pdf_path" ]]; then
            pdf_atime=$(stat -c %X "$pdf_path")
            pdf_mtime=$(stat -c %Y "$pdf_path")
            pdf_ctime=$(stat -c %Z "$pdf_path")
        else
            pdf_atime=0; pdf_mtime=0; pdf_ctime=0
        fi
    else
        # Fallback for macOS (BSD stat)
        txt_atime=$(stat -f %a "$txt_path")
        txt_mtime=$(stat -f %m "$txt_path")
        txt_ctime=$(stat -f %c "$txt_path")

        if [[ -f "$pdf_path" ]]; then
            pdf_atime=$(stat -f %a "$pdf_path")
            pdf_mtime=$(stat -f %m "$pdf_path")
            pdf_ctime=$(stat -f %c "$pdf_path")
        else
            pdf_atime=0; pdf_mtime=0; pdf_ctime=0
        fi
    fi

    echo "$perm,$bld,$floor,$txt_ctime,$txt_mtime,$txt_atime,$pdf_ctime,$pdf_mtime,$pdf_atime"
}

# Main recursive function
walk_directory_and_build_stat() {
    local root_dir="$1"
    local output_file="$2"

    # Find all .txt files matching the pattern recursively
    # We use find to avoid the complexity of manual directory walking in Bash
    find "$root_dir" -type f -name "*_log.txt" | while read -r file; do
        process_file "$file" >> "$output_file"
    done
}

build_stat() {
    local root_directory="$1"

    if [[ ! -d "$root_directory" ]]; then
        echo "Directory $root_directory does not exist"
        return 1
    fi

    local csv_path="$root_directory/log_statistic.csv"

    # Write Header
    echo "permutation,building,floor,txt_ctime,txt_mtime,txt_atime,pdf_ctime,pdf_mtime,pdf_atime" > "$csv_path"

    # Walk and append
    walk_directory_and_build_stat "$root_directory" "$csv_path"

    echo "Statistic built at: $csv_path"
}

# Execution
# build_stat "$REGRESSION_RESULTS"
# build_stat "$PREDICTION_RESULTS"

# Example usage for a specific dir passed as argument
if [[ -n "$1" ]]; then
    build_stat "$1"
else
    echo "Please provide a directory path to build stats."
fi
