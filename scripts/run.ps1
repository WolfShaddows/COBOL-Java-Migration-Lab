$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$work = Join-Path $root 'work'
$toolchain = Join-Path $root 'tools\gnucobol-3.2-msys2'
$cobc = Join-Path $toolchain 'bin\cobc.exe'
if (-not (Test-Path -LiteralPath $cobc)) {
  throw "Portable GnuCOBOL missing: $cobc"
}
$env:PATH = "$(Join-Path $toolchain 'bin');$env:PATH"
$env:COB_CONFIG_DIR = Join-Path $toolchain 'config'
$env:COB_COPY_DIR = Join-Path $toolchain 'copy'
$env:COB_LIBRARY_PATH = Join-Path $toolchain 'extras'
New-Item -ItemType Directory -Force -Path $work | Out-Null
Push-Location (Join-Path $root 'data')
try {
  javac -d $work (Join-Path $root 'src\java\LedgerBatch.java')
  if ($LASTEXITCODE -ne 0) { throw 'javac failed' }
  & $cobc -x -free -o (Join-Path $work 'ledger.exe') (Join-Path $root 'src\cobol\ledger.cbl')
  if ($LASTEXITCODE -ne 0) { throw 'GnuCOBOL compile failed' }
  java -cp $work LedgerBatch (Get-Location).Path (Join-Path $work 'java.out')
  if ($LASTEXITCODE -ne 0) { throw 'Java simulation failed' }
  & (Join-Path $work 'ledger.exe') (Join-Path $work 'cobol.out')
  if ($LASTEXITCODE -ne 0) { throw 'COBOL simulation failed' }
  $javaOutput = Get-Content (Join-Path $work 'java.out') -Raw
  $cobolOutput = Get-Content (Join-Path $work 'cobol.out') -Raw
  if ($javaOutput -cne $cobolOutput) {
    Compare-Object (Get-Content (Join-Path $work 'java.out')) (Get-Content (Join-Path $work 'cobol.out'))
    throw 'Outputs differ'
  }
  Write-Host 'PASS: COBOL and Java outputs match byte-for-byte.'
  Get-Content (Join-Path $work 'java.out')
} finally {
  Pop-Location
}
