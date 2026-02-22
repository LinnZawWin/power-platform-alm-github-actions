$envUrl = "https://lzwdev.crm6.dynamics.com/"

# Get existing auth profiles as text
$profiles = pac auth list 2>&1
$profilesText = $profiles -join "`n"

# Check if a profile already targets this URL
if ($profilesText -match [regex]::Escape($envUrl)) {
    Write-Host "Auth profile for $envUrl already exists. Skipping create."
} else {
    Write-Host "No auth profile found for $envUrl. Creating one..."
    pac auth create --environment "$envUrl" --deviceCode # Open the URL https://microsoft.com/devicelogin in its browser profile and enter the code
}

# Select the DEV environment profile by URL
pac env select --environment "$envUrl"

# Define list of solutions to export
$solutions = @(
    "ClinicalNotes"
)

# Export each solution
foreach ($solutionName in $solutions) {
    Write-Host "Exporting solution: $solutionName..."
    $solutionPath = "$solutionName"
    if (Test-Path $solutionPath) {
        Remove-Item $solutionPath -Recurse -Force
    }
    pac solution clone --name $solutionName --packagetype Both
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully exported $solutionName" -ForegroundColor Green
    } else {
        Write-Host "Failed to export $solutionName" -ForegroundColor Red
    }
}