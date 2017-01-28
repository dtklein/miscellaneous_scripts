[System.Collections.ArrayList]$Left=@(
    "Good",
    "Bad",
    "Sweet",
    "Ripe",
    "Unclear",
    "Devout",
    "Subtle",
    "Endangered",
    "Reflective",
    "Pacifist",
    "Brittle",
    "Enraged",
    "Egalitarian",
    "Golden",
    "Irridescant",
    "Glowing"
) ;
[System.Collections.ArrayList]$Right=@(
    "Donut",
    "Chocolate",
    "HumblePie",
    "Banana",
    "Judgement",
    "Decision",
    "Employment",
    "Elephant",
    "Combattant",
    "Performer",
    "Judge",
    "Librarian",
    "Leotard",
    "Jaguar",
    "Fox",
    "Metermaid",
    "Mermaid",
    "Trident"
) ;
 
$Left_Index=Get-Random -SetSeed ((Get-Date).Millisecond) -Minimum 0 -Maximum $Left.Count ;
$Right_Index=Get-Random -SetSeed ((Get-Date).Millisecond) -Minimum 0 -Maximum $Right.Count ;
 
[System.String]$Name= $Left[$Left_Index].ToUpper() + $Right[$Right_Index].ToUpper() + "`r`n" ;
$Name |Write-Output ;