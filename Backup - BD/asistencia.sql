-- phpMyAdmin SQL Dump
-- version 4.8.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 24-08-2018 a las 18:16:40
-- Versión del servidor: 10.1.34-MariaDB
-- Versión de PHP: 5.6.37

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `asistencia`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Asignar_Horario` (IN `codigo` INT, IN `dni` VARCHAR(8), IN `domingo` BIT(1), IN `lunes` BIT(1), IN `martes` BIT(1), IN `miercoles` BIT(1), IN `jueves` BIT(1), IN `viernes` BIT(1), IN `sabado` BIT(1))  begin
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_cantidad_registros` (`dni` VARCHAR(8))  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_cantidad_registros_2` (`dni` VARCHAR(8), `fecha` DATE)  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Empleados_Presentes` ()  BEGIN
	SELECT p.dni, concat_ws(', ', p.apellido , p.nombre) as nombre, a.nombre as area, p.cargo,TIME(r.hora_llegada) as hora_llegada,p.foto, p.tipo,if(DATE(p.fecha_nacimiento) = DATE(NOW()),1,0) AS cumple
    from registro r
    inner join personal p 
    on r.personal_dni = p.dni
    inner join area a
    on p.area_cod_area = a.cod_area
    where DATE(hora_llegada) = DATE(NOW()) AND estado = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_IngresarDNI` (IN `dni` VARCHAR(8))  BEGIN
	DECLARE codigo int;
    IF exists (select cod_registro from registro where DATE(hora_llegada) = DATE(NOW()) and personal_dni = dni AND estado = 1) THEN
       set  codigo = (select cod_registro from registro where DATE(hora_llegada) = DATE(NOW()) and personal_dni = dni AND estado = 1);
       update registro set hora_salida = now(),estado = 0 where cod_registro = codigo ;
       
	ELSE
        INSERT INTO registro(hora_llegada,estado,personal_dni) VALUES(NOW(),1,dni);		
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ingresar_Empleado` (IN `dnii` VARCHAR(8), IN `nombre` VARCHAR(35), IN `apellido` VARCHAR(35), IN `fecha_nacimiento` DATE, IN `sexo` BIT(1), IN `cod_area` VARCHAR(6), IN `cargo` VARCHAR(15), IN `password` VARCHAR(15), IN `tipo` VARCHAR(15), IN `foto` MEDIUMBLOB, IN `cod_horario` INT, IN `sunday` BIT(1), IN `monday` BIT(1), IN `tuesday` BIT(1), IN `wednesday` BIT(1), IN `thursday` BIT(1), IN `friday` BIT(1), IN `saturday` BIT(1))  begin
	
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ingresar_Horario` (IN `codigo` INT, IN `llegada` TIME, IN `suspender` TIME, IN `regreso` TIME, IN `salida` TIME)  begin
	IF codigo > 0 then
		update horario set hora_llegada = llegada, suspende = suspender,regresar = regreso,hora_salida = salida where cod_horario = codigo;
    ELSE
        insert into horario(hora_llegada,suspende,regresar,hora_salida) values(llegada,suspender,regreso,salida);		
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_puntualidad` (`dni` VARCHAR(8))  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_registrar_permiso` (`permiso` TEXT, `fecha` DATE, `dni` VARCHAR(8))  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ver_Registro` (`dni` VARCHAR(8), `fecha_inicio` DATE, `fecha_fin` DATE)  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ver_Registro2` (`dni` VARCHAR(8), `fecha_inicio` DATE, `fecha_fin` DATE)  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ver_Reporte` (`dni` VARCHAR(8), `fecha_inicio` DATE, `fecha_fin` DATE)  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Ver_Reporte2` (`dni` VARCHAR(8), `fecha_inicio` DATE, `fecha_fin` DATE)  BEGIN
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
		motivo text,
        horas float);
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
                                        if (@salida) is not null then
											set @horas = time_to_sec(timediff( @salida, @regreso)) / 3600 + time_to_sec(timediff( @receso, @llegada)) / 3600;
                                        else
											set @horas = time_to_sec(timediff( @receso, @llegada)) / 3600;
                                        end if;
										-- INSECION EN LA TABLA TEMPORAL
										insert into temp values (@codigo1,@codigo2,@fecha_2,@llegada,@receso,@regreso,@salida,@cod_permiso,@motivo,ROUND(@horas,2));
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
                                        if (@receso) is not null then
											set @horas  = time_to_sec(timediff( @receso, @llegada)) / 3600;
										else
											set @horas = 0;
										end if;
                                        
										-- INSERCION EN LA TABLE TEMPORAL
										insert into temp values (@codigo1,@codigo2,@fecha_2,@llegada,@receso,@regreso,@salida,@cod_permiso,@motivo,ROUND(@horas,2));
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
					if (@salida) is not null then
						set @horas = time_to_sec(timediff( @salida, @llegada)) / 3600;
					else
						set @horas = 0;
					end if;
                    
					-- INSERCION DE DATOS EN LA TABLA TEMPORAL
					insert into temp values (@codigo1,@codigo2,@fecha_2,@llegada,@receso,@regreso,@salida,@cod_permiso,@motivo,ROUND(@horas,2));
				END IF;
			else 
				-- INSERCION DE LOS DATOS EN CASO NO HAYA REGISTROS
				insert into temp values(null,null,@fecha,null,null,null,null,null,null,0);
			END IF;
		end if;
	set @fecha = adddate(@fecha,1);
	END WHILE;
    -- COMPRUEBA SI TIENE EL HORARIO TIENE UNA ENTRADA O 2 ENTRADAS
	if (select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = dni) is not null then
		select date_format(fecha,'%d %b %Y'),time_format(hora_llegada,"%r"),time_format(suspende,"%r"),time_format(regresar,"%r"),time_format(hora_salida,"%r"),motivo,horas from temp ORDER BY fecha asc;
	else
		select DATE_FORMAT(date(fecha),'%d %b %Y') as fecha,TIME_FORMAT(time(hora_llegada), "%r") as hora_llegada , 'No tiene' as suspende,'No tiene' as regresar, TIME_FORMAT(time(hora_salida),"%r") as hora_salida ,motivo,horas  from temp ORDER BY fecha asc;
    end if;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `area`
--

CREATE TABLE `area` (
  `cod_area` varchar(6) NOT NULL,
  `nombre` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignacion`
--

CREATE TABLE `asignacion` (
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horario`
--

CREATE TABLE `horario` (
  `cod_horario` int(11) NOT NULL,
  `hora_llegada` time NOT NULL,
  `suspende` time DEFAULT NULL,
  `regresar` time DEFAULT NULL,
  `hora_salida` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

CREATE TABLE `permisos` (
  `cod_permiso` int(11) NOT NULL,
  `motivo` text NOT NULL,
  `fecha_permiso` date NOT NULL,
  `personal_dni` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personal`
--

CREATE TABLE `personal` (
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registro`
--

CREATE TABLE `registro` (
  `cod_registro` int(11) NOT NULL,
  `hora_llegada` datetime NOT NULL,
  `hora_salida` datetime DEFAULT NULL,
  `estado` int(11) NOT NULL,
  `personal_dni` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `usuario` varchar(15) NOT NULL,
  `password` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_edicion_empleados`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_edicion_empleados` (
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
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_empleados` (
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
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_horarios` (
`cod_horario` int(11)
,`Horario` varchar(61)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `v_edicion_empleados`
--
DROP TABLE IF EXISTS `v_edicion_empleados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_edicion_empleados`  AS  select `p`.`foto` AS `foto`,`p`.`tipo` AS `tipo`,`p`.`dni` AS `dni`,`p`.`nombre` AS `nombre`,`p`.`apellido` AS `apellido`,`p`.`fecha_nacimiento` AS `fecha_nacimiento`,`p`.`sexo` AS `sexo`,`a`.`cod_area` AS `cod_area`,`p`.`cargo` AS `cargo`,`v`.`Horario` AS `Horario`,`asi`.`Sunday` AS `Sunday`,`asi`.`Monday` AS `Monday`,`asi`.`Tuesday` AS `Tuesday`,`asi`.`Wednesday` AS `Wednesday`,`asi`.`Thursday` AS `Thursday`,`asi`.`Friday` AS `Friday`,`asi`.`Saturday` AS `Saturday`,`p`.`password` AS `password` from (((`personal` `p` left join `area` `a` on((`p`.`area_cod_area` = `a`.`cod_area`))) join `asignacion` `asi` on((`asi`.`personal_dni` = `p`.`dni`))) join `v_horarios` `v` on((`v`.`cod_horario` = `asi`.`horario_cod_horario`))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_empleados`
--
DROP TABLE IF EXISTS `v_empleados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_empleados`  AS  select `p`.`foto` AS `foto`,`p`.`tipo` AS `tipo`,`p`.`dni` AS `dni`,`p`.`nombre` AS `nombre`,`p`.`apellido` AS `apellido`,`p`.`fecha_nacimiento` AS `fecha_nacimiento`,if((`p`.`sexo` = 1),'Masculino','Femenino') AS `sexo`,`a`.`nombre` AS `area`,`p`.`cargo` AS `cargo`,`p`.`password` AS `password`,`v`.`Horario` AS `Horario`,concat_ws('-',(case `asi`.`Monday` when '1' then 'L' end),(case `asi`.`Tuesday` when '1' then 'M' end),(case `asi`.`Wednesday` when '1' then 'Mi' end),(case `asi`.`Thursday` when '1' then 'J' end),(case `asi`.`Friday` when '1' then 'V' end),(case `asi`.`Saturday` when '1' then 'S' end),(case `asi`.`Sunday` when '1' then 'D' end)) AS `dias` from (((`personal` `p` left join `area` `a` on((`p`.`area_cod_area` = `a`.`cod_area`))) join `asignacion` `asi` on((`asi`.`personal_dni` = `p`.`dni`))) join `v_horarios` `v` on((`v`.`cod_horario` = `asi`.`horario_cod_horario`))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_horarios`
--
DROP TABLE IF EXISTS `v_horarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_horarios`  AS  select `horario`.`cod_horario` AS `cod_horario`,if(((`horario`.`suspende` > 0) and (`horario`.`regresar` > 0)),concat_ws(' con receso de ',concat_ws(' a ',`horario`.`hora_llegada`,`horario`.`hora_salida`),concat_ws(' a ',`horario`.`suspende`,`horario`.`regresar`)),concat_ws(' a ',`horario`.`hora_llegada`,`horario`.`hora_salida`)) AS `Horario` from `horario` ;

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
  ADD PRIMARY KEY (`horario_cod_horario`,`personal_dni`),
  ADD KEY `fk_horario_has_personal_personal1_idx` (`personal_dni`),
  ADD KEY `fk_horario_has_personal_horario1_idx` (`horario_cod_horario`);

--
-- Indices de la tabla `horario`
--
ALTER TABLE `horario`
  ADD PRIMARY KEY (`cod_horario`);

--
-- Indices de la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD PRIMARY KEY (`cod_permiso`),
  ADD KEY `fk_permisos_personal1_idx` (`personal_dni`);

--
-- Indices de la tabla `personal`
--
ALTER TABLE `personal`
  ADD PRIMARY KEY (`dni`),
  ADD KEY `fk_personal_area_idx` (`area_cod_area`);

--
-- Indices de la tabla `registro`
--
ALTER TABLE `registro`
  ADD PRIMARY KEY (`cod_registro`),
  ADD KEY `fk_registro_personal1_idx` (`personal_dni`);

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
  MODIFY `cod_horario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
  MODIFY `cod_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `registro`
--
ALTER TABLE `registro`
  MODIFY `cod_registro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
