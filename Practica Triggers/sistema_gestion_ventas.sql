CREATE DATABASE IF NOT EXISTS sistema_de_gestion_de_ventas;
Use `sistema_de_gestion_de_ventas`;

CREATE TABLE IF NOT EXISTS clientes(
	id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(250) UNIQUE not null
);


CREATE TABLE IF NOT EXISTS productos(
	id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) CHECK (precio >= 0) NOT NULL,
    stock INT DEFAULT 5
);

CREATE TABLE IF NOT EXISTS pedidos(
	id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad>0),
    fecha DATE NOT NULL,
    FOREIGN KEY(`cliente_id`) REFERENCES `clientes`(`id`) ON DELETE CASCADE,
    FOREIGN KEY(`producto_id`) REFERENCES `productos`(`id`)
    
);

DELIMITER //
CREATE TRIGGER validar_stock_pedido
BEFORE INSERT ON pedidos
FOR EACH ROW
BEGIN
	DECLARE stock_actual INT;
    
    SELECT stock INTO stock_actual
    FROM productos
    WHERE id= NEW.producto.id;
    
    IF NEW.cantidad > stock_actual THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No hay suficiente stock';
    
    END IF;
    
END //

DELIMITER ;