﻿
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted

$tailRecursion = {
    param(
        $Path
    )
    foreach ($childDirectory in Get-ChildItem -Force -LiteralPath $Path -Directory) {
        & $tailRecursion -Path $childDirectory.FullName
    }
    $currentChildren = Get-ChildItem -Force -LiteralPath $Path
    $isEmpty = $currentChildren -eq $null
    if ($isEmpty) {
        Write-Verbose "Removing empty folder at path '${Path}'." -Verbose
        Remove-Item -Force -LiteralPath $Path
    }
}

& $tailRecursion -Path 'D:\.kobo-images'
#'C:\Users\Kevinsky\Downloads\Books'
#'D:\Books'