#Import AD module
Import-Module ActiveDirectory

$ErrorActionPreference = "SilentlyContinue"

$searchbase = "DC=domain,DC=local"
$inactiveOU = "ou=Unused Computers,DC=domain,DC=local"
$Days = (Get-Date).AddDays(-60)
$computers = Get-ADComputer -Properties * -Filter {LastLogonDate -lt $Days} -SearchBase "DC=domain,DC=local"
$DisabledComps = Get-ADComputer -Properties Name,Enabled,LastLogonDate -Filter {(Enabled -eq "False" -and LastLogonDate -lt $Days)} -SearchBase "ou=Unused Computers,DC=concise,DC=local"

#Move inactive computer accounts to your inactive OU
foreach ($computer in $computers) {	
	Set-ADComputer $computer -Location $computer.LastLogonDate | Set-ADComputer $computer -Enabled $false 
	Move-ADObject -Identity $computer.ObjectGUID -TargetPath "ou=Unused Computers,DC=domain,DC=local"
	}