# Base de Datos e Interfaz — Máquina Expendedora SAID

[![SQLite](https://img.shields.io/badge/SQLite-8faa8b?style=for-the-badge&logo=sqlite&logoColor=white)](#)
[![SQL](https://img.shields.io/badge/SQL-DDL%2FDML-4479A1?logo=postgresql&logoColor=white)](#)
[![ESP32](https://img.shields.io/badge/ESP32-Integraci%C3%B3n-3E8E41?logo=espressif&logoColor=white)](#)
[![C++](https://img.shields.io/badge/C%2B%2B-Funciones%20de%20acceso-00599C?logo=cplusplus&logoColor=white)](#)
[![SQLite](https://img.shields.io/badge/SQLite-8faa8b?style=for-the-badge&logo=sqlite&logoColor=white)](#)

<h3 align="center">ITIID 7-1 · Septiembre 2026</h3>
<p align="center"><i>Docente: Dr. Said Polanco Martagón</i></p>

---

## Resumen

Este repositorio contiene el **módulo de persistencia** (esquema, restricciones, consultas, transacciones,
migración, respaldo y funciones de acceso) que ejecutará el ESP32 de la máquina expendedora SAID.

## Funciones principales del módulo

- **Esquema relacional (11 tablas):** administradores, productos, slots, tarjetas_demo, transacciones,
  comandos, reposiciones, movimientos_stock, movimientos_saldo, eventos y configuración.
- **Transacciones idempotentes:** toda operación de venta, entrega, recarga o reposición usa `request_id`
  para garantizar una sola aplicación, incluso si la petición llega repetida.
- **Consultas de inventario, tarjetas e informes:** funciones paginadas que alimentan tanto al ESP32 como
  a las rutas HTTP que consumirá el equipo de Aplicación Web.
- **Respaldo y restauración:** exportación consistente vía `VACUUM INTO` / API de backup de SQLite, con
  verificación de integridad antes de reactivar la venta.
- **Fecha sin Internet:** orden de eventos mediante contador de arranque + secuencia, sin depender de un
  reloj de calendario.

## Equipo y reparto de carga

| Integrante | Equipo(s) | Rol en Base de Datos | Carga relativa |
|---|---|---|---|
| **Felipe Gamaliel Malibran González** | Base de Datos | Diseño del esquema completo y transacciones críticas de venta (`autorizarCompra`, `registrarEntrega`) | Alta (reducida ligeramente) |
| **Georgina Reta Limas** | Base de Datos + Web | Consultas de inventario/informes y reposición atómica | Media-alta |
| **Angel Gabriel Coronado Sánchez** | Base de Datos + Web | Consultas de tarjetas, respaldo y restauración | Media-alta |
| **Jared de Jesús Olazarán López** ⁺ | ESP32 (préstamo a Base de Datos) | Recarga de tarjeta y persistencia de mantenimiento | Baja (acotada y alineada a su trabajo en ESP32) |

> ⁺ Jared pertenece de forma titular al equipo de **Programación ESP32** (RFID, autenticación
> administrativa, PIN, recargas y flujo de mantenimiento). Se suma como apoyo puntual a Base de Datos
> solo para dos funciones (`recargarTarjeta`, `iniciarMantenimiento`/`cerrarMantenimiento`) que de todas
> formas necesita para su propio trabajo, de modo que su carga extra es mínima.

## Estructura del repositorio

El repositorio separa **diagramas y documentación** (`docs/`) del **código SQL ejecutable** (`database/`),
para que cada entregable tenga un lugar fijo y las carpetas se puedan revisar de forma independiente.

| Ruta | Propósito |
|---|---|
| [`docs/diagrams/`](docs/diagrams/README.md) | Diagrama entidad-relación de las 11 tablas, en los formatos necesarios para el README, la entrega impresa y la edición. |
| [`docs/dictionary/`](docs/dictionary/README.md) | Diccionario de datos: explicación de cada tabla, columna, tipo y restricción. |
| [`database/`](database/README.md) | Scripts SQL vivos del proyecto: esquema (`schema.sql`) y datos semilla (`seeds.sql`). |
| [`database/migrations/`](database/migrations/README.md) | Historial de cambios de esquema, versionado con `PRAGMA user_version`. |

```
mi-proyecto/
├── docs/
│   ├── diagrams/
│   │   ├── er-diagram.svg
│   │   ├── er-diagram.pdf
│   │   ├── er-diagram.png
│   │   ├── er-diagram.json
│   │   ├── er-diagram.vsdx
│   │   └── README.md
│   └── dictionary /
│       ├── data-dictionary.pdf
│       ├── data-dictionary.docx
│       └── README.md
├── database/
│   ├── schema.sql
│   ├── seeds.sql
│   └── migrations/
│       └── README.md
└── README.md
```

## Cronograma (hitos D1–D14)

| Hito | Fase | Entrega exigida |
|---|---|---|
| D1–D3 | Esquema, datos semilla, migración y prueba en placa | Crear, consultar, reiniciar y conservar registros junto con ESP32 |
| D3–D5 | Consultas de inventario, tarjetas e informes paginados | Funciones y formatos de respuesta (JSON) |
| D5–D7 | Autorización, reservas, cierre de venta y reposición atómica | Transacciones idempotentes con `request_id` |
| D7–D10 | Respaldo, restauración y reglas de fecha sin Internet | Procedimientos y consultas verificadas |
| D9–D12 | Evidencia de verificación para QA (Q08–Q24) | `verificacion.sql` con consultas antes/después |
| D13–D14 | Manual final y corrección de fallas críticas | Documentación + demo final |

## Reglas del proyecto (definidas por Arquitectura)

- Los importes se guardan **siempre** como enteros en centavos; capacidad, stock y reservado como enteros.
- Nunca se borra un producto o tarjeta con historial: **se deshabilita**.
- Todas las consultas usan **parámetros enlazados** (nunca se concatena texto para armar SQL).
- Ninguna ruta HTTP ni el UART abren SQLite directamente: **solo el ESP32**, desde su tarea de datos.
- Si una función compartida cambia, se avisa a Arquitectura y a Programación ESP32 **antes** de modificarla.
- Ante cualquier falla de la base (ilegible, sin espacio, error de escritura), **nunca** se borra ni se
  formatea automáticamente.

## Primeros pasos

1. Aún no definidos...
