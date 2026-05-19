#!/bin/bash
# Script to sign .efi files inside a local directory

# Set target directory (default is "EFI" if not provided)
TARGET_DIR=${1:-"EFI"}

# Check if the directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' not found. Please ensure it is in the current path."
    exit 1
fi

# Check for signing keys
if [ -f "./ISK.key" ]; then
    echo "Found ISK.key"
else
    echo "Error: ISK.key not found in the current directory!"
    exit 1
fi

if [ -f "./ISK.pem" ]; then
    echo "Found ISK.pem"
else
    echo "Error: ISK.pem not found in the current directory!"
    exit 1
fi

echo "Searching for .efi files inside '$TARGET_DIR' and signing them..."

# Find .efi files, sign them, and save in the Signed directory keeping the original structure
find "$TARGET_DIR" -type f -name "*.efi" ! -name '.*' | while read -r efi_file; do
    # Clean path from any leading ./ to avoid duplication
    clean_path=$(echo "$efi_file" | sed 's|^./||')
    
    # Set the path for the new signed file
    out_file="./Signed/$clean_path"
    
    # Create necessary subdirectories inside the Signed folder
    mkdir -p "$(dirname "$out_file")"
    
    # Sign the file
    sbsign --key ISK.key --cert ISK.pem --output "$out_file" "$efi_file"
    
    echo "Signed: $clean_path"
done

echo "Process completed successfully! Signed files are located in the './Signed' directory."
