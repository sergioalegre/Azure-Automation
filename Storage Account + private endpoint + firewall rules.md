#### Basado https://www.returngis.net/2022/02/configurar-una-azure-storage-account-con-un-private-endpoint-y-reglas-de-firewall-con-azure-cli/

En este ejemplo se corta todo acceso mediante firewall permitiendo solo una ip concreta, para no usar reglas de firewall no usar este parametro en el storage account **–disable-private-endpoint-network-policies a true**

### Crear la cuenta de almacenamiento
  - Con **–default-action a Deny** me aseguro de que no haya acceso desde el exterior nada más crearla.

      ```    
      STORAGE_ACCOUNT_NAME="storage_account_name"
      # Create the storage account
      az storage account create \
      --name $STORAGE_ACCOUNT_NAME \
      --resource-group $RESOURCE_GROUP \
      --location $LOCATION \
      --sku Standard_LRS \
      --default-action Deny
      ```
### Crear una subnet
  - es importante el parámetro **–disable-private-endpoint-network-policies a true** ya que de lo contrario lo siguiente te dará error al intentar crear el private endpoint.

      ```   
      STORAGE_SUBNET_NAME="storage-subnet"
      STORAGE_SUBNET_CIDR=10.10.4.0/24
      # Create a subnet for the storage account
      az network vnet subnet create \
      --name $STORAGE_SUBNET_NAME \
      --resource-group $RESOURCE_GROUP \
      --vnet-name $WEB_APP_VNET_NAME \
      --address-prefixes $STORAGE_SUBNET_CIDR
      # Disable private endpoint network policies
      az network vnet subnet update \
      --name $STORAGE_SUBNET_NAME \
      --resource-group $RESOURCE_GROUP \
      --vnet-name $WEB_APP_VNET_NAME \
      --disable-private-endpoint-network-policies true
      ```         

### Crear private endpoint asociado a la cuenta de almacenamiento y a la subnet

      ```  
      STORAGE_ACCOUNT_ID=$(az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query id --output tsv)
      # Create a private endpoint for the storage account
      az network private-endpoint create \
      --name $STORAGE_ACCOUNT_NAME-private-endpoint \
      --resource-group $RESOURCE_GROUP \
      --vnet-name $WEB_APP_VNET_NAME \
      --subnet $STORAGE_SUBNET_NAME \
      --connection-name "storage-connection" \
      --private-connection-resource-id $STORAGE_ACCOUNT_ID \
      --group-id blob
      ```        

### Crear un private DNS zone y asociarlo a la red
  - para que otros servicios puedan resolver correctamente la IP interna de la cuenta de almacenamiento falta por crear y configurar el Private DNS:

      ```
      BLOB_PRIVATE_DNS_ZONE="privatelink.blob.core.windows.net"
      # Create a DNS private zone
      az network private-dns zone create \
      --resource-group $RESOURCE_GROUP \
      --name $BLOB_PRIVATE_DNS_ZONE
      #link the private zone to the vnet
      az network private-dns link vnet create \
      --name "blob_private_dns" \
      --resource-group $RESOURCE_GROUP \
      --zone-name $BLOB_PRIVATE_DNS_ZONE \
      --virtual-network $WEB_APP_VNET_NAME \
      --registration-enabled false
      ```
  - Una vez creado, registra la IP privada de la cuenta de almacenamiento en el DNS:

        ```
        # Register the storage account in the private DNS zone
        # Get the ID of the azure storage NIC
        STORAGE_NIC_ID=$(az network private-endpoint show --name $STORAGE_ACCOUNT_NAME-private-endpoint -g $RESOURCE_GROUP --query 'networkInterfaces[0].id' -o tsv)
        # Get the IP of the azure storage NIC
        STORAGE_ACCOUNT_PRIVATE_IP=$(az resource show --ids $STORAGE_NIC_ID --query 'properties.ipConfigurations[0].properties.privateIPAddress' --output tsv)
        # create a record set for the storage account
        az network private-dns record-set a add-record \
        --record-set-name $STORAGE_ACCOUNT_NAME \
        --resource-group $RESOURCE_GROUP \
        --zone-name $BLOB_PRIVATE_DNS_ZONE \
        --ipv4-address $STORAGE_ACCOUNT_PRIVATE_IP      
        ```   
### Permitir el acceso desde tu IP

        ```
        # Get my public IP
        HOME_IP=$(curl -s ipinfo.io/ip)
        # Create a rule to access the storage account from a specific IP
        az storage account network-rule add --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --ip-address $HOME_IP
        # List IP rules
        az storage account network-rule list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query ipRules
        ```
