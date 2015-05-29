<?php

	//DATOS PARA LA CONEXION

	$servidor = "localhost";

	$usuario = "root";

	$password = "";

	$bd_name ="asistencia";

	#Conexion Orientada a Objetos

	$mysqli=new mysqli($servidor,$usuario,$password,$bd_name);

	if (mysqli_connect_errno()) {

	    die("Error al conectar: ".mysqli_connect_error());

	}

	

	#Conexion procedimental

	$link = mysqli_connect($servidor,$usuario,$password,$bd_name);

	/* comprobar conexión */

	if (mysqli_connect_errno()) {

	    printf("Conexión fallida: %s\n", mysqli_connect_error());

	    exit();

	}
?>