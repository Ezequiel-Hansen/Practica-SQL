CREATE DATABASE IF NOT EXISTS`gestion_de_biblioteca`;
USE `gestion_de_biblioteca`;

CREATE TABLE IF NOT EXISTS Clientes(
	id INT PRIMARY KEY NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    telefono TEXT UNIQUE NOT NULL CHECK (LENGTH(telefono)=10),
    email VARCHAR(200) UNIQUE NOT NULL CHECK (email LIKE '%@%')
);

CREATE TABLE IF NOT EXISTS Libros(
	id INT PRIMARY KEY UNIQUE,
    titulo VARCHAR(50) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    stock INT CHECK (stock >=0),
    precio DECIMAL(10,2) NOT NULL CHECK(precio >0)
);

CREATE TABLE IF NOT EXISTS Prestamos(
	id_prestamo INT NOT NULL PRIMARY KEY,
    id_libro INT NOT NULL,
    id_cliente INT NOT NULL,
    fecha DATE NOT NULL,
    FOREIGN KEY (`id_libro`) REFERENCES Libros(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`id_cliente`) REFERENCES Clientes(`id`) ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER validar_stock
BEFORE INSERT ON Prestamos
FOR EACH ROW
BEGIN
	DECLARE stock_actual INT;
    
    SELECT stock INTO stock_actual
    FROM Libros
    WHERE id= NEW.Libros.id;
    
    IF stock_actual <= 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='No hay stock para hacer un prestamos';
    END IF;

END;

DELIMITER;




