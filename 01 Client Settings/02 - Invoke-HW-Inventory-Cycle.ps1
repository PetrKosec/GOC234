Invoke-CimMethod `
    -Namespace root\ccm `
    -ClassName SMS_Client `
    -MethodName TriggerSchedule `
    -Arguments @{sScheduleID='{00000000-0000-0000-0000-000000000001}'}

Write-Output "Hardware Inventory triggered."
``
