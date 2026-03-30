CREATE DATABASE IF NOT EXISTS biblioteca;
USE biblioteca;
CREATE TABLE autores (
id INT AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
nacionalidad VARCHAR(50),
fecha_nacimiento DATE
);
CREATE TABLE libros (
id INT AUTO_INCREMENT PRIMARY KEY,
titulo VARCHAR(200) NOT NULL,
autor_id INT,
genero VARCHAR(50),
anio_publicacion INT,
disponible BOOLEAN DEFAULT TRUE,
FOREIGN KEY (autor_id) REFERENCES autores(id)
);
CREATE TABLE prestamos (
id INT AUTO_INCREMENT PRIMARY KEY,
libro_id INT,
nombre_usuario VARCHAR(100),
fecha_prestamo DATE,
fecha_devolucion_prevista DATE,
fecha_devolucion_real DATE,
FOREIGN KEY (libro_id) REFERENCES libros(id)
);
INSERT INTO autores (nombre, nacionalidad, fecha_nacimiento) VALUES
('Gabriel García Márquez', 'Colombiana', '1927-03-06'),
('J.K. Rowling', 'Británica', '1965-07-31'),
('Jorge Luis Borges', 'Argentina', '1899-08-24'),
('Isabel Allende', 'Chilena', '1942-08-02'),
('Haruki Murakami', 'Japonesa', '1949-01-12');
INSERT INTO libros (titulo, autor_id, genero, anio_publicacion, disponible) VALUES
('Cien años de soledad', 1, 'Realismo mágico', 1967, TRUE),
('Harry Potter y la piedra filosofal', 2, 'Fantasía', 1997, TRUE),
('El Aleph', 3, 'Ficción', 1949, TRUE),
('La casa de los espíritus', 4, 'Realismo mágico', 1982, TRUE),
('Tokio blues (Norwegian Wood)', 5, 'Novela', 1987, TRUE),
('Crónica de una muerte anunciada', 1, 'Novela', 1981, TRUE),
('Harry Potter y la cámara secreta', 2, 'Fantasía', 1998, FALSE),
('Ficciones', 3, 'Ficción', 1944, TRUE),
('De amor y de sombra', 4, 'Drama', 1984, TRUE),
('Kafka en la orilla', 5, 'Novela', 2002, TRUE);

-- 1. Función fn_obtener_genero Recibe el ID de un libro y devuelve su género. Si el libro no existe, 
-- devuelve "Desconocido". 
delimiter $$
create function fn_obtener_genero(p_libro int)
returns VARCHAR(50)
begin
declare genero_libro VARCHAR(50);
select genero into genero_libro from libros
where id=p_libro;
if genero_libro is null then 
	return "Desconocido";
else
	return genero_libro;
end if;
end $$
delimiter ;
-- 2. Procedimiento sp_marcar_no_disponible Recibe el ID de un libro y 
-- lo marca como no disponible (disponible = FALSE). 
delimiter $$
create procedure sp_marcar_no_disponible (in p_libro int)
begin
update libros 
set disponible = false
where id=p_libro;
end $$
delimiter ;

-- 3. sp_insertar_autor
-- Recibe nombre, nacionalidad y fecha de nacimiento de un autor y lo inserta en la tabla autores.

delimiter $$
create PROCEDURE sp_insertar_autor(in p_nombre varchar(50), p_nacionalidad varchar(50), p_fecha_nacimiento DATE)
begin
insert into autores (nombre, nacionalidad, fecha_nacimiento)
values(p_nombre, p_nacionalidad,p_fecha_nacimiento);
end
delimiter $$

-- 4 fn_contar_libros_autor
-- Recibe el ID de un autor y devuelve la cantidad de libros asoci
delimiter $$
CREATE function fn_contar_libros_autor(p_id_autor int)
returns int
begin;
DECLARE cant_libros
SELECT count(*) INTO cant_libros FROM libros
WHERE autor_id=p_id_autor;
returns cant_libros;
end;
delimiter $$

-- 5 sp_actualizar_libro
-- Recibe ID y todos los datos de un libro, y actualiza sus datos si existe.
delimiter $$
CREATE procedure sp_actualizar_libro(in p_id_libro int, in p_titulo_libro varchar(100), in p_genero_libro varchar(50), in p_anio_publicacion_libro int, in p_disponible boolean, in p_autor_id int)
begin;
update libros set 
titulo=p_titulo_libro, 
autor_id=p_autor_id, 
genero=p_genero_libro, 
anio_publicacion=p_anio_publicacion, 
disponible=p_disponible 
WHERE id=p_id_libro;
end
delimiter $$

-- 6 sp_libros_disponibles_por_genero
-- Recibe un género y devuelve título, autor y año de publicación de todos los
-- libros disponibles de ese género.
delimiter $$
CREATE procedure sp_libros_disponibles_por_genero(in p_genero)
begin
select titulo, autor, anio_publicacion FROM libros
where genero = p_genero and disponible = true;
end
delimiter $$


-- 7 fn_calcular_multa
-- Recibe el ID de un préstamo y devuelve el importe de la multa:
-- ○ 0$ si no hay retraso
-- ○ 500$ por día (primeros 10 días)
-- ○ 1000$ por día (desde el día 11 en adelante)
delimiter $$
CREATE function fn_calcular_multa(p_id int)
returns decimal(10,2)
declare v_intereses int
declare v_fecha_retraso date
declare v_fecha_previa date
declare v_retraso int
begin
 select fecha_devolucion_real, fecha_devolucion_previa into v_fecha_retraso, v_fecha_previa from prestamos
 where id=p_id;
 set v_retraso= DATEDIFF(v_fecha_real, v_fecha_previa);
if (v_retraso >0) then
	if(v_retraso <=10) then
		set v_intereses= v_fecha_retraso * 500;
	else
		set v_intereses= (10*500) + (v_fecha_retraso -10) *1000);
    end if;
end if;

returns v_intereses;
end
delimiter $$