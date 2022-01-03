# Requires PowerShell ADModule to be installed. 
# See https://4sysops.com/wiki/how-to-install-the-powershell-active-directory-module/
# Alternatively, import Microsoft.ActiveDirectory.Management.dll provided in this repo.

# Echo today's date since this is a point in time snapshot.
get-date | Tee-Object -FilePath .\domain-recon.txt -Append

# Current domain

Write-Output "[+] Current domain is: "  | Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADDomain | Select-Object Name, ParentDomain, NetBIOSName, DomainMode | Tee-Object -FilePath .\domain-recon.txt -Append
# Domain Controllers
Write-Output "[+] Domain Controllers are:" | Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADDomaincontroller | Select-Object Name, IPv4Address, IPv6Address, IsReadOnly, OperatingSystem | Tee-Object -FilePath .\domain-recon.txt -Append

# Domain Trust
Write-Output "[+] If any trusts exist, those are:" | Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADTrust -Filter * | Select-Object Name, Source,Target,Direction,IntraForest| Tee-Object -FilePath .\domain-recon.txt -Append

# Forests
Write-Output "[+] Listing Forests." | Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADForest | Select-Object Name, Domains | Tee-Object -FilePath .\domain-recon.txt -Append


# All users.
Write-Output "[+] Listing all Users."| Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADUser -Filter * |Select-Object SamAccountName, enabled | Tee-Object -FilePath .\domain-recon.txt -Append

# All computers.
Write-Output "[+] Listing all computers."| Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADComputer -Filter * -Properties OperatingSystem | Select-Object Name,Enabled,OperatingSystem| Tee-Object -FilePath .\domain-recon.txt -Append

# Kerberoastable users.
Write-Output "[+] Listing all kerberoastable users."| Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName | Select-Object name, ServicePrincipalName | Tee-Object -FilePath .\domain-recon.txt -Append

# ASREP roastable users.
Write-Output "[+] Listing all ASREP Roastable Users, if any."| Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADUser -Filter {DoesNotRequirePreauth -eq $True} -Properties DoesNotRequirePreAuth | Select-Object name, DoesNotRequirePreAuth| Tee-Object -FilePath .\domain-recon.txt -Append

# Domain Admins.
Write-Output "[+] Listing all domain admins."| Tee-Object -FilePath .\domain-recon.txt -Append
(Get-ADGroupMember -Identity "Domain Admins" -Recursive).SamAccountName | Tee-Object -FilePath .\domain-recon.txt -Append

# Users with admin in their name.
Write-Output "[+] Listing all users with admin in their name"| Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADUser -Filter "Name -like 'admin*'" |Select-Object SamAccountName, enabled | Tee-Object -FilePath .\domain-recon.txt -Append

# Unconstrained delegation.
Write-Output "[+] Listing computers allowed unconstrained delegation. It is required for the DC to have unconstrained delegation. Any other sytsems showing here should be reviewed."| Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADComputer -Filter {TrustedForDelegation -eq $True} -Properties TrustedForDelegation | Select-Object name, TrustedForDelegation | Tee-Object -FilePath .\domain-recon.txt -Append

Write-Output "[+] Listing all unconstrained delegation users. This is not normal and should be reviwed."| Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADUser -Filter {TrustedForDelegation -eq $True} -Properties TrustedForDelegation |Select-Object SamAccountName,TrustedForDelegation| Tee-Object -FilePath .\domain-recon.txt -Append

# Constrained delegation.
Write-Output "[+] Listing all computers with constrained delegation. This should be reviwed."| Tee-Object -FilePath .\domain-recon.txt -Append
Get-ADComputer -Filter {msDS-AllowedToDelegateTo -ne "$null"} -Properties msDS-AllowedToDelegateTo |Select-Object DNSHostName, msDS-AllowedToDelegateTo | Tee-Object -FilePath .\domain-recon.txt -Append

# GPOs

Write-Output "[+] Printing permission for all GPOs."| Tee-Object -FilePath .\domain-recon.txt -Append
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

 $obj | Select-Object GPOName, AccountName, AccountType, Permissions | Tee-Object -FilePath .\domain-recon.txt -Append

 }     

}

