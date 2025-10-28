param (
    [string]$Subscription,
    [string]$Location = "eastus2",
    [switch]$DeployVpnGateway,
    [switch]$DeployOnlineEndpoints
)


# Variables
$projectName = "foundry"
$environmentName = "demo"
$templateFile = "infra/main.bicep"
$deploymentName = "foundrydeploy-$Location"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"


$targetAutoDeletionTime = (Get-Date).ToUniversalTime().AddDays(7).ToString("R")

# Clear account context and configure Azure CLI settings
az account clear
az config set core.enable_broker_on_windows=false
az config set core.login_experience_v2=off

# Login to Azure
az login 
az account set --subscription $Subscription

if ($DeployVpnGateway.IsPresent) {
    Set-Location -Path .\scripts

    # Create Gateway Cert
    Write-Host "*****************************************"
    Write-Host "Create VPN Gateway Cert"
    Write-Host "If timeout occurs, rerun the following command from scripts:"
    Write-Host ".\generate_certs.ps1 "
    $rootCertData = & .\generate_certs.ps1

    Set-Location -Path ..
}

# Start the deployment
$deploymentOutput = az deployment sub create `
    --name $deploymentName `
    --location $Location `
    --template-file $templateFile `
    --parameters `
        environmentName=$environmentName `
        projectName=$projectName `
        location=$Location `
        deployVpnGateway=$($DeployVpnGateway.IsPresent) `
        deployOnlineEndpoints=$($DeployOnlineEndpoints.IsPresent) `
        rootCertData="$rootCertData" `
        timestamp=$timestamp `
        targetAutoDeletionTime=$targetAutoDeletionTime `
    --query "properties.outputs"


# Parse the deployment output to get app names and resource group
$deploymentOutputJson = $deploymentOutput | ConvertFrom-Json
$resourceGroupName = $deploymentOutputJson.resourceGroupName.value


Write-Host "Deployment Complete"