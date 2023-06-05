[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $resourceGroupName,
    [Parameter()]
    [string]
    $storageAccountName,
    [Parameter()]
    [string]
    $containerName,
    [Parameter()]
    [int]
    $maximumTerraformPlanFiles = 3,
    [Parameter()]
    [string]
    $getTerraformModules = $false
)

try {
    Write-Host "Retrieving all blobs from storage container.."
    $storageAcc=Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName     
    ## Get the storage account context  
    $ctx=$storageAcc.Context  
    ## Get all the containers  
    $containers=Get-AzStorageContainer  -Context $ctx         
    ## Get all the blobs  
    $livePlans = Get-AzStorageBlob -Container $containerName  -Context $ctx  -Prefix "terraform-live" | sort @{expression="LastModified";Descending=$true}
    if($livePlans.Length -gt $maximumTerraformPlanFiles){
        Remove-AzStorageBlob -Container $containerName -Blob $livePlans[$livePlans.Length - 1].Name -Context $ctx 
    }
    if($getTerraformModules){
        $modulePlans = Get-AzStorageBlob -Container $containerName  -Context $ctx  -Prefix "terraform-modules" | sort @{expression="LastModified";Descending=$true}
        if($modulePlans.Length -gt $maximumTerraformPlanFiles){
            Remove-AzStorageBlob -Container $containerName -Blob $modulePlans[$modulePlans.Length - 1].Name -Context $ctx 
        }
    }
}
catch {
    Write-Host "An error occurred"
}