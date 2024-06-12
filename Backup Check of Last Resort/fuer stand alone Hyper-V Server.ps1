#Backup Check of Last Resort


#runs localy at Veeam Server
#only tested on stand alone hyper-v Server



#OpenAI ChatGPT (GPT 4) und COUNT IT Josy ;-)

# Veeam und Hyper-V PowerShell SnapIns laden
Add-PSSnapin VeeamPSSnapIn
Import-Module Hyper-V

# Konfigurierbare Variablen
$hyperVServer = "DeinHyperVServer"
$excludeVMs = @("VMName1", "VMName2")  # Liste der VMs, die ausgeschlossen werden sollen
$hoursThreshold = 60

# Liste aller VMs auf dem Hyper-V Server abfragen, ausgenommen die zu ignorierenden
$allVMs = Get-VM -ComputerName $hyperVServer | Where-Object {$_.Name -notin $excludeVMs}

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
