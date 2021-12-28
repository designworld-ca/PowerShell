# Get rid of those pesky folders that keep getting recreated by Windows apps you don't use

## Open Windows PowerShell using run as administrator 

### To uninstall Camera:

    Get-AppxPackage *windowscamera* | Remove-AppxPackage

### To uninstall Photos:

    Get-AppxPackage *photos* | Remove-AppxPackage
