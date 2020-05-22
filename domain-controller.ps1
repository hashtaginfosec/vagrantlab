param(
    $domain = 'windomain.local'
)

$netbiosDomain = ($domain -split '\.')[0].ToUpperInvariant()

$safeModeAdminstratorPassword = ConvertTo-SecureString 'This1sN0tBl@sphemyThis1sN0tM@dness!' -AsPlainText -Force

# make sure the Administrator has a password that meets the minimum Windows
# password complexity requirements (otherwise the AD will refuse to install).


#echo 'Disabling the Administrator account (we only use the vagrant account)...'
#Disable-LocalUser `
#    -Name Administrator

echo 'Installing the AD services and administration tools...'
Install-WindowsFeature AD-Domain-Services,RSAT-AD-AdminCenter,RSAT-ADDS-Tools

echo 'Installing the AD forest (be patient, this will take more than 30m to install)...'
Import-Module ADDSDeployment
# NB ForestMode and DomainMode are set to WinThreshold (Windows Server 2016).
#    see https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/active-directory-functional-levels
Install-ADDSForest `
    -InstallDns `
    -CreateDnsDelegation:$false `
    -ForestMode 'Win2008R2' `
    -DomainMode 'Win2008R2' `
    -DomainName $domain `
    -DomainNetbiosName $netbiosDomain `
    -SafeModeAdministratorPassword $safeModeAdminstratorPassword `
    -NoRebootOnCompletion `
    -Force
