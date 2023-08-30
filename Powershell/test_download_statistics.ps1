# test_download_statistics.ps1

# Configuration
$downloadsFolder = ".\Downloads"
$url = "http://ipv4.download.thinkbroadband.com/5MB.zip"
$filenames = @("5MB-BITS.zip", "5MB-InvokeWebRequest.zip", "5MB-WebClient.zip")
$results = @()
$previousBytes = 0
$chunk = 1024KB

# Check "Downloads" folder
if (-Not (Test-Path $downloadsFolder)) {
    Write-Host "Downloads folder empty."
    exit
}
Write-Host "Downloads folder cleaned."

# Clear all files in the Downloads folder except "blank"
Get-ChildItem -Path $downloadsFolder -Exclude "blank" | Remove-Item -Force

# Techniques to try
$techniques = @(
    { BITSMethod -RemoteUrl $url -DestinationPath (Join-Path $downloadsFolder $filenames[0]) },
    { InvokeWebRequestMethod -RemoteUrl $url -DestinationPath (Join-Path $downloadsFolder $filenames[1]) },
    { WebClientMethod -RemoteUrl $url -DestinationPath (Join-Path $downloadsFolder $filenames[2]) }
)

# Progress Statistics
function ShowProgress {
    param (
        $bytesTransferred,
        $timeElapsed
    )
    $dataReceivedMB = [math]::Round($bytesTransferred / 1e6, 2)
    $transferRateMB = [math]::Round(($bytesTransferred - $script:previousBytes) / 1e6, 2)
    $script:previousBytes = $bytesTransferred
    $script:totalTransferRate += $transferRateMB
    $script:transferRateCount++
    $averageTransferRateMB = [math]::Round($script:totalTransferRate / $script:transferRateCount, 2)
    $dataReceived = "{0:N2}" -f $dataReceivedMB
    $transferRate = "{0:N2}" -f $transferRateMB
    $averageTransferRate = "{0:N2}" -f $averageTransferRateMB
    if ($dataReceivedMB -ge 1024) {
        $dataReceived = "{0:N2}" -f ($dataReceivedMB / 1024) + "GB"
    } else {
        $dataReceived += "MB"
    }
    if ($transferRateMB -ge 1024) {
        $transferRate = "{0:N2}" -f ($transferRateMB / 1024) + "GBs"
    } else {
        $transferRate += "MBs"
    }
    if ($averageTransferRateMB -ge 1024) {
        $averageTransferRate = "{0:N2}" -f ($averageTransferRateMB / 1024) + "GBs"
    } else {
        $averageTransferRate += "MBs"
    }
    $formattedTime = $timeElapsed.ToString('hh\:mm\:ss')
    $progressBar = "`rRecieved $dataReceived, Rate/Avrg $transferRate/$averageTransferRate, Time Taken $formattedTime".PadRight(70)
    Start-Sleep -Seconds 1
    Write-Host $progressBar -NoNewline
}

# BITS Service Method
function BITSMethod {
    param (
        $RemoteUrl,
        $DestinationPath
    )
    $startTime = Get-Date
    try {
        $null = Start-BitsTransfer -Source $RemoteUrl -Destination $DestinationPath -Asynchronous -DisplayName "Downloading" -Priority Foreground
        $job = Get-BitsTransfer | Where-Object { $_.DisplayName -eq "Downloading" }
        while (($job.JobState -eq "Transferring") -or ($job.JobState -eq "Connecting")) {
            ShowProgress -bytesTransferred ($job | Measure-Object -Property BytesTransferred -Sum).Sum -timeElapsed ((Get-Date) - $startTime)
        }
        Complete-BitsTransfer -BitsJob $job -Confirm:$false
        return "True"
    } catch {
        Write-Host "Error downloading file using BITS_Service: $_"
        return "False"
    }
}

# Invoke-WebRequest Method
function InvokeWebRequestMethod {
    param (
        $RemoteUrl,
        $DestinationPath
    )
    $startTime = Get-Date
    $previousProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    try {
        $response = Invoke-WebRequest -Uri $RemoteUrl -Method Get -UseBasicParsing
        $fileStream = [System.IO.File]::OpenWrite($DestinationPath)
        $bufferSize = $chunk
        $buffer = New-Object byte[] $bufferSize
        $totalRead = 0
        $responseStream = New-Object System.IO.MemoryStream
        $responseStream.Write($response.Content, 0, $response.Content.Length)
        $responseStream.Position = 0
        do {
            $read = $responseStream.Read($buffer, 0, $bufferSize)
            $fileStream.Write($buffer, 0, $read)
            $totalRead += $read
            ShowProgress -bytesTransferred $totalRead -timeElapsed ((Get-Date) - $startTime)
        } while ($read -gt 0)
        $fileStream.Close()
        $responseStream.Close()
        return "True"
    } catch {
        Write-Host "An error occurred during download: $_"
        return "False"
    } finally {
        $ProgressPreference = $previousProgressPreference
    }
}

# WebClient Method
function WebClientMethod {
    param (
        $RemoteUrl,
        $DestinationPath
    )
    $startTime = Get-Date
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537")
        $response = $webClient.DownloadData($RemoteUrl)
        $fileStream = [System.IO.File]::OpenWrite($DestinationPath)
        $bufferSize = $chunk
        $buffer = New-Object byte[] $bufferSize
        $totalRead = 0
        $responseStream = New-Object System.IO.MemoryStream
        $responseStream.Write($response, 0, $response.Length)
        $responseStream.Position = 0
        do {
            $read = $responseStream.Read($buffer, 0, $bufferSize)
            $fileStream.Write($buffer, 0, $read)
            $totalRead += $read
            ShowProgress -bytesTransferred $totalRead -timeElapsed ((Get-Date) - $startTime)
        } while ($read -gt 0)
        $fileStream.Close()
        $responseStream.Close()
        return "True"
    } catch {
        Write-Host "Error downloading file: $_"
        return "False"
    }
}


# Try each technique
for ($i = 0; $i -lt $techniques.Length; $i++) {
    $technique = $techniques[$i]
    Write-Host "`nTrying technique $($i + 1)..."

    try {
        $success = & $technique
        $filename = $filenames[$i]
        $destinationPath = Join-Path $downloadsFolder $filename
        $filePresent = "No"
        $over1MB = "No"

        if (Test-Path $destinationPath) {
            $filePresent = "Yes"
            $fileSize = (Get-Item $destinationPath).Length
            if ($fileSize -ge 1MB) {
                $over1MB = "Yes"
            }
        }

        $results += "Method: Technique $($i + 1), File Present: $filePresent, Over 1MB: $over1MB"
    } catch {
        $results += "Error during technique $($i + 1): $_"
    }
}

# Print the report
Write-Host "`nReport:"
$results | ForEach-Object { Write-Host $_ }