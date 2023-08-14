Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted


Get-ProvisionedAppxPackage -Online | `

Where-Object { $_.PackageName -match "xbox" } | `

ForEach-Object { Remove-ProvisionedAppxPackage -Online -PackageName $_.PackageName }