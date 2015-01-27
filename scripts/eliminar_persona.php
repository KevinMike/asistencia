<?php
	include('conexion.php');
	$dni = $_REQUEST['dni'];
	echo "delete from personal where dni = '{$dni}'";
	$resultado = mysql_query("delete from personal where dni = '{$dni}'",$enlace);
	if (!$resultado) {
		die("No de pudo efectuar la eliminación : ".mysql_error());
	}
	mysql_close();
	header('Location:../empleados.php');

?>