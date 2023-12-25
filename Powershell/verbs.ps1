# Define the list of module names
$moduleNames = @('cpuStats', 'gpuStats', 'soundStats', 'networkStats')

# Path to your modules (adjust if necessary)
$modulePath = "D:\MyPrograms\PerforMancer-BaPs\scripts"

# Import each module and check for unapproved verbs
foreach ($moduleName in $moduleNames) {
    $moduleFullPath = Join-Path $modulePath "$moduleName.psm1"
    Import-Module $moduleFullPath -Verbose

    Write-Host "`nChecking module: $moduleName for unapproved verbs" -ForegroundColor Cyan

    $commands = Get-Command -Module $moduleName
    foreach ($command in $commands) {
        $verb = $command.Name.Split('-')[0]
        if (-not (Get-Verb | Where-Object { $_.Verb -eq $verb })) {
            Write-Host "Unapproved verb found: $verb in command $($command.Name)" -ForegroundColor Red
        }
    }
}