<?php
	include('conexion.php');
	$dni = $_POST['dni'];
	$query = "CALL SP_IngresarDNI('{$dni}')";
	echo $query;
	$resultado = mysql_query($query,$enlace);
	if (!$resultado) {
		die("No se pudo registrar : ".mysql_error());
	}
	mysql_close();
	header('Location:../asistencia.php');
?>