# Set up global variables
$global:downloadUrl = "http://ipv4.download.thinkbroadband.com/5MB.zip"
$global:testResults = @()
$global:outputPath = ".\"
$global:outputFile = "File1.Zip"

# Delete existing files, including ".\rAction" and ".\utFile"
Remove-Item -Path "$global:outputPath\File*.Zip", "$global:outputPath\rAction", "$global:outputPath\utFile" -ErrorAction SilentlyContinue
Write-Host "Directory Cleanup Completed.`n"
Start-Sleep -Seconds 2

function Test-WgetCommand {
    param (
        [int]$index
    )

    $localOutputFile = Join-Path $global:outputPath "File$index.zip"
    $global:outputFile = $localOutputFile  # Update the global variable

    try {
        Write-Host "Testing command: Simple Method"
        $downloadCommand = "wget.exe -O $($global:outputFile) $($global:downloadUrl)"
        Invoke-Expression $downloadCommand -ErrorAction Stop
        Write-Host "Download Success!"
        $result = [PSCustomObject]@{
            Method   = "Method $index"
            FileName = $global:outputFile
            Result   = "Success"
        }
    } catch {
        Write-Host "Error: $_"
        $result = [PSCustomObject]@{
            Method   = "Method $index"
            FileName = $localOutputFile  # Use the local variable here
            Result   = "Failure"
        }
    }

    $global:testResults += $result
    Start-Sleep -Seconds 2
}

# Test the simple wget command
Test-WgetCommand 1

# Display results
Write-Host "`nTest Results:`n"
foreach ($result in $global:testResults) {
    $filePath = $result.FileName
    if (Test-Path $filePath) {
        $fileSize = (Get-Item $filePath).length
        if ($fileSize -ge 1MB) {
            Write-Host "$($result.Method) - $($result.FileName): Success"
        } else {
            Write-Host "$($result.Method) - $($result.FileName): Failure (Incorrect size)"
        }
    } else {
        Write-Host "$($result.Method) - $($result.FileName): Failure (Not present)"
    }
}

# Pause
Read-Host "Press Enter to exit..."
