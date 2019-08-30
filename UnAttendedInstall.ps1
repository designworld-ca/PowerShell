Write-Output 'This script installs the 32 and 64 bit Oracle 12.2 clients'
Write-Output "Set up logging to UnattendedInstall.log"
$Logfile = $MyInvocation.MyCommand.Path -replace '\.ps1$', '.log'
Start-Transcript -Path $Logfile -Append
$lang=get-WinSystemLocale
Write-Output "System local is $($lang)"
if($lang.Name -notin "en-CA", "en-US" )
{
  throw "Can only be installed on Windows with the locale set to English"
}

# The command to pass to cmd.exe /c
$var = '\\cirrus-share1.istc-inf.local\DBA\Scripts\OracleClient\Software\win32_12201_client\client32\setup.exe -ignoreSysPrereqs -showProgress -silent -nowait -responseFile "\\cirrus-share1.istc-inf.local\DBA\Scripts\OracleClient\Software\win32_12201_client\client32\response\client32.rsp"'

Write-Output 'Start the 32 bit process process asynchronously, in a new window'
# as the current user with elevation (administrative rights).
# Note the need to pass the arguments to cmd.exe as an *array* and that Oracle returns 259 as success
$P = Start-Process -Verb RunAs cmd.exe -Args '/c', $var -PassThru -Wait
if($p.ExitCode -notin "0", "259" )
{
    throw "32 Bit Client Installation process returned error code: $($p.ExitCode)"
}
Write-Output 'Finished the 32 bit install, Logs at C:\Program Files (x86)\Oracle\Inventory\logs'

# The command to pass to cmd.exe /c
$var2 = '\\cirrus-share1.istc-inf.local\DBA\Scripts\OracleClient\Software\winx64_12201_client\client\setup.exe -ignoreSysPrereqs -showProgress -silent -nowait -responseFile "\\cirrus-share1.istc-inf.local\DBA\Scripts\OracleClient\Software\winx64_12201_client\client\response\client64.rsp"'

Write-Output 'Start the 64 bit process process asynchronously, in a new window'
# as the current user with elevation (administrative rights).
# Note the need to pass the arguments to cmd.exe as an *array*.
$P = Start-Process -Verb RunAs cmd.exe -Args '/c', $var2 -PassThru -Wait
if($p.ExitCode -notin "0", "259" )
{
  throw "64 Bit Client Installation process returned error code: $($p.ExitCode)"
}
Write-Output 'Finished the 64 bit client install. Logs at C:\Program Files\Oracle\Inventory\logs'


$path = "C:\TNSMaster"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
Copy-Item -Path "\\cirrus-share1.istc-inf.local\DBA\TNS_ADMIN\tnsnames.ora" -Destination "C:\TNSMaster\tnsnames.ora" -Force;
Copy-Item -Path "\\cirrus-share1.istc-inf.local\DBA\TNS_ADMIN\sqlnet.ora" -Destination "C:\TNSMaster\sqlnet.ora" -Force;
Write-Output 'Copied the tnsnames and sqlnet.ora to C:\TNSMaster'

Write-Output 'Setting Oracle environment registry keys'
$Var='regedit /s "\\cirrus-share1.istc-inf.local\DBA\Scripts\OracleClient\Registry\64BITORAENV.reg"'
$P = Start-Process -Verb RunAs cmd.exe -Args '/c', $var -PassThru -Wait
if($p.ExitCode -notin "0" )
{
    throw "Adding 64 bit entries to registry returned error code: $($p.ExitCode)"
}
$Var='regedit /s "\\cirrus-share1.istc-inf.local\DBA\Scripts\OracleClient\Registry\32BITORAENV.reg"'
$P = Start-Process -Verb RunAs cmd.exe -Args '/c', $var -PassThru -Wait
if($p.ExitCode -notin "0" )
{
    throw "Adding 32 bit entries to registry returned error code: $($p.ExitCode)"
}
$Var='regedit /s "\\cirrus-share1.istc-inf.local\DBA\Scripts\OracleClient\Registry\ENVVARIABLE.reg"'
$P = Start-Process -Verb RunAs cmd.exe -Args '/c', $var -PassThru -Wait
if($p.ExitCode -notin "0" )
{
    throw "Adding TNS_ADMIN environment entry to registry returned error code: $($p.ExitCode)"
}
Write-Output 'Finished setting Oracle environment registry keys'
Write-Output 'Rebooting machine'
Stop-Transcript
# wait a bit to let all processes finish
Start-Sleep -Seconds 3
Restart-Computer -Force
exit









