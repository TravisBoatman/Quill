param (
    [Parameter(Mandatory=$false)]
    [string]$location = 'help'
)

function Show-Locations {
    $keys = $locations.PSObject.Properties.Name
    if ($keys.Count -eq 0) {
        Write-Host "No options available in the actions file."
    } else {
        Write-Host "Available options:"
        $keys | Sort-Object | ForEach-Object { Write-Host "`t$_" }
    }
}

function Expand-PathVariables($path) {
    return $ExecutionContext.InvokeCommand.ExpandString($path)
}

try {
    $jsonPath = [System.Environment]::ExpandEnvironmentVariables("$env:TB_SCRIPTS\paths\locations.json")
    $locations = Get-Content -Path $jsonPath -ErrorAction Stop | ConvertFrom-Json
} catch {
    Write-Host "Error loading location data from JSON file. Please check the file path and format."
    exit
}

if ($location -eq "help") {
    Show-Locations
    exit
}

if ($locations.PSObject.Properties.Name -contains $location) {
    $resolvedPath = Expand-PathVariables $locations.$location
    Set-Location $resolvedPath
} else {
    Write-Host "Unknown location: $location"
    Show-Locations
}
