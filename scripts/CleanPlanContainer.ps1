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

function AuditContainer {
    param (
        [Parameter()]
        [string]
        $prefix
    )
    $storageAcc=Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
    ## Get the storage account context  
    $ctx=$storageAcc.Context
    ## Get all the containers  
    $containers=Get-AzStorageContainer -Context $ctx
    ## Get all the blobs  
    $blobs = Get-AzStorageBlob -Container $containerName  -Context $ctx  -Prefix $prefix | sort @{expression="LastModified";Descending=$true}
    if($blobs.Length -gt $maximumTerraformPlanFiles){
        $checkDiff = $blobs.Length - $maximumTerraformPlanFiles
        if($checkDiff -gt 1){
            foreach($blob in $blobs[$maximumTerraformPlanFiles..($blobs.Length - 1)]){
                Write-Output "Removing $($blob.Name)"
                Remove-AzStorageBlob -Container $containerName -Blob $blob.Name -Context $ctx
            }
        }
    }
    return "Cleaned $prefix"
}

try {
    Write-Host "Retrieving all blobs from storage container.."
    AuditContainer -prefix "terraform-live"
    if($getTerraformModules){
        AuditContainer -prefix "terraform-modules"
    }
}
catch {
    Write-Host "An error occurred"
}