#Check you are in the right Subscription
az account list --output table

#OPTIONAL: in case you are not, change with
az account set --subscription "Nombre de la Suscripcion"

#Variables
$VM_NAME
$RESOURCE_GROUP_NAME

#invocar comando: devolcera un json con el output del comando
az vm run-command invoke --command-id RunPowerShellScript --name $VM_NAME -g $RESOURCE_GROUP_NAME --scripts "c:\demo\test.bat" --debug
