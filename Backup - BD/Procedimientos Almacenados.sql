Use asistencia;
-- ---------------------------------------------------------------------------------------------------------

drop procedure if exists SP_IngresarDNI;
DELIMITER //
create procedure SP_IngresarDNI(IN dni varchar(8))
BEGIN
	DECLARE codigo int;
    IF exists (select cod_registro from registro where DATE(hora_llegada) = DATE(NOW()) and personal_dni = dni AND estado = 1) THEN
       set  codigo = (select cod_registro from registro where DATE(hora_llegada) = DATE(NOW()) and personal_dni = dni AND estado = 1);
       update registro set hora_salida = now(),estado = 0 where cod_registro = codigo ;
       
	ELSE
        INSERT INTO registro(hora_llegada,estado,personal_dni) VALUES(NOW(),1,dni);		
	END IF;
END;
//
-- ---------------------------------------------------------------------------------------------------------

-- Empleados que se encuentran trabajando
 
DROP PROCEDURE IF EXISTS SP_Empleados_Presentes;
DELIMITER //
CREATE PROCEDURE SP_Empleados_Presentes()
BEGIN
	SELECT p.dni, concat_ws(', ', p.apellido , p.nombre) as nombre, a.nombre as area, p.cargo,TIME(r.hora_llegada) as hora_llegada,p.foto, p.tipo,if(DATE(p.fecha_nacimiento) = DATE(NOW()),1,0) AS cumple
    from registro r
    inner join personal p 
    on r.personal_dni = p.dni
    inner join area a
    on p.area_cod_area = a.cod_area
    where DATE(hora_llegada) = DATE(NOW()) AND estado = 1;
END
//
call SP_Empleados_Presentes()

-- ---------------------------------------------------------------------------------------------------------

-- insertar o actualizar horarios
DROP PROCEDURE IF EXISTS SP_Ingresar_Horario;
DELIMITER //
create procedure  SP_Ingresar_Horario
(in codigo int,
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
END //

-- ---------------------------------------------------------------------------------------------------------

-- Creacion de vistas con horarios
drop  view if exists V_horarios;
create view V_horarios as
select cod_horario, if(suspende>0 and regresar >0,concat_ws(' con receso de ', concat_ws(' a ', hora_llegada , hora_salida) , concat_ws(' a ', suspende , regresar) ),concat_ws(' a ', hora_llegada , hora_salida)) as Horario from horario;

-- ---------------------------------------------------------------------------------------------------------

-- insertar asignacion de horario
DROP PROCEDURE IF EXISTS SP_Asignar_Horario;
DELIMITER //
create procedure  SP_Asignar_Horario
(in codigo int,
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
END //

-- ---------------------------------------------------------------------------------------------------------  
  
-- vista empleados
drop view if exists V_empleados;
create view V_empleados as 
select
p.foto,p.tipo,p.dni,p.nombre,p.apellido,p.fecha_nacimiento,if(sexo=1,'Masculino','Femenino') as sexo,a.nombre as area,p.cargo,p.password,v.Horario,
concat_ws('-',
case asi.Monday 
when '1' then 'L'
end,
case asi.Tuesday 
when '1' then 'M'
end,
case asi.Wednesday 
when '1' then 'Mi'
end,
case asi.Thursday 
when '1' then 'J'
end,
case asi.Friday 
when '1' then 'V'
end,
case asi.Saturday 
when '1' then 'S'
end,
case asi.Sunday 
when '1' then 'D'
end) as dias
from personal p
left join area a on p.area_cod_area  = a.cod_area
inner join asignacion asi on asi.personal_dni = p.dni
inner join V_horarios v on v.cod_horario = asi.horario_cod_horario

-- ---------------------------------------------------------------------------------------------------------

-- Procedimiento Almacenado para Ingresar empleados
DROP PROCEDURE IF EXISTS SP_Ingresar_Empleado;
DELIMITER //
create procedure  SP_Ingresar_Empleado
(in dnii varchar(8),
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
END //

-- ---------------------------------------------------------------------------------------------------------

ALTER TABLE `asignacion`
ADD PRIMARY KEY (`horario_cod_horario`,`personal_dni`), ADD KEY `fk_horario_has_personal_personal1_idx` (`personal_dni`), ADD KEY `fk_horario_has_personal_horario1_idx` (`horario_cod_horario`);

-- Editar Base de Datos
ALTER TABLE asignacion drop  foreign KEY `fk_horario_has_personal_personal1`;
SET foreign_key_checks = 0;
  alter table asignacion 
	ADD CONSTRAINT `fk_horario_has_personal_personal1`
    FOREIGN KEY (`personal_dni`)
    REFERENCES `control_asistencia`.`personal` (`dni`)
    ON DELETE cascade
    ON UPDATE cascade;
SET foreign_key_checks = 1;

-- ---------------------------------------------------------------------------------------------------------

-- Hacer Autoincrementable la columna horario
ALTER TABLE  permisos MODIFY COLUMN cod_permiso INT(11) AUTO_INCREMENT;

-- ---------------------------------------------------------------------------------------------------------

-- vizualisa la asistencia del personal de una fecha a otra

drop procedure if exists SP_Ver_Registro;
 DELIMITER //
create procedure SP_Ver_Registro
(
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
END//;
DELIMITER ;


call SP_Ver_Registro('71025849','2015-02-11','2015-02-11')

-- ---------------------------------------------------------------------------------------------------------

-- vista edicion empleados
drop view if exists V_edicion_empleados;
create view V_edicion_empleados as 
select
p.foto,p.tipo,p.dni,p.nombre,p.apellido,p.fecha_nacimiento, p.sexo,a.cod_area ,p.cargo,v.Horario,
asi.Sunday, asi.Monday, asi.Tuesday, asi.Wednesday, asi.Thursday, asi.Friday, asi.Saturday, p.password
from personal p
left join area a on p.area_cod_area  = a.cod_area
inner join asignacion asi on asi.personal_dni = p.dni
inner join V_horarios v on v.cod_horario = asi.horario_cod_horario

-- ---------------------------------------------------------------------------------------------------------

-- VERIFICAR SI SE PUEDE SEGUIR REGISTRANTO

drop procedure if exists SP_cantidad_registros;
DELIMITER $$
create procedure SP_cantidad_registros
(
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

-- ---------------------------------------------------------------------------------------------------------

-- registra el permiso cuando se edita un registro de asistencia

drop procedure if exists SP_registrar_permiso;
DELIMITER $$
CREATE PROCEDURE SP_registrar_permiso
(
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
CALL SP_Ver_Registro('71025849','2015-02-15','2015-02-15')


-- ---------------------------------------------------------------------------------------------------------

-- Editar Base de Datos
ALTER TABLE asignacion drop  foreign KEY `fk_permisos_personal1` ;
SET foreign_key_checks = 0;
	ALTER TABLE `permisos`
	ADD CONSTRAINT `fk_permisos_personal1` 
	FOREIGN KEY (`personal_dni`) 
	REFERENCES `personal` (`dni`) 
	ON DELETE cascade 
	ON UPDATE cascade;
SET foreign_key_checks = 1;
-- 

-- ---------------------------------------------------------------------------------------------------------

-- REPORTE

drop procedure if exists SP_Ver_Reporte;
 DELIMITER //
create procedure SP_Ver_Reporte
(
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
END//;
DELIMITER ;

-- ---------------------------------------------------------------------------------------------------------

-- Ver registro de asistencia mejorado
drop procedure if exists SP_Ver_Registro2;
 DELIMITER //
create procedure SP_Ver_Registro2
(
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
END //;    
DELIMITER ;

call SP_Ver_Registro2('71025849','2015-02-01','2015-02-17')

-- ---------------------------------------------------------------------------------------------------------

-- VERIFICAR SI SE PUEDE SEGUIR REGISTRANTO
drop procedure if exists SP_cantidad_registros_2;
DELIMITER $$
create procedure SP_cantidad_registros_2
(
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

call SP_cantidad_registros_2('71025849','2015-02-28')

-- ---------------------------------------------------------------------------------------------------------

-- Ver registro de asistencia mejorado
drop procedure if exists SP_Ver_Reporte2;
 DELIMITER //
create procedure SP_Ver_Reporte2
(
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
END //;    
DELIMITER ;

-- ---------------------------------------------------------------------------------------------------------

-- Verifica que entra y sale a su horario
drop procedure if exists SP_puntualidad;
delimiter //
create procedure SP_puntualidad
(
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
END //
DELIMITER ;


use control_asistencia;
select * from v_edicion_empleados
-- ---------------------------------------------------------------------------------------------------------

