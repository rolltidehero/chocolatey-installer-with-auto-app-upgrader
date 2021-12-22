#Install Chocolatey
#region
echo "Setting up Chocolatey software package manager"
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

Get-PackageProvider -Name chocolatey -Force

echo "Setting up Full Chocolatey Install"
Install-Package -Name Chocolatey -Force -ProviderName chocolatey
$chocopath = (Get-Package chocolatey | 
            ?{$_.Name -eq "chocolatey"} | 
                Select @{N="Source";E={((($a=($_.Source -split "\\"))[0..($a.length - 2)]) -join "\"),"Tools\chocolateyInstall" -join "\"}} | 
                    Select -ExpandProperty Source)
& $chocopath "upgrade all -y"
choco install chocolatey-core.extension --force
#endregion

#Update Powershell
#region
$ErrorActionPreference = "silentlycontinue"

$PSVersionTable.PSVersion
choco install powershell-core -y

$ErrorActionPreference = "continue"
#endregion

#Create daily task to automatically upgrade Chocolatey packages
#region
echo "Creating daily task to automatically upgrade Chocolatey packages"
# adapted from https://blogs.technet.microsoft.com/heyscriptingguy/2013/11/23/using-scheduled-tasks-and-scheduled-jobs-in-powershell/
$ScheduledJob = @{
    Name = "Chocolatey Daily Upgrade"
    ScriptBlock = {choco upgrade all -y}
    Trigger = New-JobTrigger -Daily -at 2am
    ScheduledJobOption = New-ScheduledJobOption -RunElevated -MultipleInstancePolicy StopExisting -RequireNetwork
}
Register-ScheduledJob @ScheduledJob
#endregion
