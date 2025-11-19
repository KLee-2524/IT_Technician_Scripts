<#
This script is designed to be stored and run from a technician's portable USB drive. 
It will gather computing device information in a .csv file for easy upload into an asset management software.

NOTE: To accurately extract the primary user of a device, the script must be run while logged in as that user instead of the ADMINISTRATOR_ACCOUNT.
#>

$info = Get-ComputerInfo # Assign computer information to the info variable.
$drive = Get-PhysicalDisk | Where-Object MediaType -eq SSD # Assign SSD information to the drive variable.
$opdir = $pwd

$type = Read-Host -Prompt "Is this device a laptop or a desktop?`n Press 1 for Laptop.`n Press 2 for Desktop.`n" # Prompt user to specify if device is a laptop or PC.
if ($type -eq '1')
{
        $device = 'Laptop'
        $location = $rm = 'Mobile'
}
elseif ($type -eq '2')
{
        $device = 'Desktop'
        $bldg = Read-Host -Prompt "Where is this device located?`n Press 1 for Building 1.`n Press 2 for Building 2.`n Press 3 for Building 3.`n" # Prompt user to specify which building the stationary PC is located in.
            if ($bldg -eq '1')
            {
            $location = 'Building 1'
            }
            elseif ($bldg -eq '2')
            {
            $location = 'Building 2'
            }
            elseif ($bldg -eq '3')
            {
            $location = 'Building 3'
            }
}

if ($location -ne 'Mobile')
{
$rm = Read-Host -Prompt "In what room is this device located?" # Prompt user to enter the room number that the stationary PC is located in and assign the value to the rm variable.
}

$shared = Read-Host -Prompt "Is this a shared device?`n Press 1 for yes.`n Press 2 for no.`n" # Prompt user to specify whether this is a shared device.
if ($shared -eq "1")
{
$user = "Shared"
}
elseif ($shared -eq "2")
{
    if ($info.CsUserName -eq "$($info.CsName)\ADMINISTRATOR_ACCOUNT")
    {
        Set-Location "C:\Users"
        $names = Get-ChildItem | Select-Object -ExpandProperty Name
        foreach ($name in $names)
        {
            if($name -ne "ADMINISTRATOR_ACCOUNT" -and $name -ne "Public" -and $name -ne "$($info.CsName)$" -and $name -ne "defaultuser0")
            {
            $user = $name
            }
        }
    }
    $user = $info.CsUserName.Remove(0,3)
}

$asset_info = [PSCustomObject]@{ # Assign all the asset information to the asset_info variable and convert into a custom PowerShell object.
    CPK          = $info.CsName.Remove(0,1)
    User         = $user
    Category     = $device
    Manufacturer = $info.CsManufacturer
    Model        = $info.CsModel
    Serial       = $info.BiosSeralNumber
    Bldg         = $location
    Rm           = $rm
    Warrenty     = 'UNKNOWN'
    CPU          = $info.CsProcessors.Name
    Drive        = "$([math]::ceiling(([int64]$($drive.Size))/1073741824)) GB"
    RAM          = "$([math]::ceiling(([int64]$($info.CsTotalPhysicalMemory))/1073741824)) GB"
}

$asset_info | Export-Csv -Path "$($opdir)\Assets.csv" -Append -NoTypeInformation # Export the asset information into a .csv file.

if ($info.CsManufacturer -eq "Dell Inc.")
{
Start-Process "https://www.dell.com/support/home/en-us/product-support/servicetag/$($info.BiosSeralNumber)/overview"
Start-Sleep -Seconds 5
Start-Process -FilePath "$($opdir)\Assets.csv"
}