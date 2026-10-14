# Nuestra postura: COBOL vs Java

## Decisión recomendada
Para un banco con core COBOL que cumple sus objetivos: **complementar primero, migrar selectivamente**. Mantener en COBOL la contabilidad crítica de alto volumen mientras su costo, operación, resiliencia y rendimiento sean aceptables. Java puede servir para capacidades nuevas o componentes con necesidad concreta, pero la frontera se elige por latencia, fallos, volumen, identidad y costo. No crear una API por reflejo ni migrar por moda.

## Aristas que importan
- **Velocidad:** Java sí puede responder en milisegundos. Eso no garantiza el p99 de un sistema entero. Mide el flujo completo y bajo carga. Batch se evalúa por volumen dentro de la ventana, I/O, contención y recuperación.
- **Dinero:** COBOL decimal suele expresar reglas financieras claramente. Java debe usar BigDecimal con escala y rounding explícitos o unidades menores enteras cuando proceda; nunca double para dinero. Monedas distintas requieren exponentes/reglas explícitas.
- **Seguridad:** CICS/RACF pueden proporcionar identidad, autorización por transacción/recurso y auditoría si se habilitaron/configuraron bien. En Java esos controles deben diseñarse y operarse. Ninguno es “seguro por lenguaje”.
- **Operación:** comparar scheduling, checkpoints, reproceso, backups, consistencia, observabilidad, incidentes, habilidades y costo total. Más servicios implican más fronteras de fallo y latencia.
- **Migración:** paridad en reglas, errores, orden, redondeo, saldos, totales, idempotencia, fecha de negocio, acceso concurrente y recuperación.

## Puertas de decisión
1. Conservar si cumple objetivos y su costo/riesgo es aceptable.
2. Complementar si hay una necesidad concreta y un contrato acotado; conservar la autoridad contable en el ledger.
3. Migrar una función solamente después de especificación, golden master, equivalencia en sombra, benchmark en plataforma real, threat model y rollback ensayado.
4. Retirar COBOL únicamente con aprobación de negocio, operaciones, plataforma y seguridad.

La publicación sobre chunks/particiones es acertada: son experimentos, no garantías. Medir round trips, bloqueos, orden, transacciones, memoria, spill y ventana. No extrapolar una demo local.
