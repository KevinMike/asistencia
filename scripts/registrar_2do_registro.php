<?php
	include('conexion.php');
	//Recibiendo parametros
	$dni = $_POST['reg_dni'];
	$fecha = $_POST['reg_fecha'];
	$query = "CALL SP_cantidad_registros_2('{$dni}','{$fecha}')";
	$resultado = mysql_query($query) or die("Error en: " . mysql_error());
	$var = mysql_fetch_array($resultado);
	mysql_close();
	if($var['num'] == 1) 
	{
		include('conexion2.php');
		$query = "insert into registro(hora_llegada,hora_salida,estado,personal_dni) values('{$fecha}',null,1,'{$dni}')";
		$resultado = mysqli_query($link,$query);
		if (!$resultado) {
			die("No se pudo registrar : ".mysqli_error());
		}
		mysqli_close($link);
		header("Location:".$_SERVER['HTTP_REFERER']); 
	}
	else
	{
		echo "<script language='javascript'>alert('LOS REGISTROS DEL DÍA SELECCIONADO ESTAN COMPLETOS');window.history.back();</script>";		
	}
?>