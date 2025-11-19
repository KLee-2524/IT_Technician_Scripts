<# 
Techincians are required to complete several tasks prior to deploying newly provisioned devices including:
  1. Verify Bitlocker encryption
  2. Syncing Trellix group policies
  3. Check compliance and install necessary applications within the Software Center
  4. Syncing group policies
  5. Run firmware updates with the Dell Command | Update application
#>

# The Trellix group policies are responsible for forcing the activation of Bitlocker encryption. 
$bl_state = Get-BitLockerVolume C: | Select-Object VolumeStatus, EncryptionPercentage, ProtectionStatus # Check BitLocker Status.
Set-Location -Path 'C:\Program Files\McAfee\Agent'
Start-Process cmdagent /s # Display Agent Status Monitor.
while ($bl_state.VolumeStatus -eq 'FullyDecrypted'){ # Check for and enforce Trellix security policies until BitLocker activates.
Start-Process cmdagent /c # Check and immdiately enforce policies.
Start-Sleep -Seconds 5
Start-Process cmdagent /e # Backup enforce command.
Start-Sleep -Seconds 25
$bl_state = Get-BitLockerVolume C: | Select-Object VolumeStatus, EncryptionPercentage, ProtectionStatus # Recheck BitLocker Status.
}

# Automatically open Software Center to allow technicians to manually install 
Set-Location -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Endpoint Manager\Configuration Manager'
Start-Process "Software Center.lnk"

# Update Group Policy Objects (GPOs)
gpupdate /force

# Automatic Dell Updates
Set-Location -Path 'C:\Program Files (x86)\Dell\CommandUpdate' 
Start-Process dcu-cli.exe /applyUpdates | Wait-Process

# Get serial number
$serial = Get-WmiObject -Class Win32_Bios | Select-Object -ExpandProperty SerialNumber # Automatically acquire the BIOS serial number of the Dell device.

# Open Dell.com
Start-Process https://www.dell.com/support/home/en-us/product-support/servicetag/$($serial)/overview # Opens the firmware downloads page for the device. Download the latest necessary BIOS firmware update file.

# Recheck BitLocker conditions
$bl_state = Get-BitLockerVolume C: | Select-Object VolumeStatus, EncryptionPercentage, ProtectionStatus
while ($bl_state.VolumeStatus -ne 'FullyEncrypted' -or $bl_state.ProtectionStatus -ne 'On'){ # Displays progress of BitLocker encryption.
$bl_state = Get-BitLockerVolume C: | Select-Object VolumeStatus, EncryptionPercentage, ProtectionStatus
Write-Progress -Activity 'Encrypting BitLocker' -Status "$($bl_status.EncryptionPercentage)% Complete:" -PercentComplete $bl_state.EncryptionPercentage
Start-Sleep -Seconds 60
} # No further steps are taken until after BitLocker finishes encrypting.

# Assuming this is a new device with ONLY the BIOS firmware update file in the downloads folder, this section will automatically initialize the BIOS update tool. 
Set-Location 'C:\Users\ADMINISTRATOR_ACCOUNT\Downloads'
$bios_update = Get-ChildItem | Select-Object -ExpandProperty Name
Start-Process $bios_update

# Trellix CLI: https://kcm.trellix.com/corporate/index?page=content&id=KB52707&actp=LIST&viewlocale=en_US&locale=en_US
# Dell CLI: https://www.dell.com/support/manuals/en-us/command-update/dellcommandupdate_rg/dell-command-%7C-update-cli-commands?guid=guid-92619086-5f7c-4a05-bce2-0d560c15e8ed&lang=en-us