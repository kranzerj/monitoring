Only Vmware: 

![VMware](https://github.com/kranzerj/monitoring/blob/main/Backup%20Check%20of%20Last%20Resort/Veeam01.jpg?raw=true)


Only Hyper-V:
create AD User and group 



Ad Group to 

see: PowerShell: Implementing Just-Enough-Administration (JEA), Step-by-Step – SID-500.COM

New-PSSessionConfigurationFile -Path 'C:\_adminfiles\dauerhaft\hv_conf.pssc'
Edit this File:
change Author (line 10)
change Session Type (Line 16) to RestrictedRemoteServer
enable RunAsVirtualAccount (Line 22) 
configure RoleDefinitions (Line 28)
RoleDefinitions = @{ 'domain\read-hyperv-server' = @{  'RoleCapabilities' = 'HVread' }}
Add: 
ModulestoImport = ‘Hyper-V’

