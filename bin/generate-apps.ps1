$ErrorActionPreference = 'Stop'
$apps = [Ordered]@{}

# Get all JSON files in the bucket directory
$bucketPath = Join-Path $PSScriptRoot "..\bucket"
if (-not (Test-Path $bucketPath)) {
    Write-Error "Bucket directory not found at $bucketPath"
}

$files = Get-ChildItem "$bucketPath\*.json" | Sort-Object Name

if ($null -eq $files) {
    Write-Warning "No JSON files found in bucket directory."
}
else {
    Write-Host "Found $($files.Count) files."
    
    foreach ($file in $files) {
        try {
            $content = Get-Content $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            $apps[$file.BaseName] = $content
        }
        catch {
            Write-Warning "Failed to process $($file.Name): $_"
        }
    }
}

$outputPath = Join-Path $PSScriptRoot "..\apps.json"
$apps | ConvertTo-Json -Depth 20 | Set-Content $outputPath -Encoding UTF8
Write-Host "Generated apps.json at $outputPath"
