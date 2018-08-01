-- phpMyAdmin SQL Dump
-- version 4.2.11
-- http://www.phpmyadmin.net
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 22-02-2015 a las 19:15:36
-- Versión del servidor: 5.6.21
-- Versión de PHP: 5.6.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `asistencia`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Asignar_Horario`(in codigo int,
in dni varchar(8),
in domingo bit(1),
in lunes bit(1),
in martes bit(1),
in miercoles bit(1),
in jueves bit(1),
in viernes bit(1),
in sabado bit(1)
)
begin
	SET FOREIGN_KEY_CHECKS=0;
    IF exists (select horario_cod_horario,personal_dni from asignacion where horario_cod_horario = codigo and personal_dni = dni)  then
		update asignacion set 
        -- horario_cod_horario = codigo,
        -- personal_dni = dni,
        Sunday = domingo,
        Monday = lunes,
        Tuesday = martes,
        Wednesday = miercoles,
        Thursday = jueves,
        Friday = viernes,
        Saturday = sabado
        where horario_cod_horario = codigo and personal_dni = dni;
    ELSE
        insert into asignacion(horario_cod_horario,personal_dni,Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday) values(codigo,dni,domingo,lunes,martes,miercoles,jueves,viernes,sabado);
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_cantidad_registros`(
	dni varchar(8)
)
BEGIN
	SET @num = (select count(*) as num from registro where personal_dni = dni and date(hora_llegada) = date(now()) and estado = 0);
    IF (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni) is not null then
		IF @num < 2 then
			select 1 as num;
		else
			select 0 as num;
		end if;
	else
		if @num < 1 then
			select 1 as num;
		else
			select 0 as num;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_cantidad_registros_2`(
	dni varchar(8),
    fecha date
)
BEGIN
	SET @num = (select count(*) as num from registro where personal_dni = dni and date(hora_llegada) = date(fecha));
    if fecha <= date(now()) then
		IF (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni) is not null then
			IF @num < 2 then
				select 1 as num;
			else
				select 0 as num;
			end if;
		else
			if @num < 1 then
				select 1 as num;
			else
				select 0 as num;
			END IF;
		END IF;
	else
		select 0 as num;
	end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Empleados_Presentes`()
BEGIN
	SELECT p.dni, concat_ws(', ', p.apellido , p.nombre) as nombre, a.nombre as area, p.cargo,TIME(r.hora_llegada) as hora_llegada,p.foto, p.tipo,if(DATE(p.fecha_nacimiento) = DATE(NOW()),1,0) AS cumple
    from registro r
    inner join personal p 
    on r.personal_dni = p.dni
    inner join area a
    on p.area_cod_area = a.cod_area
    where DATE(hora_llegada) = DATE(NOW()) AND estado = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_IngresarDNI`(IN dni varchar(8))
BEGIN
	DECLARE codigo int;
    IF exists (select cod_registro from registro where DATE(hora_llegada) = DATE(NOW()) and personal_dni = dni AND estado = 1) THEN
       set  codigo = (select cod_registro from registro where DATE(hora_llegada) = DATE(NOW()) and personal_dni = dni AND estado = 1);
       update registro set hora_salida = now(),estado = 0 where cod_registro = codigo ;
       
	ELSE
        INSERT INTO registro(hora_llegada,estado,personal_dni) VALUES(NOW(),1,dni);		
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ingresar_Empleado`(in dnii varchar(8),
in nombre varchar(35),
in apellido varchar(35),
in fecha_nacimiento date,
in sexo bit(1),
in cod_area varchar(6),
in cargo varchar(15),
in password varchar(15),
in tipo varchar(15),
in foto mediumblob,
in cod_horario int,
in sunday bit(1),
in monday bit(1),
in tuesday bit(1),
in wednesday bit(1),
in thursday bit(1),
in friday bit(1),
in saturday bit(1)
)
begin
	
	IF exists (select dni from personal where dni= dnii) then
		if tipo = '' then
			update personal 
			set 
				nombre = nombre,
				apellido = apellido,
				fecha_nacimiento = fecha_nacimiento,
				sexo = sexo,
				area_cod_area = cod_area,
				cargo = cargo,
				password = password
				where dni = dnii;
			update asignacion
			set
				horario_cod_horario = cod_horario,
				Sunday = sunday,
				Monday = monday,
				Tuesday =  tuesday,
				Wednesday =  wednesday,
				Thursday = thursday,
				Friday = friday,
				Saturday = saturday
			where personal_dni = dnii;
		else
			update personal 
			set 
				nombre = nombre,
				apellido = apellido,
				fecha_nacimiento = fecha_nacimiento,
				sexo = sexo,
				area_cod_area = cod_area,
				cargo = cargo,
				password = password,
				tipo = tipo,
				foto = foto where dni = dnii;
			update asignacion
			set
				horario_cod_horario = cod_horario,
				Sunday = sunday,
				Monday = monday,
				Tuesday =  tuesday,
				Wednesday =  wednesday,
				Thursday = thursday,
				Friday = friday,
				Saturday = saturday
			where personal_dni = dnii;
        end if;
    ELSE
        insert into personal(dni,nombre,apellido,fecha_nacimiento,sexo,area_cod_area,cargo,password,tipo,foto) values(dnii,nombre,apellido,fecha_nacimiento,sexo,cod_area,cargo,password,tipo,foto);
	END IF;
    call SP_Asignar_Horario(cod_horario,dnii,sunday,monday,tuesday,wednesday,thursday,friday,saturday);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ingresar_Horario`(in codigo int,
in llegada time,
in suspender time,
in regreso time,
in salida time)
begin
	IF codigo > 0 then
		update horario set hora_llegada = llegada, suspende = suspender,regresar = regreso,hora_salida = salida where cod_horario = codigo;
    ELSE
        insert into horario(hora_llegada,suspende,regresar,hora_salida) values(llegada,suspender,regreso,salida);		
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_puntualidad`(
	dni varchar(8)
)
BEGIN
    -- Si el SP devuelve 2 es por que llego tarde, si devuelve 3 es por que se quiere ir antes
    set @dni = dni;
    -- Cantidad de registros en el dia para fijarse en cual hora de salida se debe usar
    set @cant_e = ( select count(*) from registro where personal_dni = dni and date(hora_llegada) = date(now()) );
    set @cant_s = ( select count(*) from registro where personal_dni = dni and date(hora_llegada) = date(now()) and estado = 0 );
    if (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = @dni) is not null then
         set @hora_llegada = (select hora_llegada from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni );
         set @suspende = (select suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni );
         set @regresar = (select regresar from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni );
          set @hora_salida = (select hora_salida from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni );
        -- select @hora_llegada,@suspende,@regresar,@hora_salida;
    else
		set @hora_llegada = (select hora_llegada from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
        set @hora_salida = (select hora_salida from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni );
        -- select @hora_llegada,@hora_salida;
    end if;
    -- Verifica si se realizara una entrada o una salida
    if @cant_e = @cant_s then
		-- Verifica si tiene 1 o 2 entradas
        if (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = @dni) is not null then
			if @cant_e = 0 then
				if time_to_sec(curtime()) <= (time_to_sec(@hora_llegada) + time_to_sec('00:15:00')) then
					select 1 as num;
				else
					select 2 as num ,@hora_llegada as llegada;
				end if;
			else
				if time_to_sec(curtime()) <= (time_to_sec(@regresar) + time_to_sec('00:15:00')) then
					select 1 as num;
				else
					select 2 as num,@regresar as llegada;
				end if;
            end if;
        else
			if time_to_sec(curtime()) <= (time_to_sec(@hora_llegada) + time_to_sec('00:15:00')) then
				select 1 as num;
			else
				select 2 as num,@hora_llegada as llegada;
			end if;
        end if;
    else
		-- Verifica is tiene una o 2 salidas
        if (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = @dni) is not null then
			if @cant_s = 0 then
				if time_to_sec(curtime()) >= (time_to_sec(@suspende)) then
					select 1 as num;
				else
					select 3 as num,@suspende as salida;
				end if;
			else
				if time_to_sec(curtime()) >= (time_to_sec(@hora_salida)) then
					select 1 as num;
				else
					select 3 as num,@hora_salida as salida;
				end if;
            end if;
        else
			if time_to_sec(curtime()) >= (time_to_sec(@hora_salida)) then
				select 1 as num;
			else
				select 3 as num,@hora_salida as salida;
			end if;
        end if;
    end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_registrar_permiso`(
	permiso text,
    fecha date,
    dni varchar(8)
)
BEGIN
	if exists (select cod_permiso from permisos where fecha_permiso = fecha and personal_dni = dni) then
		set @codigo = (select cod_permiso from permisos where fecha_permiso = fecha and personal_dni = dni);
        update permisos 
        set 
        motivo = permiso,
        fecha_permiso = fecha,
        personal_dni = dni
        where cod_permiso = @codigo;
    else
		insert into permisos(motivo,fecha_permiso,personal_dni) values(permiso,fecha,dni);
    end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ver_Registro`(
	dni varchar(8),
    fecha_inicio DATE,
    fecha_fin DATE
)
BEGIN
	if (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni) is not null then
		-- Todos los horarios tienen receso
		drop table if exists temp;
        CREATE TEMPORARY TABLE temp
		(	codigo1 int primary key, 
			codigo2 int,
			fecha date,
			hora_llegada time,
			suspende time,
			regresar time,
			hora_salida time,
			cod_permiso int,
            motivo text );
        set @fecha = fecha_inicio;
		while @fecha <= fecha_fin do
				if exists (select date(hora_llegada) from registro where personal_dni = dni and date(hora_llegada) = @fecha) THEN
					IF exists (SELECT date(hora_llegada) as fecha, hora_llegada,hora_salida from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1,1) THEN
						-- reuperando datos
                        set @codigo1 = (SELECT cod_registro from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1);
                        set @codigo2 =  (SELECT cod_registro from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
                        set @fecha_2 = @fecha;
						set @llegada = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
						set @receso = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
						set @regreso = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
						set @salida = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
                        set @cod_permiso = (SELECT cod_permiso from permisos where date(fecha_permiso) = @fecha and personal_dni = dni);
                        set @motivo = (select motivo from permisos where date(fecha_permiso)  = @fecha and personal_dni = dni);
						-- emitiendo consulta
						insert into temp values (@codigo1,@codigo2,@fecha_2,@llegada,@receso,@regreso,@salida,@cod_permiso,@motivo);
					else
						-- reuperando datos
                        set @codigo1 = (SELECT cod_registro from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1);
                        set @codigo2 =  (SELECT cod_registro from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
                        set @fecha_2 = @fecha;
						set @llegada = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
						set @receso = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
						set @regreso = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
						set @salida = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
                        set @cod_permiso = (SELECT cod_permiso from permisos where date(fecha_permiso) = @fecha and personal_dni = dni);
                        set @motivo = (select motivo from permisos where date(fecha_permiso)  = @fecha and personal_dni = dni);
						-- emitiendo consulta
						insert into temp values (@codigo1,@codigo2,@fecha_2,@llegada,@receso,@regreso,@salida,@cod_permiso,@motivo);
                    END IF;
				END IF;
		    set @fecha = adddate(@fecha,1);
            END WHILE;
            select * from temp;
    else 
		select r.cod_registro as 'codigo1','No tiene' as 'codigo2',date(hora_llegada) as fecha,time(hora_llegada) as hora_llegada , 'No tiene' as suspende,'No tiene' as regresar, time(hora_salida) as hora_salida , cod_permiso,motivo 
		from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
		where r.personal_dni = dni and date(hora_llegada) >= fecha_inicio and date(hora_llegada) <= fecha_fin;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ver_Registro2`(
	dni varchar(8),
    fecha_inicio DATE,
    fecha_fin DATE
)
BEGIN
	-- Todos los horarios tienen receso
	drop table if exists temp;
	CREATE TEMPORARY TABLE temp
	(	codigo1 int, 
		codigo2 int,
		fecha date PRIMARY KEY,
		hora_llegada time,
		suspende time,
		regresar time,
		hora_salida time,
		cod_permiso int,
		motivo text );
	set @fecha = fecha_inicio;
    set @d1 = (select Sunday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d2= (select Monday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d3 = (select Tuesday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d4= (select Wednesday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d5= (select Thursday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d6= (select Friday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d7= (select Saturday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
	set @c = 0;
    while @fecha <= fecha_fin do
		case dayofweek(@fecha)
			when 1 then set @c = @d1;
			when 2 then set @c = @d2;
			when 3 then set @c = @d3;
			when 4 then set @c = @d4;
			when 5 then set @c = @d5;
			when 6 then set @c = @d6;
			when 7 then set @c = @d7;
		end case;
       -- comprobar si esta dentro del horario	
        if @c = 1 then
            -- COMPRUEBA SI EXISTE ALGUN REGISTRO EN CASO CONTRARIO DEVUELE SOLO LA FECHA
			if exists (select date(hora_llegada) from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1) THEN
				-- COMPRUEBA SI TIENE EL HORARIO TIENE UNA ENTRADA O 2 ENTRADAS
				if (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni) is not null then
									IF exists (SELECT date(hora_llegada) as fecha, hora_llegada,hora_salida from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1,1) THEN
										-- reuperando datos
										set @codigo1 = (SELECT cod_registro from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @codigo2 =  (SELECT cod_registro from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @fecha_2 = @fecha;
										set @llegada = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @receso = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @regreso = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @salida = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @cod_permiso = (SELECT cod_permiso from permisos where date(fecha_permiso) = @fecha and personal_dni = dni);
										set @motivo = (select motivo from permisos where date(fecha_permiso)  = @fecha and personal_dni = dni);
										-- INSECION EN LA TABLA TEMPORAL
										insert into temp values (@codigo1,@codigo2,@fecha_2,@llegada,@receso,@regreso,@salida,@cod_permiso,@motivo);
									else
										-- reuperando datos
										set @codigo1 = (SELECT cod_registro from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @codigo2 =  (SELECT cod_registro from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @fecha_2 = @fecha;
										set @llegada = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @receso = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @regreso = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @salida = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @cod_permiso = (SELECT cod_permiso from permisos where date(fecha_permiso) = @fecha and personal_dni = dni);
										set @motivo = (select motivo from permisos where date(fecha_permiso)  = @fecha and personal_dni = dni);
										-- INSERCION EN LA TABLE TEMPORAL
										insert into temp values (@codigo1,@codigo2,@fecha_2,@llegada,@receso,@regreso,@salida,@cod_permiso,@motivo);
									END IF;
				else 
					-- reuperando datos
					set @codigo1 = (select r.cod_registro from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
									where r.personal_dni = dni and date(hora_llegada) = @fecha);
					set @codigo2 =  'No tiene';
					set @fecha_2 = @fecha;
					set @llegada = (select time(hora_llegada)  from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
									where r.personal_dni = dni and date(hora_llegada) = @fecha);
					set @receso = 'No tiene';
					set @regreso ='No tiene';
					set @salida = (select time(hora_salida) from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
									where r.personal_dni = dni and date(hora_llegada) = @fecha);
					set @cod_permiso = (select cod_permiso from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
									where r.personal_dni = dni and date(hora_llegada) = @fecha);
					set @motivo = (select motivo from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
									where r.personal_dni = dni and date(hora_llegada) = @fecha);
					-- INSERCION DE DATOS EN LA TABLA TEMPORAL
					insert into temp values (@codigo1,@codigo2,@fecha_2,@llegada,@receso,@regreso,@salida,@cod_permiso,@motivo);
				END IF;
			else 
				-- INSERCION DE LOS DATOS EN CASO NO HAYA REGISTROS
				insert into temp values(null,null,@fecha,null,null,null,null,null,null);
			END IF;
		end if;
	set @fecha = adddate(@fecha,1);
	END WHILE;
    -- COMPRUEBA SI TIENE EL HORARIO TIENE UNA ENTRADA O 2 ENTRADAS
	if (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni) is not null then
		select * from temp ORDER BY fecha asc;
	else
		select codigo1,'No tiene' as codigo2,fecha,hora_llegada,'No tiene'as suspende,'No tiene' as regresar, hora_salida,cod_permiso,motivo from temp ORDER BY fecha asc;
    end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ver_Reporte`(
	dni varchar(8),
    fecha_inicio DATE,
    fecha_fin DATE
)
BEGIN
	if (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni) is not null then
		-- Todos los horarios tienen receso
		drop table if exists temp;
        CREATE TEMPORARY TABLE temp
		(	fecha date primary key,
			hora_llegada time,
			suspende time,
			regresar time,
			hora_salida time,
            motivo text );
        set @fecha = fecha_inicio;
		while @fecha <= fecha_fin do
				if exists (select date(hora_llegada) from registro where personal_dni = dni and date(hora_llegada) = @fecha) THEN
					IF exists (SELECT date(hora_llegada) as fecha, hora_llegada,hora_salida from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1,1) THEN
						-- reuperando datos
                        set @fecha_2 = @fecha;
						set @llegada = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
						set @receso = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
						set @regreso = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
						set @salida = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
                        set @motivo = (select motivo from permisos where date(fecha_permiso)  = @fecha and personal_dni = dni);
						-- emitiendo consulta
						insert into temp values (@fecha_2,@llegada,@receso,@regreso,@salida,@motivo);
					else
						-- reuperando datos
                        set @fecha_2 = @fecha;
						set @llegada = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
						set @receso = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
						set @regreso = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
						set @salida = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
                        set @motivo = (select motivo from permisos where date(fecha_permiso)  = @fecha and personal_dni = dni);
						-- emitiendo consulta
						insert into temp values (@fecha_2,@llegada,@receso,@regreso,@salida,@motivo);
                    END IF;
				END IF;
		    set @fecha = adddate(@fecha,1);
            END WHILE;
            select date_format(fecha,'%d %b %Y'),time_format(hora_llegada,"%r"),time_format(suspende,"%r"),time_format(regresar,"%r"),time_format(hora_salida,"%r"),motivo from temp;
    else 
		select DATE_FORMAT(date(hora_llegada),'%d %b %Y') as fecha,TIME_FORMAT(time(hora_llegada), "%r") as hora_llegada , 'No tiene' as suspende,'No tiene' as regresar, TIME_FORMAT(time(hora_salida),"%r") as hora_salida ,motivo 
		from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
		where r.personal_dni = dni and date(hora_llegada) >= fecha_inicio and date(hora_llegada) <= fecha_fin;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ver_Reporte2`(
	dni varchar(8),
    fecha_inicio DATE,
    fecha_fin DATE
)
BEGIN
	-- Todos los horarios tienen receso
	drop table if exists temp;
	CREATE TEMPORARY TABLE temp
	(	codigo1 int, 
		codigo2 int,
		fecha date PRIMARY KEY,
		hora_llegada time,
		suspende time,
		regresar time,
		hora_salida time,
		cod_permiso int,
		motivo text );
	set @fecha = fecha_inicio;
    set @d1 = (select Sunday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d2= (select Monday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d3 = (select Tuesday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d4= (select Wednesday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d5= (select Thursday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d6= (select Friday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
    set @d7= (select Saturday from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni);
	set @c = 0;
    while @fecha <= fecha_fin do
		case dayofweek(@fecha)
			when 1 then set @c = @d1;
			when 2 then set @c = @d2;
			when 3 then set @c = @d3;
			when 4 then set @c = @d4;
			when 5 then set @c = @d5;
			when 6 then set @c = @d6;
			when 7 then set @c = @d7;
		end case;
       -- comprobar si esta dentro del horario	
        if @c = 1 then
            -- COMPRUEBA SI EXISTE ALGUN REGISTRO EN CASO CONTRARIO DEVUELE SOLO LA FECHA
			if exists (select date(hora_llegada) from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1) THEN
				-- COMPRUEBA SI TIENE EL HORARIO TIENE UNA ENTRADA O 2 ENTRADAS
				if (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni) is not null then
									IF exists (SELECT date(hora_llegada) as fecha, hora_llegada,hora_salida from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1,1) THEN
										-- reuperando datos
										set @codigo1 = (SELECT cod_registro from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @codigo2 =  (SELECT cod_registro from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @fecha_2 = @fecha;
										set @llegada = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @receso = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @regreso = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @salida = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @cod_permiso = (SELECT cod_permiso from permisos where date(fecha_permiso) = @fecha and personal_dni = dni);
										set @motivo = (select motivo from permisos where date(fecha_permiso)  = @fecha and personal_dni = dni);
										-- INSECION EN LA TABLA TEMPORAL
										insert into temp values (@codigo1,@codigo2,@fecha_2,@llegada,@receso,@regreso,@salida,@cod_permiso,@motivo);
									else
										-- reuperando datos
										set @codigo1 = (SELECT cod_registro from registro where personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @codigo2 =  (SELECT cod_registro from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @fecha_2 = @fecha;
										set @llegada = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @receso = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1);
										set @regreso = (SELECT hora_llegada from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @salida = (SELECT hora_salida from registro where registro.personal_dni = dni and date(hora_llegada) = @fecha limit 1,1);
										set @cod_permiso = (SELECT cod_permiso from permisos where date(fecha_permiso) = @fecha and personal_dni = dni);
										set @motivo = (select motivo from permisos where date(fecha_permiso)  = @fecha and personal_dni = dni);
										-- INSERCION EN LA TABLE TEMPORAL
										insert into temp values (@codigo1,@codigo2,@fecha_2,@llegada,@receso,@regreso,@salida,@cod_permiso,@motivo);
									END IF;
				else 
					-- reuperando datos
					set @codigo1 = (select r.cod_registro from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
									where r.personal_dni = dni and date(hora_llegada) = @fecha);
					set @codigo2 =  'No tiene';
					set @fecha_2 = @fecha;
					set @llegada = (select time(hora_llegada)  from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
									where r.personal_dni = dni and date(hora_llegada) = @fecha);
					set @receso = 'No tiene';
					set @regreso ='No tiene';
					set @salida = (select time(hora_salida) from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
									where r.personal_dni = dni and date(hora_llegada) = @fecha);
					set @cod_permiso = (select cod_permiso from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
									where r.personal_dni = dni and date(hora_llegada) = @fecha);
					set @motivo = (select motivo from registro r left join permisos p on (fecha_permiso = date(hora_llegada) and p.personal_dni = r.personal_dni)
									where r.personal_dni = dni and date(hora_llegada) = @fecha);
					-- INSERCION DE DATOS EN LA TABLA TEMPORAL
					insert into temp values (@codigo1,@codigo2,@fecha_2,@llegada,@receso,@regreso,@salida,@cod_permiso,@motivo);
				END IF;
			else 
				-- INSERCION DE LOS DATOS EN CASO NO HAYA REGISTROS
				insert into temp values(null,null,@fecha,null,null,null,null,null,null);
			END IF;
		end if;
	set @fecha = adddate(@fecha,1);
	END WHILE;
    -- COMPRUEBA SI TIENE EL HORARIO TIENE UNA ENTRADA O 2 ENTRADAS
	if (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni) is not null then
		select date_format(fecha,'%d %b %Y'),time_format(hora_llegada,"%r"),time_format(suspende,"%r"),time_format(regresar,"%r"),time_format(hora_salida,"%r"),motivo from temp ORDER BY fecha asc;
	else
		select DATE_FORMAT(date(fecha),'%d %b %Y') as fecha,TIME_FORMAT(time(hora_llegada), "%r") as hora_llegada , 'No tiene' as suspende,'No tiene' as regresar, TIME_FORMAT(time(hora_salida),"%r") as hora_salida ,motivo  from temp ORDER BY fecha asc;
    end if;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `area`
--

CREATE TABLE IF NOT EXISTS `area` (
  `cod_area` varchar(6) NOT NULL,
  `nombre` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `area`
--

INSERT INTO `area` (`cod_area`, `nombre`) VALUES
('enei', 'Escuela del INEI');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignacion`
--

CREATE TABLE IF NOT EXISTS `asignacion` (
  `horario_cod_horario` int(11) NOT NULL,
  `personal_dni` varchar(8) NOT NULL,
  `Sunday` bit(1) DEFAULT NULL,
  `Monday` bit(1) DEFAULT NULL,
  `Tuesday` bit(1) DEFAULT NULL,
  `Wednesday` bit(1) DEFAULT NULL,
  `Thursday` bit(1) DEFAULT NULL,
  `Friday` bit(1) DEFAULT NULL,
  `Saturday` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `asignacion`
--

INSERT INTO `asignacion` (`horario_cod_horario`, `personal_dni`, `Sunday`, `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`) VALUES
(1, '71025849', b'1', b'1', b'1', b'1', b'1', b'1', b'1'),
(5, '88888888', b'1', b'1', b'1', b'1', b'1', b'1', b'1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horario`
--

CREATE TABLE IF NOT EXISTS `horario` (
`cod_horario` int(11) NOT NULL,
  `hora_llegada` time NOT NULL,
  `suspende` time DEFAULT NULL,
  `regresar` time DEFAULT NULL,
  `hora_salida` time NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `horario`
--

INSERT INTO `horario` (`cod_horario`, `hora_llegada`, `suspende`, `regresar`, `hora_salida`) VALUES
(1, '11:00:00', NULL, NULL, '23:30:00'),
(5, '13:00:00', NULL, NULL, '18:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

CREATE TABLE IF NOT EXISTS `permisos` (
`cod_permiso` int(11) NOT NULL,
  `motivo` text NOT NULL,
  `fecha_permiso` date NOT NULL,
  `personal_dni` varchar(8) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `permisos`
--

INSERT INTO `permisos` (`cod_permiso`, `motivo`, `fecha_permiso`, `personal_dni`) VALUES
(5, 'salud', '2015-02-21', '71025849');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personal`
--

CREATE TABLE IF NOT EXISTS `personal` (
  `dni` varchar(8) NOT NULL,
  `nombre` varchar(35) NOT NULL,
  `apellido` varchar(35) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `sexo` bit(1) NOT NULL,
  `area_cod_area` varchar(6) NOT NULL,
  `cargo` varchar(15) NOT NULL,
  `password` varchar(15) DEFAULT NULL,
  `tipo` varchar(15) DEFAULT NULL,
  `foto` mediumblob
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `personal`
--

INSERT INTO `personal` (`dni`, `nombre`, `apellido`, `fecha_nacimiento`, `sexo`, `area_cod_area`, `cargo`, `password`, `tipo`, `foto`) VALUES
('71025849', 'Kevin', 'Herrera Vega', '1994-08-22', b'1', 'enei', 'Practicante', 'kevinmike', 'image/jpeg', 0xffd8ffe000104a46494600010100000100010000ffe1007a45786966000049492a0008000000020031010200070000002600000069870400010000002e00000000000000476f6f676c650000020000900700040000003032323009900700260000004c000000000000000a24080110011800200028003000380040004801500058006001680170007801800101880101ffdb0084000302020b0a0a0a0a080a0a0a080b0a0a0a0a080a0a0808080a0a080a0808080808080a080808080808080808080a080808080a0a0a08080c0c0a080c08080908010304040605060a06060a100c0c0e0d0c0f0f0f0f0d0d0d0f0d0d0d0d0c0c0c0c0d0d0c0c0d0c0c0d0c0c0d0c0c0d0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0cffc0001108008c008c03011100021101031101ffc4001d000001050101010100000000000000000006020304050708010009ffc400481000020004040207040704040f00000000010200030411051221310641071322516171810891a1b11423324272c1f0526282d1243392d4154344455354559394a2a3c2d2e1e2ffc4001b01000203010101000000000000000000000203010405000607ffc4003111000202020103020403080300000000000001021103213104124122510513325261718114234291a1b1d1f033c1f1ffda000c03010002110311003f00e63e05c4f230bec7437e4796be7cfce2b70141d33af7a3ee3d06827c8736c8ac53f0cc0411fc2e6ffc71af87aa52c12c4df053cbd3359a39179ffa29fda0486a2a24ff00498961c96efbd4237fdb7f48a0a1a2c49ece87973f7b443810a4227cf85bc63132a2aa7c2a58c35328712aa8538fe0314ac027e220cf3179210b7ef36bb7a0b81e60c457821bbd83d8bd68b986286ec53046baa05e18e2bc82c1fac30c7daf609495a44476d2d1053555bf56828b4d90e3ec55d40f4814d5b42ddffbe082f0d8a4806b5a22bda216d9124d90aa46a3cfe40c42ae285cd05b82dbab5bf75bdd17170557a04e5b156f0e42323c6cda36de02e23cc8baea6cade84137f3b030b72516cbb08a946ecd0ba65c4b30c225ef9b17a13e88cec74f48d28bf4e8cf9ad9d0eb88c31ec42d6c62a31281922c2651e238b40b541201f8b78ce5c943326be551dda9279003ef126d602135e424ce5ee26f68932e63f512eecd6be622ca40b12729b5dac34573f90436aa99c075574f154c6ff56a398b137f13724f9016f580ef64a8886e9ce71d910f7eff00ce254fb76ce6af4824c0ba5159bd998b91fbf42a7c2fcbd61b0c89b0251a2de7d4de1b740a2baa66475d02cab9cf0557c016429b3223b89ad688b32644df93bb4ae79dda3e1a0f5d4c0a97913dbbd865c3bfd5afafce2d2a294aef829b14a6b6b1858e49e8de9c5a764ce8ff0088b24cb13a369e008dbdfb7ba07245b7dc866096ebdcd1b1be2fcf51852b6a25d62ccfec2cc20fa43ba7caeddf819d4624aab93a469b8c01e71ab1c89947b28faa38a073304d9c8c13a6ff006826a71929caf5879904903bf90f9fa69089ceb48289c918d719d44f62d366bb93c99c91af2009b01e5685b77b64220a824d9ac6fcc36df184b925b4369bd592452aa83981bf8dcfc435be70a5272e02aae515f31f5d22cc52f224765624c34bfebce21e34cebe42ce14e911d1824d6ba1d2e775eef310c4bd80346993efac15a38815063bb88e382134d8eba23764699363bb8eb2075da9f3f9da224bd8537c85580d5760799fe70f8dd151b7e0973d6ea63cddbeed1e9650d02752b91891cb9f8c5ebba28af4f24a91c619aaa90bf6423962c4d87d8717d76d7c613f2e51849ffbc975668ca714f8373a1e912581ace9639eae83e663b1659476cb19218fc3441e31e99e4c9944acc49930e8b2d5d58df9160a490a3737b6d6dcc5d8e56ca93514b5b672d716f113cf98cd30dc93bfe4072039011d05bee65694aca3974a09ed358439cdd691118a7cba1c7083662df0fca169ce5caa39a8ae1d930550cba1d79839bf316f742bb5dec2725456bd46bdc7e11692742852377fbe399c26a1768e8901bf0d71e859612666246808b6dc86a609da64513e6f1d2720df0fe702e4c8223f192fecb7c225700bbf033338ac7ec9f78fe511c80d902a38935b85f3d624ea6394fc7ee82caa2de27bfd20d688edb35b96e2d1e6768df51f2097143588b73117704ad5329e65405e2a7b697d803f28b8afb59589d3e68cabe422bd35a632d1498835d84393d1d443aea120937baf7fce1b09a7a3a506b67d87e159ce911933a80cc381e4e0b2abe1c64fbac7d34f788af1cfdfe4b53e9250e5320d43b0d96df13eb787429f92b4e2d6a881393bc4598cbd8aee2d7232ad0dab045bce8151d9c3721f58296c82c918c275c3640a2e638e5b3ecc62503a1b990688bd8ce431275a375cfa47966df937e2b40f7128bdb9c59c2db29e602f1b519d7368329f18d283b8e8a5493d89993741a72f87280f2151535e75bc3a15b218fe1320bb5b7be8079c0666a28b5822e52a363e1ee03cb94e5d0f3f1f18f3b93a86ecf75d2743d89683fa5e150e8465114e39e5166dfecb092a600f10747763f67e11a10ea1aa461e7e8137a404e2fc216bdc1f08bd1cfb546266e8e93b40d4fe136dc45c8f52999393a27ca45157d19536317f1cfb95a33a707074c8d0d0033c3f0d05149dec0c27b4ace7c8e9c3847765b16e6c69e8441f603dcec626518ee82480949f91bfa10887a2559a999fa7ebdd1e5ead9ea14f45262cf7610e8b515a1393608e31479a66e05909d7cc0b45ec52f4dfe25494537b3c9b2fb23d3f2898b05f243c488200b6a39f7f8fe5130beed07a710d3a0ae0d6a9aa5007d5a0cced6d00d2c2fdec6dfa1143e239d6387e2cf47f07e95e5ca9f85c9da12f87a95572bcd948c00d0b28b69cee63ca5c9db48fa039280ac364d25caca988cc37cacadf230e5072e50bf99f6b43f57c1b25f5b886c7475fba0278bf8669d4768a80399207be1d152e5099f625ebd194e29434b73966cbd3b981f808bb534b832323c2f86804e34e0797365b3d390ce05ec39db5db706d7de2ce0cef14aa5c191d67490cd172c7ca31a793ada3d2295a3c63d7268f8648bcb4fc23e423acafda38f4b1dde80abf033369e0bb88ed647994f05dd40b86f64632a26af60b8b0d566691e512dd1e8adfe8565537687ac353a54734813c5d3eb4e970107ccc5dc5ff001fea54c9f57e82a63e82213f070f48e169d31264d9525de4ca1f593154944bf366d877f86f00f2c23e96e9977174d39c7be316d2e4eabe86784d65e152da5dd664f5cef3068fdab95ed6e005b0d3bcf7c795eb72379df9a67d17e178963e9a35e55813c56b4d29591c4e9eea0b3757f740d4b127bb998b9814e74f481ea963c51f5db33fe1e32a64ceb29c4e976600126fa9d8661df6db9da34f26392d4a8c9e965872cae168eafe8fb059d328da66606d7176df4fce306734a54cf58a1ad6ce6ae928b4d9843976d6c0036178dae9a37f49e67e22d3d4af4016053a533b20a6762a18b76896013ed1237d3bb5317a509457d5679cc5930ca5dbd8cd2f85f86a59226492477afe4473f8c6664c8dfa59e830e0827dd0e0c7b8ef0222ae724b526c43594722aac741cae4c6df4d96b12726790ebb035d44a3057e7f408304fead3f088b9dc64d7824b2c1260b5ec4698227f2012233413760cd11d92241df80accb1d575a4d81608073248bed7dadce3cc53efed37d57659513f7f4896a80d305eae6fd635bf647c0931a105fbbfd4a72dcb439523f5df03f90d8a37ee8cb86c3e1935fac644fa3d4ab053bcd63300461cc327577bebda1dc23cf75537f3d2af28fa67c321197c3a973eab3a2fa0ac195e82951ac47d1e55c79a027e2632ba893f9add7965ee963fba8a5ecbfb17b5fd07495ccc88a330218db36607756bdee0f31b784361925cb1d931daa9ab29385fa13a7964e494892c1cda201dafdddcdcdbed5cda2dcfa8f4db76c0c3d2e38aa8c520e930854a69e12c16c400396919c9b94acd18aed8d185615d1b4b9a2e40333983adcfeb9c68aea251d2665e4c116fbaac9b2ba0697a9540acdf688005edfb44019ade30f9676f7654f918d3d448f51d16ad3824117d6f15d657239e25ec73b63f85debaa186fd4a5bbf536d3fb3f18d4c72fdc457e2cc68e25fb64e4bed45069adb6bb0f713f9c6dc1e97e4787ea2be6cabee7fdd9f1862e4ac469861a9d6c16861c41dfb01256359639abf2427dba3c9559994266501483ae9aedbdbe718bdb4ecd55b55658d872208b6e3584ce2c6a54e8a46c1f3cd7d6d6cbcafbdfc445befa8e8438f74992df86aff7f6fddffea03beb90d63ae19befb30b2af5f49308759995d65d82dfb2526817241397ab6b5c688751189f11e5644b83dc7c03254678a4ff0015fa9bff00054a5a5fa85b8597d8517b9caba25cf3ecdb5e718cdb93d9ea2351d234ec2f16cfa31d227be8b15642e2cc7d556d70aa376d801ccfebc22396471a33bace99a9be8ee89315f3122e083b687506ddfce2cc314af81729a71b4ccfba39e2547988d26607562d7035b107716874b1495a921119464ad3b367a9c6b2aef0b50f601994f1af13dee2f0c8435685646609c552f2f5b3762458369cbec8bf3373b79c6a62db514627519162c72cbe69aff065941585142ef6e7df1b8a4ad9f381d38a9ee104b9d1036d891ee112f4aace1a7c40f743937408d7d34f7417757906bf03f4e13d84704e746fe5f4cc47fbd88f13fb6e6f7fe88f511e9b1ffad93293d87f055da8dffe3311fef70b7d5e57a6ff00a21b1e9f1fb1357d8db0704ff42173b9fa456dcdbbcfd26fa402eab2afe2fe8862c105c2172bd8f7085bda8f7d2c6a2b081a83700d41b1361a8b731b1223bf6ac9f704b043d87e83d96f0b90c2648a6eae729ba4c13aa98ab5ac0d9e7ba9f2656079885cb3e492a6f9fcbfc16314562929c794671d2170d3d2cf19d95fac19832a754343948cb9e66a001721b5cdb08ad18f6b3d3f4fd57ce6ed512b05c40db786b4b45f6cb0c628a5cd92f2a67df52b7e62fcc1ef1bc4434ed072c89239b788ba27992542a296d5b3651a6e6dc87ddb5f4def1ad8b2a93766665eeedd79647e8e306322687008b1d89d35dc0d0881cf93bfd281c09c7ea35ac771b04764e968ad12d4a4ab465f8b4fccdbc32d7699f9a4da36ae0df67ea53287d35054170af91b3224bb8be5003dd9866b16636d059575bf2cb917d0eb479aea737ce5dad6904b2bd9bb0aff005193ff0053ff003872ea72f99194f0c1782c64fb34e15a7f40a7fec93f36867cf9fdc29e287844a1ecc5851ff20a6ff760c12cf93ee7fcc1f950f61c97eccb850ff37d2fac943f941acd91ff0013fe643845784484f66ac2bfd9d467ce44b27de444fce97dcff98b715f69b4068c23d12159a2295e89b767d7885bd07c1f168ee3838626344136645d3ce159a42ce03592fa9e7926764fb9821f2bc4bd973a4c9d992bdcc4e9789557730c8ab3d42698378cf14d5337f476952e5f39d333330fc281483ea4436318afa818c3ba40ed760934827fc2ca59810c195d2c0ef6faf37d79655f48b70715fc3ff85ac90d526bfa19ed45354496b49aa4982fa8b301e24769b97943bd176e3f918f9b1e48bd4ac2fa7e2536cb33ed5bdf00f12e510e6d2a62f01a6eba74b976be7700f96ec7d16e61138fa6ccdea7376c4eb29388c578f0796eef259d2d7fac31681ee2fe86b2189260b6cb7a7a987240b262c1ad690b62c44f6a02cb41323216cdb4f5a161a2780d736786644701a620bc45592dd0d4d991c4594f8ad02cc5797305d1d4ab0ef0c0831dc92b47097101326a26d3cc3da9731e5df6be462a1bc980bc598e36e368f49872da45cc8c11e6ae5536079c2552766b49b650e21ecf6edda3392fdd6d879f7f85a3423d42f633f260b7760d56747ef25bed036e63be09664c53c2e2eca9afa9c9f6cebfada1ca9f053c993b5ecd33a14c37ed54b6e6e92c77016cedea7b23c9bbe2b6677514799eb7a86e548d7e9716bef0a493667bc810e198844b6b8647705387d6c4adb26d84149590daf00dbe0b7913a18b8a2078188e3c82d6cb079919d746cd1f24e88af28eb142640b8ef61dbf024cd886bd894fdc61a6c451d77a21d5cf0a0b31000049274000e64f744341c536d24714f4fd8275f3e74f9170735c72240001247ef105b5d45f945ac392b5e0f418f0c9417ba32ac17a59992064980e9a5f6fd18b4f0a93b263d64a1e99afd49add3f30074d795ce90c5d226d6c997c49257407d6f4aeec6ec753ca2d2e9d2d99d93e20e76544baf79cf76b804ed04e292d19ce72c92b6741747fc452d64a4acea8eba656217316248cb7fb4493b0d7c36273e516df065f558e4a4e4f80f696aa1497b147f12f70eaeb18248e52dec30c32ba22d790d04b455305dbad125ed2d44322eab671629510749ece45a968ce6acd2139a036311e1789f164a644c4314496a5a63aa20d4b332aa81e249023aaea8eee302e95fda7652a3c9a062f34e86a40b4b507ed7544f699fee86ca00d482481173174cdcae443924819e00e995ea93e8f5334b4d5b952c54758bc8121573326ddacc48d6e4decbcfd2c97aa3f49abd0e4c7b4feaf04cadc3c316bec62a24f937a3230fe94fa39ca73a8d0efa45fc391fd3656cd8d49598bd6e07a9d23423392d18b3c311347838ee86caeb913182b09b0fa40042269c8b1718033c53c4b98e543a29bdc77c5ee9f07dc79deb7a94fd302df837a74a991a3b75d280b6473afa3fdab8f1b8f0dac597a38c9e91971c8fc9b8709f4fb4d32c261692dfbe3327a3adffe6558ce9f4b383f7435493e0d938738925cc03ab988ff008595be46f151c1fb50f5b0e682a6395f0c1f211515441a4ac3458a54438920f1874b5494771533d55c02dd52fd64db72ec2dcae6e59f283dfce292c4e5c1a1c18871cfb655b2ad048ed11769951a85dac165cb7d74fbc660b7ec9de2de3e8efea603c9467b89fb52e20eb613525efda4972c36bcae55ade196c7c4c3174915e191deff002331e20e2a9d3dcbce98f3188176762c4dafcc93a0e422d420a3e00727e4af91550c92db2131350877462ac3504123dc791f111c96b675b5b4f61c708f4d33651cb523ad4d8b7f8c1ebb35bf7b5f11153274519a6e3a35fa7f88ca2ea6acd4a8319a7ae42253ab3d8fd59b0983f80ea7cc5c465fcb9e27b46fc33e3caae2cc7f8d3a347562554dbca3431cd4b455cd1ada01eb70dea5734cec81dff2b738b2a1dcf466659ac69ca4e802c738c19ce54d13e26343174f18ee479dcfd6ca7a8f05289062cda5c19bc936930a2440db4ec2a2e69f0eb446bca268bfa1ab616b1d46c79fa1de02708bdd07093416e0dd28d5c9b757513401f74b174f2cad997e1089e08cbc0c5959baf47ded44a484ae4b1b693a58d0fe397c8f8a9b1fd95e74a5d357d21a9de8dc70be91a966a874a89257c5d5082391562ac0f981151c651d50767031c51a65ddd8b3cc62cce492cc58925998dc924ea6fbc6dfcb5119ddee3132aef30fb84776eaa81ee4a478d3f5b4125a0bcf23e1edac04a01c65a152df29b836f1dbce2249b5c59d169707c8fdd01d94f41f7de862711ebdf0e8aad8b6ef8238cca4329371b30d0f81046a227b7bb4c84e4b6985b8574b357294abb24e0745eb46775fe2b8627f1168acfa4837a45e87c4324154b7ec66dc5626ce72f35f393f0f00a2caa3c0002342118c55246375139e493727653c9c0808615a8b293848e6212d84968992640ffd443b0a23d97dd0714bc83b1525b94322903f90f031cc947c2640a8df28e6f7a1c35cddf01f293da47773f73ec2db44fd73804acbb17c11da67d61f38776f022fd4c947be078d0c7a273368216c37269aa3c07485af572323cb1a138c1a5b391e4b37bf847497905ba636fa1d2222ed02de8f1d34bed0cf20bd912a2501a4127e05cf5b3d99280da2179417b882b132542ebc9ea24163e45b7ba148bbc4c95264c3636d051f003d3161a18d1cd5210e36f58e8bbd91214c902b4423ffd9),
('88888888', 'Roy', 'DÃ­az NuÃ±es', '2015-02-22', b'1', 'enei', 'Practicante', 'roy', '', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registro`
--

CREATE TABLE IF NOT EXISTS `registro` (
`cod_registro` int(11) NOT NULL,
  `hora_llegada` datetime NOT NULL,
  `hora_salida` datetime DEFAULT NULL,
  `estado` int(11) NOT NULL,
  `personal_dni` varchar(8) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `registro`
--

INSERT INTO `registro` (`cod_registro`, `hora_llegada`, `hora_salida`, `estado`, `personal_dni`) VALUES
(8, '2015-02-21 00:00:00', '2015-02-21 00:00:00', 0, '71025849'),
(9, '2015-02-21 23:15:37', '2015-02-21 23:15:37', 0, '71025849'),
(10, '2015-02-22 13:12:11', NULL, 1, '88888888');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE IF NOT EXISTS `usuario` (
  `usuario` varchar(15) NOT NULL,
  `password` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`usuario`, `password`) VALUES
('admin', '12345');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_edicion_empleados`
--
CREATE TABLE IF NOT EXISTS `v_edicion_empleados` (
`foto` mediumblob
,`tipo` varchar(15)
,`dni` varchar(8)
,`nombre` varchar(35)
,`apellido` varchar(35)
,`fecha_nacimiento` date
,`sexo` bit(1)
,`cod_area` varchar(6)
,`cargo` varchar(15)
,`Horario` varchar(61)
,`Sunday` bit(1)
,`Monday` bit(1)
,`Tuesday` bit(1)
,`Wednesday` bit(1)
,`Thursday` bit(1)
,`Friday` bit(1)
,`Saturday` bit(1)
,`password` varchar(15)
);
-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_empleados`
--
CREATE TABLE IF NOT EXISTS `v_empleados` (
`foto` mediumblob
,`tipo` varchar(15)
,`dni` varchar(8)
,`nombre` varchar(35)
,`apellido` varchar(35)
,`fecha_nacimiento` date
,`sexo` varchar(9)
,`area` varchar(30)
,`cargo` varchar(15)
,`password` varchar(15)
,`Horario` varchar(61)
,`dias` varchar(14)
);
-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_horarios`
--
CREATE TABLE IF NOT EXISTS `v_horarios` (
`cod_horario` int(11)
,`Horario` varchar(61)
);
-- --------------------------------------------------------

--
-- Estructura para la vista `v_edicion_empleados`
--
DROP TABLE IF EXISTS `v_edicion_empleados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_edicion_empleados` AS select `p`.`foto` AS `foto`,`p`.`tipo` AS `tipo`,`p`.`dni` AS `dni`,`p`.`nombre` AS `nombre`,`p`.`apellido` AS `apellido`,`p`.`fecha_nacimiento` AS `fecha_nacimiento`,`p`.`sexo` AS `sexo`,`a`.`cod_area` AS `cod_area`,`p`.`cargo` AS `cargo`,`v`.`Horario` AS `Horario`,`asi`.`Sunday` AS `Sunday`,`asi`.`Monday` AS `Monday`,`asi`.`Tuesday` AS `Tuesday`,`asi`.`Wednesday` AS `Wednesday`,`asi`.`Thursday` AS `Thursday`,`asi`.`Friday` AS `Friday`,`asi`.`Saturday` AS `Saturday`,`p`.`password` AS `password` from (((`personal` `p` left join `area` `a` on((`p`.`area_cod_area` = `a`.`cod_area`))) join `asignacion` `asi` on((`asi`.`personal_dni` = `p`.`dni`))) join `v_horarios` `v` on((`v`.`cod_horario` = `asi`.`horario_cod_horario`)));

-- --------------------------------------------------------

--
-- Estructura para la vista `v_empleados`
--
DROP TABLE IF EXISTS `v_empleados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_empleados` AS select `p`.`foto` AS `foto`,`p`.`tipo` AS `tipo`,`p`.`dni` AS `dni`,`p`.`nombre` AS `nombre`,`p`.`apellido` AS `apellido`,`p`.`fecha_nacimiento` AS `fecha_nacimiento`,if((`p`.`sexo` = 1),'Masculino','Femenino') AS `sexo`,`a`.`nombre` AS `area`,`p`.`cargo` AS `cargo`,`p`.`password` AS `password`,`v`.`Horario` AS `Horario`,concat_ws('-',(case `asi`.`Monday` when '1' then 'L' end),(case `asi`.`Tuesday` when '1' then 'M' end),(case `asi`.`Wednesday` when '1' then 'Mi' end),(case `asi`.`Thursday` when '1' then 'J' end),(case `asi`.`Friday` when '1' then 'V' end),(case `asi`.`Saturday` when '1' then 'S' end),(case `asi`.`Sunday` when '1' then 'D' end)) AS `dias` from (((`personal` `p` left join `area` `a` on((`p`.`area_cod_area` = `a`.`cod_area`))) join `asignacion` `asi` on((`asi`.`personal_dni` = `p`.`dni`))) join `v_horarios` `v` on((`v`.`cod_horario` = `asi`.`horario_cod_horario`)));

-- --------------------------------------------------------

--
-- Estructura para la vista `v_horarios`
--
DROP TABLE IF EXISTS `v_horarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_horarios` AS select `horario`.`cod_horario` AS `cod_horario`,if(((`horario`.`suspende` > 0) and (`horario`.`regresar` > 0)),concat_ws(' con receso de ',concat_ws(' a ',`horario`.`hora_llegada`,`horario`.`hora_salida`),concat_ws(' a ',`horario`.`suspende`,`horario`.`regresar`)),concat_ws(' a ',`horario`.`hora_llegada`,`horario`.`hora_salida`)) AS `Horario` from `horario`;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `area`
--
ALTER TABLE `area`
 ADD PRIMARY KEY (`cod_area`);

--
-- Indices de la tabla `asignacion`
--
ALTER TABLE `asignacion`
 ADD PRIMARY KEY (`horario_cod_horario`,`personal_dni`), ADD KEY `fk_horario_has_personal_personal1_idx` (`personal_dni`), ADD KEY `fk_horario_has_personal_horario1_idx` (`horario_cod_horario`);

--
-- Indices de la tabla `horario`
--
ALTER TABLE `horario`
 ADD PRIMARY KEY (`cod_horario`);

--
-- Indices de la tabla `permisos`
--
ALTER TABLE `permisos`
 ADD PRIMARY KEY (`cod_permiso`), ADD KEY `fk_permisos_personal1_idx` (`personal_dni`);

--
-- Indices de la tabla `personal`
--
ALTER TABLE `personal`
 ADD PRIMARY KEY (`dni`), ADD KEY `fk_personal_area_idx` (`area_cod_area`);

--
-- Indices de la tabla `registro`
--
ALTER TABLE `registro`
 ADD PRIMARY KEY (`cod_registro`), ADD KEY `fk_registro_personal1_idx` (`personal_dni`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
 ADD PRIMARY KEY (`usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `horario`
--
ALTER TABLE `horario`
MODIFY `cod_horario` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
MODIFY `cod_permiso` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT de la tabla `registro`
--
ALTER TABLE `registro`
MODIFY `cod_registro` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `asignacion`
--
ALTER TABLE `asignacion`
ADD CONSTRAINT `fk_horario_has_personal_horario1` FOREIGN KEY (`horario_cod_horario`) REFERENCES `horario` (`cod_horario`) ON DELETE NO ACTION ON UPDATE NO ACTION,
ADD CONSTRAINT `fk_horario_has_personal_personal1` FOREIGN KEY (`personal_dni`) REFERENCES `personal` (`dni`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `permisos`
--
ALTER TABLE `permisos`
ADD CONSTRAINT `fk_permisos_personal1` FOREIGN KEY (`personal_dni`) REFERENCES `personal` (`dni`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `personal`
--
ALTER TABLE `personal`
ADD CONSTRAINT `fk_personal_area` FOREIGN KEY (`area_cod_area`) REFERENCES `area` (`cod_area`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `registro`
--
ALTER TABLE `registro`
ADD CONSTRAINT `fk_registro_personal1` FOREIGN KEY (`personal_dni`) REFERENCES `personal` (`dni`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
