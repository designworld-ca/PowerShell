                         function Get-VidFiles
                         {
                           <#
                             .SYNOPSIS
                             Filters for file types ending in .mp4
                             .DESCRIPTION
                             Acts on all files within a folder.
                             .PARAMETER InputObject
                             A directory.
                             .EXAMPLE
                              $vidList = $Dir | Get-VidFiles
                             .INPUTS
                             A directory.
                             .OUTPUTS
                             An array of file items of type video
                           #>


                           param
                           (
                             [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Filtering for video files')]
                             [PSObject]$InputObject
                           )
                           process
                           {
                             if ($InputObject.extension -eq '.mp4')
                             {
                               $InputObject
                             }
                           }
                         }


$inFolderPath = 'C:\Users\LarocheK\Downloads'
$outFolderPath = 'C:\Users\LarocheK\Documents'

$start= '00:00:00:00','00:00:19:55','00:00:39:50','00:00:59:45','00:01:19:40','00:01:39:35','00:01:59:25','00:02:19:55','00:02:39:50'
$end  = '00:00:19:55','00:00:39:50','00:00:59:45','00:01:19:40','00:01:39:35','00:01:59:25','00:02:19:55','00:02:39:50','00:02:59:35'

$Dir = get-childitem -Path $inFolderPath 
$vidList = $Dir | Get-VidFiles
ForEach($vidFile in $vidList)
{

$inFile = $inFolderPath + '\' + $vidFile.Name
##get length of the video file
$LengthColumn = 27
$objShell = New-Object -ComObject Shell.Application 
$objFolder = $objShell.Namespace($inFolderPath)
$objFile = $objFolder.ParseName($vidFile)
$Length = $objFolder.GetDetailsOf($objFile, $LengthColumn)

Write-Output ('File {0} is {1} long' -f $vidFile, $Length)


$TimeSpan = [System.TimeSpan]::Parse($Length)
$Minutes = [System.Math]::Round($TimeSpan.TotalMinutes,0)
Write-Output ('which is {0} minutes' -f $Minutes.ToString() )
##how many times do we have to cut it?
$numberCuts = [System.Math]::Round([Int32]$Minutes / 19) + 1
Write-Output ('so we have to cut it into {0} portions' -f $numberCuts)
 

For ($i=0;$i-le$numberCuts;$i++){
$outName = $vidFile.BaseName + '_' + ($i + 1) + $vidFile.Extension
$outFile = $outFolderPath + '\' + $outName
$Parms = ("-i {0} -ss {1} -to {2} -c:v copy -c:a copy {3}" -f $inFile, $start[$i], $end[$i],$outfile)
Write-Output $Parms

} #end of for loop
#$Command = "C:\X64\Xendesktop Setup\ffmpeg.exe"
#$Parms = "-i input.mp4 -ss 00:00:00 -to 00:19:55 -c:v copy -c:a copy output.mp4"

#$Prms = $Parms.Split(" ")
#& "$Command" $Prms
} #end of ForEach
