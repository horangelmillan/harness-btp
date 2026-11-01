# cf-safe-patterns.ps1 - Tabla central de redaccion de secretos (fail-closed).
# Sin tildes (PS5.1 + UTF8). Sin secretos: solo regex y marcador.
# Patron de referencia: doc-extract-lab/srv/lib/die-client.js (redactDieSecrets).

$RedactPatterns = @(
  # 1. Asignaciones clave=valor / clave: valor de secretos comunes.
  @{ Name = 'secret-assignment'; Regex = '(?i)("?(?:access_token|refresh_token|id_token|client_secret|clientsecret|clientSecret|secret|password|passwd|pwd|api_key|apikey|private_key)"?\s*[:=]\s*"?)[^"&\s,}]+("?)'; Replace = '$1***REDACTED***$2' },
  # 2. Cabeceras de autorizacion Bearer / Basic.
  @{ Name = 'auth-header'; Regex = '(?i)\b(Bearer|Basic)\s+[A-Za-z0-9\-._~+/=]+'; Replace = '$1 ***REDACTED***' },
  # 3. JWT (tres segmentos base64url separados por puntos).
  @{ Name = 'jwt'; Regex = '\beyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_.-]+'; Replace = '***REDACTED***' },
  # 4. Bloques PEM de clave privada.
  @{ Name = 'private-key-block'; Regex = '(?s)-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----.*?-----END (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'; Replace = '***REDACTED***' },
  # 5. Bloques "credentials" JSON (valor completo hasta llave de cierre simple).
  @{ Name = 'credentials-block'; Regex = '(?i)("credentials"\s*:\s*\{)[^}]*\}'; Replace = '$1***REDACTED***}' },
  # 6. Parametros -p / --parameters con JSON en linea (cf service-key -p '{...}').
  @{ Name = 'inline-parameters'; Regex = "(?i)(?:-p\s+|--parameters\s+)('[^']*'|\{[^{}]*\})"; Replace = '$1***REDACTED***' }
)

$RedactMarker = '***REDACTED***'

function Redact-Secrets {
  # Redaccion fail-closed: ante cualquier error devuelve el marcador,
  # nunca el texto original.
  param([string]$Text)
  if ([string]::IsNullOrEmpty($Text)) { return '' }
  try {
    $out = $Text
    foreach ($p in $RedactPatterns) {
      $out = [regex]::Replace($out, $p.Regex, $p.Replace)
    }
    # Verificacion fail-closed: si tras redactar queda alguna senal
    # evidente de secreto, colapsa la linea entera al marcador.
    $leftover = @('clientsecret', 'client_secret', 'BEGIN PRIVATE', 'Bearer eyJ', 'Basic ')
    foreach ($sig in $leftover) {
      if ($out -like "*$sig*") {
        $lines = $out -split "`r?`n"
        $lines = foreach ($ln in $lines) {
          if ($ln -like "*$sig*") { $RedactMarker } else { $ln }
        }
        $out = $lines -join [Environment]::NewLine
      }
    }
    return $out
  } catch {
    return $RedactMarker
  }
}
