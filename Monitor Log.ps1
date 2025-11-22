# This script is designed to be stored and run from a technician's portable USB drive or local device. 
# It will autoamtically extract monitor information in a .csv file for easy upload into an inventory management software.
# Some of the original script has been modified to protect organizational privacy and security.
 
# Save the current operating directory
$opdir = $pwd

# Enter monitor location
$bldg = Read-Host -Prompt "Where is this device located?`n Press 1 for Building 1.`n Press 2 for Building 2.`n Press 3 for Building 3.`n" #Prompt user to specify which building the stationary PC is located in.
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

$rm_num = Read-Host -Prompt "In what room is this device located?" #Prompt user to enter the room number that the stationary PC is located in and assign the value to the rm variable.

if ($location -eq 'Building 1')
    {
    $rm = "1-$($rm_num)"
    }
elseif ($location -eq 'Building 2')
    {
    $rm = "2-$($rm_num)"
    }
elseif ($location -eq 'Building 3')
    {
    $rm = "3-$($rm_num)"
    }

# Create empty array to hold extracted monitor data
$Monitor_Array = @()

# Query all monitors connected to the computer
$Monitors = Get-WmiObject -Namespace "root\WMI" -Class "WMIMonitorID"

# Map all manufacturer codes to human readable manufacturer names
 $ManufacturerHash = @{ 
    "AAC" =	"AcerView";
    "ACR" = "Acer";
    "AOC" = "AOC";
    "AIC" = "AG Neovo";
    "APP" = "Apple Computer";
    "AST" = "AST Research";
    "AUO" = "Asus";
    "BNQ" = "BenQ";
    "CMO" = "Acer";
    "CPL" = "Compal";
    "CPQ" = "Compaq";
    "CPT" = "Chunghwa Pciture Tubes, Ltd.";
    "CTX" = "CTX";
    "DEC" = "DEC";
    "DEL" = "Dell";
    "DPC" = "Delta";
    "DWE" = "Daewoo";
    "EIZ" = "EIZO";
    "ELS" = "ELSA";
    "ENC" = "EIZO";
    "EPI" = "Envision";
    "FCM" = "Funai";
    "FUJ" = "Fujitsu";
    "FUS" = "Fujitsu-Siemens";
    "GSM" = "LG Electronics";
    "GWY" = "Gateway 2000";
    "HEI" = "Hyundai";
    "HIT" = "Hyundai";
    "HSL" = "Hansol";
    "HTC" = "Hitachi/Nissei";
    "HWP" = "HP";
    "IBM" = "IBM";
    "ICL" = "Fujitsu ICL";
    "IVM" = "Iiyama";
    "KDS" = "Korea Data Systems";
    "LEN" = "Lenovo";
    "LGD" = "Asus";
    "LPL" = "Fujitsu";
    "MAX" = "Belinea"; 
    "MEI" = "Panasonic";
    "MEL" = "Mitsubishi Electronics";
    "MS_" = "Panasonic";
    "NAN" = "Nanao";
    "NEC" = "NEC";
    "NOK" = "Nokia Data";
    "NVD" = "Fujitsu";
    "OPT" = "Optoma";
    "PHL" = "Philips";
    "REL" = "Relisys";
    "SAN" = "Samsung";
    "SAM" = "Samsung";
    "SBI" = "Smarttech";
    "SGI" = "SGI";
    "SNY" = "Sony";
    "SRC" = "Shamrock";
    "SUN" = "Sun Microsystems";
    "SEC" = "Hewlett-Packard";
    "TAT" = "Tatung";
    "TOS" = "Toshiba";
    "TSB" = "Toshiba";
    "VSC" = "ViewSonic";
    "ZCM" = "Zenith";
    "UNK" = "Unknown";
    "_YV" = "Fujitsu";
}

ForEach ($Monitor in $Monitors) {

    # Gather identifying monitor details
    if ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName) -ne $null) {
        $Name = ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)).Replace("$([char]0x0000)","")
    }
    else {
        $Name = $null
    }
    $Manufacturer_Code = ([System.Text.Encoding]::ASCII.GetString($Monitor.ManufacturerName)).Replace("$([char]0x0000)","")
    $Manufacturer = $ManufacturerHash.$Manufacturer_Code
    $Serial_Number = ([System.Text.Encoding]::ASCII.GetString($Monitor.SerialNumberID)).Replace("$([char]0x0000)","")
    $Attached_Computer = ($Monitor.PSComputerName).Replace("$([char]0x0000)","")
    $Attached_Asset_Number = $Attached_Computer.Substring(1)

    # Save details into a custom PowerShell object, while leaving a placeholder for manual entry of the asset tag number.
    $Monitor_Obj = [PSCustomObject]@{
        Manufacturer     = $Manufacturer
        Model            = $Name
        Serial_Number    = $Serial_Number
        Connected_CPK    = $Attached_Asset_Number
        Building         = $location
        Room             = $rm
        Category         = 'SHRI - Displays'
        Asset_Tag        = 'PLACEHOLDER'
    }

    # Append monitor to monitor array
    $Monitor_Array += $Monitor_Obj
}

$Monitor_Array | Export-Csv -Path "$($opdir)\Monitors.csv" -Append -NoTypeInformation #Export the monitor information into a .csv file.



# https://github.com/MaxAnderson95/Get-Monitor-Information/blob/master/Get-Monitor.ps1
