#Backup Check of Last Resort

#OpenAI ChatGPT (GPT 4) und COUNT IT Josy ;-)

#runs localy at Veeam Server with Hyper-V RSAT:
@veeam Server:
Install-WindowsFeature Hyper-V-PowerShell 
If the two servers are not in the same domain:
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "fqdn-of-hyper-v-host"
Enable-WSManCredSSP -Role client -DelegateComputer "fqdn-of-hyper-v-host"
group policy: Computer Configuration > Administrative Templates > System > Credentials Delegation > Allow delegating fresh credentials with NTLM-only server authentication
Click Enable and add wsman/fqdn-of-hyper-v-host.


@hyper-v Server:

If the two servers are not in the same domain
Enable-PSRemoting + Enable-WSManCredSSP -Role server @Hyper-v




#only tested on stand alone hyper-v Server

#a monitoring server, with remote powershell to the Veem server, would probably be the best option. But in my case there is none





# Veeam und Hyper-V PowerShell SnapIns laden

Import-Module Hyper-V

# Konfigurierbare Variablen
$hyperVServer = "fqdn-of-hyper-v-host"
$excludeVMs = @("VMName1", "VMName2")  # Liste der VMs, die ausgeschlossen werden sollen
$hoursThreshold = 60
$username="Benutzername"
$password = ConvertTo-SecureString "kennwort" -AsPlainText -Force




$credential = New-Object System.Management.Automation.PSCredential ($username, $password)


# Erstellen einer PSSession auf dem Hyper-V Server
$session = New-PSSession -ComputerName $hyperVServer -ConfigurationName 'hvread' -Credential $credential

# Ausführen von Get-VM innerhalb der PSSession und Speichern der Ergebnisse in $vmList
$vmList = Invoke-Command -Session $session -ScriptBlock {
    Get-VM | Select-Object Name
}

# Schließen der PSSession
Remove-PSSession -Session $session

# Filtern der VMs lokal, anstatt im Scriptblock der Remotesitzung
$allVMs = $vmList | Where-Object {$_.Name -notin $excludeVMs}






# Überprüfen der Backup-Zeit für jede VM
$failedVMs = @()
foreach ($vm in $allVMs) {
    $lastBackup = Get-VBRRestorePoint -Name $vm.Name | Sort-Object CreationTime -Descending | Select-Object -First 1

    if ($lastBackup -ne $null) {
        $timeSinceLastBackup = (New-TimeSpan -Start $lastBackup.CreationTime -End (Get-Date)).TotalHours
        if ($timeSinceLastBackup -gt $hoursThreshold) {
            $failedVMs += $vm.Name
        }
    } else {
        $failedVMs += $vm.Name
    }
}

# Ausgabe und Exit Codes
if ($failedVMs.Count -gt 0) {
    Write-Output "CRITICAL: Backup failed for VM(s): $($failedVMs -join ', ')"
    exit 2
} elseif ($allVMs.Count -eq 0) {
    Write-Output "UNKNOWN: No VMs found or all excluded from the check"
    exit 3
} else {
    Write-Output "OK: All VMs have recent backups"
    exit 0
}


#last resort: place the vms under an allied country's command
