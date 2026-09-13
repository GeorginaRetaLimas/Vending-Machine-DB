# 📖 Diccionario de datos — `docs/dictionary/`

Documentación del esquema SQLite que ejecuta el ESP32. Corresponde al primer entregable del subgrupo de
Base de Datos (hito D2–D3: crear, consultar, reiniciar y conservar registros) y es la referencia oficial
para Programación ESP32, Arquitectura y QA.

| Dato | Valor |
|---|---|
| **Versión de esquema** | 1 |
| **Motor** | SQLite |
| **Script correspondiente** | [`../../database/schema.sql`](../../database/schema.sql) — validado contra un motor SQLite real antes de esta entrega |

## Archivos de esta carpeta

| Archivo | Formato | Uso |
|---|---|---|
| `data-dictionary.pdf` | Documento final | Diccionario completo entregado: alcance, convenciones, diagrama ER, las 11 tablas documentadas, relaciones e historial de correcciones. Es la versión para entregar al docente y para consulta de otros equipos. |
| `data-dictionary.docx` | Editable | Fuente editable del documento anterior; aquí se actualiza el texto cuando cambia una tabla, y luego se re-exporta a PDF. |

## Convenciones generales del esquema

- El dinero se guarda **siempre** como entero en centavos (columnas `*_centavos`); nunca como decimal.
- Las cantidades (`stock`, `capacidad`, `reservado`) son enteras.
- SQLite no tiene tipo booleano nativo: los valores sí/no son `INTEGER` restringidos con `CHECK (... IN (0,1))`.
- Ningún registro con historial se borra físicamente: se desactiva con una bandera (`activo`, `habilitado`, `habilitada`).
- Toda operación que debe poder repetirse sin duplicar su efecto (reposición, recarga) tiene una columna
  `request_id` con `UNIQUE` — así es idempotente.
- No existen fechas de calendario reales: el orden de los eventos se resuelve con contadores de secuencia
  y tiempo transcurrido desde el arranque.
- Las llaves foráneas están activas (`PRAGMA foreign_keys = ON`) y se comprueban en cada operación.

## Las 11 tablas

| Tabla | Tipo | Para qué sirve |
|---|---|---|
| `administradores` | Catálogo/entidad | Identidad y trazabilidad de quien hace mantenimiento, reposición o recargas. |
| `productos` | Catálogo/entidad | Catálogo de productos, independiente del canal físico donde estén colocados. |
| `slots` | Ciclo de venta | Los 4 canales físicos: producto asignado, precio, capacidad, stock y reservado. |
| `tarjetas_demo` | Catálogo/entidad | Tarjetas RFID simuladas usadas como método de pago. |
| `transacciones` | Ciclo de venta | Ciclo de vida de cada compra, de `RESERVADA` a `CONFIRMADA` o `INCIERTA`. |
| `comandos` | Ciclo de venta | La orden física `VEND` enviada al motor del canal y su resultado. |
| `reposiciones` | Ciclo de venta | Cada reabastecimiento de un canal, de `PENDIENTE` a `CERRADA`. |
| `movimientos_stock` | Bitácora | Auditoría de cada cambio de stock (venta, reposición, ajuste). |
| `movimientos_saldo` | Bitácora | Auditoría de cada cambio de saldo de una tarjeta (compra, recarga). |
| `eventos` | Configuración/diagnóstico | Bitácora general de errores y advertencias del sistema. |
| `configuraciones` | Configuración/diagnóstico | Estado global consultado por el ESP32 al arrancar (versión de esquema, secuencia global, etc.). |

## Relaciones

Todas las relaciones son **1:N**, excepto `transacciones` → `comandos`, que se comporta como **1:1** forzada
con `UNIQUE (id_transaccion)` (regla de negocio: un solo `VEND` por transacción).

Tres columnas son **referencias libres** (texto, no llave foránea formal), pensadas solo para
lectura/diagnóstico porque pueden apuntar a distintas tablas según el caso:
`movimientos_stock.referencia_operacion`, `movimientos_saldo.referencia_opcional` y
`eventos.operacion_relacionada`.

Detalle de cardinalidad y obligatoriedad de cada relación (padre → hijo) en la sección 5 de
`data-dictionary.pdf`.

## Historial de correcciones sobre el diagrama original

- `movimientos_saldo`: la columna se llamaba `id_tarea` por error de captura; se corrigió a `id_tarjeta`
  como llave foránea hacia `tarjetas_demo`.
- `movimientos_stock.operador` y `movimientos_saldo.operador`: se formalizaron como llave foránea hacia
  `administradores.id_admin` (antes eran una columna suelta sin restricción declarada).
- La tabla "comandas" del diagrama original se documentó como `comandos`, por consistencia con el nombre
  usado en el encargo oficial del proyecto.

## Control de versiones del documento

| Versión | Fecha / hito | Cambios |
|---|---|---|
| 1 | Hito D2–D3 | Primera versión del esquema, validada contra un motor SQLite real (`schema.sql` adjunto). |
