<# Verificación de fuentes oficiales del harness BTP (PowerShell 5.1).
   Uso:
     powershell -ExecutionPolicy Bypass -File AI/scripts/check-docs.ps1
   - Comprueba cada URL de AI/docs/fuentes-oficiales.md con UN solo intento
     HTTP GET (timeout 15 s, sin reintentos ni bucles).
   - Emite OK / ROTO / PENDIENTE por fuente + fecha.
   - OK: HTTP 2xx-3xx. ROTO: HTTP 4xx-5xx confirmado. PENDIENTE: sin respuesta
     (timeout/DNS; avisa pero no falla: re-verificar y actualizar la fecha).
   - exit 1 si alguna fuente REQUERIDA está ROTA. exit 0 en otro caso.
   - Cero secretos: solo peticiones GET anónimas, sin credenciales. #>

$ErrorActionPreference = "Continue"
$Fecha = (Get-Date).ToString("yyyy-MM-dd")
$FallosReq = 0

function Test-Doc {
  param([string]$Nombre, [string]$Url, [string]$Nivel)
  try {
    $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 15 -MaximumRedirection 5
    $code = [int]$r.StatusCode
    if ($code -ge 200 -and $code -lt 400) {
      Write-Output ("{0} | OK | {1} | {2}" -f $Nombre, $Fecha, $Url)
    } else {
      Write-Output ("{0} | ROTO (HTTP {1}) | {2} | {3}" -f $Nombre, $code, $Fecha, $Url)
      if ($Nivel -eq "REQ") { $script:FallosReq++ }
    }
  } catch {
    $resp = $_.Exception.Response
    if ($resp -ne $null) {
      try { $code = [int]$resp.StatusCode } catch { $code = 0 }
      # .NET Framework (PS 5.1) no sigue HTTP 308 automáticamente aunque se pida
      # -MaximumRedirection: se sigue la redirección UNA sola vez, sin bucles.
      if ($code -eq 308) {
        try {
          $loc = $resp.Headers["Location"]
          if ($loc -notmatch "^https?://") {
            $base = ([System.Uri]$Url).GetLeftPart([System.UriPartial]::Authority)
            $loc = $base + $loc
          }
          $r2 = Invoke-WebRequest -Uri $loc -UseBasicParsing -TimeoutSec 15 -MaximumRedirection 5
          $code2 = [int]$r2.StatusCode
          if ($code2 -ge 200 -and $code2 -lt 400) {
            Write-Output ("{0} | OK (redirige HTTP 308 a {1}) | {2} | {3}" -f $Nombre, $loc, $Fecha, $Url)
          } else {
            Write-Output ("{0} | ROTO (HTTP {1} tras 308) | {2} | {3}" -f $Nombre, $code2, $Fecha, $Url)
            if ($Nivel -eq "REQ") { $script:FallosReq++ }
          }
        } catch {
          Write-Output ("{0} | PENDIENTE (308 sin destino legible) | {1} | {2}" -f $Nombre, $Fecha, $Url)
        }
      } else {
        Write-Output ("{0} | ROTO (HTTP {1}) | {2} | {3}" -f $Nombre, $code, $Fecha, $Url)
        if ($Nivel -eq "REQ") { $script:FallosReq++ }
      }
    } else {
      Write-Output ("{0} | PENDIENTE (sin respuesta: timeout/DNS) | {1} | {2}" -f $Nombre, $Fecha, $Url)
    }
  }
}

Write-Output ""
Write-Output ("Fuentes oficiales del harness BTP ({0})" -f $Fecha)
Test-Doc "cf-cli" "https://docs.cloudfoundry.org/cf-cli/install-go-cli.html" "REQ"
Test-Doc "mbt" "https://github.com/SAP/cloud-mta-build-tool" "REQ"
Test-Doc "cap" "https://cap.cloud.sap/docs/get-started/" "REQ"
Test-Doc "ui5-cli" "https://ui5.github.io/cli/" "REQ"
Test-Doc "opencode" "https://docs.opencode.ai/docs" "REQ"
Test-Doc "npm-trusted-publishers" "https://docs.npmjs.com/trusted-publishers/" "REQ"
Test-Doc "op-1password" "https://developer.1password.com/docs/cli/get-started/" "OPT"
Write-Output ""

if ($FallosReq -gt 0) {
  Write-Output ("RESULTADO: {0} fuente(s) REQUERIDA(s) ROTA(s). Revisa AI/docs/fuentes-oficiales.md y actualiza la fecha tras corregir." -f $FallosReq)
  exit 1
} else {
  Write-Output "RESULTADO: ninguna fuente REQUERIDA rota. Actualiza la columna de fecha en AI/docs/fuentes-oficiales.md."
  exit 0
}
