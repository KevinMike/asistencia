<?php
	session_start();
	if ($_SESSION['login'] != true) {
	 	header("Location:index.php");
	 } 
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Panel de Administración</title>
	<link rel="stylesheet" href="normalize.css">
	<link href="css/panel.css" rel="stylesheet">
	<link href="css/bootstrap.css" rel="stylesheet">
</head>
<body>
	<header>
		<figure>
			<img src="img/inei.png" width="120px" alt="">
		</figure>
		<div class="contenedor">
			<div class="titulo">
				<h1>SISTEMA DE ASISTENCIA</h1>
			</div>
			<nav>
				<li><a href="index.php">Inicio</a></li>
				<li><a href="editar.php">Edicion y Reporte de Registros</a></li>
				<li><a href="empleados.php">Gestionar Personal</a></li>
				<li><a href="scripts/cerrar_sesion.php">Cerrar Sesion</a></li>
			</nav>
		</div>
	</header>
	<section>
	</section>
</body>
</html>