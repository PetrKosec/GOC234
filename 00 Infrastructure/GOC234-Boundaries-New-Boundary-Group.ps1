New-CMBoundaryGroup -Name BG_Contoso -DefaultSiteCode CHQ
Get-CMBoundary | Where-Object {$_.DisplayName -match ".*contoso.*"} | Add-CMBoundaryToGroup -BoundaryGroupName BG_Contoso
Set-CMBoundaryGroup -Name BG_Contoso -AddSiteSystemServerName CM1.corp.contoso.com
