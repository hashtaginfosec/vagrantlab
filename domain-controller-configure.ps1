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
$testerPassword = ConvertTo-SecureString -AsPlainText 'It3st2Detest!' -Force
$thanosPwd = ConvertTo-SecureString -AsPlainText 'S3cur1tyWin2020!' -Force
$rHowePwd = ConvertTo-SecureString -AsPlainText 'DianneWasP@tient0' -Force
$SvcAcctPwd = ConvertTo-SecureString -AsPlainText 'P@ssw0rd1' -Force
$AdminstratorPassword = ConvertTo-SecureString 'YouMortal!HowDareYouQuestionThe1?' -AsPlainText -Force

# add the vagrant user to the Enterprise Admins group.
# NB this is needed to install the Enterprise Root Certification Authority.
Add-ADGroupMember `
    -Identity 'Enterprise Admins' `
    -Members "CN=vagrant,$usersAdPath"

Add-ADGroupMember `
    -Identity 'Domain Admins' `
    -Members "CN=vagrant,$usersAdPath"

# set the Administrator password.
# NB this is also an Domain Administrator account.
Set-ADAccountPassword `
    -Identity "CN=Administrator,$usersAdPath" `
    -Reset `
    -NewPassword $AdminstratorPassword
Set-ADUser `
    -Identity "CN=Administrator,$usersAdPath" `
    -PasswordNeverExpires $true


# add tester.
$name = 'tester'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -DisplayName 'tester' `
    -AccountPassword $testerPassword `
    -Enabled $true `
    -PasswordNeverExpires $true

# add Thanos
$name = 'thanos.dione'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'Thanos' `
    -Surname 'Dione' `
    -DisplayName 'Thanos Dione' `
    -AccountPassword $thanosPwd `
    -Enabled $true `
    -PasswordNeverExpires $true

Add-ADGroupMember `
    -Identity 'Domain Admins' `
    -Members "CN=$name,$usersAdPath"

# add Rebecca Howe.
$name = 'rebecca.howe'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'Rebecca' `
    -Surname 'Howe' `
    -DisplayName 'Rebecca Howe' `
    -AccountPassword $rHowePwd `
    -Enabled $true `
    -PasswordNeverExpires $true

# add Svc Acct.
$name = 'svc.acct'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -DisplayName 'Svc Acct' `
    -AccountPassword $SvcAcctPwd `
    -Enabled $true `
    -ServicePrincipalNames "MSSQLSVC/parentSQL.parentdomain.local" `
    -PasswordNeverExpires $true


New-ADComputer `
   -Description "Who is a good computer? I'm a good computer." `
   -DisplayName "parentWkstn" `
   -DNSHostName "parentWkstn.ParentDomain.local" `
   -Enabled $True `
   -Name "parentWkstn" `
   -SAMAccountName "parentWkstn"

New-ADComputer `
   -Description "Who is a good computer? I'm a good computer." `
   -DisplayName "parentSQL" `
   -DNSHostName "parentSQL.parentdomain.local" `
   -Enabled $True `
   -Name "parentSQL" `
   -SAMAccountName "parentSQL"

Get-ADComputer -Identity 'parentWkstn' | Set-ADAccountControl -TrustedToAuthForDelegation $true
Set-ADComputer -Identity 'parentWkstn' -Add @{'msDS-AllowedToDelegateTo'=@('cifs/PARENTDC')}

echo 'thanos.dione Group Membership'
Get-ADPrincipalGroupMembership -Identity 'thanos.dione' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'rebecca.howe Group Membership'
Get-ADPrincipalGroupMembership -Identity 'rebecca.howe' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'svc.acct Group Membership'
Get-ADPrincipalGroupMembership -Identity 'svc.acct' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'vagrant Group Membership'
Get-ADPrincipalGroupMembership -Identity 'vagrant' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'tester Group Membership'
Get-ADPrincipalGroupMembership -Identity 'tester' `
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

