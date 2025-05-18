#!/bin/sh
# Si WEB=true -> arranca el servidor; de lo contrario sale silenciosamente.
if [ "$WEB" = "true" ]; then
  exec python -m http.server 8001
else
  echo "Frontend Web deshabilitado (WEB!=\"true\"). Saliendo."
  exit 0
fi
