#!/bin/bash

BASE_DIR="."

# Loop through all subdirectories
for dir in "$BASE_DIR"/*; do
  if [ -d "$dir" ] && ls "$dir"/*.tf > /dev/null 2>&1; then
    echo "Destroying Terraform resources in $dir..."
    cd "$dir"
    
    terraform init -input=false
    terraform destroy -auto-approve

    cd - > /dev/null
  fi
done
