Write-Output "Set up logging to UnattendedUnInstall.log"
$Logfile = $MyInvocation.MyCommand.Path -replace '\.ps1$', '.log'
Start-Transcript -Path $Logfile -Append


# The command to pass to cmd.exe /c
$var = 'D:\Oracle\product\12.2.0\client_1\client32\deinstall\deinstall.bat -silent -paramFile "<filepath>\OracleClient\Uninstall\32Bit\deinstallclient32.rsp"'

Write-Output 'Start the 32 bit uninstall asynchronously'
# as the current user with elevation (administrative rights).
# Note the need to pass the arguments to cmd.exe as an *array* and that Oracle returns 259 as success
$P = Start-Process -Verb RunAs cmd.exe -Args '/c', $var -PassThru -Wait
if($p.ExitCode -notin "0", "259" )
{
    throw "32 bit uninstall process returned error code: $($p.ExitCode)"
}
Write-Output 'Finished the 32 bit uninstall, Logs at <filepath>\OracleClient\Uninstall\32Bit\32BitLogs'

Write-Output 'Deleting the 32 bit client folder'

$folder='D:\Oracle\product\12.2.0\client_1'

Remove-Item $folder -ErrorAction Ignore

Write-Output 'Rebooting machine'
Stop-Transcript
# wait a bit to let all processes finish
Start-Sleep -Seconds 3
Restart-Computer -Force
exit
