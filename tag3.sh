#!/bin/bash

# --- Configuration ---

# Define the list of resource groups you want to target.
# Add or remove resource group names as needed.
RESOURCE_GROUP_NAMES=(
    "ResourceGroupA"
    "MyProdRG"
    "Test_RG_01"
    "AnotherResourceGroupWithSpaces InName" # Example: if your RG name has spaces
)

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

echo "Starting tag application to resources across multiple resource groups."
echo "Tags to apply: ${ADDITIONAL_TAGS[@]}"
echo "Target Resource Groups: ${RESOURCE_GROUP_NAMES[@]}"
echo "----------------------------------------------------"

# Outer loop: Iterate through each resource group in the list
for rg_name in "${RESOURCE_GROUP_NAMES[@]}"; do
    echo ""
    echo "--- Processing Resource Group: $rg_name ---"

    # Get all resource IDs in the current resource group
    # Using '2>/dev/null' to suppress stderr if RG doesn't exist or no resources
    resource_ids=$(az resource list --resource-group "$rg_name" --query "[].id" --output tsv 2>/dev/null)

    # Check if any resources were found or if the resource group exists
    if [ -z "$resource_ids" ]; then
        # Check if the resource group itself exists
        if ! az group show --name "$rg_name" --output none &>/dev/null; then
            echo "Resource Group '$rg_name' does not exist or you don't have permissions."
        else
            echo "No resources found in resource group '$rg_name'."
        fi
        echo "Skipping this resource group."
        continue # Move to the next resource group
    fi

    # Inner loop: Loop through each resource within the current resource group and apply the tags
    for resource_id in $resource_ids; do
        echo "  Processing resource: $resource_id"
        az tag update \
            --resource-id "$resource_id" \
            --operation Merge \
            --tags "${ADDITIONAL_TAGS[@]}"
        if [ $? -eq 0 ]; then
            echo "  Successfully updated tags for $resource_id"
        else
            echo "  Failed to update tags for $resource_id"
        fi
    done

    echo "--- Finished processing Resource Group: $rg_name ---"
done

echo ""
echo "Tagging operation completed for all specified resource groups."
