#!/bin/bash
# Validador solo-lectura de apps CAP/UI5/MTA (espejo Unix de validate-app.ps1).
# Uso: bash AI/scripts/validate-app.sh [PATH]  (defecto .)
# Solo lee archivos y escribe en stdout. Exit 0 si ningun FAIL; exit 1 si hay FAIL.
# Usa python3 o node solo si existen; si no, chequeo por texto grep/sed.
# Formato: RESULTADO|ambito|archivo|problema|impacto|fix|auto-fix|evidencia
TARGET="${1:-.}"
HAS_FAIL=0
emit() { # emit RESULTADO ambito archivo problema impacto fix autofix evidencia
  [ "$1" = "FAIL" ] && HAS_FAIL=1
  printf '%s|%s|%s|%s|%s|%s|%s|%s\n' "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
}
if [ ! -e "$TARGET" ]; then
  emit FAIL param "$TARGET" "ruta inexistente" "no se puede validar" "usa una ruta existente" NO LOCAL
  exit 1
fi
have_py=0; have_node=0
command -v python3 >/dev/null 2>&1 && have_py=1
command -v node >/dev/null 2>&1 && have_node=1
json_ok() { # json_ok archivo -> 0 si JSON valido
  f="$1"
  if [ "$have_py" -eq 1 ]; then python3 -c "import json,sys; json.load(open(sys.argv[1], encoding='utf-8-sig'))" "$f" 2>/dev/null; return $?
  elif [ "$have_node" -eq 1 ]; then node -e "var s=require('fs').readFileSync(process.argv[1],'utf8'); if(s.charCodeAt(0)===65279)s=s.slice(1); JSON.parse(s)" "$f" 2>/dev/null; return $?
  else grep -q '{' "$f" 2>/dev/null; return $?
  fi
}

# --- Deteccion de tipo ---
is_cap=0; is_hana=0; is_ui5=0; is_mta=0; is_approuter=0; is_xsuaa=0
[ -d "$TARGET/srv" ] && is_cap=1
if ls "$TARGET"/db/*.cds >/dev/null 2>&1; then is_cap=1; fi
if [ -f "$TARGET/package.json" ] && grep -q '@sap/cds' "$TARGET/package.json" 2>/dev/null; then is_cap=1; fi
if ls "$TARGET"/db/src/*.hdb* >/dev/null 2>&1 || ls "$TARGET"/db/*.hdb* >/dev/null 2>&1 || find "$TARGET/db" -name '*.hdb*' 2>/dev/null | grep -q .; then is_hana=1; fi
if find "$TARGET" -name '*.hdbtabledata' 2>/dev/null | grep -q .; then is_hana=1; fi
if find "$TARGET" -name 'manifest.json' 2>/dev/null | grep -q .; then
  while IFS= read -r m; do grep -q 'sap\.app' "$m" 2>/dev/null && { is_ui5=1; break; }; done <<EOF
$(find "$TARGET" -name 'manifest.json' 2>/dev/null)
EOF
fi
[ -f "$TARGET/mta.yaml" ] && is_mta=1
[ -f "$TARGET/xs-app.json" ] && is_approuter=1
[ -f "$TARGET/xs-security.json" ] && is_xsuaa=1
desc=""
[ "$is_cap" -eq 1 ] && desc="${desc}+CAP"
[ "$is_hana" -eq 1 ] && desc="${desc}+HANA"
[ "$is_ui5" -eq 1 ] && desc="${desc}+UI5"
[ "$is_mta" -eq 1 ] && desc="${desc}+MTA"
[ "$is_approuter" -eq 1 ] && desc="${desc}+approuter"
[ "$is_xsuaa" -eq 1 ] && desc="${desc}+xsuaa"
[ -z "$desc" ] && desc="+desconocido"
desc="${desc#+}"
[ "$is_cap" -eq 1 ] && [ "$is_ui5" -eq 1 ] && desc="${desc}+fullstack"
emit PASS tipo . "tipo detectado: $desc" "alcance de checks" ninguno NO LOCAL

# --- mta.yaml ---
if [ ! -f "$TARGET/mta.yaml" ]; then
  emit N-A mta mta.yaml "sin mta.yaml" "deploy MTA no aplica" "crea mta.yaml si el MVP exige MTA" NO LOCAL
else
  grep -qE '^[[:space:]]*modules[[:space:]]*:' "$TARGET/mta.yaml" \
    && emit PASS mta mta.yaml "modules[] presente" ninguno ninguno NO LOCAL \
    || emit FAIL mta mta.yaml "falta modules[]" "mbt/cf deploy falla" "declara modules: con al menos un modulo" NO LOCAL
  grep -qE '^[[:space:]]*resources[[:space:]]*:' "$TARGET/mta.yaml" \
    && emit PASS mta mta.yaml "resources[] presente" ninguno ninguno NO LOCAL \
    || emit WARNING mta mta.yaml "falta resources[]" "servicios sin declarar" "declara resources: (xsuaa/destination) si aplica" NO LOCAL
  if grep -qE '^[[:space:]]*requires[[:space:]]*:' "$TARGET/mta.yaml"; then
    if grep -qE 'name[[:space:]]*:' "$TARGET/mta.yaml"; then
      emit PASS mta mta.yaml "todo requires tiene destino/nombre" ninguno ninguno NO LOCAL
    else
      emit FAIL mta mta.yaml "requires sin destino" "binding roto en deploy" "anade name: al requires" NO LOCAL
    fi
  else
    emit N-A mta mta.yaml "sin requires con nombre" "nada que resolver" ninguno NO LOCAL
  fi
fi

# --- xs-security.json ---
if [ ! -f "$TARGET/xs-security.json" ]; then
  emit N-A xsuaa xs-security.json "sin xs-security.json" "auth XSUAA no aplica" "crealo si el MVP exige xsuaa" NO LOCAL
else
  f="$TARGET/xs-security.json"
  json_ok "$f" && emit PASS xsuaa xs-security.json "JSON valido" ninguno ninguno NO LOCAL \
    || emit FAIL xsuaa xs-security.json "JSON invalido" "deploy xsuaa falla" "valida el JSON" NO LOCAL
  grep -q '"xsappname"' "$f" \
    && emit PASS xsuaa xs-security.json "xsappname presente" ninguno ninguno NO LOCAL \
    || emit FAIL xsuaa xs-security.json "falta xsappname" "instancia xsuaa invalida" "anade xsappname" NO LOCAL
  if grep -q '"scopes"' "$f" && grep -q '"role-templates"' "$f"; then
    emit PASS xsuaa xs-security.json "scopes+role-templates presentes" ninguno ninguno NO LOCAL
  else
    emit FAIL xsuaa xs-security.json "faltan scopes o role-templates" "autorizacion incompleta" "declara scopes y role-templates" NO LOCAL
  fi
  scopes=$(grep -o '\$XSAPPNAME\.[A-Za-z0-9_-]*' "$f" 2>/dev/null | sed 's/.*\.//' | sort -u)
  names=$(grep -o '"name"[[:space:]]*:[[:space:]]*"\$XSAPPNAME\.[^"]*"' "$f" 2>/dev/null | sed 's/.*\.//;s/"//' | sort -u)
  orphan=""
  for s in $scopes; do echo "$names" | grep -qx "$s" || orphan="$orphan,$s"; done
  orphan="${orphan#,}"
  [ -z "$orphan" ] \
    && emit PASS xsuaa xs-security.json "scope-references existen" ninguno ninguno NO LOCAL \
    || emit FAIL xsuaa xs-security.json "scope-references sin scope: $orphan" "rol roto en runtime" "declara el scope o corrige la referencia" NO LOCAL
  if grep -qiE 'clientsecret|password|BEGIN PRIVATE' "$f"; then
    emit FAIL xsuaa xs-security.json "posible secreto literal" "fuga de credencial" "mueve el secreto fuera del repo" NO LOCAL
  elif grep -qE 'eyJ[A-Za-z0-9_-]{8,}' "$f"; then
    emit FAIL xsuaa xs-security.json "posible token JWT literal" "fuga de credencial" "elimina el token del repo" NO LOCAL
  else
    emit PASS xsuaa xs-security.json "cero secretos literales" ninguno ninguno NO LOCAL
  fi
fi

# --- xs-app.json ---
if [ ! -f "$TARGET/xs-app.json" ]; then
  emit N-A approuter xs-app.json "sin xs-app.json" "approuter no aplica" "crealo si el MVP exige approuter" NO LOCAL
else
  f="$TARGET/xs-app.json"
  json_ok "$f" || emit FAIL approuter xs-app.json "JSON invalido" "approuter no arranca" "valida el JSON" NO LOCAL
  if grep -q '"routes"' "$f" && grep -q '"source"' "$f"; then
    emit PASS approuter xs-app.json "routes[] presente" ninguno ninguno NO LOCAL
    nsrc=$(grep -c '"source"' "$f"); ndst=$(grep -cE '"destination"|"localDir"' "$f")
    if [ "$ndst" -ge "$nsrc" ] && [ "$nsrc" -gt 0 ]; then
      emit PASS approuter xs-app.json "rutas con source y destination|localDir" ninguno ninguno NO LOCAL
    else
      emit FAIL approuter xs-app.json "ruta(s) sin source o destino" "ruta 404/500" "anade source y destination|localDir" NO LOCAL
    fi
  else
    emit FAIL approuter xs-app.json "routes[] vacio o ausente" "sin rutas" "declara al menos una ruta" NO LOCAL
  fi
  grep -q '"authenticationMethod"' "$f" \
    && emit PASS approuter xs-app.json "authenticationMethod presente" ninguno ninguno NO LOCAL \
    || emit FAIL approuter xs-app.json "falta authenticationMethod" "auth ambigua" "declara authenticationMethod (route)" NO LOCAL
fi

# --- package.json CAP ---
if [ ! -f "$TARGET/package.json" ]; then
  emit N-A cap package.json "sin package.json" "CAP no aplica" "crealo si el MVP exige CAP" NO LOCAL
else
  f="$TARGET/package.json"
  json_ok "$f" && emit PASS cap package.json "JSON valido" ninguno ninguno NO LOCAL \
    || emit FAIL cap package.json "JSON invalido" "npm install falla" "valida el JSON" NO LOCAL
  if [ "$is_cap" -eq 1 ]; then
    grep -qE '"@sap/cds"[[:space:]]*:[[:space:]]*"\^?10' "$f" \
      && emit PASS cap package.json "@sap/cds ^10 presente" ninguno ninguno NO LOCAL \
      || emit FAIL cap package.json "falta @sap/cds ^10" "modelo CAP no compila" "anade @sap/cds ^10" NO LOCAL
    grep -q '"@cap-js/sqlite"' "$f" \
      && emit PASS cap package.json "@cap-js/sqlite presente (dev local)" ninguno ninguno NO LOCAL \
      || emit WARNING cap package.json "falta @cap-js/sqlite" "sin BD local para dev/test" "anade @cap-js/sqlite (solo dev local, nunca en MTA)" NO LOCAL
    if grep -q '"test"' "$f" && grep -q '"build"' "$f"; then
      emit PASS cap package.json "scripts test+build presentes" ninguno ninguno NO LOCAL
    else
      emit WARNING cap package.json "faltan scripts test/build" "CI/E2E incompleto" "anade scripts test y build" NO LOCAL
    fi
  else
    emit N-A cap package.json "no es proyecto CAP" "nada que exigir" ninguno NO LOCAL
  fi
fi

# --- manifest.json ---
manifests=$(find "$TARGET" -name 'manifest.json' 2>/dev/null)
if [ -z "$manifests" ]; then
  emit N-A ui5 manifest.json "sin manifest.json" "UI5 no aplica" "crealo si el MVP exige UI5" NO LOCAL
else
  echo "$manifests" | while IFS= read -r m; do
    rel="${m#"$TARGET"/}"; [ "$rel" = "$m" ] && rel=$(basename "$m")
    if ! json_ok "$m"; then emit FAIL ui5 "$rel" "JSON invalido" "app UI5 no carga" "valida el JSON" NO LOCAL; continue; fi
    grep -q '"sap\.app"' "$m" \
      && emit PASS ui5 "$rel" "sap.app presente" ninguno ninguno NO LOCAL \
      || emit FAIL ui5 "$rel" "falta sap.app" "descriptor UI5 invalido" "anade sap.app" NO LOCAL
    grep -q '"id"' "$m" \
      && emit PASS ui5 "$rel" "sap.app/id presente" ninguno ninguno NO LOCAL \
      || emit FAIL ui5 "$rel" "falta sap.app/id" "id de app desconocido" "anade sap.app.id" NO LOCAL
    grep -q '"type"' "$m" \
      && emit PASS ui5 "$rel" "type presente" ninguno ninguno NO LOCAL \
      || emit WARNING ui5 "$rel" "falta type" "tooling incompleto" "anade sap.app.type=application" NO LOCAL
  done
fi

# --- db/srv *.cds no vacios ---
cds=$(find "$TARGET/db" "$TARGET/srv" -name '*.cds' 2>/dev/null)
if [ -z "$cds" ]; then
  emit N-A db "db/*.cds" "sin modelos CDS" "CAP/HANA no aplica" "crea db/schema.cds si el MVP exige CAP" NO LOCAL
else
  echo "$cds" | while IFS= read -r c; do
    rel="${c#"$TARGET"/}"
    if [ -s "$c" ]; then emit PASS db "$rel" "CDS no vacio" ninguno ninguno NO LOCAL
    else emit FAIL db "$rel" "CDS vacio" "modelo sin entidades" "declara entidades" NO LOCAL; fi
  done
  # propaga FAIL de subshell via marcador
  if echo "$cds" | while IFS= read -r c; do [ -s "$c" ] || echo FAIL; done | grep -q FAIL; then HAS_FAIL=1; fi
fi

# --- test-aislamiento: 3 WARNING solo-lectura (regex, nunca FAIL) ---
testfiles=$(find "$TARGET" \( -name '*.test.js' -o -name '*.spec.js' \) 2>/dev/null)
if [ -z "$testfiles" ]; then
  emit N-A test "test/*.test.js" "sin suites de test" "aislamiento no aplica" "crea suites con fixtures propias si el MVP exige matriz" NO LOCAL
else
  all_t=$(find "$TARGET" \( -name '*.test.js' -o -name '*.spec.js' \) -exec cat {} + 2>/dev/null)
  if echo "$all_t" | grep -qE 'localhost:[0-9]+|127\.0\.0\.1:[0-9]+|PORT *= *[0-9]+' \
    && ! echo "$all_t" | grep -qE 'process\.env\.PORT|process\.env\['; then
    emit WARNING test "test/*.test.js" "puerto fijo sin process.env.PORT" "suites colisionan en paralelo/CI" "usa const PORT = Number(process.env.PORT || 4011)" NO LOCAL
  else
    emit PASS test "test/*.test.js" "puerto via env o sin literal" ninguno ninguno NO LOCAL
  fi
  if echo "$all_t" | grep -q 'try' && echo "$all_t" | grep -q 'finally' && echo "$all_t" | grep -q 'cleanup'; then
    emit PASS test "test/*.test.js" "try/finally+cleanup presentes" ninguno ninguno NO LOCAL
  else
    emit WARNING test "test/*.test.js" "falta try/finally+cleanup" "estado compartido entre casos" "envuelve cada it en try/finally con cleanup(DELETE)" NO LOCAL
  fi
  if echo "$all_t" | grep -q 'serialNumber' && ! echo "$all_t" | grep -qE 'randomUUID|randomBytes|Date\.now\(\)|uuid'; then
    emit WARNING test "test/*.test.js" "serial hardcodeado sin unicidad" "colision unique en rerun/paralelo" "genera seriales unicos por caso (randomUUID)" NO LOCAL
  else
    emit PASS test "test/*.test.js" "seriales unicos o sin serial" ninguno ninguno NO LOCAL
  fi
fi

# --- LOCAL-BUILD: BLOCKED sin fallar ---
if [ "$is_cap" -eq 1 ]; then
  command -v cds >/dev/null 2>&1 \
    && emit PASS build cds "CLI cds disponible" ninguno ninguno NO LOCAL \
    || emit BLOCKED build cds "CLI cds no disponible" "compilacion CAP no verificable" "npx -p @sap/cds-dk cds compile --to edmx" NO LOCAL
fi
if [ "$is_mta" -eq 1 ]; then
  command -v mbt >/dev/null 2>&1 \
    && emit PASS build mbt "CLI mbt disponible" ninguno ninguno NO LOCAL \
    || emit BLOCKED build mbt "CLI mbt no disponible" "MTAR no verificable" "npx -p @sap/cloud-mta-build-tool mbt build" NO LOCAL
fi

[ "$HAS_FAIL" -eq 1 ] && exit 1 || exit 0
