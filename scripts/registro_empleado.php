<?php
	include('conexion.php');
	$dni = $_POST['DNI'];
	$nombre = $_POST['nombre'];
	$apellido = $_POST['apellido'];
	$fecha_nacimiento = $_POST['fecha_nacimiento'];
	$sexo = $_POST['sexo'];
	$cod_area = $_POST['area'];
	$cargo = $_POST['cargo'];
	$password = $_POST['password'];
	$query = "insert into personal values('{$dni}','{$nombre}','{$apellido}','{$fecha_nacimiento}','{$sexo}','$cod_area','$cargo','{$password}')";
	$resultado = mysql_query($query,$enlace);
	if (!$resultado) {
		die("No de pudo hacer el registro : ".mysql_error());
	}
	mysql_close();
	header('Location:../empleados.php');
?>
