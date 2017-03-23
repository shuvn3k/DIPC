#Se debe tener permisos de intalacion y de ejecucion
#Lo adecuado, ejecutar el script en modo administrador

#Crear directorio en C:
New-Item -path c:\instalaciones -type directory


# Creamos la funcion para descromprimir el ZIP
function Expand-ZIPFile($file, $destination){
	$shell = new-object -com shell.application
	$zip = $shell.NameSpace($file)
	foreach($item in $zip.items()){
		$shell.Namespace($destination).copyhere($item)
	}
}

# Instalaremos Winlogbeat (Recolector y enviador de Logs de windows)
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-5.2.1-windows-x86_64.zip","c:\instalaciones\Winlogbeat.zip")

# Descromprimimos el archivo
Expand-ZIPFile -File "c:\instalaciones\Winlogbeat.zip" -Destination "C:\Program Files\"

# Cambiamos de nombre al directorio
Move-Item 'C:\Program Files\winlogbeat-5.2.1-windows-x86_64' 'C:\Program Files\Winlogbeat'

# Accedemos a la carpeta de winlogbeat
#cd 'C:\Program Files\Winlogbeat'

# Instalamos Winlogbeat
PowerShell.exe -ExecutionPolicy UnRestricted -File 'C:\Program Files\Winlogbeat\install-service-winlogbeat.ps1'

# Descargar certificados
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/ivanathletic/Practicas_DIPC/master/sync/logstash-forwarder.crt","C:\ProgramData\winlogbeat\logstash-forwarder.crt")
#$WebClient = New-Object System.Net.WebClient
#$WebClient.DownloadFile("https://raw.githubusercontent.com/ivanathletic/Practicas_DIPC/master/sync/logstash-forwarder.key","C:\ProgramData\winlogbeat\logstash-forwarder.key")
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/ivanathletic/Practicas_DIPC/clienteWindows/winlogbeat_copy.yml","C:\instalaciones\winlogbeat_copy.yml")

#Modificamos el fichero de configuraciones
(Get-Content "C:\instalaciones\winlogbeat_copy.yml") | Set-Content "C:\Program Files\Winlogbeat\winlogbeat.yml"
(Get-Content "C:\instalaciones\winlogbeat_copy.yml") | Set-Content "C:\Program Files\Winlogbeat\winlogbeat.full.yml"

# Iniciar el servicio Winlogbeat
Start-Service winlogbeat


# Descargar NSClient++
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://github.com/mickem/nscp/releases/download/0.5.0.62/nscp-0.5.0.62-x64.zip","c:\instalaciones\nscp.zip")
Expand-ZIPFile -File "c:\instalacione.\nscp.exe service --starts\nscp.zip" -Destination "C:\Program Files\NSClient++"

cd "C:\Program Files\NSClient++"

.\vcredist_x64.exe /passive /norestart

.\nscp.exe service --install
.\nscp.exe service --start

netsh advfirewall firewall add rule name="Allow nscp" dir=in program='C:\Program Files\NSClient++\nscp.exe' protocol=tcp localport=5666 remoteip=192.168.34.0/24 action=allow
netsh advfirewall firewall add rule name="Allow NSClient" dir=in protocol=tcp localport=12489 remoteip=192.168.34.0/24 action=allow

#Borrar directorio en C:\instalaciones:
Remove-Itema -path c:\instalaciones

#.\nscp settings --activate-module NRPEServer --add-defaults
#.\nscp settings --path /settings/NRPE/server --key "allow arguments" --set true
#.\nscp settings --path /settings/NRPE/server --key "allow nasty characters" --set true
#.\nscp settings --path /settings/NRPE/server --key insecure --set true
#.\nscp settings --path /settings/NRPE/server --key "verify mode" --set none
#.\nscp settings --activate-module CheckExternalScripts --add-defaults
#.\nscp settings --path "/settings/external scripts" --key "allow arguments" --set true
#.\nscp settings --path "/settings/external scripts" --key "allow nasty characters" --set true