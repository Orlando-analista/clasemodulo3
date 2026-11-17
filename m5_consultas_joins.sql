CREATE DATABASE Ventas_Tech_DB;

USE Ventas_Tech_DB;

-- === SECCIÓN 1: DROP ===

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;

-- === SECCIÓN 2: CREATE ===

CREATE TABLE Categorias (
id_categoria INT PRIMARY KEY,
nombre_categoria VARCHAR (50) NOT NULL,
descripcion VARCHAR (200)
)

CREATE TABLE Clientes (
id_cliente INT PRIMARY KEY,
nombre VARCHAR (100) NOT NULL,
email VARCHAR (100) UNIQUE,
ciudad VARCHAR (50),
fecha_registro DATE NOT NULL
)

CREATE TABLE Productos (
id_producto INT PRIMARY KEY,
nombre_producto VARCHAR (100) NOT NULL,
id_categoria INT,
precio DECIMAL (10,2) NOT NULL,
stock INT DEFAULT 0,
activo BIT DEFAULT 1,
FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
)

CREATE TABLE ventas (
id_venta INT PRIMARY KEY,
id_cliente INT,
id_producto INT,
cantidad INT NOT NULL,
precio_unitario DECIMAL (10,2) NOT NULL,
fecha_venta DATE NOT NULL,
FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
)

-- === SECCIÓN 3: INSERT ===

INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) 
VALUES
(1, 'Computación',    'Laptops, PCs y monitores'),
(2, 'Accesorios',     'Periféricos y complementos'),
(3, 'Audio',          'Auriculares y parlantes'),
(4, 'Almacenamiento', 'Discos y memorias');

INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) 
VALUES
(1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
(2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
(3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
(4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
(5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) 
VALUES
(1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
(2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
(3, 'Monitor 4K 27',      1,  450.00, 12, 1),
(4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
(5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
(6, 'Teclado Mecánico',   2,   95.00, 40, 1);

INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) 
VALUES
( 1, 1, 1, 2, 1200.00, '2024-03-05'),
( 2, 2, 2, 5,   28.00, '2024-03-06'),
( 3, 3, 3, 1,  450.00, '2024-03-07'),
( 4, 1, 4, 2,  120.00, '2024-03-08'),
( 5, 4, 5, 3,  130.00, '2024-03-10'),
( 6, 2, 6, 4,   95.00, '2024-03-11'),
( 7, 5, 1, 1, 1200.00, '2024-03-12'),
( 8, 3, 2, 8,   28.00, '2024-03-13'),
( 9, 4, 4, 1,  120.00, '2024-03-14'),
(10, 5, 3, 2,  450.00, '2024-03-15');

-- === SECCIÓN 4: VALIDACION ===

SELECT * FROM categorias;   -- esperado: 4 filas
SELECT * FROM clientes;     -- esperado: 5 filas
SELECT * FROM productos;    -- esperado: 6 filas
SELECT * FROM ventas;       -- esperado: 10 filas


SELECT 
MONTH(fecha_venta) AS Mes,
SUM(cantidad * precio_unitario) AS Total_Ventas
FROM ventas
GROUP BY MONTH(fecha_venta);

SELECT TOP 5 
id_producto,
SUM(cantidad) AS Unidades_Vendidas,
SUM(cantidad * precio_unitario) AS Total_Generado
FROM ventas
GROUP BY id_producto
ORDER BY Total_Generado DESC;

SELECT 
id_cliente,
COUNT(*) AS Cantidad_Pedidos,
SUM(cantidad * precio_unitario) AS Total_Gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1;

WITH FacturacionPorProducto AS (
SELECT 
id_producto,
SUM(cantidad * precio_unitario) AS Total_Facturado
FROM ventas
GROUP BY id_producto
)
SELECT 
id_producto,
Total_Facturado,
CASE 
WHEN Total_Facturado > (SELECT AVG(Total_Facturado) FROM FacturacionPorProducto) THEN 'Por encima'
ELSE 'Por debajo'
END AS Categoria_Promedio
FROM FacturacionPorProducto;

-- BLOQUE DE CIERRE: HALLAZGOS Y CONCLUSIONES DEL ANÁLISIS
-- =========================================================================
-- 1. Hallazgo de Producto: El producto 1 ("Laptop Pro 15") concentra más del 
--    55% de la facturación total del mes (3600 de un total de 6444), a pesar 
--    de haberse vendido solo 3 unidades en total.
-- 2. Hallazgo de Clientes: El 100% de los clientes registrados son recurrentes, 
--    ya que cada uno de los 5 clientes realizó exactamente 2 pedidos durante 
--    el período de marzo de 2024.
-- 3. Hallazgo de Facturación por Cliente: La cliente María López (id_cliente = 1) 
--    lidera la facturación individual gracias a la compra de productos de 
--    mayor valor como la Laptop Pro 15.




-- Consulta 1 — Vista base del proyecto (INNER JOIN)
-- Propósito: Combinar las tablas transaccionales y dimensionales para consolidar 
-- en una sola vista la fecha, cliente, producto, categoría, ciudad, cantidad y total de venta.
SELECT 
ventas.fecha_venta,
clientes.id_cliente,
clientes.nombre AS cliente,
clientes.ciudad,
productos.nombre_producto,
categorias.nombre_categoria AS categoria,
ventas.cantidad,
ventas.precio_unitario,
(ventas.cantidad * ventas.precio_unitario) AS total_venta
FROM ventas
INNER JOIN clientes ON ventas.id_cliente = clientes.id_cliente
INNER JOIN productos ON ventas.id_producto = productos.id_producto
INNER JOIN categorias ON productos.id_categoria = categorias.id_categoria;

-- Hallazgo: La vista integrada permite cruzar la facturación por ciudad y categoría, 
-- evidenciando que la categoría 'Computación' genera el mayor impacto en ingresos a pesar de registrar menor cantidad de unidades vendidas frente a los accesorios.


-- Consulta 2 — Clientes sin ventas (LEFT JOIN)
-- Propósito: Detectar clientes registrados que nunca han comprado nada para que el área de CRM diseñe campañas de activación.
SELECT 
clientes.nombre,
clientes.email,
clientes.fecha_registro
FROM clientes
LEFT JOIN ventas ON clientes.id_cliente = ventas.id_cliente
WHERE ventas.id_cliente IS NULL;

-- Hallazgo: 0 de los 5 clientes registrados figuran sin compras; el 100% de la base de clientes 
-- posee al menos un pedido registrado, lo que indica que no hay clientes inactivos por el momento y la conversión inicial es total.


-- Consulta 3 — Productos sin ventas (LEFT JOIN)
-- Propósito: Identificar artículos del catálogo que no tienen ninguna venta registrada para que el departamento de inventario tome decisiones.
SELECT 
productos.nombre_producto,
categorias.nombre_categoria AS categoria,
productos.precio
FROM productos
INNER JOIN categorias ON productos.id_categoria = categorias.id_categoria
LEFT JOIN ventas ON productos.id_producto = ventas.id_producto
WHERE ventas.id_producto IS NULL;

-- Hallazgo: 0 productos del catálogo se encuentran sin ventas; los 6 artículos registrados 
-- han tenido al menos una salida comercial, demostrando que el inventario inicial está completamente activo y alineado con las compras de los clientes.


-- Consulta 4 — Consolidado por canal (UNION ALL)
-- Propósito: Comparar el volumen total de ventas dividiendo las transacciones en dos canales simulados ('Online' y 'Presencial') mediante subconsultas y UNION ALL.
SELECT 
canal, 
SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, (cantidad * precio_unitario) AS total, 'Online' AS canal
    FROM ventas 
    WHERE id_venta <= 5
    
    UNION ALL
    
    SELECT fecha_venta, (cantidad * precio_unitario) AS total, 'Presencial' AS canal
    FROM ventas 
    WHERE id_venta > 5
) AS consolidado
GROUP BY canal;

-- Hallazgo: Al segmentar las primeras 5 ventas como canal 'Online' y las siguientes 5 como 'Presencial', 
-- se observa que ambos bloques generan ingresos comparables, permitiendo evaluar de forma equilibrada el desempeño de los dos canales comerciales.