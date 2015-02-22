<?php
	include('conexion.php');
	//recibiendo parametros
	$dni = $_GET['dni'];
	$fecha = $_GET['fecha']	;
	$query = "select if((select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = '{$dni}') is not null,1,0) as num";
	$resultado = mysql_query($query) or die("Error : ".mysql_error());
	$fila = mysql_fetch_array($resultado);
	if ($fila['num'] == 1) {
		$query = "insert into registro(hora_llegada,hora_salida,estado,personal_dni) values('{$fecha}','{$fecha}',0,'{$dni}');";
		$query .= "insert into registro(hora_llegada,hora_salida,estado,personal_dni) values('{$fecha}','{$fecha}',0,'{$dni}')";
	}
	else
	{
		$query = "insert into registro(hora_llegada,hora_salida,estado,personal_dni) values('{$fecha}','{$fecha}',0,'{$dni}')";
	}
	mysql_close();
	include('conexion2.php');
	if ($mysqli->multi_query($query)) {
	}
	else
	{
		echo "Se ha producido un error el procesar la edicion";
	}
	$mysqli->close();
	header("Location:".$_SERVER['HTTP_REFERER']);  
?>
