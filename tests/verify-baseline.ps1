# ============================================================
# COBOL + Java Migration Lab
# Verificación de referencia de las salidas existentes.
#
# Este script NO ejecuta los programas ni modifica sus salidas.
# Comprueba que los resultados presentes sean los esperados.
# ============================================================

$ErrorActionPreference = 'Stop'

# Resolver las rutas respecto de la raíz del proyecto.
$root = Split-Path -Parent $PSScriptRoot
$work = Join-Path $root 'work'

$javaPath = Join-Path $work 'java.out'
$cobolPath = Join-Path $work 'cobol.out'

# Definir la salida esperada para las seis transacciones
# y los dos saldos finales del conjunto de datos actual.
$expectedLines = @(
    'TX|T00000000001|APPROVED|00000020000'
    'TX|T00000000002|APPROVED|00000021250'
    'TX|T00000000003|DECLINED|00000000900'
    'TX|T00000000004|APPROVED|00000016250'
    'TX|T00000000004|DUPLICATE|00000016250'
    'TX|T00000000005|NO_ACCOUNT|00000000000'
    'BAL|A000000001|00000016250'
    'BAL|A000000002|00000000900'
)

# Detener la prueba si falta alguna de las salidas.
foreach ($path in @($javaPath, $cobolPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Falta el archivo requerido: $path"
    }
}

# Leer los archivos como bytes para comprobar su igualdad real.
$javaBytes = [System.IO.File]::ReadAllBytes($javaPath)
$cobolBytes = [System.IO.File]::ReadAllBytes($cobolPath)

$bytesMatch = $javaBytes.Length -eq $cobolBytes.Length

if ($bytesMatch) {
    for ($index = 0; $index -lt $javaBytes.Length; $index++) {
        if ($javaBytes[$index] -ne $cobolBytes[$index]) {
            $bytesMatch = $false
            break
        }
    }
}

if (-not $bytesMatch) {
    throw 'FAIL: las salidas de COBOL y Java difieren byte por byte.'
}

Write-Host '[PASS] COBOL y Java son idénticos byte por byte.'

# Leer las líneas con la codificación UTF-8 y validar el contenido.
$javaLines = [System.IO.File]::ReadAllLines(
    $javaPath,
    [System.Text.Encoding]::UTF8
)

$cobolLines = [System.IO.File]::ReadAllLines(
    $cobolPath,
    [System.Text.Encoding]::UTF8
)

# Verificar que el número de resultados sea el esperado.
if ($javaLines.Count -ne $expectedLines.Count) {
    throw "FAIL: Java produjo $($javaLines.Count) líneas; se esperaban $($expectedLines.Count)."
}

if ($cobolLines.Count -ne $expectedLines.Count) {
    throw "FAIL: COBOL produjo $($cobolLines.Count) líneas; se esperaban $($expectedLines.Count)."
}

# Comprobar cada resultado contra la referencia aprobada.
for ($index = 0; $index -lt $expectedLines.Count; $index++) {
    if ($javaLines[$index] -cne $expectedLines[$index]) {
        throw "FAIL: Java difiere de la referencia en la línea $($index + 1). Esperado: $($expectedLines[$index])"
    }

    if ($cobolLines[$index] -cne $expectedLines[$index]) {
        throw "FAIL: COBOL difiere de la referencia en la línea $($index + 1). Esperado: $($expectedLines[$index])"
    }
}

Write-Host '[PASS] Las ocho líneas coinciden con la referencia.'
Write-Host '[PASS] Los saldos finales coinciden con los esperados.'
Write-Host 'BASELINE PASS: las salidas actuales superan todas las verificaciones.'