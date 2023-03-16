﻿Get-ProvisionedAppxPackage -Online | `

Where-Object { $_.PackageName -match "xbox" } | `

ForEach-Object { Remove-ProvisionedAppxPackage -Online -PackageName $_.PackageName }