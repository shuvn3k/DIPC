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

#Borrar directorio en C:\instalaciones:
Remove-Itema -path c:\instalaciones