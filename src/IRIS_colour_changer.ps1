function Restore-OriginalFile($cspBrokerPath) {
    # Ask user to provide path to csp\broker folder location so we can locate ZEN_Component__core.js
    $csp_broker_path = $cspBrokerPath
	Write-Host $csp_broker_path	

    # Check if the provided path does not exist
    if (!(Test-Path -Path $csp_broker_path)) {
        Write-Host "The provided path does not exist. Please check the path and try again."
        pause "Press any key to exit the script."
        exit 1
    }

    # Construct the full path to ZEN_Component__core_backup.js
    $backup_path = Join-Path -Path $csp_broker_path -ChildPath "ZEN_Component__core_backup.js"
    
    # Check if ZEN_Component__core_backup.js exists in the specified folder
    if (!(Test-Path -Path $backup_path)) {
        Write-Host "ZEN_Component__core_backup.js not found in the specified folder."
        pause "Press any key to exit the script."
        exit 1
    }

    Write-Host "ZEN_Component__core_backup.js found at: $backup_path"
    # Restore the original file from backup
    $zen_component_path = Join-Path -Path $csp_broker_path -ChildPath "ZEN_Component__core.js"
    try {
        Copy-Item -Path $backup_path -Destination $zen_component_path -Force
        Write-Host "Successfully restored ZEN_Component__core.js from backup."
    }
    catch {
        Write-Host "Failed to restore ZEN_Component__core.js: $_"
        pause "Press any key to exit the script."
        exit 1
    }

    # now, we can remove the zCustom_env_colours.js file if it exists and the backup file
    $new_script_path = Join-Path -Path $csp_broker_path -ChildPath "zCustom_env_colours.js"
    if (Test-Path -Path $new_script_path) {
        try {
            Remove-Item -Path $new_script_path -Force
            Write-Host "Successfully removed zCustom_env_colours.js."
        }
        catch {
            Write-Host "Failed to remove zCustom_env_colours.js: $_"
            pause "Press any key to exit the script."
            exit 1
        }
    }
    try {
        Remove-Item -Path $backup_path -Force
        Write-Host "Successfully removed ZEN_Component__core_backup.js."
    }
    catch {
        Write-Host "Failed to remove ZEN_Component__core_backup.js: $_"
		pause "Press any key to exit the script."
		exit 1		
    }

}

Function Set-HeaderColour($cspBrokerPath) {
    $csp_broker_path = $cspBrokerPath

    # ask user to choose a colour for the header
    $Colour = Get-Colour

    # Check if the provided path exists
    if (!(Test-Path -Path $csp_broker_path)) {
        Write-Host "One or both of the provided paths do not exist. Please check the paths and try again."
        pause "Press any key to exit the script."
        exit 1
    }

    # Construct the full path to ZEN_Component__core.js
    $zen_component_path = Join-Path -Path $csp_broker_path -ChildPath "ZEN_Component__core.js"
    
    # Check if ZEN_Component__core.js exists in the specified folder
    if (!(Test-Path -Path $zen_component_path)) {
        Write-Host "ZEN_Component__core.js not found in the specified folder."
        pause "Press any key to exit the script."
        exit 1
    }
    Write-Host "ZEN_Component__core.js found at: $zen_component_path"

    # if the backup file already exists, we will run the script to restore the original file and then continue with the rest of the script, passing in the path to the csp\broker folder

    $backup_path = Join-Path -Path $csp_broker_path -ChildPath "ZEN_Component__core_backup.js"
    if (Test-Path -Path $backup_path) {
        Write-Host "Backup file already exists. Restoring original ZEN_Component__core.js from backup."
        Restore-OriginalFile $csp_broker_path
    }

    # create a copy of ZEN_Component__core.js to a backup location
    $backup_path = Join-Path -Path $csp_broker_path -ChildPath "ZEN_Component__core_backup.js"
    try {
        Copy-Item -Path $zen_component_path -Destination $backup_path -Force
        Write-Host "Backup of ZEN_Component__core.js created at: $backup_path"
        if (!(Test-Path -Path $backup_path)) {
            Throw "Backup file does not exist after copy operation."
        }
        Write-Host "Backup file exists: $backup_path"
        
    }
    catch {
        Write-Host "Failed to create backup: $_"
        pause "Press any key to exit the script."
        exit 1
    }

    # create the new script file that will be referenced in the modified ZEN_Component__core.js
    $new_script_path = Join-Path -Path $csp_broker_path -ChildPath "zCustom_env_colours.js"

    # add the new script content to the new script file
    $new_script_content = "// This script will change the header of the instance of IRIS installed on this machine" + "`n" + "document.getElementsByClassName(""portalTitle"")[0].style.background = "" " + $Colour + " "";"

    try {
        Set-Content -Path $new_script_path -Value $new_script_content -Force
        Write-Host "New script file created at: $new_script_path"
    }
    catch {
        Write-Host "Failed to create new script file: $_"
        pause "Press any key to exit the script."
        exit 1
    }


    # Now we have a backup of the file, attempt to modify the original ZEN_Component__core.js file
    try {
        # Read the content of the original file
        $content = Get-Content -Path $zen_component_path -Raw

        # add in the new lines required to  alert the script to point at the new file we will create for changing the header colour.
        $line1 = "var newScript= document.createElement('script');"
        $line2 = "newScript.src = 'zCustom_env_colours.js';"
        $line3 = "document.body.appendChild(newScript);"

        $modified_content = $line1 + "`n" + $line2 + "`n" + $line3 + "`n" + $content

        # Write the modified content back to the original file
        Set-Content -Path $zen_component_path -Value $modified_content -Force
        Write-Host "Successfully modified ZEN_Component__core.js"
    
	
    }
    catch {
        Write-Host "Failed to modify ZEN_Component__core.js: $_"
        pause "Press any key to exit the script."
        exit 1
    }
}

function pause ($message) {
    # Check if running Powershell ISE
    if ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    }
    else {
        Write-Host "$message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

function Get-Colour {
    $type = Read-Host "
    1 - Red
    2 - Orange
    3 - Yellow
    4 - Green
    5 - Blue
    Please choose"
    Switch ($type) {
        1 { $choice = "Red" }
        2 { $choice = "Orange" }
        3 { $choice = "Yellow" }
        4 { $choice = "Green" }
        5 { $choice = "Blue" }
    }
    return $choice
}

function Set-Action {
    $type = Read-Host "
    1 - Change Header Colour
    2 - Restore Original File
    Please choose"
    Switch ($type) {
        1 { $choice = "Change Header Colour" }
        2 { $choice = "Restore Original File" }
    }
    return $choice
}


# ask user to provide path to csp\broker folder location so we can locate ZEN_Component__core.js
$csp_broker_path = Read-Host "Please provide the path to the csp\broker folder: "

#  prompt the user to see if they want to either change the header colour of the instance of IRIS installed on this machine or to restore the original ZEN_Component__core.js file from the backup created by this script.
$action = Set-Action

If ($action -eq "Change Header Colour") {
    Set-HeaderColour $csp_broker_path
}

elseIf ($action -eq "Restore Original File") {
    Restore-OriginalFile $csp_broker_path
}

else {
    Write-Host "Invalid choice. Exiting script."
}
pause "Press any key to exit the script."
exit 0
