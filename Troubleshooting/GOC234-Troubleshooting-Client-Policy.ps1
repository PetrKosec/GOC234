# Machine Policy 
Invoke-WmiMethod -Namespace root\ccm -Class SMS_Client -Name TriggerSchedule -ArgumentList "{00000000-0000-0000-0000-000000000021}" 

# Policyagent.log
# PolicyEvaluator.log
# CCMMessaging.log

Get-CimInstance -Namespace root\ccm\Policy\Client -ClassName CCM_PolicyAgent_PolicyEvaluationCycle | Select-Object -Property Name, LastExecutionTime

 
# Scan 
Invoke-WmiMethod -Namespace root\ccm -Class SMS_Client -Name TriggerSchedule -ArgumentList "{00000000-0000-0000-0000-000000000113}" 
 
# Deployment Evaluation 
Invoke-WmiMethod -Namespace root\ccm -Class SMS_Client -Name TriggerSchedule -ArgumentList "{00000000-0000-0000-0000-000000000114}" 
 
# PolicyAgent.log 
# WUAHandler.log 
# ScanAgent.log 
# UpdatesDeployment.log 
# UpdatesHandler.log 
 
Invoke-CimMethod ` 
 -Namespace root\ccm ` 
 -ClassName SMS_Client ` 
 -MethodName TriggerSchedule ` 
 -Arguments @{sScheduleID="{00000000-0000-0000-0000-000000000113}"} 


# Windows Installer Source List Update Cycle (SourceUpdateManager.log) 
