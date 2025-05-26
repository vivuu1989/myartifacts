#!/bin/bash

# --- Configuration ---
RESOURCE_GROUP_NAME="YourResourceGroupName" # Replace with your resource group name

# Define tags as an array.
# Each element in the array should be a "Key=Value" string.
# If a Key or Value has spaces, enclose that specific element in double quotes.
ADDITIONAL_TAGS=(
    "Environment=Production"
    "Project=MyApplication"
    "Cost Center=Sales Department" # Example with a space in the key
    "Team Lead=\"John Doe\""      # Example with a space in the value, requiring internal quotes
    "Status=Active"
)

# --- Script ---

echo "Applying tags to all resources in resource group: $RESOURCE_GROUP_NAME"

# Get all resource IDs in the specified resource group
resource_ids=$(az resource list --resource-group "$RESOURCE_GROUP_NAME" --query "[].id" --output tsv)

# Check if any resources were found
if [ -z "$resource_ids" ]; then
    echo "No resources found in resource group '$RESOURCE_GROUP_NAME'."
    exit 0
fi

# Loop through each resource and apply the tags
for resource_id in $resource_ids; do
    echo "Processing resource: $resource_id"
    az tag update \
        --resource-id "$resource_id" \
        --operation Merge \
        --tags "${ADDITIONAL_TAGS[@]}" # Correctly passes all array elements as separate arguments
    if [ $? -eq 0 ]; then
        echo "Successfully updated tags for $resource_id"
    else
        echo "Failed to update tags for $resource_id"
    fi
done

echo "Tagging operation completed."
