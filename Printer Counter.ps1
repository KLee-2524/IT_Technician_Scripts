<#
The vendor who supplies and maintains my company's copiers requires quarterly print counter reports.
Technicians can remotely access these counts by accessing each printer's IP address from a wired ethernet connection.
This script will automatically open the selected printers' web GUIs in a browser to enable quick and easy access to all necessary counts. 
#>

$printers = Get-Printer -ComputerName "PRINT_SERVER_NAME" | Where-Object { $_.Name -like "COMPANY_PREFIX*" } | Select Name, Location, PortName, DriverName #get all company printers on //PRINT_SERVER_NAME

$printerTable = New-Object 'object[,]' $printers.Count,5 # Create an array that will hold all of the company's important printer information such as printer name, location data, IP address, and manufacturer.

# Populate the $printerTable array
for ($i=0; $i -lt $printers.Count; ++$i) {
    $printerTable[$i,0] = "$($i+1))"
    $printerTable[$i,1] = $printers[$i].Name
    $printerTable[$i,2] = $printers[$i].Location
    $printerTable[$i,3] = $printers[$i].PortName

    # Classify each printer by brand (This company is mainly concerned with RICOH printers since those are covered by the contract with the printer vendor)
    if ($printers[$i].DriverName -like "*RICOH*") {
        $printerTable[$i,4] = "RICOH"
    }
    elseif ($printers[$i].DriverName -like "*HP*") {
        $printerTable[$i,4] = "HP"
    }
    elseif ($printers[$i].DriverName -like "*EPSON*") {
        $printerTable[$i,4] = "EPSON"
    }
    else {
        $printerTable[$i,4] = "Other / Unknown"
    }
}

$selection = Read-Host -Prompt "Select printers:`n Press R for RICOH printers.`n Press H for HP printers.`n Press A for ALL company printers.`n Press C to make a custom selection.`n" #Prompt user to specify which printers they want to open.
if ($selection -like "R") { # Opens web GUIs for all RICOH printers
    for ($i=0; $i -lt $printers.Count; ++$i) {
        if($printerTable[$i,4] -match "RICOH") {
            #$printerTable[$i,3]
            Start-Process http://$($printerTable[$i,3])
            Write-Host "Opening printer $($printerTable[$i,1]) located in $($printerTable[$i,2]) (IP address: $($printerTable[$i,3]))"
        }
    }
}
elseif ($selection -like "H") { # Opens web GUIs for all HP printers
    for ($i=0; $i -lt $printers.Count; ++$i) {
        if($printerTable[$i,4] -match "HP") {
            #$printerTable[$i,3]
            Start-Process http://$($printerTable[$i,3])
            Write-Host "Opening printer $($printerTable[$i,1]) located in $($printerTable[$i,2]) (IP address: $($printerTable[$i,3]))"
        }
    }
}
elseif ($selection -like "A") { # Opens web GUIs for ALL company printers
    for ($i=0; $i -lt $printers.Count; ++$i) {
        #$printerTable[$i,3]
        Start-Process http://$($printerTable[$i,3])
        Write-Host "Opening printer $($printerTable[$i,1]) located in $($printerTable[$i,2]) (IP address: $($printerTable[$i,3]))"
    }
}
elseif ($selection -like "C") { # Opens menu for user to custom select which printers to open
    Write-Host "`nCustom Selection Menu`n`nInstructions: Press the number(s) of the printer(s) you would like to select. Press D when you are done.`nEX: Pressing `"1`" + `"Enter`" + `"D`" + `"Enter`" selects only printer 1.`n" # Display instructions for user
    
    # Output a numbered menu with each company printer brand and location
    for ($i=0; $i -lt $printers.Count; ++$i) {
        if ($i -lt 9) {
            "$($printerTable[$i,0]) `t $($printerTable[$i,4]) `t $($printerTable[$i,2])"
        }
        else {
            "$($printerTable[$i,0]) `t $($printerTable[$i,4]) `t $($printerTable[$i,2])"
        }
    }

    $collecting = 1 # Declare collecting variable
    $selectionList = New-Object string[] $printers.Count # Declare an array to contain selected printer numbers
    $printerNum = 0 # Declare variable to iterate through above array

    # Make custom selections
    while ($collecting -eq 1) { # While collecting variable is true, keep prompting user to select printer numbers
        $input = Read-Host -Prompt "`nSelect a number (1 - $($printers.Count)) or press `"D`" to complete your selection"
        if ($input -like "D") { # When user enters "D" or "d", set collecting variable to false
            $collecting = 0
        }
        else {
            $selectionList[$printerNum] = $input
            $printerNum = $printerNum + 1 #increment printerNum to iterate to next element in selectionList array
        }
    }

    # Parse through each printer number in the printerTable array, if a match is found, open that printer's web GUI
    for ($i=0; $i -lt $printers.Count; ++$i) {
        for ($j=0; $j -lt $selectionList.Count; ++$j) {
            if ($printerTable[$i,0] -eq "$($selectionList[$j]))") {
                Start-Process http://$($printerTable[$i,3])
                Write-Host "Opening printer $($printerTable[$i,1]) located in $($printerTable[$i,2]) (IP address: $($printerTable[$i,3]))"
            }
        }
    }
    
}

Read-Host -Prompt "`nVerify all the printers you wanted to open have opened, refer to the above output if certain IP addresses do not work.`nPress Enter when finished."

<#
https://stackoverflow.com/questions/41591529/how-to-get-the-output-of-a-powershell-command-into-an-array
https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-09?view=powershell-7.5         Microsoft Learn | Arrays
https://stackoverflow.com/questions/2988880/extract-a-substring-using-powershell
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-7.5
#>