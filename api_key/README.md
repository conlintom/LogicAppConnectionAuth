# LogicAppConnectionAuth
PowerShell Script to provide the API key to a Logic App connector.

## What this script does

This script will provide the API Key Logic Apps connectors that require authentication using an API Key. This can be used after deployment of a Logic App with connectors that require API Key authentication. 

## How to use

Run this script and substitute out parameters as needed:

| Name | Description |
| --- | --- |
| ResourceGroupName | Name of the resource group for the connection |
| ResourceLocation | Location of the resource group |
| api | The name of the api to generate a connection for |
| ConnectionName | Name of the connection resource to create or generate authorization for |
| SubscriptionId | Azure Subscription ID to use for connection creation/authorization |
| createConnection | set to `false` if the connection was already deployed |
| useVault | set to `false` if secrets will be passed to the script via arguments |

This script can also be run as post deployment as a task of an Pipeline in Azure DevOps. In this case, it is recommended to store secrets in Azure KeyVault and access these secrets via a Variable Group. Provide secrets to the release tasks in the Parameters section. 
