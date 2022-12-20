cls
az login
$date = Get-Date -Format "yyyyMMdd"

############################
### OPCION1: desde listas ###
############################

$lista_RGs = @(
    'rg-001',
    'rg-002',
    'rg-002'
    )
$lista_Suscriptions = @(
    'Suscripcion1',
    'Suscripcion3',
    'Suscripcion1'
    )

$i=0
$date = Get-Date -Format "yyyyMMdd"

foreach ($rg in $lista_RGs) {
    Write-Host $rg esta en $lista_Suscriptions[$i]
    az account set --subscription $lista_Suscriptions[$i]
    az group export --name $rg > C:\TEMP\$rg"_"$date.json
    $i+=1
}

############################
## OPCION2: lista bidimens ##
############################

$lista_bi = @(
    'rg-DPL-001#Grupo Antolin ITHQ PoCs',
    'rg-CBT-VISION-001#Grupo Antolin ITHQ Production',
    'rg-aicad-001#Grupo Antolin ITHQ Production'
    )


$lista_bi | foreach {
    $r = $_ -split '#'
    Write-Host $r[0] esta en $r[1]
    az account set --subscription $r[1]
    $nombre_json=$r[0]+"_"+$date
    az group export --name $r[0] > C:\TEMP\$nombre_json.json
}

############################
## OPCION3: desde archivo ###
############################

Get-Content C:\Users\hq_admin15\Desktop\proyectos_complejos_azure.txt | ForEach-Object {
    $f = $_ -split '#'
    Write-Host $f[0] esta en $f[1]
    az account set --subscription $f[1]
    $nombre_json=$f[0]+"_"+$date
    az group export --name $f[0] > C:\TEMP\$nombre_json.json
}
