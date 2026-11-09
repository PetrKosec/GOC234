$SiteServerName = CM1.corp.contoso.com
$Ports = @(80,443)

foreach ($Port in $Ports)
{
    Test-NetConnection `
        -ComputerName $SiteServerName `
        -Port $Port `
        -InformationLevel Quiet
}
