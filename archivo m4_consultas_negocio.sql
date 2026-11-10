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