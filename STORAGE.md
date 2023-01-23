[#AZCopy](#AZCopy)

[#Blobs](#Blobs)

[#Network](#Network)


------------

### AZCopy
  - Download a blob to PC:
      ```    
      C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy>azcopy /source:https://<NOMBRE_STORAGE_ACCOUNT>.blob.core.windows.net/<NOMBRE_BLOB> /dest:c:\blobs_recuperados /sourcekey:<AQUI_LA_KEY>

      ```
  - Copy Azure Files Share to Azure Blob (at AzureCLI):
      - get both source & destination URL
      - create both SAS tokens for source & Destination
      - modifi: stDeOrigen, nombreShare, ?svXXX%3D (token origen), stDestino, containerDestino, ?svYYY%3D (token Destino)
      - at AzureCLI run:
      ```    
      azcopy cp 'https://stDeOrigen.file.core.windows.net/nombreShare?svXXX%3D' 'https://stDestino.blob.core.windows.net/containerDestino?svYYY%3D' --recursive=true
      ```      


### Blobs
  - Blob management varios:
        ```
    #### Pre-reqs: 'AzureRM' PowerShell module
        Install-Module AzureRM

    #### Connect Azure
        Connect-AzureRmAccount

    #### Variables
        $contenedor = "contenedor_name"
        $resource_group = "rg_name"
        $StorageAccount = Get-AzureRmStorageAccount -Name $contenedor -ResourceGroupName $resource_group

    #### LIST
        Get-AzureStorageContainer -Context $StorageAccount.Context

        #listar un único blob
        Get-AzureStorageBlob -Container $contenedor -Blob 000/012/A1C0000125354.jpg -Context $StorageAccount.Context | FT -AutoSize

        #listar todos los blobs de un producto (mismo patron de nombre)
        $lista_blobs_proyecto=Get-AzureStorageBlob -Container $contenedor -Blob 000/012/*0000125354.jpg -Context $StorageAccount.Context

    #### CAMBIAR TIER
        #desarchivar un blob
        $blob_desarchivar = Get-AzureStorageBlob -Container $contenedor -Blob 000/012/A1C0000120000.jpg -Context $StorageAccount.Context
        $blob_desarchivar.ICloudBlob.SetStandardBlobTier("Cool")

        #desarchivar varios blob
        $blobs_desarchivar = Get-AzureStorageBlob -Container $contenedor -Blob 000/012/*0000120000.jpg -Context $StorageAccount.Context
        $blobs_desarchivar.ICloudBlob.SetStandardBlobTier("Cool")

        #archivar un blob
        $blob_a_enfriar=Get-AzureStorageBlob -Container $contenedor -Blob 000/012/A1C0000120000.jpg -Context $StorageAccount.Context
        $blob_a_enfriar.ICloudBlob.SetStandardBlobTier("Archive")

    #### DOWNLOAD
        # Download un único blob
        Get-AzureStorageBlobContent -Container $contenedor -Blob 000/012/A1C0000125354.jpg -Destination "C:\blobs_recuperados\" -Context $StorageAccount.Context

        # Download de los blobs de un proyecto
        $lista_blobs_proyecto | %{
            Get-AzureStorageBlobContent -Container $contenedor -Blob $_.Name -Destination "C:\blobs_recuperados\" -Context $StorageAccount.Context
        }

    #### DELETE a blob
        Remove-AzureStorageBlob -Container $contenedor -Blob "archivo_a_borrar.pdf" -Context $StorageAccount.Context

        Get-AzureStorageBlob -Container $contenedor -Blob * -Context $StorageAccount.Context | Remove-AzureStorageBlob

    #### UPLOAD blobs
        Set-AzureStorageBlobContent -Container $contenedor -Blob archivo_a_subir.pdf -File C:\Blobs\archivo_a_subir.pdf -Context $StorageAccount.Context

        Get-ChildItem C:\Blobs | Set-AzureStorageBlobContent -Container $contenedor -Context $StorageAccount.Context -Force

    #### COPY blobs between Containers
        Get-AzureStorageContainer -Context $StorageAccount.Context | Get-AzureStorageBlob -Context $StorageAccount.Context

        Start-AzureStorageBlobCopy -SrcContainer iso -SrcBlob ipswitch.iso -DestContainer iso02 -DestBlob ipswitch.iso -Context $StorageAccount.Context

        Get-AzureStorageBlob -Container iso -Blob "*.iso" -Context $StorageAccount.Context | Start-AzureStorageBlobCopy -DestContainer iso02

        Get-AzureStorageBlobCopyState -Blob "Windows10_x64.iso" -Container "iso02" -Context $StorageAccount.Context

    #### RENAME a blob
        Get-AzureStorageBlob -Container "iso" -Blob * -Context $StorageAccount.Context

        Start-AzureStorageBlobCopy -SrcContainer iso -SrcBlob Windows10_x64.iso  -DestContainer iso -DestBlob Windows10_x64_NUEVO.iso  -Context $StorageAccount.Context

        Remove-AzureStorageBlob -Container "iso" -Blob "Windows10_x64.iso" -Context $StorageAccount.Context

    #### MAKE SNAPSHOT of a blob
        $ReadmeBlob = Get-AzureStorageBlob -Container $contenedor -Blob archivo.txt -Context $StorageAccount.Context

        $ReadmeBlob.ICloudBlob.CreateSnapshot()

        $snapshots = Get-AzureStorageBlob -Container $contenedor -prefix archivo.txt -Context $StorageAccount.Context | Where-Object {$_.ICloudBlob.IsSnapshot -and $_.SnapshotTime -ne $null}

    #### RESTORE SNAPSHOT
        Get-AzureStorageBlob -Container docs -Blob archivo.txt -Context $StorageAccount.Context

        $snapshots = Get-AzureStorageBlob -Container docs -prefix archivo.txt -Context $StorageAccount.Context | Where-Object {$_.ICloudBlob.IsSnapshot -and $_.SnapshotTime -ne $null}

        $snapshots | Out-GridView -PassThru | Start-AzureStorageBlobCopy -DestContainer docs -Force

    #### DELETE SNAPSHOT
        $snapshots = Get-AzureStorageBlob -Container docs -Context $StorageAccount.Context | Where-Object {$_.ICloudBlob.IsSnapshot -and $_.SnapshotTime -ne $null}

        $snapshots | Remove-AzureStorageBlob
      ```

  - Change tier & download blobs:
        ```  
    #### 1: Conectar
        Connect-AzureRmAccount
        $contenedor = "containername"
        $resource_group = "rg_name"
        $StorageAccount = Get-AzureRmStorageAccount -Name $contenedor -ResourceGroupName $resource_group

    #### 2: Lista objetivo y cambiar el Tier. Podemos usar wildcards para
        #D1
        $ruta_D1 = "000/012/*C0000129485.jpg"
        Get-AzureStorageBlob -Container $contenedor -Blob $ruta_D1 -Context $StorageAccount.Context | FT -AutoSize
        $blobs_desarchivar1 = Get-AzureStorageBlob -Container $contenedor -Blob $ruta_D1 -Context $StorageAccount.Context
        $blobs_desarchivar1.ICloudBlob.SetStandardBlobTier("Cool")

    #### 3: Esperar Archive->Cool
        Start-Sleep -s 21600 #6h

    #### 4: Decargar (-Force para sobreescribir el fichero si existiera)
        $blobs_desarchivar1 | %{ Get-AzureStorageBlobContent -Container $contenedor -Blob $_.Name -Destination "C:\blobs_recuperados\" -Context $StorageAccount.Context -Force | FT -AutoSize}
        ```   

  - Blob aiging template: archive a los 90 días y eliminar a los 1000
      ```
      https://docs.microsoft.com/es-es/azure/storage/blobs/storage-lifecycle-management-concepts#rule-filters
      {
        "rules": [
          {
            "name": "Aiging",
            "enabled": true,
            "type": "Lifecycle",
            "definition": {
              "filters": {
                "blobTypes": [ "blockBlob" ]
              },
              "actions": {
                "baseBlob": {
                  "tierToArchive": { "daysAfterModificationGreaterThan": 90 },
                  "delete": { "daysAfterModificationGreaterThan": 1000 }
                },
                "snapshot": {
                  "delete": { "daysAfterCreationGreaterThan": 90 }
                }
              }
            }
          }
        ]
      }
      ```

### Network
  - Identify the IP address of the blob service endpoint of the Azure Storage account. Notice a single RESOURCE_GROUP can have multiple STORAGE ACCOUNTS so here: 'RESOURCE_GROUP_NAME_HERE')[NUMBER]    number goes from 0 to n:
      ```   
    [System.Net.Dns]::GetHostAddresses($(Get-AzStorageAccount -ResourceGroupName 'RESOURCE_GROUP_NAME_HERE')[4].StorageAccountName + '.blob.core.windows.net').IPAddressToString
    ```
