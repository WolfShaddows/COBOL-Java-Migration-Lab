# Pagos, terminales y la evidencia compartida

Las capturas muestran placa/adaptador junto a un lector SumUp; app con $10; estados “Payment approved” y “Transaction successful”. Eso solo acredita los mensajes visibles. No prueba qué protocolo se usó, si la placa alteró tráfico, si hubo tarjeta real, autorización del adquirente/emisor o liquidación. No debemos presentar como hecho la interpretación técnica inicial ni inferir fraude.

EMV usa criptografía/criptogramas de transacción; una imagen no verifica esos datos ni clearing. Para investigar legítimamente, correlacionar ID/recibo con el proveedor, autorización y liquidación, bajo consentimiento y autorización.

Controles por capa:
- **Terminal:** dispositivos aprobados, autenticidad/anti-tamper, inventario, inspección y firmware/llaves controladas.
- **Adquirencia:** confirmar autorización del backend; enlazar importe, moneda, comercio, terminal e ID idempotente; límites, reverso y conciliación. UI local no es el ledger.
- **Middleware:** canal protegido, autenticación de servicio, identidad propagada, autorización, validación, límites de tasa, replay protection y logs sin secretos.
- **Core:** contabilización idempotente/atómica, controles de cuenta/estado/saldo, reconciliación y auditoría.
- **Respuesta:** preservar logs, seguir procedimiento y contactar adquirente/proveedor; no experimentar con terminales comerciales ni tarjetas/cuentas ajenas.

CICS/RACF ofrece controles posibles y configurables; Java también puede implementarlos. Verificar configuración efectiva y pruebas de denegación en ambos. El lenguaje no detiene manipulación de un terminal.

Este paquete no incluye ni repite detalles biométricos de las capturas. Difumina identificadores antes de publicar el material y revisa sus metadatos.
