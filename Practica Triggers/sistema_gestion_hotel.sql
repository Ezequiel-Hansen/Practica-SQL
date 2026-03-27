CREATE DATABASE IF NOT EXISTS`sistema_de_reservas_de_hotel`;
USE `sistema_de_reservas_de_hotel`;

CREATE TABLE IF NOT EXISTS Clientes(
	id INT PRIMARY KEY NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(200) UNIQUE NOT NULL CHECK (email LIKE '%@%')
);

CREATE TABLE IF NOT EXISTS Habitaciones(
	id INT PRIMARY KEY UNIQUE,
    tipo_de_habitacion TEXT NOT NULL,
    precio_por_noche DECIMAL(10,2) CHECK (precio_por_noche >0),
    estado TEXT DEFAULT 'DISPONIBLE'
);

CREATE TABLE IF NOT EXISTS Reservas(
	id INT PRIMARY KEY UNIQUE,
    id_habitacion INT NOT NULL,
    id_cliente INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    FOREIGN KEY(`id_habitacion`) REFERENCES Habitaciones(`id`) ON DELETE CASCADE,
    FOREIGN KEY(`id_cliente`) REFERENCES Clientes(`id`) ON DELETE CASCADE
);

DELIMITER //

CREATE TRIGGER validar_disponibilidad
BEFORE INSERT ON Reservas
FOR EACH ROW
BEGIN

	DECLARE cant_reservas INT;
    
    
    SELECT COUNT(*) INTO cant_reservas
    FROM Reservas
    WHERE id_habitaciones=NEW.id_habitaciones AND ((NEW.check_in < check_out) AND (NEW.check_out > check_in));
    
    IF cant_reservas > 0 THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Esta habitacion esta reservada para la fecha elegida';
    END IF;

END;

DELIMITER;

