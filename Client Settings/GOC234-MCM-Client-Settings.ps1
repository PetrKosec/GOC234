# The client settings information

Get-CMClientSetting | ft -AutoSize
Get-CMClientSetting -Name "GOC234 - Baseline"
(Get-Command Set-CMClientSetting).ParameterSets

Get-CMClientSetting | Select-Object -Property Name,Priority | Sort-Object -Property Priority | Format-Table -AutoSize

New-CMClientSetting -Name "GOC234 - Fast Onboarding" -Type Device -Description "Gopas courseware"
Set-CMClientSetting -Name "GOC234 - Fast Onboarding" -PolicyPollingInterval 5 -EnableUserPolicy $True -EnableUserPolicyOnInternet $false

# Set-CMClientSetting -Name 'Test Settings - Server' -Priority 1

# Set-CMClientSetting -Name "Default Client Settings" -HardwareInventorySettings -InventorySchedule 000120000010008

$HWInvSched = New-CMSchedule -RecurCount 1 -RecurInterval Days
Set-CMClientSetting -Name "Default Client Agent Settings" -HardwareInventorySettings -InventorySchedule $HWInvSched

New-CMClientSetting -Name "GOC234 - Wave-1" -Type Device -Description "Gopas courseware"

New-CMClientSetting -Name "GOC234 - Cloud Services" -Type Device -Description "Gopas courseware"
Set-CMClientSetting -Name "GOC234 - Cloud Services" -AllowCloudDistributionPoint  -CloudService $false



New-CMClientSetting -Name "TSQA02" -Type Device -Description "Gopas courseware"

Set-CMClientSetting -Name "TSQA02" `
    -PowerManagement $True `
    -AllowUserToOptOutFromPowerPlan $True `
    -EnablePowerManagement $False

Set-CMClientSetting -Name "TSQA02" `
    -StateMessage `
    -StateMessagingReportingCycleMinutes 10

Set-CMClientSetting -Name "TSQA02" `
    -ComputerRestart `
    -RebootLogoffNotificationCountdownDuration 60 `
    -RebootLogoffNotificationFinalWindowMinutes 10

$setting = Get-CMClientSetting -Name "TSQA02"
$setting

Get-Command *CMClientSettingComputerRestart*
