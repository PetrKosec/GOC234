$userDiscoveryArr = @("ldap://OU=USERS,OU=CORP,DC=corp,DC=contoso,DC=com","ldap://OU=Administrators,OU=CORP,DC=corp,DC=contoso,DC=com")

Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode CHQ -Enabled $true -EnableDeltaDiscovery $true -DeltaDiscoveryMins 5 `
   -AddActiveDirectoryContainer $userDiscoveryArr
