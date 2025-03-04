# zip a folder, give it a name based on the date and move it to a backup location

$sourcefolder      = "C:\Users\kevilaro\Documents\test"
$destinationfolder = "C:\Users\kevilaro\Downloads\testbackup\"
$destinationzip    = "test.zip"
$ziptimestamp      = Get-Date -format yyyyMMdd;
$destinationpath   = $destinationfolder + $ziptimestamp + $destinationzip


Compress-Archive -Path $sourcefolder -DestinationPath $destinationpath 
