<?php
	include('conexion.php');
	$cod_horario = $_GET['cod_horario'];
	$query = "delete from horario where cod_horario = {$cod_horario}";
	mysql_query($query);
	mysql_close();
	header('Location:../horario.php');
?>