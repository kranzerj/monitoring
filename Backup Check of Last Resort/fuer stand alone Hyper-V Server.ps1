#Backup Check of Last Resort


#Parameter ob Backup erfolgreich war, wird von Veeam geschrieben
#Set successful backup details to this VM attribute -> Last Backup
#https://helpcenter.veeam.com/docs/backup/vsphere/backup_job_advanced_notify_vm.html?ver=120


#OpenAI ChatGPT (GPT 4o) und COUNT IT Josy ;-)


# VMs to exclude from the check
param (
    [string[]]$excludedVMs = @("VM-Test01","Test-VM")
)

function Get-CustomAttribute {
    param (
        [string]$VMName,
        [string]$AttributeName
    )

    try {
        $vm = Get-VM -Name $VMName -ErrorAction Stop
        $attribute = $vm | Get-VMMetadata -Name $AttributeName -ErrorAction Stop
        return [datetime]$attribute.Value
    } catch {
        Write-Output "UNKNOWN: Error retrieving attribute for VM $VMName: $_"
        exit 3
    }
}

function Check-BackupStatus {
    $currentDate = Get-Date
    $cutoffDate = $currentDate.AddHours(-60)
    $criticalVMs = @()

    $vms = Get-VM | Where-Object { $excludedVMs -notcontains $_.Name }

    foreach ($vm in $vms) {
        $backupDate = Get-CustomAttribute -VMName $vm.Name -AttributeName "Backup"
        if ($backupDate -lt $cutoffDate) {
            $criticalVMs += $vm.Name
        }
    }

    if ($criticalVMs.Count -eq 0) {
        Write-Output "OK: All VMs have recent backups"
        exit 0
    } else {
        $criticalVMsList = $criticalVMs -join ", "
        Write-Output "CRITICAL: Backup failed for VM(s): $criticalVMsList"
        exit 2
    }
}

try {
    Check-BackupStatus
} catch {
    Write-Output "UNKNOWN: An unexpected error occurred: $_"
    exit 3
}

#last resort: place the vms under an allied country's command
