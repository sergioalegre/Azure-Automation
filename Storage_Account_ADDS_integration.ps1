#Basado en https://docs.microsoft.com/es-es/azure/storage/files/storage-files-identity-ad-ds-enable
#Basado en https://www.youtube.com/watch?v=jd49W33DxkQ

# Define parameters, $StorageAccountName currently has a maximum limit of 15 characters
$SubscriptionId = "668*****-****-****-****-********45c2" #ha de ser un numero largo
$ResourceGroupName = "rg-name"
$StorageAccountName = "storage_account_name"
$DomainAccountType = "ComputerAccount" # Default is set as ComputerAccount
# If you don't provide the OU name as an input parameter, the AD identity that represents the storage account is created under the root directory.
$OuDistinguishedName = "OU=AzureFiles,OU=Azure,OU=_it,DC=mydomain,DC=com"
# Specify the encryption agorithm used for Kerberos authentication. Default is configured as "'RC4','AES256'" which supports both 'RC4' and 'AES256' encryption.
$EncryptionType = "AES256,RC4"

cls
cd E:\Scripts\Azure\AzFilesHybrid

# Change the execution policy to unblock importing AzFilesHybrid.psm1 module
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Navigate to where AzFilesHybrid is unzipped and stored and run to copy the files into your path
.\CopyToPSPath.ps1

# Import AzFilesHybrid module
Import-Module -Name AzFilesHybrid


Connect-AzAccount
Select-AzSubscription -SubscriptionId $SubscriptionId

# Register the target storage account with your active directory environment under the target OU (for example: specify the OU with Name as "UserAccounts" or DistinguishedName as "OU=UserAccounts,DC=CONTOSO,DC=COM").
# You can use to this PowerShell cmdlet: Get-ADOrganizationalUnit to find the Name and DistinguishedName of your target OU. If you are using the OU Name, specify it with -OrganizationalUnitName as shown below. If you are using the OU DistinguishedName, you can set it with -OrganizationalUnitDistinguishedName. You can choose to provide one of the two names to specify the target OU.
# You can choose to create the identity that represents the storage account as either a Service Logon Account or Computer Account (default parameter value), depends on the AD permission you have and preference.
# Run Get-Help Join-AzStorageAccountForAuth for more details on this cmdlet.


Join-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -StorageAccountName $StorageAccountName `
        -DomainAccountType $DomainAccountType `
        -OrganizationalUnitDistinguishedName $OuDistinguishedName `
        -EncryptionType $EncryptionType `


#Run the command below if you want to enable AES 256 authentication. If you plan to use RC4, you can skip this step.
#Update-AzStorageAccountAuthForAES256 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName

#You can run the Debug-AzStorageAccountAuth cmdlet to conduct a set of basic checks on your AD configuration with the logged on AD user. This cmdlet is supported on AzFilesHybrid v0.1.2+ version. For more details on the checks performed in this cmdlet, see Azure Files Windows troubleshooting guide.
#Debug-AzStorageAccountAuth -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -Verbose
