param (
    [Parameter(Mandatory=$false)]
    [string[]]$names = @('help')
)

function Show-Options {
    $keys = $actions.PSObject.Properties.Name
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
    $jsonPath = [System.Environment]::ExpandEnvironmentVariables("$env:TB_SCRIPTS\paths\actions.json")
    $actions = Get-Content -Path $jsonPath -ErrorAction Stop | ConvertFrom-Json
} catch {
    Write-Host "Error loading actions data from JSON file. Please check the file path and format."
    exit
}

if ($names -contains "help") {
    Show-Options
    exit
}

$expandedNames = @()
foreach ($name in $names) {
    if ($actions.PSObject.Properties.Name -contains "groups" -and $null -ne $actions.groups -and $actions.groups.PSObject.Properties.Name -contains $name) {
        $expandedNames += $actions.groups.$name
    } else {
        $expandedNames += $name
    }
}

foreach ($name in $expandedNames) {
    if ($actions.PSObject.Properties.Name -contains $name) {
        $resolvedPath = Expand-PathVariables $actions.$name
        
        if (($resolvedPath -match "^https?://") -or (Test-Path $resolvedPath)) {
            Start-Process -FilePath $resolvedPath
        } else {
            $parts = $resolvedPath -split ' ', 2
            $exe = $parts[0]
            $args1 = if ($parts.Count -gt 1) { $parts[1] } else { $null }
            Start-Process -FilePath $exe -ArgumentList $args1
        }
    } else {
        Write-Host "Unknown option: $name"
        Show-Options
    }
}
