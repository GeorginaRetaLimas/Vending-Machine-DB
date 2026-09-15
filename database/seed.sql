-- *********************************************************************
-- Máquina expendedora basada en diagramas de estado
-- Datos semilla
-- Este script se ejecuta DESPUÉS de schema.sql
-- *********************************************************************

PRAGMA foreign_keys = ON;

-- productos: uno por cada canal físico (4 canales -> 4 productos)
INSERT INTO productos (id_producto, codigo_unico, nombre, costo_referencia_centavos, activo) VALUES
    (1, 'COCA-355', 'Lata Coca-Cola de 355 ml',  1200, 1), -- Costo: $12.00
    (2, 'TAKF-BOL', 'Bolsa Takis Fuego 94g',     1000, 1), -- Costo: $10.00
    (3, 'AGUA-600', 'Agua natural 600ml',         400, 1), -- Costo: $4.00
    (4, 'CHO-HERS', 'Barra Chocolate Hershey 40g', 1100, 1); -- Costo: $11.00

-- slots: los 4 canales físicos, cada uno con su producto, precio y capacidad. 
INSERT INTO slots (id_slot, id_producto, precio_centavos, capacidad, stock, reservado, habilitado, version) VALUES
    (1, 1, 2000, 10, 8, 0, 1, 0),  -- Coca Lata -> Precio: $20.00
    (2, 2, 1800, 10, 8, 0, 1, 0),  -- Takis Fuego -> Precio: $18.00
    (3, 3, 1000, 12, 10, 0, 1, 0), -- Agua natural -> Precio: $10.00
    (4, 4, 2200, 10, 6, 0, 1, 0);  -- Chocolate Hershey -> Precio: $22.00

-- administradores
-- Usuario: admin_demo
-- PIN: 482913
-- Contraseña: DemoSAID_2026!
-- Ambos hashes fueron calculados con sha256(valor + sal)
-- ---------------------------------------------------------------------
INSERT INTO administradores (id_admin, nombre_acceso, hash_contrasena, hash_pin, sal, activo) VALUES
    (1, 'admin_demo',
     'c844d92600904c7d26c10ae386f624e7f9f96627699bf50129c6b8e0e1da454b',
     '2a2ce2fa95274335fa3f2780a8a421557871700df02b56cc307aeedcbee2a576',
     '21bfb579411eb04f',
     1);

-- tarjetas_demo
INSERT INTO tarjetas_demo (id_tarjeta, uid, saldo_centavos, reserva_centavos, habilitada) VALUES
    (1, 'RFID-0001', 5000, 0, 1),  -- Tarjeta activa con $50.00 de saldo
    (2, 'RFID-0002',    0, 0, 0);  -- Tarjeta deshabilitada

-- caja_efectivo: cantidad inicial de piezas disponibles para dar cambio.
-- Más piezas de baja denominación, ya que son las que más se usan al dar cambio.
INSERT INTO caja_efectivo (id_denominacion, cantidad, version)
SELECT id_denominacion, 30, 0 FROM denominaciones
    WHERE tipo = 'moneda';                                   -- $1, $2, $5, $10, $20 (moneda): 30 piezas c/u

INSERT INTO caja_efectivo (id_denominacion, cantidad, version)
SELECT id_denominacion, 15, 0 FROM denominaciones
    WHERE valor_centavos = 2000 AND tipo = 'billete';         -- $20 (billete): 15 piezas

INSERT INTO caja_efectivo (id_denominacion, cantidad, version)
SELECT id_denominacion, 10, 0 FROM denominaciones
    WHERE valor_centavos IN (5000, 10000) AND tipo = 'billete'; -- $50, $100: 10 piezas c/u

INSERT INTO caja_efectivo (id_denominacion, cantidad, version)
SELECT id_denominacion, 5, 0 FROM denominaciones
    WHERE valor_centavos IN (20000, 50000, 100000) AND tipo = 'billete'; -- $200, $500, $1000: 5 piezas c/u

-- configuracion: la fila id=1 ya existe (se crea en schema.sql).
-- Aquí solo se actualiza para reflejar que los datos semilla ya se
-- cargaron, dato que el ESP32 puede consultar al arrancar.
UPDATE configuraciones SET estado_inicializacion = 'CARGADA' WHERE id_configuracion = 1;