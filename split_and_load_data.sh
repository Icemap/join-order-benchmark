#!/bin/bash
set -e

# Configuration
MYSQL_HOST=${MYSQL_HOST:-127.0.0.1}
MYSQL_PORT=${MYSQL_PORT:-4000}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PSWD=${MYSQL_PSWD:-}
DB_NAME=imdbload
CHUNK_SIZE=100000  # Number of lines per chunk
MAX_FILE_SIZE_MB=50  # Maximum file size in MB before splitting

# Common MySQL arguments
COMMON_ARGS=(--protocol tcp -h"${MYSQL_HOST}" --port "${MYSQL_PORT}" -u"${MYSQL_USER}")
if [ -n "${MYSQL_PSWD}" ]; then
  COMMON_ARGS+=( -p"${MYSQL_PSWD}" )
fi

# Function to get file size in MB
get_file_size_mb() {
    local file="$1"
    if [ -f "$file" ]; then
        echo $(($(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null) / 1024 / 1024))
    else
        echo 0
    fi
}

# Function to split large CSV files
split_large_file() {
    local csv_file="$1"
    local base_name="${csv_file%.*}"
    local file_size_mb=$(get_file_size_mb "$csv_file")
    
    echo "Processing $csv_file (${file_size_mb}MB)"
    
    if [ "$file_size_mb" -gt "$MAX_FILE_SIZE_MB" ]; then
        echo "File is large (${file_size_mb}MB), splitting into chunks..."
        
        # Create chunks directory
        local chunks_dir="${base_name}_chunks"
        mkdir -p "$chunks_dir"
        
        # Split file into chunks
        local chunk_num=1
        local temp_file="${chunks_dir}/temp_chunk_${chunk_num}.csv"
        
        # Copy header to first chunk
        head -n 1 "$csv_file" > "$temp_file"
        
        # Split remaining lines
        tail -n +2 "$csv_file" | split -l "$CHUNK_SIZE" - "${chunks_dir}/chunk_"
        
        # Rename chunks and add headers
        local chunk_count=0
        for chunk_file in "${chunks_dir}"/chunk_*; do
            chunk_count=$((chunk_count + 1))
            local final_chunk="${chunks_dir}/chunk_${chunk_count}.csv"
            
            # Add header to chunk
            head -n 1 "$csv_file" > "$final_chunk"
            cat "$chunk_file" >> "$final_chunk"
            rm "$chunk_file"
            
            echo "Created chunk: $final_chunk"
        done
        
        echo "Split $csv_file into $chunk_count chunks"
    else
        echo "File is small enough, no splitting needed"
    fi
}

# Function to load data from a single file
load_single_file() {
    local csv_file="$1"
    local table_name="$2"
    
    echo "Loading $csv_file into table $table_name..."
    
    local sql="LOAD DATA LOCAL INFILE '$csv_file' INTO TABLE $table_name FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"';"
    
    # Try loading with retry mechanism
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if mysql --local-infile=1 "${COMMON_ARGS[@]}" -D "$DB_NAME" -e "$sql" 2>/dev/null; then
            echo "Successfully loaded $csv_file"
            return 0
        else
            retry_count=$((retry_count + 1))
            echo "Failed to load $csv_file (attempt $retry_count/$max_retries)"
            sleep 5
        fi
    done
    
    echo "Failed to load $csv_file after $max_retries attempts"
    return 1
}

# Function to load all data
load_all_data() {
    local CURDIR=$(cd `dirname $0`; pwd)
    local csv_dir="$CURDIR/csv_files"
    local failed_files=()
    
    # Process each CSV file
    for csv_file in "$csv_dir"/*.csv; do
        if [ ! -f "$csv_file" ]; then
            continue
        fi
        
        local base_name=$(basename "$csv_file")
        local table_name="${base_name%.*}"
        local file_size_mb=$(get_file_size_mb "$csv_file")
        
        echo "=== Processing $base_name (${file_size_mb}MB) ==="
        
        if [ "$file_size_mb" -gt "$MAX_FILE_SIZE_MB" ]; then
            # Handle large files
            local chunks_dir="${csv_file%.*}_chunks"
            
            if [ ! -d "$chunks_dir" ]; then
                echo "Splitting $csv_file..."
                split_large_file "$csv_file"
            fi
            
            # Load chunks
            local chunk_count=0
            for chunk_file in "$chunks_dir"/chunk_*.csv; do
                if [ -f "$chunk_file" ]; then
                    chunk_count=$((chunk_count + 1))
                    echo "Loading chunk $chunk_count: $chunk_file"
                    
                    if ! load_single_file "$chunk_file" "$table_name"; then
                        failed_files+=("$chunk_file")
                    fi
                fi
            done
            
            echo "Completed loading $chunk_count chunks for $table_name"
        else
            # Handle small files
            if ! load_single_file "$csv_file" "$table_name"; then
                failed_files+=("$csv_file")
            fi
        fi
        
        echo ""
    done
    
    # Report failed files
    if [ ${#failed_files[@]} -gt 0 ]; then
        echo "Failed to load the following files:"
        for file in "${failed_files[@]}"; do
            echo "  - $file"
        done
        return 1
    else
        echo "All files loaded successfully!"
        return 0
    fi
}

# Main execution
main() {
    echo "=== IMDB Data Loading Script ==="
    echo "Chunk size: $CHUNK_SIZE lines"
    echo "Max file size before splitting: ${MAX_FILE_SIZE_MB}MB"
    echo "Database: $DB_NAME"
    echo "Host: $MYSQL_HOST:$MYSQL_PORT"
    echo ""
    
    # Drop and recreate database
    echo "Dropping existing database..."
    mysql "${COMMON_ARGS[@]}" -e "DROP DATABASE IF EXISTS $DB_NAME;" 2>/dev/null || true
    
    echo "Creating database and schema..."
    mysql "${COMMON_ARGS[@]}" < schema-tidb.sql
    
    echo "Loading data..."
    if load_all_data; then
        echo "=== Data loading completed successfully! ==="
    else
        echo "=== Data loading completed with errors ==="
        exit 1
    fi
}

# Run main function
main "$@"
