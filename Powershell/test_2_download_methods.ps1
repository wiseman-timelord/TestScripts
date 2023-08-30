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
    { Invoke-WebRequest -Uri $url -OutFile (Join-Path $downloadsFolder $filenames[0]) -UseBasicParsing },
    { Invoke-WebRequest -Uri $url -OutFile (Join-Path $downloadsFolder $filenames[1]) },
    { $response = Invoke-WebRequest $url -Method Get; [System.IO.File]::WriteAllBytes((Join-Path $downloadsFolder $filenames[2]), $response.Content) },
    { Invoke-WebRequest -Uri $url -OutFile (Join-Path $downloadsFolder $filenames[3]) -TimeoutSec 60 },
    { $client = New-Object System.Net.WebClient; $client.DownloadFile($url, (Join-Path $downloadsFolder $filenames[4])) },
    { $response = Invoke-RestMethod $url; Set-Content -Path (Join-Path $downloadsFolder $filenames[5]) -Value $response },
    { $webRequest = [System.Net.WebRequest]::Create($url); $response = $webRequest.GetResponse(); $stream = $response.GetResponseStream(); $reader = New-Object System.IO.StreamReader($stream); $result = $reader.ReadToEnd(); Set-Content -Path (Join-Path $downloadsFolder $filenames[6]) -Value $result },
    { $webClient = New-Object System.Net.WebClient; $webClient.Headers.Add("user-agent", "PowerShell Script"); $webClient.DownloadFile($url, (Join-Path $downloadsFolder $filenames[7])) },
    { Invoke-WebRequest -Uri $url -OutFile (Join-Path $downloadsFolder $filenames[8]) -MaximumRedirection 0 },
    { Invoke-WebRequest -Uri $url -OutFile (Join-Path $downloadsFolder $filenames[9]) -DisableKeepAlive }
)

# Try each technique
$successfulTechniques = @()
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
                $successfulTechniques += $filename
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

Write-Host "Successful techniques: $($successfulTechniques -join ', ')"
