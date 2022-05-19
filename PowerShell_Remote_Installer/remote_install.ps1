<#===================================================================================
|                                                                                   |
|  LPT driver and demo repo pusher script.                                          |
|   - Elio Sjak-Shie, 2022.                                                         |
|                                                                                   |
=====================================================================================


    Remotely downloads the LPT driver repo and installs the driver.

    To run, open the file in Windows PowerShell ISE and press F5. If that is
    disabled, select all and click F8.

    NOTE: Change the PcNames array to the desired PCs.

===================================================================================#>


# PC names to push to:
$PcNames = @('W0037962')

# Parameters:
$Params = @{}
$Params.GitRepoName = 'lpt-driver-and-demos'
$Params.GitSrcUrl = "https://github.com/solo-fsw/$($Params.GitRepoName)"
$Params.DestPath = 'C:\SOLO\'

# Get credentials:
if (-not $creds)
{
    $creds = Get-Credential
}


#========================================================================================
Function Install-InpOut($Params_in)
{

    # If the folder does not exist, make it:
    if (-Not (Test-Path -Path $Params_in.DestPath))
    {
      New-Item -ItemType Directory -Force -Path $Params_in.DestPath
    }

    cd $Params_in.DestPath

    if (Test-Path -Path ".\$($Params_in.GitRepoName)") 
    {
      Remove-Item ".\$($Params_in.GitRepoName)" -Recurse -force
    }

    # Note, wrap the below in a try because git outputs to stderr, which causes the command
    # to hand since $ErrorActionPreference = "Stop". For some reason, the 2>$null does not
    # work in the remote session.
    try 
    {
        git clone $Params_in.GitSrcUrl 2>$null
    } catch 
    {
    }

    # Check that the folder exists.
    if (-Not (Test-Path -Path .\$($Params_in.GitRepoName)))
    {
        throw "Git clone failed. Perhaps Git is not installed."
    }

    cd ".\$($Params_in.GitRepoName)"

    # Check python version (same try-catch reason as above):
    try
    { 
        $pyVers = py --list
    } catch
    {
    }
    $pyGoodVer = $pyVers | Select-String -Pattern ' -3\.\d{1,2}-64'
    if (-Not $pyGoodVer.Count)
    {
        throw "No 64-bit python found."
    }

    # Run installer using the first suitable python version:
    py $pyGoodVer[0].ToString().Trim() "install_inpoutx64.py"

}




#========================================================================================
Function Make-RemoteSession($pcName)
{

    # Check if the PC is available; bail if not:
    try
    {
        $WsManResult = Test-WsMan $pcName -ErrorAction Stop
        Write-Host "PC $pcName is available."
    }
    catch
    {
        Write-Host "PC $pcName not available, skipping PC." -ForegroundColor Red
        return
    }

    # Make PS session:
    try
    {
        $session = New-PSSession -ComputerName $pcName -Credential $creds
        Write-Host "Remote session to $pcName connected."
        return $session
    }
    catch
    {
        Write-Host 'Remote session failed:' -ForegroundColor Red
        Write-Host $_ -ForegroundColor Red
        Write-Host "Skipping PC $pcName." -ForegroundColor Red
        return
    }

}




# Do for all PCs (on crash, inform and continue to next PC):
for ($i=0; $i -lt $pcNames.Count; $i++)
{
    $pcName = $PcNames[$i]
    Write-Host "Doing PC $($i+1) of $($PcNames.Count) ($pcName):" -ForegroundColor DarkGreen  -BackgroundColor white

    try
    {
        $session = Make-RemoteSession($pcName)
        if ($session)
        {
                    
            # Configure remote PC:
            Invoke-Command -Session $session -ScriptBlock {$ErrorActionPreference = "Stop"}

            # Install:
            Invoke-Command -Session $session `
                -ScriptBlock ${Function:Install-InpOut} `
                -ArgumentList $Params

            $session | Remove-PSSession   
        }
    }
    catch
    {
        Write-Host 'Installing Toolbox failed:' -ForegroundColor Red
        Write-Host $_ -ForegroundColor Red
        Write-Host "Skipping PC $pcName." -ForegroundColor Red
    }
}

Write-Host "Done" -ForegroundColor DarkGreen  -BackgroundColor white