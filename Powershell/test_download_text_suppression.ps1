# Configuration
$downloadsFolder = ".\Downloads"
$url = "http://ipv4.download.thinkbroadband.com/5MB.zip"
$filenames = 1..10 | ForEach-Object { "5MB-Technique$_.zip" }

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

# Clear all files in the Downloads folder except "blank"
Get-ChildItem -Path $downloadsFolder -Exclude "blank" | Remove-Item -Force

# Techniques to try
$techniques = @(
    { $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri $url -OutFile (Join-Path $downloadsFolder $filenames[0]) -UseBasicParsing; $ProgressPreference = 'Continue' },
    { $null = Invoke-WebRequest -Uri $url -OutFile (Join-Path $downloadsFolder $filenames[1]) },
    { $client = New-Object System.Net.WebClient; $client.DownloadFile($url, (Join-Path $downloadsFolder $filenames[2])) > $null },
    { function Out-Default {}; Invoke-WebRequest -Uri $url -OutFile (Join-Path $downloadsFolder $filenames[3]); Remove-Item -Path function:Out-Default },
    { & { Write-Host "This will disappear!"; Write-Warning "A Warning" } 6>$null; Invoke-WebRequest -Uri $url -OutFile (Join-Path $downloadsFolder $filenames[4]) },
    { $webClient = New-Object System.Net.WebClient; $webClient.Headers.Add("user-agent", "PowerShell Script"); $webClient.DownloadFile($url, (Join-Path $downloadsFolder $filenames[5])) }
)

# Try each technique
$report = @()
for ($i = 0; $i -lt $techniques.Length; $i++) {
    $technique = $techniques[$i]
    Write-Host "Trying technique $($i + 1)..."

    try {
        & $technique
        $filename = $filenames[$i]
        $destinationPath = Join-Path $downloadsFolder $filename

        if (Test-Path $destinationPath) {
            $fileSize = (Get-Item $destinationPath).Length
            if ($fileSize -ge 1MB) {
                Write-Host "Success: $filename"
                $userResponse = Read-Host "Was the text suppressed? (yes/no)"
                $report += [PSCustomObject]@{
                    Technique = "Technique $($i + 1)"
                    Result    = "Success"
                    Suppressed = $userResponse
                }
            } else {
                Write-Host "Failure: $filename"
            }
        } else {
            Write-Host "Failure: File not found. $filename"
        }
    } catch {
        Write-Host "Error during technique $($i + 1): $_"
    }
}

Write-Host "Report:"
$report | Format-Table -AutoSize
