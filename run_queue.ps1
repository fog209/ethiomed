$projectPath = "C:\Users\TestUser\ethiomed"
$deviceId = "SOAYYD7HEE65QKY5"
$model = "kilo/nex-agi/nex-n2-pro:free"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$branchName = "overnight-$timestamp"
$logFile = Join-Path $projectPath "overnight_log_$timestamp.txt"
$maxRetries = 5
$backoff = 15

$env:PATH += ";C:\Program Files\Git\usr\bin"
$env:PATH += ";C:\Users\TestUser\AppData\Local\Android\Sdk\platform-tools"
$env:PATH += ";C:\Users\TestUser\AppData\Local\Pub\Cache\bin"
$env:PATH += ";C:\Users\TestUser\AppData\Roaming\npm"

$tasks = @(
    # Tasks go here after Grand Audit
)

function Log {
    param([string]$msg)
    $line = "$(Get-Date -Format 'HH:mm:ss') $msg"
    Write-Host $line
    Add-Content -Path $logFile -Value $line
}

Set-Location $projectPath
git checkout -b $branchName
Log "Branch $branchName created. master NEVER touched."

$taskNum = 0
foreach ($task in $tasks) {
    $taskNum++
    Log "===== TASK $taskNum / $($tasks.Count) ====="
    git add . *> $null
    git commit -m "checkpoint: before task $taskNum" --allow-empty *> $null

    $success = $false
    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        Log "Attempt $attempt of $maxRetries"
        $output = & kilocode run -m "$model" "$task" 2>&1
        $exitCode = $LASTEXITCODE
        Add-Content -Path $logFile -Value $output
        $isServerError = ($output -join "`n") -match "429|rate.?limit|503|502|overloaded"
        if ($exitCode -eq 0 -and -not $isServerError) { $success = $true; break }
        elseif ($isServerError -and $attempt -lt $maxRetries) {
            $wait = $backoff * [math]::Pow(2, $attempt - 1)
            Log "Server error. Backing off $wait sec."
            Start-Sleep -Seconds $wait} else { Log "Task $taskNum failed."; break }
    }

    if (-not $success) {
        Log "STOPPING. Rolling back task $taskNum."
        git checkout . *> $null
        git clean -fd *> $null
        break
    }

    Log "Running flutter analyze..."
    & C:\flutter\bin\flutter.bat analyze *> $null
    if ($LASTEXITCODE -ne 0) {
        Log "flutter analyze FAILED. Rolling back and STOPPING."
        git checkout . *> $null
        git clean -fd *> $null
        break
    }

    git add . *> $null
    git commit -m "feat: task $taskNum complete — analyze clean" *> $null
    Log "Task $taskNum committed clean."
}

Log "Queue complete."
Log "Merge: git checkout master && git merge $branchName"
