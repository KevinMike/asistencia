
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
END //;    
DELIMITER ;
