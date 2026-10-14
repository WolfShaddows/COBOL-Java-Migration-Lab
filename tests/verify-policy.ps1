$ErrorActionPreference = 'Stop'

$root = 'C:\Users\PC\Desktop\COBOL-Java-Migration-Lab'
$work = Join-Path $root 'work\policy-tests'
$caseRoot = Join-Path $work 'cases'
$javaClasses = Join-Path $work 'java-classes'
$cobolExe = Join-Path $work 'ledger-policy.exe'
$reportPath = Join-Path $work 'policy-test-report.txt'

$cobc = Join-Path $root 'tools\gnucobol-3.2-msys2\bin\cobc.exe'
# Match the portable GnuCOBOL environment used by scripts/run.ps1.
$toolchain = Join-Path $root 'tools\gnucobol-3.2-msys2'
$env:PATH = "$(Join-Path $toolchain 'bin');$env:PATH"
$env:COB_CONFIG_DIR = Join-Path $toolchain 'config'
$env:COB_COPY_DIR = Join-Path $toolchain 'copy'
$env:COB_LIBRARY_PATH = Join-Path $toolchain 'extras'
$javac = (Get-Command javac -ErrorAction Stop).Source
$java = (Get-Command java -ErrorAction Stop).Source

foreach ($file in @(
    (Join-Path $root 'src\cobol\ledger.cbl'),
    (Join-Path $root 'src\java\LedgerBatch.java'),
    $cobc
)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Archivo requerido no encontrado: $file"
    }
}

New-Item -ItemType Directory -Path $caseRoot -Force | Out-Null
New-Item -ItemType Directory -Path $javaClasses -Force | Out-Null

Write-Host "`n=== COMPILACIÓN COBOL ===" -ForegroundColor Cyan

& $cobc -x -free -o $cobolExe (Join-Path $root 'src\cobol\ledger.cbl')

if ($LASTEXITCODE -ne 0) {
    throw 'La compilación COBOL falló. No se ejecutaron las pruebas.'
}

Write-Host '[PASS] COBOL compilado.' -ForegroundColor Green

Write-Host "`n=== COMPILACIÓN JAVA ===" -ForegroundColor Cyan

& $javac -d $javaClasses (Join-Path $root 'src\java\LedgerBatch.java')

if ($LASTEXITCODE -ne 0) {
    throw 'La compilación Java falló. No se ejecutaron las pruebas.'
}

Write-Host '[PASS] Java compilado.' -ForegroundColor Green

$baseline = @(
    'TX|T00000000001|APPROVED|00000020000'
    'TX|T00000000002|APPROVED|00000021250'
    'TX|T00000000003|DECLINED|00000000900'
    'TX|T00000000004|APPROVED|00000016250'
    'TX|T00000000004|ID_CONFLICT|00000016250'
    'TX|T00000000005|NO_ACCOUNT|00000000000'
    'BAL|A000000001|00000016250'
    'BAL|A000000002|00000000900'
)

$cases = @(
    [pscustomobject]@{
        Id = 'R00'
        Name = 'original-baseline'
        Accounts = @(
            'ACCOUNT_ID,OPENING_CENTS'
            'A000000001,25000'
            'A000000002,900'
        )
        Transactions = @(
            'TX_ID,ACCOUNT_ID,TYPE,AMOUNT_CENTS'
            'T00000000001,A000000001,D,5000'
            'T00000000002,A000000001,C,1250'
            'T00000000003,A000000002,D,1200'
            'T00000000004,A000000001,D,5000'
            'T00000000004,A000000001,C,99999'
            'T00000000005,A999999999,C,100'
        )
        Expected = $baseline
        RejectInput = $false
    }
    [pscustomobject]@{
        Id = 'R01'
        Name = 'negative-debit'
        Accounts = @('ACCOUNT_ID,OPENING_CENTS','A000000001,10000')
        Transactions = @('TX_ID,ACCOUNT_ID,TYPE,AMOUNT_CENTS','T00000000001,A000000001,D,-1000')
        Expected = @('TX|T00000000001|INVALID_AMOUNT|00000010000','BAL|A000000001|00000010000')
        RejectInput = $false
    }
    [pscustomobject]@{
        Id = 'R02'
        Name = 'negative-credit'
        Accounts = @('ACCOUNT_ID,OPENING_CENTS','A000000001,10000')
        Transactions = @('TX_ID,ACCOUNT_ID,TYPE,AMOUNT_CENTS','T00000000001,A000000001,C,-1000')
        Expected = @('TX|T00000000001|INVALID_AMOUNT|00000010000','BAL|A000000001|00000010000')
        RejectInput = $false
    }
    [pscustomobject]@{
        Id = 'R03'
        Name = 'unknown-type'
        Accounts = @('ACCOUNT_ID,OPENING_CENTS','A000000001,10000')
        Transactions = @('TX_ID,ACCOUNT_ID,TYPE,AMOUNT_CENTS','T00000000001,A000000001,X,1000')
        Expected = @('TX|T00000000001|INVALID_TYPE|00000010000','BAL|A000000001|00000010000')
        RejectInput = $false
    }
    [pscustomobject]@{
        Id = 'R04'
        Name = 'zero-amount'
        Accounts = @('ACCOUNT_ID,OPENING_CENTS','A000000001,10000')
        Transactions = @('TX_ID,ACCOUNT_ID,TYPE,AMOUNT_CENTS','T00000000001,A000000001,D,0')
        Expected = @('TX|T00000000001|APPROVED|00000010000','BAL|A000000001|00000010000')
        RejectInput = $false
    }
    [pscustomobject]@{
        Id = 'R05'
        Name = 'identical-duplicate'
        Accounts = @('ACCOUNT_ID,OPENING_CENTS','A000000001,10000')
        Transactions = @(
            'TX_ID,ACCOUNT_ID,TYPE,AMOUNT_CENTS'
            'T00000000001,A000000001,D,1000'
            'T00000000001,A000000001,D,1000'
        )
        Expected = @(
            'TX|T00000000001|APPROVED|00000009000'
            'TX|T00000000001|DUPLICATE|00000009000'
            'BAL|A000000001|00000009000'
        )
        RejectInput = $false
    }
    [pscustomobject]@{
        Id = 'R06'
        Name = 'duplicate-id-conflicting-payload'
        Accounts = @('ACCOUNT_ID,OPENING_CENTS','A000000001,10000')
        Transactions = @(
            'TX_ID,ACCOUNT_ID,TYPE,AMOUNT_CENTS'
            'T00000000001,A000000001,D,1000'
            'T00000000001,A000000001,C,9000'
        )
        Expected = @(
            'TX|T00000000001|APPROVED|00000009000'
            'TX|T00000000001|ID_CONFLICT|00000009000'
            'BAL|A000000001|00000009000'
        )
        RejectInput = $false
    }
    [pscustomobject]@{
        Id = 'R07'
        Name = 'rejected-transaction-id-remains-reserved'
        Accounts = @('ACCOUNT_ID,OPENING_CENTS','A000000001,10000')
        Transactions = @(
            'TX_ID,ACCOUNT_ID,TYPE,AMOUNT_CENTS'
            'T00000000001,A000000001,D,-1000'
            'T00000000001,A000000001,D,1000'
        )
        Expected = @(
            'TX|T00000000001|INVALID_AMOUNT|00000010000'
            'TX|T00000000001|ID_CONFLICT|00000010000'
            'BAL|A000000001|00000010000'
        )
        RejectInput = $false
    }
    [pscustomobject]@{
        Id = 'R08'
        Name = 'duplicate-account-file'
        Accounts = @(
            'ACCOUNT_ID,OPENING_CENTS'
            'A000000001,10000'
            'A000000001,20000'
        )
        Transactions = @(
            'TX_ID,ACCOUNT_ID,TYPE,AMOUNT_CENTS'
            'T00000000001,A000000001,D,1000'
        )
        Expected = @()
        RejectInput = $true
    }
)

$results = [System.Collections.Generic.List[string]]::new()
$passed = 0
$failed = 0

$results.Add('COBOL + Java Migration Lab')
$results.Add('Fase 5.8 - Pruebas de política')
$results.Add("Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$results.Add('Las pruebas se ejecutan con entradas aisladas en work/.')
$results.Add('')

foreach ($case in $cases) {
    $caseDir = Join-Path $caseRoot $case.Id
    New-Item -ItemType Directory -Path $caseDir -Force | Out-Null

    $accountsPath = Join-Path $caseDir 'accounts.csv'
    $transactionsPath = Join-Path $caseDir 'transactions.csv'
    $cobolOut = Join-Path $caseDir 'cobol.out'
    $javaOut = Join-Path $caseDir 'java.out'

    [System.IO.File]::WriteAllLines(
        $accountsPath,
        [string[]]$case.Accounts,
        [System.Text.UTF8Encoding]::new($false)
    )

    [System.IO.File]::WriteAllLines(
        $transactionsPath,
        [string[]]$case.Transactions,
        [System.Text.UTF8Encoding]::new($false)
    )

    Remove-Item -LiteralPath $cobolOut,$javaOut -Force -ErrorAction SilentlyContinue

    $cobolExit = -999
    $javaExit = -999
    $cobolLog = @()
    $javaLog = @()

    Push-Location -LiteralPath $caseDir
    try {
        $cobolLog = @(& $cobolExe $cobolOut 2>&1)
        $cobolExit = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    $javaLog = @(& $java -cp $javaClasses LedgerBatch $caseDir $javaOut 2>&1)
    $javaExit = $LASTEXITCODE

    $cobolExists = Test-Path -LiteralPath $cobolOut -PathType Leaf
    $javaExists = Test-Path -LiteralPath $javaOut -PathType Leaf

    $cobolLines = @()
    $javaLines = @()

    if ($cobolExists) {
        $cobolLines = @(Get-Content -LiteralPath $cobolOut)
    }

    if ($javaExists) {
        $javaLines = @(Get-Content -LiteralPath $javaOut)
    }

    $cobolPass = $false
    $javaPass = $false

    if ($case.RejectInput) {
        $cobolPass = ($cobolExit -ne 0) -and ($cobolLines.Count -eq 0)
        $javaPass = ($javaExit -ne 0) -and ($javaLines.Count -eq 0)
    }
    else {
        $expectedLines = [string[]]$case.Expected
        $cobolPass = ($cobolExit -eq 0) -and ($cobolExists) -and (($cobolLines -join "`n") -ceq ($expectedLines -join "`n"))
        $javaPass = ($javaExit -eq 0) -and ($javaExists) -and (($javaLines -join "`n") -ceq ($expectedLines -join "`n"))
    }

    $same = ($cobolExists -and $javaExists) -and (($cobolLines -join "`n") -ceq ($javaLines -join "`n"))

    if ($cobolPass -and $javaPass) {
        $state = 'PASS'
        $passed++
        Write-Host "[PASS] $($case.Id) $($case.Name)" -ForegroundColor Green
    }
    else {
        $state = 'FAIL'
        $failed++
        Write-Host "[FAIL] $($case.Id) $($case.Name) | COBOL=$cobolPass Java=$javaPass" -ForegroundColor Yellow
    }

    $results.Add("[$state] $($case.Id) $($case.Name)")
    $results.Add("  COBOL exit: $cobolExit; expected policy pass: $cobolPass")
    $results.Add("  Java exit: $javaExit; expected policy pass: $javaPass")
    $results.Add("  Outputs identical: $same")
    $results.Add("  Expected file-level rejection: $($case.RejectInput)")

    if (-not $cobolPass) {
        $results.Add('  COBOL actual output:')
        foreach ($line in $cobolLines) {
            $results.Add("    $line")
        }
        foreach ($line in $cobolLog) {
            $results.Add("    MESSAGE: $line")
        }
    }

    if (-not $javaPass) {
        $results.Add('  Java actual output:')
        foreach ($line in $javaLines) {
            $results.Add("    $line")
        }
        foreach ($line in $javaLog) {
            $results.Add("    MESSAGE: $line")
        }
    }

    $results.Add('')
}

$results.Add("Total: $($cases.Count)")
$results.Add("Passed: $passed")
$results.Add("Failed: $failed")

[System.IO.File]::WriteAllLines(
    $reportPath,
    $results.ToArray(),
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host "`n=== RESUMEN DE POLÍTICA ===" -ForegroundColor Cyan
Write-Host "Total:  $($cases.Count)"
Write-Host "PASS:   $passed" -ForegroundColor Green
Write-Host "FAIL:   $failed" -ForegroundColor Yellow
Write-Host "Informe: $reportPath"

if ($failed -gt 0) {
    Write-Host "`nHay reglas aprobadas que las implementaciones todavía no cumplen." -ForegroundColor Yellow
    Write-Host 'Esto es esperado antes de corregir los programas.'
}
else {
    Write-Host "`nTodas las pruebas de política pasaron." -ForegroundColor Green
}