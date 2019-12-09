
  <#
      .SYNOPSIS
      Sets local user permissions, adds a module to the profile and sets your credentials

      .DESCRIPTION
      Asks the users to allow a change in Script permissions without which the module will not work.
      Adds the module to the users local PowerShell profile
      Asks for credentials and stores them in an encrypted file on your desktop

      .EXAMPLE
      Set-OneTimeSetup
      See Description

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Set-OneTimeSetup

      .INPUTS
      None

      .OUTPUTS
      List of output types produced by this function.
  #>
 
                         
  function Find-ModuleInProfile
                         {
                           <#
                             .SYNOPSIS
                             Acts as a filter to find a folder path.

                             .DESCRIPTION
                             Used to verify that the DLLS module is in the profile path

                             .PARAMETER InputObject
                             Describe parameter -InputObject.

                             .EXAMPLE
                             Where-ModuleInProfile -InputObject Value
                             Describe what this call does

                             .NOTES
                             Place additional notes here.

                             .LINK
                             URLs to related sites
                             The first link is opened by Get-Help -Online Where-ModuleInProfile

                             .INPUTS
                             List of input types that are accepted by this function.

                             .OUTPUTS
                             List of output types produced by this function.
                           #>


                           param
                           (
                             [Object]
                             [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Looks for the DLLS modules in a path')]
                             $InputObject
                           )
                           process
                           {
                             if ($InputObject.Contains($modulePath))
                             {
                               $InputObject
                             }
                           }
                         }

  #just in case the policy has not been set
  set-executionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
  $PSModuleAutoloadingPreference = 'All'
  
  $modulePath       = 'N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools'
  $addToProfilePath = '$env:PSModulePath = $env:PSModulePath + ";' + $modulePath + '"'
  $addModules = 'import-module Observations'
  
  'Checking to see if the DLLS module is in your local PowerShell profile'
  if (!(Test-Path -Path $PROFILE)) {
    'No local profile found, creating one'
    New-Item -ItemType File -Path $PROFILE -Force
    Add-Content -Path $Profile.CurrentUserCurrentHost -Value $addToProfilePath
    Add-Content -Path $Profile.CurrentUserCurrentHost -Value $addModules
  }
  else
  {
    #check if path already present
    if ( @( Get-Content -path $Profile.CurrentUserCurrentHost -Raw | Find-ModuleInProfile ).Count -eq 0)
     {
      'Local profile exists but does not have Observations module, adding it'
      Add-Content -Path $Profile.CurrentUserCurrentHost -Value $addToProfilePath
      Add-Content -Path $Profile.CurrentUserCurrentHost -Value $addModules       
     }
    else
    {
      'Local profile found with Observations module path added already: no actions taken'
    }
  }

    if ( @( Get-Content -path $Profile.CurrentUserCurrentHost -Raw | Find-ModuleInProfile ).Count -gt 0)
     {
      'Success: the DLLS module is now available every time you start PowerShell'
     }
     

  Import-Module -Name N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools\Observations\Observations.psm1

  
  if (-not (Get-Module -Name CredentialsManager)) {
    Import-Module -Name N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools\Observations\credentialsmanager\CredentialsManager.psm1
  }
  Set-Credential
  
  'Your credentials have now been stored under the short name you supplied for reuse'
  'Enter Exit and return or close this window'

