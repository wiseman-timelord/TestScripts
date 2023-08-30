# Configuration
$downloadsFolder = ".\Downloads"
$url = "http://ipv4.download.thinkbroadband.com/5MB.zip"
$iterations = 3
$techniqueTimings = @{}

# Check for admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Run as Administrator."
    exit
}

# Check "Downloads" folder
if (-Not (Test-Path $downloadsFolder)) {
    Write-Host "Downloads not present...Exiting."
    exit
}
Write-Host "Downloads folder ready."

# Techniques to try
$techniques = @(
    { Start-BitsTransfer -Source $url -Destination (Join-Path $downloadsFolder "Technique1.zip") },
    { Start-BitsTransfer -Source $url -Destination (Join-Path $downloadsFolder "Technique2.zip") -Priority High },
    { Start-BitsTransfer -Source $url -Destination (Join-Path $downloadsFolder "Technique3.zip") -Priority Low },
    { Start-BitsTransfer -Source $url -Destination (Join-Path $downloadsFolder "Technique4.zip") -TransferPolicy Unrestricted },
    { $job = Start-BitsTransfer -Source $url -Destination (Join-Path $downloadsFolder "Technique5.zip") -Asynchronous; Complete-BitsTransfer -BitsJob $job -ErrorAction SilentlyContinue },
    { Start-BitsTransfer -Source $url -Destination (Join-Path $downloadsFolder "Technique6.zip") -Suspended; Resume-BitsTransfer -BitsJob (Get-BitsTransfer) },
    { Start-BitsTransfer -Source $url -Destination (Join-Path $downloadsFolder "Technique7.zip") -DisplayName "Custom Download" },
    { Start-BitsTransfer -Source $url -Destination (Join-Path $downloadsFolder "Technique8.zip") -RetryInterval 10 -RetryTimeout 600 },
    { Start-BitsTransfer -Source $url -Destination (Join-Path $downloadsFolder "Technique9.zip") -TransferType Download }
)

# Try each technique
for ($iteration = 1; $iteration -le $iterations; $iteration++) {
    Write-Host "Iteration $iteration of $iterations"
    Get-ChildItem -Path $downloadsFolder -Exclude "blank" | Remove-Item -Force

    for ($i = 0; $i -lt $techniques.Length; $i++) {
        $technique = $techniques[$i]
        Write-Host "Trying technique $($i + 1)..."

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            & $technique
            $filename = "Technique$($i + 1).zip"
            $destinationPath = Join-Path $downloadsFolder $filename

            if (Test-Path $destinationPath) {
                $fileSize = (Get-Item $destinationPath).Length
                if ($fileSize -ge 1MB) {
                    Write-Host "Success: $filename"
                    $techniqueTimings["Technique$($i + 1)"] += $stopwatch.Elapsed.TotalSeconds
                } else {
                    Write-Host "Failure: $filename"
                }
            } else {
                Write-Host "Failure: File not found. $filename"
            }
        } catch {
            Write-Host "Error during technique $($i + 1): $_"
        }
        $stopwatch.Stop()
    }
}

# Calculate average timings and rank techniques
$rankedTechniques = @{}
foreach ($key in $techniqueTimings.Keys) {
    $rankedTechniques[$key] = ($techniqueTimings[$key] | Measure-Object -Average).Average
}

Write-Host "Successful techniques ranked by average time taken (seconds):"
$rankedTechniques.GetEnumerator() | Sort-Object Value | Format-Table -AutoSize
