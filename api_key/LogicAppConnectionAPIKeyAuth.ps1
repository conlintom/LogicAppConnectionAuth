Param(
    [string] $resourceGroupName = '',
    [string] $resourceLocation = '',
    [string] $vaultName = '',
    [string] $secretName = '', 
    [string] $api = 'serverless360',
    [string] $connectionName = 'serverless360',
    [string] $apiKey = '',
    [string] $parameterName = 'api_key',
    [string] $servicePrincipalId = '',
    [string] $tenantId = '',
    [string] $servicePrincipalSecret = '',
    [string] $subscriptionId = '',
    [bool] $createConnection =  $false,
    [bool] $useVault = $false
)

# The follow variables need to be passed to the Powershell script in order to authenticate using a service principal
# servicePrincipalId - Application (client) Id for the Service Principal
# tenantId - Directory (tenant) ID
# servicePrincipalSecret - Secret for authenticating using the service principal

# The following variables need to be passed to the Powershell script:
# subscriptionId
# resourceLocation
# resourceGroupName
# apiKey
# api - if not serverless360
# connectionName - if not serverless360

# If the subscription Id isn't provided, exit 
If ($subscriptionId -eq '') {
    Write-Host "A required value was not provided, please provide all required values and try again..."
    Write-Host "Required Values: subcriptionId, resourceLocation, resourceGroupName, and apiKey. Note api and connetionName default to serverless360 - override as needed"
    exit
}

$sub = Get-AzSubscription -SubscriptionId $subscriptionId

#select the subscription
$subscription = Select-AzSubscription -SubscriptionId $sub.Id

#if the connection wasn't alrady created via a deployment
if ($createConnection)
{
    Write-Host "Doesn't Exist"
    $connection = New-AzResource -Properties @{"api" = @{"id" = "subscriptions/" + $sub.Id + "/providers/Microsoft.Web/locations/" + $resourceLocation + "/managedApis/" + $api}; "displayName" = $connectionName; } -ResourceName $connectionName -ResourceType "Microsoft.Web/connections" -ResourceGroupName $resourceGroupName -Location $resourceLocation -Force
}
#else (meaning the conneciton was created via a deployment) - get the connection
else {
    Write-Host "Exists"
    $connection = Get-AzResource -ResourceType "Microsoft.Web/connections" -ResourceGroupName $resourceGroupName -ResourceName $connectionName
}

# Get Connection Properties
$connectionProps = $connection.Properties

# Get Connection Parameter Values
$connectionParamVals = $connectionProps.parameterValues 

# Check if we should use the key vault or if we will get the value from command line args
# API key is set in the commandline otherwise 

if ($useVault) {
    # Get API Key from Key Vault
    $apiKey = Get-AzureKeyVaultSecret -VaultName $vaultName -Name $name
}
elseif ($apikey -eq '') {
    # API Key wasn't provided
    Write-Host 'API Key was not provided...'
    exit
}
else {
    Write-Host 'API Key not provided...'
    exit
}

# Add the API Key to the connection parameters
Add-Member -InputObject $connectionParamVals -Name 'api_key' -Value $apiKey.SecretValueText -MemberType NoteProperty

Write-Host "Connection properties: " $connectionProps

Set-AzResource -ResourceId $connection.ResourceId -Properties $connectionProps -Force

# Retrieve the connection
$connection = Get-AzResource -ResourceType "Microsoft.Web/connections" -ResourceGroupName $ResourceGroupName -ResourceName $ConnectionName

Write-Host "connection status now: " $connection.Properties.Statuses[0]