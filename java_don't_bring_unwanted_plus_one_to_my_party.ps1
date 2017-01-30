[CmdletBinding()]Param() ;

## This script prevents the Java installer from offering to install unwanted third-party applications like IE toolbars and other dreck
## To achieve this, you need to add two registry keys
##    HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft: "SPONSORS"="DISABLE"
##    HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft: "SPONSORS"="DISABLE"
## Additionally, you need to add at least the following parm in the deployment.properties file in the %WINDIR%\Sun\Java\Deployment folder
##    install.disable.sponsor.offers=true  
## While you're in there, you might as well set a few other parms, like sane TLS and code-signing settings
##
## Note, this has to be run as root, and this scrupt doesn't assume that you are already in a privileged session
## To get around that, it steps up to a privileged session using UAC
##



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



## The parm-file in %WINDIR% 
## I am setting up a backup of it, just in case I screw up it 
##
[System.String]$file='{0}\Sun\Java\Deployment\deployment.properties' -f $env:WINDIR ;
[System.String]$GUID=[guid]::NewGuid().toString() ;
[System.String]$saved_file='{0}.{1}' -f $file,$GUID ;

"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Running " + $MyInvocation.MyCommand + " as the user " + ([System.Security.Principal.WindowsPrincipal]([System.Security.Principal.WindowsIdentity]::GetCurrent())).Identity.Name |Write-Debug ;
"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Going to check parameters in " + $file + " and save a backup to  " + $saved_file |Write-Debug ;

$parms=[ordered]@{} ;

[System.Int16]$RowNum=0 ;

"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Input parm-file: `r`n" + (Get-Content $file) + "`r`n`r`n" |Write-Debug ;

## Ingest the original parm file, read it line-by-line, identify named parms, shove them into an ordered hasttable (which I don't get how that exists, but it is awesome)

foreach($parm in (Get-Content $file)) {
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Row number: " + ++$RowNum + " of the input parm file" |Write-Debug ;
    if($parm -match '^#') {
        "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Found a comment the reads: " + $parm |Write-Debug ;
    } elseif($parm -match '^[ `t]*$' ) {
        "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Found an empty line" |Write-Debug ;
    } else {
        ($parm_name,$parm_value)=$parm.split('=') ;
        "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Found parm named " + $parm_name + " with value " + $parm_value |Write-Debug ;
        $parms.Add($parm_name,$parm_value) ;
    }
}

"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Before Modifications: `r`n" + ($parms |Format-Table -AutoSize |Out-String) + "`r`n`r`n" |Write-Debug ;

## Look for the parm named install.disable.sponsor.offers
## If it exists and it is not set to true, remove it, so we can shove-in one that is

if($parms.Contains("install.disable.sponsor.offers") -and $parms."install.disable.sponsor.offers" -ne "true") {
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Removing parm called `"install.disable.sponsor.offers`" with value " + $parms."install.disable.sponsor.offers" |Write-Debug ;
    $parms.Remove("install.disable.sponsor.offers") ;
}

## We're going to set it to true and then lock it because I want install.disable.sponsor.offers to say in-place 

"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Adding install.disable.sponsor.offers=true" |Write-Debug ;
$parms.Add("install.disable.sponsor.offers","true") ;
"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Locking install.disable.sponsor.offers parm" |Write-Debug ;
$parms.Add("install.disable.sponsor.offers.locked","true") ;

## Here is what the parms will look like now

"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "After Modifications`r`n`r`n"+ ($parms |Format-Table -AutoSize |Out-String) + "`r`n`r`n" |Write-Debug ;

## Just to hold the layout of the new file that we will build-up line-by-line, because I am lame and don't know a functional way to Hashtabe --> Ini file in one fell-swoop

[System.Collections.ArrayList]$Output_File_Contents=New-Object -TypeName System.Collections.ArrayList ;

foreach($parm in $parms.Keys) {
    [void]$Output_File_Contents.Add([System.String]::Join('=',@($parm,$parms.$parm))) ;
} 


"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "After Modifications, file " + $file + " will look like: `r`n" + [System.String]::Join("`r`n",$Output_File_Contents.ToArray()) + "`r`n`r`n" |Write-Debug ;

[System.String]$Registry_commands ;

try {
    $JWowProp=(Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft").SPONSORS ;
    if(!($JWowProp -eq 'DISABLE')) {
        "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "A property called SPONSORS on registry key [HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft] was found with value " + $JWowProp |Write-Debug ;
        $Registry_commands="{0}`r`nRemove-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft' -Name 'SPONSORS'" -f $Registry_commands ;
    }
} catch {
    $Error[0].Exception.Message |Write-Warning ;
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "A property called SPONSORS on registry key [HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft] doesn't appear to exist" |Write-Debug ;
} finally {
    $Registry_commands="{0}`r`nNew-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft' -Name 'SPONSORS' -Value 'DISABLE' -PropertyType 'String'" -f $Registry_commands ;
    Remove-Variable JWowProp ;
}


try {
    $JWowProp=(Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft").SPONSORS ;
    if(!($JWowProp -eq 'DISABLE')) {
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "A property called SPONSORS on registry key [HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft] was found with value " + $JWowProp |Write-Debug ;
        $Registry_commands="{0}`r`nRemove-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft' -Name 'SPONSORS'" -f $Registry_commands ;
    }
} catch {
    $Error[0].Exception.Message |Write-Warning ;
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "A property called SPONSORS on registry key [HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft] doesn't appear to exist" |Write-Debug ;
} finally {
    $Registry_commands="{0}`r`nNew-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft' -Name 'SPONSORS' -Value 'DISABLE' -PropertyType 'String'" -f $Registry_commands ;
    Remove-Variable JWowProp ;
}



[System.String]$Privileged_Commands=@"
Copy-Item -Path {0} -Destination {1} ;
Set-Content -Path {2} -Value """{3}""" ;
{4}
"@ -f $file,$saved_file,$file,[System.String]::Join("`r`n",$Output_File_Contents.ToArray()),$Registry_commands ;



"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "As root, I am going to execute the following commands: `r`n" + $Privileged_Commands |Write-Debug ;


## Step up rights using UAC to run as a root-equivalent user and execute the commands that we setup above

Start-Process `
    -Verb RunAs `
    (Get-Command powershell.exe).Definition `
    -ArgumentList `
        " -NoExit",`
        " -ExecutionPolicy Unrestricted", `
        " -Command", `
        $Privileged_Commands ;

<# #>


## Check the contents of the deployment.properties file 


"On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "Contents of deployment.properties file: `r`n" + (Get-Content -Path $file |Out-String) |Write-Debug ;

if((Get-Content -Path $file) -contains"install.disable.sponsor.offers=true") {
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "deployment.properties has disabled sponsor offers" |Write-Output ;
}

if((Get-Content -Path $file) -contains"install.disable.sponsor.offers.locked") {
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "deployment.properties has locked sponsor offers" |Write-Output ;
}

if((Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft").SPONSORS -eq 'DISABLE') {
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "SPONSOR is set to disable in 32bit JavaSoft" |Write-Output ;
}

if((Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft").SPONSORS -eq 'DISABLE') {
    "On line " + (Get-CurrentLineNumber) + " in file " + (Get-CurrentFileName) +" :`t" + "SPONSOR is set to disable in 64bit JavaSoft" |Write-Output ;
}


