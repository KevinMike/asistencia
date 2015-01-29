<?php
	//DATOS PARA LA CONEXION
	$servidor = "127.0.0.1:3306";
	$usuario = "root";
	$password = "";
	$bd_name ="control_asistencia";
	#Conexion
	$mysqli=new mysqli($servidor,$usuario,$password,$bd_name);
	if (mysqli_connect_errno()) {
	    die("Error al conectar: ".mysqli_connect_error());
	}
	# Buscamos la imagen a mostrar
	$result=$mysqli->query("SELECT * FROM personal WHERE dni='{$_GET['dni']}'");
	$row=$result->fetch_array(MYSQLI_ASSOC);
	# Mostramos la imagen
	header("Content-type:".$row["tipo"]);
	echo $row["foto"];
?>