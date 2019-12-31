
Set-Variable -name encodeFormat -value 'UTF8' -Scope Global -Option ReadOnly -Force -ErrorAction SilentlyContinue

Set-Variable -name obsModulePath -value $MyInvocation.MyCommand.Module.ModuleBase -Scope Global -Option ReadOnly -Force -ErrorAction SilentlyContinue
 

function script:Set-Credential{
  <#
      .SYNOPSIS
      Accepts your username and password which are identified by a short form name.       
      This setting is saved for reuse. 

      .DESCRIPTION
      Calls the CredentialsManager module.  This calls an interactive box
      where you enter your username and password.  The information is stored
      on the local computer in an encrypted form.

      .PARAMETER $credentialName
      A string with a short form name for your username and password.


      .INPUTS
      A string representing the short form name of the credential

      .OUTPUTS
      Writes the domain, username and password to an encrypted file on your workstation

      .EXAMPLE
       ./SetCredentials

      .LINK
      https://www.powershellgallery.com/packages/CredentialsManager/1.1 


  #>
  param(
    [Parameter(Mandatory,HelpMessage='Enter your username and password in the popup box')] 
    [ValidateNotNullorEmpty()]
    [string]$credentialName
  )
   if (-not (Get-Module -Name CredentialsManager)) {
    Import-Module -Name N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools\CredentialsManager\CredentialsManager.psm1
  }

  Write-Credential -Environment $credentialName

} #end function


function script:Export-JsonToCsv{
  <#
      .SYNOPSIS
      Accepts a path to a folder where json files are located. Reads these files
      and writes out the content to a csv file in the output folder

      .DESCRIPTION
      Converts each json file into a csv file with UTF8 encoding

      .PARAMETER $inFolderPath
      The path to the folder where the json files are located
      .PARAMETER $outFolderPath
      The path to the folder where the csv files will be written

      .INPUTS
      A string representing the folder path

      .OUTPUTS
      One csv file json file located in the inFolderPath parameter

      .EXAMPLE
       ./Export-JsonToCsv  $in  $out

      .LINK
      Export-Csv

      .NOTES
      Folder paths have a \ added at the end to construct the file names

  #>
  param (
    [Parameter(Mandatory,
    HelpMessage='Enter the path to the folder where the json files are located')] 
    [ValidateScript({Test-Path -Path $_})]
    [string]$inFolderPath,
    [Parameter(Mandatory,
    HelpMessage='Enter the path to the folder where the csv files will be written')] 
    [ValidateScript({Test-Path -Path $_})]
    [string]
  $outFolderPath)

  

                         function Get-JsonFiles
                         {
                           <#
                             .SYNOPSIS
                             Filters for file types ending in .json

                             .DESCRIPTION
                             Acts on all files within a folder.

                             .PARAMETER InputObject
                             A directory.

                             .EXAMPLE
                              $jsonList = $Dir | Get-JsonFiles

                             .INPUTS
                             A directory.

                             .OUTPUTS
                             An array of file items of type json
                           #>


                           param
                           (
                             [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Filtering for json files')]
                             [PSObject]$InputObject
                           )
                           process
                           {
                             if ($InputObject.extension -eq '.json')
                             {
                               $InputObject
                             }
                           }
                         }

  $Dir = get-childitem -Path $inFolderPath

  $jsonList = $Dir | Get-JsonFiles

  ForEach($jsonFile in $jsonList)
  {
    $inFile  = $inFolderPath + '\' + $jsonFile.Name
    $trimmedFileName = $jsonFile.BaseName
    $outFile = $outFolderPath + '\' + $trimmedFileName + '.csv'

    $results = Get-Content -Path $inFile -Encoding $encodeFormat | ConvertFrom-Json 
    'Processed ' +  $inFile
    $results | Export-CSV -Path $outFile -NoTypeInformation -Encoding $encodeFormat
  }
} #end function

function script:Export-CsvToJson{
  <#
      .SYNOPSIS
      Accepts a path to a folder where csv files are located. Reads these files
      and writes out the content to a json file in the output folder

      .DESCRIPTION
      Converts each csv file into a json file with UTF8 encoding

      .PARAMETER $inFolderPath
      The path to the folder where the csv files are located

      .PARAMETER $outFolderPath
      The path to the folder where the json files will be written

      .INPUTS
      A string representing the folder path origin and destination

      .OUTPUTS
      One json file json file located in the inFolderPath parameter

      .EXAMPLE
       ./Export-CsvToJson  $in  $out

      .LINK
      Import-Csv
      ConvertTo-Json

      .NOTES
      Folder paths have a \ added at the end to construct the file names

  #>
  param (
    [Parameter(Mandatory,
    HelpMessage='Enter the path to the folder where csv files are located')] 
    [ValidateScript({Test-Path -Path $_})]
    [string]$inFolderPath,
    [Parameter(Mandatory,
    HelpMessage='Enter the path to the folder where the json files will be written')] 
    [ValidateScript({Test-Path -Path $_})]
    [string]
  $outFolderPath)

  
                         function Get-CsvFiles
                         {
                           <#
                             .SYNOPSIS
                             Filters for file types of csv type.

                             .DESCRIPTION
                             Acts on all files within a folder.

                             .PARAMETER InputObject
                             A directory

                             .EXAMPLE
                              $csvList = $Dir | Get-CsvFiles

                             .INPUTS
                             A directory

                             .OUTPUTS
                             An array of file items of type csv
                           #>


                           param
                           (
                             [Parameter(Mandatory, ValueFromPipeline, HelpMessage='File type to filter for')]
                             [PSObject]$InputObject
                           )
                           process
                           {
                             if ($InputObject.extension -eq '.csv')
                             {
                               $InputObject
                             }
                           }
                         }

  $Dir = get-childitem -Path $inFolderPath

  $csvList = $Dir | Get-CsvFiles

  ForEach($csvFile in $csvList)
  {
    $inFile  = $inFolderPath + '\' + $csvFile.Name
    $trimmedFileName = $csvFile.BaseName
    $outFile = $outFolderPath + '\' + $trimmedFileName + '.json'
    
    #if the json file exists rename it to .old
    if (Test-Path -Path $outFile) 
    {
      Write-Verbose 'Renaming an existing json file to <xxx>.json.old'
      $renamedFile = $outFile + '.old'
      Rename-Item -Path $outFile -NewName $renamedFile
    }
    

    import-csv -Path $inFile -Encoding $encodeFormat | 
    ConvertTo-Json -Depth 99 | 
    Add-Content -Path $outfile -Encoding $encodeFormat
    'Wrote {0}' -f $outfile
  }


} #end function

function script:Export-SPListFieldNamesToCsv{
  <#
      .SYNOPSIS
      Queries a SharePoint List for the names of the fields 

      .DESCRIPTION
      Gets a list of field names and writes them to a csv file

      .PARAMETER $spSiteUrl
      Base url of the site. Not a correct uri.
      .PARAMETER $spListName
      Name of the list as displayed on the SharePoint Site
      .PARAMETER $outFolderPath
      Path to a folder where you want the output to be written to

      .INPUTS
      A string representing the url of the site
      A string representing the name of the list
      An optional string for the folder to write to.  If not
      entered the csv file is written to the users documents folder

      .OUTPUTS
      A csv file with the names of the fields in the list with naming format <SPLLCT Short Name>Mapping.csv

      .EXAMPLE
       Export-SPListFieldNamesToCsv -spSiteUrl $spBaseSite -spListName "SPLLCT" -outFolderPath $($in + "\")

      .LINK
      https://www.powershellgallery.com/packages/SharePointSDK/2.1.6
      Export-CSV

      .NOTES
      Nested fields such as Create By or Editor have subfields  

  #>
  param (
    [Parameter(Mandatory,
    HelpMessage='Enter the base url of a SharePoint SPLLCT')] 
    [ValidateNotNullorEmpty()]
    [string]
    $spSiteUrl,
    [Parameter(Mandatory,
    HelpMessage='Enter the name of the list to be exported')] 
    [ValidateNotNullorEmpty()]
    [string]$spListName,
    [Parameter(Mandatory,
      HelpMessage='Enter a name for the SPLLCT Observation List')]
      [ValidateNotNullorEmpty()]
    [string]$SPLLCTName,
    [string]$outFolderPath,
    [string]$credentialName)

  if ( ($outFolderPath -eq $Null) -or ($outFolderPath -eq '')) 
  {
    'No path entered writing to your documents folder'
    $outFolderPath = Get-UserDocumentsPath
  }
  else
  {
    #test that the folder exists
    if(-Not ($outFolderPath | Test-Path) )
    {
      ('Folder {0} does not exist. Writing to your documents folder' -f $outFolderPath) 
      $outFolderPath = Get-UserDocumentsPath
    }
  }

  if ($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent)
  {
    Write-Verbose 'Log file started and located in same folder as this script'
    $Logfile = $outFolderPath +('{0}.log' -f $SPLLCTName)
    Start-Transcript -Path $Logfile 
  }
  

  $outputFile   = $outFolderPath+('{0}{1}.csv' -f $SPLLCTName, 'Mapping')
  
  if (-not (Get-Module -Name SharepointSDK)) {
    Import-Module -Name N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools\sharepointsdk\sharepointsdk.psm1
  }
    
  if (-not (Get-Module -Name CredentialsManager)) {
    Import-Module -Name N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools\CredentialsManager\CredentialsManager.psm1
  }


  if (($credentialName -eq $Null) -or ($credentialName -eq ''))
  {
    $credentialName = Read-Host -Prompt 'Enter the name of the credential to use. If you have not created one exit and use Set-Credential'
    
  }
  try {
    $cred = Read-Credential -Environment $credentialName
  }
  catch {
    throw 'This credential is not valid. Enter the name of the credential to use not your username.'
  
  }


  'This script lists all the entries and their fields in a SharePoint List, nested fields such as Create By or Editor have subfields'              

  $listFields = Get-SPListFields -SiteUrl $spSiteUrl -Credential $cred -IsSharePointOnlineSite $false -ListName $spListName
  $listFields
  write-Output -InputObject $listFields | Select-Object  -Property Title, InternalName, Description | Export-Csv -Path $outputFile -Encoding $encodeFormat -NoTypeInformation

    if ($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent)
    {
      Stop-Transcript
    }

} #end function

function Export-AllSPListFieldsToCsv{
  <#
      .SYNOPSIS
      Exports one csv file per SPLLCT of the field names and descriptions of every SPLLCT listed in the SPLLCTList.json Template folder 

      .DESCRIPTION
      Exports the name, internal name and description of the fields in each Observation

      .PARAMETER $yourCredentialName
      Username and password created with Set-Credential

      .INPUTS
      A short form name for a credential that has been previously created using Set-Credential

      .OUTPUTS
      A csv file for each SPLLCT site with the observation field names in the SharePoint List

      .EXAMPLE
      Export-AllSPListFieldsToCsv -yourCredentialName DWAN

      .LINK
      Links to further documentation.

      .NOTES
      Overwrites existing csv files named  <nick>.csv Does not append data.

  #>
  param (
    [Parameter(Mandatory,
    HelpMessage='Enter the short form name of your credentials')] 
    [ValidateNotNullorEmpty()]
  [string]$yourCredentialName)
    
  if (-not (Get-Module -Name SharepointSDK)) {
    Import-Module -Name N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools\sharepointsdk\sharepointsdk.psm1
  }
    
  if (-not (Get-Module -Name CredentialsManager)) {
    Import-Module -Name N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools\CredentialsManager\CredentialsManager.psm1
  }
  
  

  if (($yourCredentialName -eq $Null) -or ($yourCredentialName -eq ''))
  {
    $yourCredentialName = Read-Host -Prompt 'Enter the name of the credential to use. If you have not created one exit and use Set-Credential'
    
  }
  try {
    $cred = Read-Credential -Environment $yourCredentialName
  }
  catch {
    throw 'This credential is not valid. Enter the name of the credential to use not your username.'
  
  }  
 
  $spllctSites = Get-Content -Raw -Path  ('{0}\Templates\SPLLCTList.json' -f $MyInvocation.MyCommand.Module.ModuleBase) | ConvertFrom-Json

  Foreach ($site in $spllctSites) 
  {
    $nick     = $site.shortName
    $siteUrl  = $site.baseUrl
    $siteList = $site.observationListName
    
    Write-output -InputObject $nick

    Export-SPListFieldNamesToCsv -spSiteUrl $siteUrl -spListName $siteList -SPLLCTName $nick -credentialName $yourCredentialName
  }

} #end function

function Export-SpListByShortName{
  <#
      .SYNOPSIS
      Given a short form name from the template export all the observations to a csv file in your documents folder 

      .DESCRIPTION
      still a work in progress as needs dynamic field mapping

      .PARAMETER $$SPLLCTName
      .PARAMETER $thisCredentialName


      .INPUTS
      A string representing the short name of the credential

      .OUTPUTS
      Nothing

      .EXAMPLE
      Export-SpListByShortName -SPLLCTName 'DGIMPD' -thisCredentialName 'DWAN'

      .LINK
      Links to further documentation.

      .NOTES
      Detail on what the script does, if this is needed.

  #>
   param( [Parameter(Mandatory,
    HelpMessage='Enter the short form name of the SharePoint site from the template')] 
    [string]$SPLLCTName,
    [Parameter(Mandatory,
    HelpMessage='Enter the short form name of your credentials')] 
    [ValidateNotNullorEmpty()]
    [string]$thisCredentialName)
    
      if (-not (Get-Module -Name SharepointSDK)) {
    Import-Module -Name N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools\sharepointsdk\sharepointsdk.psm1
  }
    
  if (-not (Get-Module -Name CredentialsManager)) {
    Import-Module -Name N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools\CredentialsManager\CredentialsManager.psm1
  }
  
  

  if (($thisCredentialName -eq $Null) -or ($thisCredentialName -eq ''))
  {
    $thisCredentialName = Read-Host -Prompt 'Enter the name of the credential to use. If you have not created one exit and use Set-Credential'
    
  }
  try {
    $cred = Read-Credential -Environment $thisCredentialName
  }
  catch {
    throw 'This credential is not valid. Enter the name of the credential to use not your username.'
  
  }
    $userDocumentsPath = Get-UserDocumentsPath
  
    $spllctSite = Get-Content -Raw -Path ('{0}\Templates\SPLLCTList.json' -f $MyInvocation.MyCommand.Module.ModuleBase) | ConvertFrom-Json
    $thisSite = $spllctSite | Where-Object -Property shortName -eq -Value $SPLLCTName
    
    write-output -InputObject 'short name is ', $thisSite.shortName
    write-output -InputObject 'url is ', $thisSite.baseUrl
    write-output -InputObject 'List name is ', $thisSite.observationListName
    Export-SpListToJson -spSiteUrl $thisSite.baseUrl -spListName $thisSite.observationListName -SPLLCTName $thisSite.shortName -outFolderPath $userDocumentsPath -credentialName $thisCredentialName
    
} #end function


function Export-SPListToJson{
  <#
      .SYNOPSIS
      Exports the contents of a Sharepoint List to json 

      .DESCRIPTION
      Uses Templates/SPLLCTList.json  to get the details of the List (URL, name, short form name)
      Uses SPLLCTFields/<ShortFormName>.json to map SPLLCT to DLLS

      .PARAMETER $spSiteUrl
      web address of SharePoint Observations
      .PARAMETER $spListName
      name of the list of observations to be exported
      .PARAMETER $SPLLCTName
      short form name of the SPLLCT found in the SPLLCTList.json file
      .PARAMETER $outFolderPath
      path where output will be written
      .PARAMETER $credentialName
      A short form name for your username and password. Use Set-Credential to create

      .INPUTS
      A string representing the path to the Sharepoint List

      .OUTPUTS
      A json file to a folder, usually your documents folder

      .EXAMPLE
      .\Export-SPList $siteUrl $listName $outputPath $cred

      .LINK
      https://www.powershellgallery.com/packages/SharePointSDK/2.1.6
      https://html-agility-pack.net/
      Get-SPListItem
      ConvertTo-Json

      .NOTES
      All output must be encoded in UTF8 to avoid character set conversion of french characters

  #>
  param(
    [Parameter(Mandatory,
    HelpMessage='Enter the base url of the SharePoint Site')] 
    [String]$spSiteUrl,
    [Parameter(Mandatory,
    HelpMessage='Enter the name of the list to be exported')] 
    [String]$spListName,
    [Parameter(Mandatory,
    HelpMessage='Enter the short form name of the SharePoint site from the template')] 
    [string]$SPLLCTName,
    [Parameter(Mandatory,
    HelpMessage='Enter the path to the folder where the json files will be written')] 
    [string]$outFolderPath,
    [string]$credentialName)

  #Add a library that can strip out the html code
  Add-Type -AssemblyName HtmlAgilityPack
  $dateFormat       = 'yyyy-MM-ddTHH:mm:ss.fffZ'

  'This script exports the contents of a Sharepoint List to Json files'
  $verbose =  $PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent
      if ($verbose)
     {
        'Log file started and located in same folder as this script'
        $Logfile = $MyInvocation.MyCommand.Path -replace '\.ps1$', '.log'
        Start-Transcript -Path $Logfile
      }

  #Load module which supplies or writes your credentials
  if (-not (Get-Module -Name SharepointSDK)) {
    Import-Module -Name N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools\sharepointsdk\sharepointsdk.psm1
  }
    
  if (-not (Get-Module -Name CredentialsManager)) {
    Import-Module -Name N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ConversionTools\CredentialsManager\CredentialsManager.psm1
  }

  if ( ($outFolderPath -eq $Null) -or ($outFolderPath -eq '')) 
  {
    'No path entered writing to your documents folder'
    $outFolderPath = Get-UserDocumentsPath
  }
  else
  {
    #test that the folder exists
    if(-Not ($outFolderPath | Test-Path) )
    {
      ('Folder {0} does not exist. Writing to your documents folder' -f $outFolderPath) 
      $outFolderPath = Get-UserDocumentsPath
    }
  }

  if ($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent)
  {
    Write-Verbose 'Log file started and located in same folder as this script'
    $Logfile = $outFolderPath +('{0}.log' -f $SPLLCTName)
    Start-Transcript -Path $Logfile 
  }
  
  

  if (($credentialName -eq $Null) -or ($credentialName -eq ''))
  {
    $credentialName = Read-Host -Prompt 'Enter the name of the credential to use. If you have not created one exit and use Set-Credential'
    
  }
  try {
    $cred = Read-Credential -Environment $credentialName
  }
  catch {
    throw 'This credential is not valid. Enter the name of the credential to use not your username.'
  
  }
###################start of json creation For DGIMPD only###############################
#create some place holders for html and api tags
$textOpen                 = "[{\""insert\"":\`""
$textOpenPlaceHolder      =  " txtOPlHolder "
$textClose                = "\\n\`"}]"
$textClosePlaceHolder     = " txtCPlHolder "
$textHtmlOpen             = "<p>"
$textHtmlOpenPlaceHolder  = " txtHtOPlHolder "
$textHtmlClose            = "<br/></p>"
$textHtmlClosePlaceHolder = " txtHtCPlHolder "
  
  #Create a collection and fill it with the Observations
  $SPListItemCollection = Get-SPListItem -SiteUrl $spSiteUrl -ListName $spListName -Credential $cred -IsSPO $false 

  #iterate through the collection creating a json object for each observation
  foreach($ListItem in $SPListItemCollection )
  {
    #set up some fields we need later
    $username  = $ListItem.Editor.Email.Substring(0, $ListItem.Editor.Email.lastIndexOf('@'))
    $TextInfo  = (Get-Culture).TextInfo
    $fileTitle = $TextInfo.ToTitleCase($ListItem.Title) -replace '[^a-zA-Z]', ''

    #1.1 create nested entries in actionBy Object
    $actionBy = @()
    $actionBy += [PSCustomObject]@{
      displayName = $ListItem.Editor.LookupValue
      domain   = "FORCES"
      username = $username
      email    = $ListItem.Editor.Email
    } 

    #1.2 nest this in the createAction object
    $createAction = @()
    $createAction += [PSCustomObject]@{
      actionId       ="Created"
      actionContextId ="A"
      actionBy        = $actionBy
      actionAtUtc     = (Get-Date -Date $ListItem.Modified -Format $dateFormat) 
    }
    #1.3 create last action object
    $lastAction = @()
    $lastAction += [PSCustomObject]@{
      actionId="Submitted"
      actionContextId="A"
      actionBy = $actionBy
      actionAtUtc = (Get-Date -Date $ListItem.Modified -Format $dateFormat)
    }
    #1.4 create  status object
    $status = @()
    $status += [PSCustomObject]@{
      B="Ready"
      A="Submitted"
    }
    #1.5  dotmplfi  ugly, ugly hack for single member of a Json List
    #because we remove all the  [ and ] later as they are rejected by the api every other
    #place except here and the history object
    $dotmplfi = "openBracket" + "22a23acc-e1ef-444c-b08f-2134fa4b5a75" + "closeBracket"

  
    #1.6 create history action
    $histAction = @()
    $histAction += [PSCustomObject]@{
      actionId        ="Created"
      actionContextId ="A"
      actionBy        = $actionBy
    }
    #1.7 nest this in history Entry
    $historyEntry = @()
    $historyEntry += [PSCustomObject]@{
        historyAction  = $histAction
        actionAtUtc    = (Get-Date -Date $ListItem.Modified -Format $dateFormat)
        assignedTo     = $null
        complexDetails = $null
    }

    #1.8 identification:  hard coded values should be changed
    #to call some functions to map any data
    $obsIdentification = @()
    $obsIdentification+= [PSCustomObject]@{
        l1Id = "8ce9e156-f9b6-44db-97bd-a93930f6b057"
        l2Id = $null
        globalTopicArea = "6c835eb8-ad2b-4698-93ef-921881118782"
        activityList  = $null
        keywordList   = $null
        dotmlpfi      = $dotmplfi
        riskSeverity  = "3704bf79-2998-4b34-a9a0-9267042f5f4c"
        riskFrequency = "1ecb8d0f-b8d5-4bb6-b69a-e18041676684"
    }
    #1.9 modify action
    $modifyAction = @()
    $modifyAction += [PSCustomObject]@{
        actionId = "Modified"
        actionContextId = "A"
        actionBy = $actionBy
    }
    #1.10 part A sub fields
    $doc = New-Object -TypeName HtmlAgilityPack.HtmlDocument
    $doc.LoadHtml($ListItem.Statement_x0020_of_x0020_Context)
    #1.11 background
    $complexBackground = @()
    $complexBackground += [PSCustomObject]@{
        value     = $textOpenPlaceHolder     + $doc.DocumentNode.InnerText + $textClosePlaceHolder
        valueHtml = $textHtmlOpenPlaceHolder + $doc.DocumentNode.InnerText + $textHtmlClosePlaceHolder
    }
    #1.12 observation
    $doc.LoadHtml($ListItem.Observations)
    $complexObservation = @()
    $complexObservation += @{
        value     = $textOpenPlaceHolder     + $doc.DocumentNode.InnerText + $textClosePlaceHolder
        valueHtml = $textHtmlOpenPlaceHolder + $doc.DocumentNode.InnerText + $textHtmlClosePlaceHolder
    }
    #1.13 recommendation
    $doc.LoadHtml($ListItem.Recommendations)
    $complexRecommendations = @()
    $complexRecommendations += @{
        value     = $textOpenPlaceHolder     + $doc.DocumentNode.InnerText + $textClosePlaceHolder
        valueHtml = $textHtmlOpenPlaceHolder + $doc.DocumentNode.InnerText + $textHtmlClosePlaceHolder
    }

    #1.14 part A
    $partA = @()
    $partA+= [PSCustomObject]@{
        editUser      = $actionBy
        nextUser      = $actionBy
        modifyAction  = $modifyAction
        actionAtUtc   = (Get-Date -Date $ListItem.Modified -Format $dateFormat)
        submitAction  = $lastAction
        archiveAction = $null
        lastAction    = $null
        submitNotification = $null
        proceedLfr    = $null
        complexBackground  = $complexBackground 
        complexObservation = $complexObservation
        complexRecommendations = $complexRecommendations
        complexArchivedRationale = $null
    }

    $partB  = @()
    $partB += [PSCustomObject]@{
        editUser        = $actionBy
        modifyAction    = $null
        submitAction    = $null
        archiveAction   = $null
        lastAction      = $null
        proceedLfr      = $null
        complexFindings = $complexObservation
        complexRecommendations = $complexRecommendations
        complexArchiveRationale = $null
    }
 

    #2 create the json observation
    $cleanedObs = @()
    $cleanedObs += [PSCustomObject]@{
        id     = $null
        systemUpdate = $null
        correlationId = $null
        externalCorrelationId = $null
        createAction = $createAction
        lastAction   = $lastAction
        lastSubmitToAction = $null
        classificationLevelId= "92dce20c-e580-42c8-8156-1c05bd2b3dc8"
        status = $status
        isArchived = $false
        attentionRequiredUsername = $username
        observationNumber = $null
        title = $ListItem.Title
        attachmentList = $null  #when you pass null to an array it is entered as []
        assignmententryList = $null
        historyEntryList = $historyEntry
        identification = $obsIdentification
        partA = $partA
        partB = $partB
    }
      

    #3 send the powershell object to a json file 
    $fileName = ('{0}_{1}.json' -f $SPLLCTName,$fileTitle )
    convertTo-Json -InputObject $cleanedObs -Depth 99 | Set-Content  `
    -Path  ('{0}\{1}' -f  $outFolderPath, $fileName) `
    -Encoding $encodeFormat -Force 

    #4 clean up 
    #add the opening brackets back around the history entry
    #add brackets around the dotmplfi list which the api only needs here
    #replace the placeholders for large text fields with a special sequence
    #that there is no good reason for except it doesnt work otherwise
    $newPath =('N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ExportedData\Staging\{0}' -f  $fileName)
    Get-Content -Path ('{0}{1}' -f  $outFolderPath, $fileName) | ForEach-Object{
        $_ -replace [Regex]::Escape("["),""  `
           -replace [Regex]::Escape("]"), "" `
           -replace "historyEntryList`":" ,"historyEntryList`": [" `
           -replace [Regex]::Escape("""openBracket"), "[""" `
           -replace [Regex]::Escape("closeBracket"""), """]" `
           -replace $textOpenPlaceHolder, $textOpen `
           -replace $textClosePlaceHolder, $textClose `
           -replace $textHtmlOpenPlaceHolder, [Regex]::Escape($textHtmlOpen) `
           -replace $textHtmlClosePlaceHolder, [Regex]::Escape($textHtmlClose) `
    } | Set-Content $newPath

    #put back a ] square bracket on line 71 as the API requires it for the history entry
    $content = Get-Content -Path $newPath -Encoding $encodeFormat
    $content[70] = '],'
    $newPath =('N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ExportedData\{0}' -f $fileName )
    $content | Set-Content -Path $newPath -Encoding $encodeFormat

  } #end for each   

    if ($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent)
  {
    Stop-Transcript
  }

} #end function

function script:Import-JsonToDLLS{
  <#
      .SYNOPSIS
      Accepts a path to a folder where json files are located. Reads these files
      and writes out the content to a REST API

      .DESCRIPTION
      Converts each json file into a Rest API call with UTF8 encoding

      .PARAMETER $inFolderPath
      The path to the folder where the json files are located
      .PARAMETER $outUri
      The uri of the web site API

      .INPUTS
      A string representing the folder path

      .OUTPUTS
      A response from the Swagger API

      .EXAMPLE

      $in      = 'N:\0_DGIMPD_DGRPGI\0_DPDCC\C2MP\DLLS\ExportedData'
      $outUri  = 'http://eis-ls2-av07130:7016/api/v1/Observations'
       ./Import-JsonToDLLS  $in  $outUri

      .LINK
      Get-Content
      Invoke-RestMethod

      .NOTES
      Folder paths have a \ added at the end to construct the file names

  #>
  param (
    [Parameter(Mandatory,
    HelpMessage='Enter the path to the folder where the json files are located')] 
    [ValidateScript({Test-Path -Path $_})]
    [string]$inFolderPath,
    [Parameter(Mandatory,
    HelpMessage='Enter the uri to the API where the json files will be written')] 
    [string]$outUri) #,
    #[Parameter(Mandatory,
    #HelpMessage='Enter the short form name of the list to be imported')] 
    #[String]$spListName)

  

                         function Get-JsonFiles
                         {
                           <#
                             .SYNOPSIS
                             Filters for file types ending in .json

                             .DESCRIPTION
                             Acts on all files within a folder.

                             .PARAMETER InputObject
                             A directory.

                             .EXAMPLE
                              $jsonList = $Dir | Get-JsonFiles

                             .INPUTS
                             A directory.

                             .OUTPUTS
                             An array of file items of type json
                           #>


                           param
                           (
                             [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Filtering for json files')]
                             [PSObject]$InputObject
                           )
                           process
                           {
                             if ($InputObject.extension -eq '.json')
                             {
                               $InputObject
                             }
                           }
                         }

    $headers = ""
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type","application/json")
    $headers.Add("Accept","application/json")
    <#no credentials required currently but they would be added here
    $restUserName = "xxxxx"
    $restUserPass = "xxxxx"
    $headers.Add("X-Auth-user  = $restUserName; "X-Auth-Password" = $restUserPass)
    or another example
    $username = Read-Host “Enter username: “
    $password = Read-Host “Enter password: “
    $userpass  = $username + “:” + $password
    $bytes= [System.Text.Encoding]::UTF8.GetBytes($userpass)
    $encodedlogin=[Convert]::ToBase64String($bytes)
    $authheader = "Basic " + $encodedlogin
    $headers.Add("Authorization",$authheader)
    #>

  $Dir = get-childitem -Path $inFolderPath

  $jsonList = $Dir | Get-JsonFiles

  ForEach($jsonFile in $jsonList)
  {
    $inFile  = $inFolderPath + '\' + $jsonFile.Name
    $trimmedFileName = $jsonFile.BaseName
    $json = Get-Content $inFile -Raw -Encoding $encodeFormat

    try{

        $response = ""
        $response = Invoke-RestMethod -Uri $outUri -Headers $headers -Method Post -Body $json -ContentType "application/json" 
       }
    catch {
        Write-Output "`n"
        Write-Error $_.Exception
        Write-Output $response.details
        Write-Output "`n"
       }
       Write-Output "`n"
       Write-Output $trimmedFileName " processed with details=" 
       Write-Output "`n"
       Write-Output $response
  } #end for each
} #end function

function Get-UserDocumentsPath{
  <#
      .SYNOPSIS
      Internal function to return the path to the users documents folder 

      .DESCRIPTION
      In case the user does not enter a folder path we use their documents folder where we know they have write permission

      .PARAMETER $userDocuments
      returns the path to the user's documents folder

      .INPUTS
      No inputs

      .OUTPUTS
      System.String  path to the users documents folder

      .EXAMPLE
       $outFolderPath = Get-UserDocumentsPath

      .LINK
      about_Environment_Variables

  #>


  return  [Environment]::GetFolderPath('MyDocuments') + '\'
} #end function


