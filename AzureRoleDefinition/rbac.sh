#!/bin/bash
# List resource types:
az provider operation show -n "Microsoft.Compute/" --query "resourceTypes[].{displayName:displayName,name:name}"


# Given a resource type, show its operations
az provider operation show -n "Microsoft.Compute" --query "resourceTypes[?name=='virtualMachines'].operations[].{displayName:displayName,name:name}"


# List all role definitions
az role definition list
az role definition list --query "[].{roleName:roleName,description:description}"

#Custom role definitions
#The hard way like the docs do it: 
az role definition list --output json | jq "[?contains(properties.type,'CustomRole')].{id:id,name:name,assignableScopes:join(', ',properties.assignableScopes)}"

#The easier way:
az role definition list --custom-role-only --query "[].{id:id,name:name,assignableScopes:assignableScopes}"
az role definition list --custom-role-only

# Get a specific role definition
az role definition list --name "Virtual Machine Contributor"
# or, using JMESPath query
az role definition list --query "[?roleName == 'Virtual Machine Contributor']"

# List the actions of a role definition
az role definition list --name "Virtual Machine Contributor" --query '[].{"actions":permissions[0].actions, "notActions":permissions[0].notActions}'



# Create role definition
az role definition create --role-definition virtualMachineOperator.json

# List role assignments
az role assignment list --all
az role assignment list --all --assignee kylo@blueskyabove.us

# Create a role assignment for a user
az role assignment create --role "Virtual Machine Operator" --assignee "kylo@blueskyabove.us" --resource-group "AAD-DS"

# Create a role assignment for an application
az role assignment create --role "Virtual Machine Contributor" --assignee-object-id 44444444-4444-4444-4444-444444444444 --resource-group pharma-sales-projectforecast

# Remove access
az role assignment delete --assignee kylo@blueskyabove.us --role "Virtual Machine Operator" --resource-group AAD-DS
