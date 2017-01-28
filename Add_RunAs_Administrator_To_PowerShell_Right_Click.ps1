Start-Process -Verb RunAs powershell.exe {
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\Microsoft.PowershellScript.1\Shell\runas\command" -Force -Name '' -Value '"C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe" "%1"'

    ## If you want the RunAs to simply execute and not display the contents in an ISE window, remove the above line and replace it with
    ## New-Item -Path "Registry::HKEY_CLASSES_ROOT\Microsoft.PowershellScript.1\Shell\runas\command" -Force -Name '' -Value '"c:\windows\system32\windowspowershell\v1.0\powershell.exe" -noexit "%1"'

    ## Just remember, as Sartre would have said, "Hell is other people's scripts" and there is no exit
    ## Actually, this is more of a fail-safe for myself, so I don't accidentally run something half-baked or malicious as root-equivalent user without the chance to make the deliberate decision after viewing it
} 
