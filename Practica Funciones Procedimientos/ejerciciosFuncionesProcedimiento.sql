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


-- 8  sp_registrar_libro
-- Recibe título, nombre del autor, género y año. Si el autor existe, lo usa; si no,
-- lo crea.

delimiter $$
CREATE procedure sp_registrar_libro(in p_titulo varchar, in p_autor_nombre int , in p_genero varchar, in p_anio_publicacion int)
declare v_autor_id varchar
begin
	select id into v_autor_id from autores
    where nombre=p_autor_nombre
    limit 1;
	if(v_autor_id is null) then
		insert into autores (nombre,nacionalidad,fecha_nacimiento) values(p_autor_nombre)
        set v_autor_id= LAST_INSERT_ID()
    else
		insert into libros (titulo, autor, genero, anio_publicacion, disponible) values (,p_titulo, v_autor_id, p_genero, p_anio_publicacion, true)
    end if;
end;

delimiter $$


-- 9  fn_promedio_libros_por_autor
-- Devuelve la media de libros por autor.

delimiter $$

CREATE function fn_promedio_libros_por_autor()
	returns decimal(10,2)
begin
declare v_media_libro decimal(10,2)
select AVG(conteo_libros) into v_media_libro
from(
	select count(*) as conteo_libros
	from libros
	group by autor_id)
returns v_media_libros
end;

delimiter $$


-- 10  sp_categorizar_libros
-- Recibe un año y clasifica los libros según su publicación:
-- ○ Clásico (antes de 1900)
-- ○ Moderno (1900 hasta el año parámetro)
-- ○ Contemporáneo (después del año parámetro)

delimiter $$
CREATE PROCEDURE sp_categorizar_libros(IN p_anio_publicacion int)
begin

select anio_publicacion from libro

if(p_anio_publicacion < 1900) then
	return "Clasico";
if else (p_anio_publicacion >= 1900 and anio_publicacion <= p_anio_publicacion) then
	return "Moderno";
else
	return "Contemporaneo";
    
end if;
end if;
end;

delimiter $$

-- 11 sp_autores_por_nacionalidad
-- Recibe una nacionalidad y devuelve autores, sus libros y la cantidad de
-- préstamos por libro.

delimiter $$
create procedure sp_autores_por_nacionalidad(in p_nacionalidad, out p_autores, )


delimiter $$







    