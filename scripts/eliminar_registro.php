<?php
	include('conexion.php');
	//Recibiendo parametros
	$codigo1 =  $_GET['codigo1'];
	$codigo2 = $_GET['codigo2'];
	//echo $codigo1." ".$codigo2;
	if(!empty($codigo2))
	{
		$query = "delete from registro where cod_registro = {$codigo1}; delete from registro where cod_registro = {$codigo2};";
	}
	else
	{
		$query = "delete from registro where cod_registro = {$codigo1}";
	}
	echo $query;
	//mysql_query($query);
	mysql_close();
	//header("Location:../editar.php")
?>