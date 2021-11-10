param (
    [string]$SASURIKey, 
    [string]$StorageAccount
)

$InstallPath = 'C:\Install'
$LabsPath = 'C:\_SQLHACK_\LABS'
$Labs1Path = 'C:\_SQLHACK_\LABS\01-Data_Migration'
$Labs2Path = 'C:\_SQLHACK_\LABS\02-Administering_Monitoring'
$Labs3Path = 'C:\_SQLHACK_\LABS\03-Security'
$Labs3SecurityPath = 'C:\_SQLHACK_\LABS\03-Security\SQLScripts'
$Labs4Path = 'C:\_SQLHACK_\LABS\04-SSIS_Migration'

##################################################################
#Create Folders for Labs and Installs
##################################################################
md -Path $LabsPath
md -Path $InstallPath
md -Path $Labs1Path
md -Path $Labs2Path
md -Path $Labs3Path
#md -Path $Labs3SecurityPath
md -Path $Labs4Path

$SASURIKey = $SASURIKey | ConvertFrom-Json

#Download Items for LAB 01
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Invoke-WebRequest 'https://github.com/praderichard/SQL-OH/raw/master/Hands-On%20Lab/Background.pdf' -OutFile "C:\_SQLHACK_\Lab Background.pdf"
Invoke-WebRequest 'https://github.com/praderichard/SQL-OH/blob/master/Hands-On%20Lab/01%20Data%20Migration/01-%20DB%20Migration%20Lab%20and%20Parameters%20Overview.pdf' -OutFile "$Labs1Path\01- DB Migration Lab and Parameters.pdf"
Invoke-WebRequest 'https://github.com/praderichard/SQL-OH/blob/master/Hands-On%20Lab/01%20Data%20Migration/SimpleTranReportApp.exe?raw=true' -OutFile "$Labs1Path\SimpleTranReportApp.exe"
Invoke-WebRequest 'https://raw.githubusercontent.com/praderichard/SQL-OH/master/Hands-On%20Lab/01%20Data%20Migration/Migration%20Helper%20Script.sql' -OutFile "$Labs1Path\Migration Helper Script.txt"
Invoke-WebRequest 'https://github.com/praderichard/SQL-OH/raw/master/Hands-On%20Lab/01%20Data%20Migration/02-%20DB%20Migration%20Lab%20Step-by-step.pdf' -OutFile "$Labs1Path\02- DB Migration Lab Step-by-step.pdf"
Invoke-WebRequest 'https://raw.githubusercontent.com/praderichard/SQL-OH/master/Build/SQL%20SSIS%20Databases/SSIS%20Build%20Script%20-%20TeamServer.ps1'  -OutFile "$InstallPath\SSIS Build Script.ps1"

$SASURIKey | out-file -FilePath "$Labs1Path\SASKEY.txt"

#Download Items for LAB 02
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/praderichard/SQL-OH/blob/master/Hands-On%20Lab/02%20Admin%20Monitoring/01-%20DB%20Administering%20%2B%20Monitoring%20Lab%20Step-by-step.pdf' -OutFile "$Labs2Path\01- DB Administering Monitoring Lab Step-by-step.pdf"
Invoke-WebRequest 'https://github.com/praderichard/SQL-OH/raw/master/Hands-On%20Lab/02%20Admin%20Monitoring/Part_01_Monitoring_Lab_1.sql' -OutFile "$Labs2Path\Part_01_Monitoring_Lab_1.sql"
Invoke-WebRequest 'https://github.com/praderichard/SQL-OH/raw/master/Hands-On%20Lab/02%20Admin%20Monitoring/Part_02_Monitoring_Lab_1.sql' -OutFile "$Labs2Path\Part_02_Monitoring_Lab_1.sql"
#Download Items for LAB 03
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/praderichard/SQL-OH/raw/master/Hands-On%20Lab/03%20Security/01-%20Security%20Lab.pdf' -OutFile "$Labs3Path\01- Security Lab.pdf"
$StorageAccount | out-file -FilePath "$Labs3Path\StorageAccount.txt"

#Invoke-WebRequest 'https://raw.githubusercontent.com/praderichard/SQL-OH/master/Hands-On%20Lab/03%20Security/SQLScripts/2.%20Auditing.sql' -OutFile "$Labs3SecurityPath\2.Auditing.sql"
#Invoke-WebRequest 'https://raw.githubusercontent.com/praderichard/SQL-OH/master/Hands-On%20Lab/03%20Security/SQLScripts/3.%20Dynamic%20Data%20Masking.sql' -OutFile "$Labs3SecurityPath\3.Dynamic Data Masking.sql"
#Invoke-WebRequest 'https://raw.githubusercontent.com/praderichard/SQL-OH/master/Hands-On%20Lab/03%20Security/SQLScripts/4.%20TDE%20and%20Password%20Reset.sql' -OutFile "$Labs3SecurityPath\4.TDE and Password Reset.sql"

#Download Items for LAB 04
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/praderichard/SQL-OH/blob/master/Hands-On%20Lab/04%20SSIS%20Migration/04-SSIS%20Migration.zip?raw=true' -OutFile "$InstallPath\Lab4.zip"

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "$InstallPath\Lab4.zip" "$Labs4Path"



#########################################################################
#Install Applications
#########################################################################

# Download and install SSDT
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2124518' -OutFile 'C:\Install\SSDT-Setup-ENU.exe'
Start-Process -file 'C:\Install\SSDT-Setup-ENU.exe' -arg '/layout c:\Install\vs_install_bits /quiet /log C:\Install\SSDTLayout_install.txt' -wait
start-sleep 10
Start-Process -file 'C:\Install\vs_install_bits\SSDT-Setup-enu.exe' -arg '/INSTALLVSSQL /install INSTALLALL /norestart /passive /log C:\Install\SSDT_install.txt' -wait 

# Download and install Data Mirgation Assistant
Invoke-WebRequest 'https://download.microsoft.com/download/C/6/3/C63D8695-CEF2-43C3-AF0A-4989507E429B/DataMigrationAssistant.msi' -OutFile "$InstallPath\DataMigrationAssistant.msi"
Start-Process -file 'C:\Install\DataMigrationAssistant.msi' -arg '/qn /l*v C:\Install\dma_install.txt' -passthru 

# Download Storage Explorer
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?LinkId=708343&clcid=0x409' -OutFile "$InstallPath\StorageExplore.exe"
Start-Process -file 'C:\Install\StorageExplore.exe' -arg '/VERYSILENT /ALLUSERS /norestart /LOG C:\Install\StorageExplore_install.txt'

# Download and install SQL Server Management Studio
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2168063' -OutFile 'C:\Install\SSMS-Setup.exe'
start-sleep 5
#$pathArgs = {C:\Install\SSMS-Setup.exe /S /v/qn}
#Invoke-Command -ScriptBlock $pathArgs 
Start-Process -file 'C:\Install\SSMS-Setup.exe' -arg '/passive /install /norestart /quiet /log C:\Install\SSMS_install.txt' -wait 


# Create Shortcut on desktop
$TargetFile   = "C:\_SQLHACK_\"
$ShortcutFile = "C:\Users\Public\Desktop\_SQLHACK_.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut     = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
