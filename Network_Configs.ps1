
[System.Collections.ArrayList]$ifaces=New-Object -TypeName System.Collections.ArrayList ;
[System.Collections.ArrayList]$gateways=New-Object -TypeName System.Collections.ArrayList ;
$NWConfig=@{} ;

Get-NetIPAddress |select InterfaceAlias,IPv4Address |Where-Object { $_.IPv4Address -notmatch "^((127|169)\.|$)" } |% {$ifaces.Add($_)} 
Get-NetRoute -DestinationPrefix 0.0.0.0/0 |select InterfaceAlias,NextHop |% { $gateways.Add($_) } 

$NWConfig.Add("Interfaces",$ifaces) 
$NWConfig.Add("Gateways",$gateways)

$NWConfig |ConvertTo-Json |Write-Output 

