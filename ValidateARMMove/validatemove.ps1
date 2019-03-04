function Get-AzureRmCachedAccessToken([Microsoft.Azure.Commands.Profile.Models.PSAzureContext]$context)
{
  $ErrorActionPreference = 'Stop'
  
  if(-not (Get-Module AzureRm.Profile)) {
    Import-Module AzureRm.Profile
  }  
  $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
  $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
  Write-Debug ("Getting access token for tenant" + $context.Subscription.TenantId)
  $token = $profileClient.AcquireAccessToken($context.Subscription.TenantId)
  $token.AccessToken
}

$sourceResourceGroupName="Cloud-AADDS"
$targetResourceGroupName="Operations"

$context = Get-AzureRmContext

$subscriptionId = $context.Subscription
$targetResourceGroupId="/subscriptions/$subscriptionId/resourceGroups/$targetResourceGroupName"

$resourceIds = Get-AzureRmResource -ResourceGroupName $sourceResourceGroupName | Select -Property ResourceId
$request = ""
foreach($resourceId in $resourceIds)
{    
    $request += "`"" + $resourceId.ResourceId + "`","
}
$request = $request.Remove($request.Length -1, 1)

$token=Get-AzureRmCachedAccessToken $context

$body="{`"resources`": [$request],`"targetResourceGroup`":`"$targetResourceGroupId`"}"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "bearer $token")

$endpoint="https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$sourceResourceGroupName/validateMoveResources?api-version=2018-05-01"

Invoke-RestMethod $endpoint -Method Post -Headers $headers -Body $body -ContentType "application/json"
