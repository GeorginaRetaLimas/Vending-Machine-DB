# 🗄️ Base de datos — `database/`

Esta carpeta contiene los **scripts SQL ejecutables** del proyecto: el esquema completo, los datos de
prueba y el historial de migraciones. Es la fuente de verdad del módulo de persistencia — si algo no
coincide con `docs/database/data-dictionary.pdf`, lo que manda es lo que está escrito aquí.

## Archivos y para qué sirve cada uno

| Archivo / carpeta | Propósito |
|---|---|
| [`schema.sql`](schema.sql) | Crea las 11 tablas, sus restricciones (`CHECK`, `UNIQUE`, llaves foráneas) y los índices de apoyo. Incluye la fila inicial de `configuraciones` (versión de esquema = 1). Se ejecuta **primero**, contra una base vacía. |
| [`seed.sql`](seed.sql) | Datos de prueba: 4 productos, los 4 slots con precio/capacidad/stock, un administrador demo y dos tarjetas RFID (una habilitada, una deshabilitada). Se ejecuta **después** de `schema.sql`, nunca antes. |
| [`migrations/`](migrations/README.md) | Historial de cambios de esquema versionados, para cuando `schema.sql` cambie después de la versión 1. |

## Orden de ejecución

```bash
sqlite3 said.db < schema.sql
sqlite3 said.db < seed.sql
```

`seed.sql` depende de que las tablas ya existan (usa `INSERT` e `UPDATE` sobre `productos`, `slots`,
`administradores`, `tarjetas_demo` y `configuraciones`), por eso el orden no es intercambiable.

## Qué valida `schema.sql`

- `PRAGMA foreign_keys = ON` activo desde el inicio.
- Dinero en centavos (enteros), nunca `REAL`.
- `CHECK (stock + reservado <= capacidad)` en `slots` y `CHECK (saldo_centavos - reserva_centavos >= 0)`
  en `tarjetas_demo`: impiden guardar un estado físicamente imposible.
- `request_id UNIQUE` en `reposiciones` y `movimientos_saldo`: garantiza idempotencia.
- `id_transaccion UNIQUE` en `comandos`: un solo `VEND` por transacción.
- Índices adicionales (`idx_transacciones_slot`, `idx_transacciones_tarjeta`, `idx_reposiciones_slot`,
  `idx_mov_stock_slot`, `idx_mov_saldo_tarjeta`) para las consultas por llave foránea más frecuentes
  (inventario, informes y bitácoras).

## Qué contiene `seed.sql`

| Tabla | Datos de prueba |
|---|---|
| `productos` | 4 productos (Coca-Cola, Takis Fuego, Agua natural, Chocolate Hershey) con costo de referencia. |
| `slots` | Los 4 canales, cada uno con su producto asignado, precio de venta y stock inicial. |
| `administradores` | Un usuario demo (`admin_demo`) con contraseña y PIN ya cifrados con hash + sal — **nunca en texto plano**. |
| `tarjetas_demo` | Una tarjeta habilitada con saldo (`RFID-0001`, $50.00) y una deshabilitada sin saldo (`RFID-0002`), para probar el caso de tarjeta inactiva. |
| `configuraciones` | Actualiza `estado_inicializacion` a `'CARGADA'` para que el ESP32 sepa, al arrancar, que los datos semilla ya se cargaron. |

> ⚠️ Los hashes y la sal de `admin_demo` son datos de **demostración**, documentados a propósito en un
> comentario del script para fines del curso. En un entorno real esas credenciales nunca se versionarían
> en texto plano ni serían públicas.

## Antes de modificar estos archivos

1. Probar el cambio primero en [DB Browser for SQLite](https://sqlitebrowser.org/) sobre una copia local.
2. Si el cambio altera una tabla o restricción ya usada por Programación ESP32 o Web, avisar a Arquitectura
   **antes** de fusionarlo (regla del proyecto).
3. Si el cambio afecta la estructura de una tabla existente (no solo datos semilla), agregar el script
   correspondiente en [`migrations/`](migrations/README.md) en lugar de editar `schema.sql` directamente
   sobre una base que ya tiene datos.
4. Actualizar `docs/database/data-dictionary.pdf` / `.docx` para que la documentación no quede desfasada.