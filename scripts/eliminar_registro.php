<?php
	include('conexion2.php');
	//Recibiendo parametros
	$codigo1 =  $_GET['codigo1'];
	$codigo2 = $_GET['codigo2'];
	$permiso = $_GET['cod_permiso'];
	if(empty($codigo2))
	{
		$codigo2 = 0;
	}
	if(empty($permiso))
	{
		$permiso = 0;
	}
	if($codigo2 != 0)
	{
		
		$query = "delete from registro where cod_registro = {$codigo1};";
		$query .= "delete from registro where cod_registro = {$codigo2};";
		$query .= "delete from permisos where cod_permiso = {$permiso}";

	}
	else
	{
		$query = "delete from registro where cod_registro = {$codigo1};";
		$query .= "delete from permisos where cod_permiso = {$permiso}";
	}
	echo $query;
	if ($mysqli->multi_query($query)) {
	}
	else
	{
		echo "Se ha producido un error el procesar la edicion";
	}
	$mysqli->close();
	header("Location:".$_SERVER['HTTP_REFERER']);  
?>