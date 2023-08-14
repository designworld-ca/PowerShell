# adjust file path as desired-includes everything but some installs are shown in non english character sets

Get-WmiObject -Class Win32_Product | Select-Object -Property Name > D:\InstalledSoftwareList.txt
