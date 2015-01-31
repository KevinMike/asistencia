<?php
	include('conexion.php');
	$llegada = $_REQUEST['hora_ingreso'];
	$suspender = $_REQUEST['suspende'];
	$regreso = $_REQUEST['regresar'];
	$salida = $_REQUEST['hora_salida'];
	if (isset($suspender) && isset($regreso)) {
		$query = "call SP_Ingresar_Horario(0,'{$llegada}','{$suspender}','{$regreso}','{$salida}')";
	}
	else
	{
		$query = "call SP_Ingresar_Horario(0,'{$llegada}',null,null,'{$salida}')";
	}
	//mysql_query($query);
	echo $query;
	mysql_close();
	//header('Location:../horario.php');
?>