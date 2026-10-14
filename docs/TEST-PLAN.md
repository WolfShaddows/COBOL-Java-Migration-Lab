# Plan de prueba / aceptación

- Reglas: débito válido, insuficiente, crédito, cuenta inexistente, duplicado, mismo ID distinto payload, cero, límite, overflow, entrada malformada, archivo vacío y orden cambiado.
- Exactitud: golden master aprobado; salidas, saldos y totales idénticos; ningún diff monetario inexplicado.
- Rendimiento: volúmenes bajo/típico/pico en destino; ventana batch; throughput, CPU, I/O, locks, memoria/GC, round trips y p50/p95/p99; cargas competidoras.
- Resiliencia: caída antes/durante/después de commit, timeout ambiguo, reintento, archivo parcial, checkpoint y conciliación.
- Seguridad: permisos positivos/negativos por usuario/acción/cuenta/sucursal, identidad propagada, replay/idempotencia, logs/secretos, segregación.
- Corte: rollback probado y reconciliado, alarmas y responsables on-call.
- Gate: negocio, operación, plataforma y seguridad aceptan resultados y SLO con margen; nunca corte con diferencias inexplicadas.
