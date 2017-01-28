[CmdletBinding()]Param() ;


## This is to fix an annoying bug in the interaction between the Windows metro icons in Windows 10 flag-menu and Chrome apps, which have chrome.exe as the executable
## For whatever reason, when you pin a chrome app to start, it puts the icon of the executable in the wide part of the flag-menu instead of the launcher-specific icon
## Making this weirder, it seems that the icon is evaluated at the time that the launcher is moved into the start menu (the main cascading folders part, not the wide part)
## Apparently if the VisualElementsManifest isn't found in the Chrome Application folder, it will actually look into the launcher and get the specified icon file to dislay
## Just for my records, this file resides in the "C:\Program Files (x86)\Google\Chrome\Application" folder, and this folder requires root access to make changes
## Looking in the VisualElementsManifest file, there is not much content there, so I am renaming it to hide it, and then move the launchers back to the start menu, so they
## will be reevaluated. I could probably delete it, but I am concerned I might break something. 
## This was learned from Neil Tay's post and grberk's follow-up in https://productforums.google.com/forum/#!msg/chrome/H_G-xgNSkPs/RVdDaRJaBgAJ
## And unlike that answer, you don't appear to have to remove / unpin the app icons from the wide part of the flag menu for it to work



## Flagrantly stolen from https://poshoholic.com/2009/01/19/powershell-quick-tip-how-to-retrieve-the-current-line-number-and-file-name-in-your-powershell-script/ 
## because the actual behavior of $MyInvocation.ScriptLineNumber was making me angry and I could not figure out. 
## Now I understand better it is more about when it is executed than when its value is observed

function Get-CurrentLineNumber { 
    return($MyInvocation.ScriptLineNumber) ;
}

function Get-CurrentFileName { 
    ## Only taking the basename, as keeping the full dirname + basename makes the debug lines below really long
    return($MyInvocation.ScriptName.Split("\")[-1]) ;
}


"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Running " + $MyInvocation.MyCommand + " as the user " + ([System.Security.Principal.WindowsPrincipal]([System.Security.Principal.WindowsIdentity]::GetCurrent())).Identity.Name |Write-Debug ;

[System.String]$GUID=[guid]::NewGuid().toString() ;
"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Will use " + $GUID + " as the UUID for this script" |Write-Debug ;
[System.String]$Working_Dir=$env:TEMP + "\" + $GUID ;
"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Will put Chrome App icons into " + $Working_Dir + " while I get rid of the VisualElementsManifest" |Write-Debug ;
[System.String]$Chrome_Shortcut_Directory=$env:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Chrome Apps" ;
"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Will get the chrome icons from " + $Chrome_Shortcut_Directory |Write-Debug ;
[System.String]$Chrome_Application_Directory=${env:ProgramFiles(x86)} + "\Google\Chrome\Application" ;
"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Will find the VisualElementsManifest file in the " + $Chrome_Application_Directory + " folder" |Write-Debug ;



try {
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Creating a working folder called " + $GUID + " inside " + $env:TEMP |Write-Debug ;
    New-Item -ItemType Directory -Path $env:TEMP -Name $GUID -ErrorAction Stop |Out-Null ;
} catch {
    $Caught_Error=$Error[0].Exception.Message ;
}

try {
    Get-Item -Path $Working_Dir -ErrorAction Stop |Out-Null ;
} catch {
    $Caught_Error=$Error[0].Exception.Message ;
    [System.String]$mkdir_failed_message="Cannot find path '" + $Working_Dir + "' because it does not exist." ;
    if($Caught_Error -match $mkdir_failed_message) {
        Write-Error "Exiting because we could not make or could not find the working folder" ;
    }
    Write-Error $Caught_Error ;
    Break ;
}

"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Going to move " + (Get-ChildItem -Path $Chrome_Shortcut_Directory).Length + " items from the " + $Chrome_Shortcut_Directory + " folder" |Write-Debug ;

"`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n" |Write-Debug ;

[System.Int16]$fileno=0 ;

foreach($chrapp in (Get-ChildItem -Path $Chrome_Shortcut_Directory)) {
    ## Move the launchers out, so I can move them back in, so they will be reevaluated
    [System.String]$OldPath=$Chrome_Shortcut_Directory + "\" + $chrapp ;
    Move-Item -Path $OldPath -Destination $Working_Dir ;
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Moving file number " + ++$fileno + " from " + $OldPath + " to " + $Working_Dir |Write-Debug ;
}

Remove-Variable fileno ;

"`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n" |Write-Debug ;

$ScriptBlock={
    [CmdletBinding()]Param(
        [Parameter(Mandatory=$true,Position=0)][System.String]$Chrome_Application_Directory 
    )

    function Get-CurrentLineNumber { 
        return($MyInvocation.ScriptLineNumber) ;
    }

    function Get-CurrentFileName { 
        return($MyInvocation.ScriptName.Split('"""\"""')[-1]) ;
    }

    '"""On line """' + (Get-CurrentLineNumber) + '""" in file """' + (Get-CurrentFileName) + '""" :`t"""' +'"""Going to fix the VisualElementsManifest in folder """' + $Chrome_Application_Directory |Write-Debug ;

    [System.String]$OldPath=$Chrome_Application_Directory + '"""\chrome.VisualElementsManifest.xml"""' ;
    '"""On line """' + (Get-CurrentLineNumber) + '""" in file """' + (Get-CurrentFileName) + '""" :`t"""' + '"""Old Path Name is: """' + $OldPath |Write-Debug ;
    [System.String]$NewName=$Chrome_Application_Directory + '"""\chrome.VisualElementsManifest.xml."""' + $GUID ;
    '"""On line """' + (Get-CurrentLineNumber) + '""" in file """' + (Get-CurrentFileName) + '""" :`t"""' + '"""New Name is: """' + $NewName |Write-Debug ;
    
    try {
        Rename-Item -Path $OldPath -NewName $NewName ;
        '"""On line """' + (Get-CurrentLineNumber) + '""" in file """' + (Get-CurrentFileName) + '""" :`t"""' + '"""Renaming the file """' + $OldPath + '""" to """' + $NewName |Write-Debug ;
        Get-ItemProperty -Path $NewName |Write-Debug ;
    } catch {
        $Caught_Error=$Error[0].Exception.Message ;
        Write-Error $Caught_Error ;
    }
}


"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Going to elevate to root so I can rename the VisualElementsManifest in folder " + $Chrome_Application_Directory |Write-Debug ;


## Apparently the only straightforward way (staying within powershell) to step-up rights with UAC is to use Start-Process, which is not as friendly as Invoke-Command or similar
## I finally got it after going round-and-round and landing on https://stackoverflow.com/questions/22544930/powershell-executing-a-function-within-a-script-block-using-start-process-does-w for the third time
## It's a mix of "{ & { do_stuff } }" and single-quotes around double-quotes. This is really hideous syntax, MSFT. Please add a commandlet like "Execute-ElevatedCommand" that can be called simply and directly 


Start-Process -Verb RunAs powershell.exe -ArgumentList "-NoExit -Command & {$ScriptBlock } -Debug" ;

"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Going to move " + (Get-ChildItem -Path $Working_Dir).Length + " items from the " + $Working_Dir + " folder" |Write-Debug ;

"`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n" |Write-Debug ;

[System.Int16]$fileno=0 ;

foreach($chrapp in (Get-ChildItem -Path $Working_Dir)) {
    ## Now when they move back in, Windows will reevaluate their icons from the launcher files instead of the chrome.exe
    [System.String]$OldPath=$Working_Dir + "\" + $chrapp ;
    Move-Item -Path $OldPath -Destination $Chrome_Shortcut_Directory ;
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Moving file number " + ++$fileno + " from " + $OldPath + " to " + $Chrome_Shortcut_Directory |Write-Debug ;
}

"`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n" |Write-Debug ;

Remove-Item -Path $Working_Dir ;
"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Removing working folder " + $Working_Dir |Write-Debug ;
#>