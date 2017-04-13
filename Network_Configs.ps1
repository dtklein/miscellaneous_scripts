﻿
[System.Collections.ArrayList]$ifaces=New-Object -TypeName System.Collections.ArrayList ;
[System.Collections.ArrayList]$gateways=New-Object -TypeName System.Collections.ArrayList ;
$NWConfig=@{} ;

Get-NetIPAddress |Where-Object { $_.IPv4Address -notmatch "^((127|169)\.|$)" } |% {
    $InterfaceAlias=$_.InterfaceAlias ;
    $IPv4Address=$_.IPv4Address ;
    $PrefixLength=[System.Convert]::ToUInt32($_.PrefixLength) ;
    $Hostmask=32-$PrefixLength ;
    $BitString="".PadLeft($PrefixLength,"1") + "".PadRight($Hostmask,"0") ;
    $SubnetMask=[System.String]::join(
        ".",
        @(
            ([System.Convert]::ToUInt16($BitString.Substring(0,8),2)).toString() ,
            ([System.Convert]::ToUInt16($BitString.Substring(7,8),2)).toString() ,
            ([System.Convert]::ToUInt16($BitString.Substring(15,8),2)).toString() ,
            ([System.Convert]::ToUInt16($BitString.Substring(23,8),2)).toString() 
        )
    ) ;
    $DNSClientServerAddress=(Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias |Where-Object { $_.AddressFamily -eq 2 }).Address ;
    $ThisInterface=New-Object -TypeName psobject -Property ([ordered]@{
        "Interface Alias" = $InterfaceAlias ;
        "IPv4 Address" = $IPv4Address ;
        "Prefix Length" = $PrefixLength ;
        "Subnet Mask" = $SubnetMask ;
        "DNS Server" = $DNSClientServerAddress ;
    }) ;
    $ifaces.Add($ThisInterface) ;
    # $InterfaceAlias + ":`t" + $IPv4Address + "/" + $PrefixLength + ":`t" + $SubnetMask + "`r`n" |Write-Output ;
}

Get-NetRoute -DestinationPrefix 0.0.0.0/0 |select InterfaceAlias,NextHop |% { $gateways.Add($_) } 

$NWConfig.Add("Interfaces",$ifaces) 
$NWConfig.Add("Gateways",$gateways)

$NWConfig |ConvertTo-Json |Write-Output 

