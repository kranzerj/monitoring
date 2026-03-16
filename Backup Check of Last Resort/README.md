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



![Hyper-V](https://github.com/kranzerj/monitoring/blob/main/Backup%20Check%20of%20Last%20Resort/HV01.jpg?raw=true)

New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\JEA\RoleCapabilities' -ItemType Directory

New-PSRoleCapabilityFile -Path 'C:\Program Files\WindowsPowerShell\Modules\JEA\RoleCapabilities\HVread.psrc’

Maybe change Author (7), ComanyName(13) and Copyright (16)

Change VisibleCmdlets (Line 25) to:
VisibleCmdlets = @{
    Name = 'Get-VM'
    Parameters = @(
        @{
            Name = '*'
        }
    )
}





Register-PSSessionConfiguration -Name HVread -Path 'C:\_adminfiles\dauerhaft\hv_conf.pssc’



Restart-Service WinRM




all: 

nsclient.ini
[/settings/external scripts/scripts]
allow arguments=true
alias_BCOLR = cmd /c echo scripts/vm_bak_check.ps1; exit($lastexitcode) | powershell.exe -command -

Restart NSclient Service

![nagios-config](https://github.com/kranzerj/monitoring/blob/main/Backup%20Check%20of%20Last%20Resort/nagios01.jpg?raw=true)


