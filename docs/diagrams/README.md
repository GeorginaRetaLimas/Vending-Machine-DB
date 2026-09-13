# 📊 Diagramas — `docs/diagrams/`

Esta carpeta contiene el **diagrama entidad-relación (ER)** de las 11 tablas del esquema
(`administradores`, `productos`, `slots`, `tarjetas_demo`, `transacciones`, `comandos`, `reposiciones`,
`movimientos_stock`, `movimientos_saldo`, `eventos`, `configuracion`).

El diagrama se elaboró en [lucidchart](https://lucid.co/es/lucidchart) pero se puede editar en un futuro en [dbdiagram.io](https://dbdiagram.io) o [draw.io](https://app.diagrams.net).

## Archivos y para qué sirve cada uno

| Archivo | Formato | Uso |
|---|---|---|
| `er-diagram.svg` | Vectorial, embebible | Se muestra directamente en el `README.md` de GitHub (renderiza sin descargar nada). |
| `er-diagram.pdf` | Documento | Versión para **imprimir o entregar** al docente / a Arquitectura. |
| `er-diagram.png` | Imagen | Vista rápida o respaldo cuando no se puede abrir un SVG (por ejemplo, en Word o PowerPoint). |
| `er-diagram.json` | Datos | Respaldo exportado de la herramienta usada (dbdiagram.io), por si hay que reconstruir el diagrama en otra cuenta o computadora. |
| `er-diagram.vsdx` | Editable | Versión para **modificar** el diagrama en Visio o draw.io sin perder el formato original. |

## Cómo actualizar el diagrama

1. Editar la fuente en dbdiagram.io / draw.io.
2. Exportar de nuevo **los cinco formatos** y reemplazar los archivos de esta carpeta (mismo nombre, para
   que el enlace del README raíz no se rompa).
3. Avisar al equipo en el canal compartido si el cambio afecta una llave foránea o una tabla que ya usa
   Programación ESP32 o Aplicación Web.
