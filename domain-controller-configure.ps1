# wait until we can access the AD. this is needed to prevent errors like:
#   Unable to find a default server with Active Directory Web Services running.
while ($true) {
    try {
        Get-ADDomain | Out-Null
        break
    } catch {
        Start-Sleep -Seconds 10
    }
}


$adDomain = Get-ADDomain
$domain = $adDomain.DNSRoot
$domainDn = $adDomain.DistinguishedName
$usersAdPath = "CN=Users,$domainDn"
$password = ConvertTo-SecureString -AsPlainText 'S3cur1ty!' -Force
$password1 = ConvertTo-SecureString -AsPlainText 'Spring2019!' -Force
$password2 = ConvertTo-SecureString -AsPlainText 'Fall2019!' -Force
$password3 = ConvertTo-SecureString -AsPlainText 'Winter2020!' -Force
$password4 = ConvertTo-SecureString -AsPlainText 'Spring2020!' -Force
$AdminstratorPassword = ConvertTo-SecureString 'This1sBl@sphemyThis1sM@dness!' -AsPlainText -Force

# add the vagrant user to the Enterprise Admins group.
# NB this is needed to install the Enterprise Root Certification Authority.
Add-ADGroupMember `
    -Identity 'Enterprise Admins' `
    -Members "CN=vagrant,$usersAdPath"


# disable all user accounts, except the ones defined here.
$enabledAccounts = @(
    # NB vagrant only works when this account is enabled.
    'vagrant',
    'Administrator'
)
Get-ADUser -Filter {Enabled -eq $true} `
    | Where-Object {$enabledAccounts -notcontains $_.Name} `
    | Disable-ADAccount


# set the Administrator password.
# NB this is also an Domain Administrator account.
Set-ADAccountPassword `
    -Identity "CN=Administrator,$usersAdPath" `
    -Reset `
    -NewPassword $AdminstratorPassword
Set-ADUser `
    -Identity "CN=Administrator,$usersAdPath" `
    -PasswordNeverExpires $true


# add the local-administrators group.
# NB this is used by https://github.com/rgl/localqube-windows-vagrant.
#New-ADGroup `
#    -Path $usersAdPath `
#    -Name 'local-administrators' `
#    -GroupCategory 'Security' `
#    -GroupScope 'DomainLocal'

# add tester.
$name = 'tester'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -DisplayName 'tester' `
    -AccountPassword $password `
    -Enabled $true `
    -PasswordNeverExpires $true
# we can also set properties.
Set-ADUser `
    -Identity "CN=$name,$usersAdPath" `
    -HomePage "https://$domain/~$name"

# add John Doe.
$name = 'john.doe'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'John' `
    -Surname 'Doe' `
    -DisplayName 'John Doe' `
    -AccountPassword $password `
    -Enabled $true `
    -PasswordNeverExpires $true
# we can also set properties.
Set-ADUser `
    -Identity "CN=$name,$usersAdPath" `
    -HomePage "https://$domain/~$name"
# add user to the Domain Admins group.
Add-ADGroupMember `
    -Identity 'Domain Admins' `
    -Members "CN=$name,$usersAdPath"
# add user to the local-administrators group.
#Add-ADGroupMember `
#    -Identity 'local-administrators' `
#    -Members "CN=$name,$usersAdPath"


# add Jane Doe.
$name = 'jane.doe'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'Jane' `
    -Surname 'Doe' `
    -DisplayName 'Jane Doe' `
    -AccountPassword $password1 `
    -Enabled $true `
    -PasswordNeverExpires $true

# add Joe Shmuck.
$name = 'joe.shmuck'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'Joe' `
    -Surname 'Shmuck' `
    -DisplayName 'Joe Shmuck' `
    -AccountPassword $password2 `
    -Enabled $true `
    -PasswordNeverExpires $true

# add Jim Gordon.
$name = 'jim.gordon'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'Jim' `
    -Surname 'Gordon' `
    -DisplayName 'Jim Gordon' `
    -AccountPassword $password3 `
    -Enabled $true `
    -PasswordNeverExpires $true
# add user to the local-administrators group.
#Add-ADGroupMember `
#    -Identity 'local-administrators' `
#    -Members "CN=$name,$usersAdPath"

# add Diane Chambers.
$name = 'diane.chambers'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'diane' `
    -Surname 'chambers' `
    -DisplayName 'Diane Chambers' `
    -AccountPassword $password4 `
    -Enabled $true `
    -PasswordNeverExpires $true
Add-ADGroupMember `
    -Identity 'Schema Admins' `
    -Members "CN=$name,$usersAdPath"

echo 'john.doe Group Membership'
Get-ADPrincipalGroupMembership -Identity 'john.doe' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'jane.doe Group Membership'
Get-ADPrincipalGroupMembership -Identity 'jane.doe' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'vagrant Group Membership'
Get-ADPrincipalGroupMembership -Identity 'vagrant' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000


echo 'Enterprise Administrators'
Get-ADGroupMember `
    -Identity 'Enterprise Admins' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'Domain Administrators'
Get-ADGroupMember `
    -Identity 'Domain Admins' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000


echo 'Enabled Domain User Accounts'
Get-ADUser -Filter {Enabled -eq $true} `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000
[qasimchadhar@FACTORCENTOS vagrantlab]$
