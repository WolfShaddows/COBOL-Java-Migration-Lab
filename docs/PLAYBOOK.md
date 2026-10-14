# Proyecto de migración, de punta a punta

1. **Delimitar:** escoger un solo job; registrar dueño, SLA, volumen, ventanas, dependencias, archivos/tablas, calendarios, checkpoints, reintentos y rollback.
2. **Descubrir:** inventariar COBOL/copybooks/JCL, scheduler, CICS/DB2, utilidades, salidas, códigos de retorno y runbooks. Entrevistar operaciones y contabilidad para encontrar reglas tácitas.
3. **Especificar:** fijar formatos, monedas/escalas, rounding, overflow, orden, fecha de negocio, duplicados, atomicidad y errores. Negocio aprueba ejemplos.
4. **Golden master:** congelar versión COBOL y corpus sintético/enmascarado con outputs y totales esperados. Cubrir extremos, formatos inválidos, duplicados, reinicio y reproceso.
5. **Portar una unidad:** preservar contrato observable. Java usa decimal exacto; separar parseo, regla y persistencia. Integración con COBOL debe declarar identidad, timeout, backpressure, error y granularidad. Sin API por default.
6. **Equivalencia:** correr ambas versiones con mismo snapshot/orden, en sombra y sin efectos externos del candidato. Comparar registros, saldos, conteos, totales, códigos, orden y reinicios. Cero diferencias financieras inexplicadas.
7. **Capacidad:** medir en plataforma objetivo, con volúmenes bajo/típico/pico y contención. Reportar throughput, CPU/I/O/memoria/GC/locks, p50/p95/p99 y recuperación. Chunks/particiones se prueban contra la carga y aislamiento; definir commits/checkpoints para que reinicios no dupliquen ni pierdan movimientos.
8. **Seguridad:** threat model de terminal/adquirente/middleware/core/DB/operaciones. Mínimo privilegio, autorización por acción y objeto, identidad propagada, auditoría protegida, idempotencia/replay, secretos, límites, segregación y alertas.
9. **Piloto:** canary con límites, feature flag, on-call y conciliación. COBOL conserva autoridad hasta aprobar ciclos representativos.
10. **Rollback/corte:** ensayar detener escrituras, drenar colas, conciliar claves idempotentes, volver al job COBOL y reprocesar desde checkpoint aprobado. Retirar COBOL solo al final.

Entregables: mapa de dependencias, contrato, corpus, matriz de controles, diff de equivalencia, benchmark/capacidad, runbook y rollback demostrado.
