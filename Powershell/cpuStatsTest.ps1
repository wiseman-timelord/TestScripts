Clear-Host

# Processor Information
try {
    Write-Host "`nProcessor Information:" -ForegroundColor Green
    $processorInfo = Get-WmiObject Wnin32_Processor | Select-Object Name, Manufacturer, Description, NumberOfCores, NumberOfLogicalProcessors, L2CacheSize, L3CacheSize
    $processorInfo | Format-Table -AutoSize
} catch {
    Write-Host "Error fetching Processor Information"
}

try {
    Write-Host "Processor Statistics:`n" -ForegroundColor Green
    # CPU Load
    $cpuLoad = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
    Write-Host "Current CPU Load: $cpuLoad%"

    # Clock Speed
    $clockSpeed = Get-WmiObject Win32_Processor | Select-Object -ExpandProperty MaxClockSpeed
    Write-Host "Maximum Clock Speed: $clockSpeed MHz"

    # Additional CPU Frequency Details (if available)
    $cpuFrequencyInfo = Get-WmiObject Win32_Processor | Select-Object CurrentClockSpeed, ExtClock
    if ($cpuFrequencyInfo) {
        Write-Host "Current Clock Speed: $($cpuFrequencyInfo.CurrentClockSpeed) MHz"
        Write-Host "External Clock Speed: $($cpuFrequencyInfo.ExtClock) MHz"
    }

} catch {
    Write-Host "Error fetching CPU Stats"
}
