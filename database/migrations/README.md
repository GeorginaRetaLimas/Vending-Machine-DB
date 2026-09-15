# 🔄 Migraciones — `database/migrations/`

Esta carpeta guarda el **historial de cambios de esquema** de la base SQLite, para que un cambio futuro
(agregar una columna, ajustar una restricción) no rompa datos ya existentes en el ESP32.

## Cómo funciona el versionado

- La versión actual del esquema se refleja en la tabla `configuracion`.
- En el arranque, el ESP32 compara la versión guardada contra la versión esperada por el firmware. Si son
  distintas, se aplica la migración correspondiente antes de operar con normalidad.
- El procedimiento es intencionalmente simple: **no** se sobrescribe ni se recrea la base; cada migración
  solo agrega los `ALTER TABLE` / ajustes necesarios para llegar de una versión a la siguiente.

  Cada migración debe tener dentro de sí la siguiente estructura:

  ```sql
  BEGIN TRY
      BEGIN TRANSACTION;

      ALTER TABLE usuarios ADD num_telf VARCHAR(15); -- Función de la migración

      UPDATE configuraciones SET version_esquema = 2; -- Número de versión correspondiente

      COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
      ROLLBACK TRANSACTION; -- Rollback en caso de error
  END CATCH;
  ```  

## Convención de nombres

Cada migración se guarda como un archivo `.sql` numerado según la versión de esquema a la que lleva:

```
migrations/
├── 001_esquema_inicial.sql
├── 002_agrega_columna_x.sql
└── ...
```

Cada archivo debe:

1. Empezar con un comentario indicando **de qué versión a qué versión** migra y **qué problema resuelve**.
2. Envolver los cambios en una transacción (`BEGIN` / `COMMIT`) cuando sea posible.
3. Actualizar `PRAGMA user_version` (o la fila correspondiente en `configuracion`) al final.
4. Ser **aditivo y seguro**: si algo falla a la mitad, la base debe quedar en un estado recuperable, nunca
   corrupta o vacía (regla de Arquitectura: ante una falla, nunca se borra ni se formatea automáticamente).

## Responsable

Angel define el mecanismo de versión de esquema y el procedimiento de migración (hitos D2–D3). Felipe
revisa cualquier migración que toque las tablas críticas de venta (`slots`, `transacciones`, `comandos`)
antes de aplicarla en la placa real.
