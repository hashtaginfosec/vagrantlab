# Requires PowerShell ADModule to be installed. 
# See https://4sysops.com/wiki/how-to-install-the-powershell-active-directory-module/

# Current domain
Write-Host "[+] Current domain is:"  (Get-ADDomain).Name

# Domain Controllers
Write-Host "[+] Domain Controllers are:" 
Get-ADDomaincontroller | Select Name, IPv4Address, IPv6Address, IsReadOnly, OperatingSystem | Out-Default
start-sleep 1
# Domain Trust
Write-Host "[+] If any trusts exist, those are:" 
Get-ADTrust -Filter * | select Name, Source,Target,Direction,IntraForest

# Forests
Write-Host "[+] Listing Forests." 
Get-ADForest | select Name, Domains | Out-Default


# All users.
Write-Host "[+] Listing all Users."
Get-ADUser -Filter * |select SamAccountName, enabled | Out-Default

# All computers.
Write-Host "[+] Listing all computers."
Get-ADComputer -Filter * -Properties OperatingSystem | Select Name,Enabled,OperatingSystem

# Kerberoastable users.
Write-Host "[+] Listing all kerberoastable users."
Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName | Select name, ServicePrincipalName | Out-Default

# ASREP roastable users.
Write-Host "[+] Listing all ASREP Roastable Users, if any."
Get-ADUser -Filter {DoesNotRequirePreauth -eq $True} -Properties DoesNotRequirePreAuth | select name, DoesNotRequirePreAuth| Out-Default

# Domain Admins.
Write-Host "[+] Listing all domain admins."
(Get-ADGroupMember -Identity "Domain Admins" -Recursive).SamAccountName | Out-Default

# Users with admin in their name.
Write-Host "[+] Listing all users with admin in their name"
Get-ADUser -Filter "Name -like 'admin*'" |select SamAccountName, enabled | Out-Default

# Unconstrained delegation.
Write-Host "[+] Listing computers allowed unconstrained delegation. It is required for the DC to have unconstrained delegation. Any other sytsems showing here should be reviewed."
Get-ADComputer -Filter {TrustedForDelegation -eq $True} -Properties TrustedForDelegation | select name, TrustedForDelegation | Out-Default

Write-Host "[+] Listing all unconstrained delegation users. This is not normal and should be reviwed."
Get-ADUser -Filter {TrustedForDelegation -eq $True} -Properties TrustedForDelegation |select SamAccountName,TrustedForDelegation| Out-Default

# Constrained delegation.
Write-Host "[+] Listing all computers with constrained delegation. This should be reviwed."
Get-ADComputer -Filter {msDS-AllowedToDelegateTo -ne "$null"} -Properties msDS-AllowedToDelegateTo |select DNSHostName, msDS-AllowedToDelegateTo | Out-Default

# GPOs

Write-Host "[+] Printing permission for all GPOs."
$GPOs = Get-GPO -All
ForEach($GPO In $GPOs){
    $GPOPerms = Get-GPPermissions -DisplayName $GPO.DisplayName -All
    foreach ($perm in $GPOPerms) {
        $obj = New-Object -TypeName PSObject -Property @{
            GPOName  = $GPO.DisplayName
            AccountName = $($perm.trustee.name)
            AccountType = $($perm.trustee.sidtype.tostring())
            Permissions = $($perm.permission)

 }

 $obj | select GPOName, AccountName, AccountType, Permissions 

 }     

}

