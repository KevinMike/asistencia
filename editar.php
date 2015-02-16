<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Busqueda</title>
	<script src="js/jquery-1.11.2.min.js"type="text/javascript"></script>
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<link href="css/panel.css" rel="stylesheet">
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
			</nav>
		</div>
	</header>
	<section>
		<h1>Busqueda</h1>
		<div class="formulario">
			<form role="form" method="GET" action="resultado_editar.php">
		 		<div class="form-group">
					<label for="dni">Ingrese el DNI :</label>
					<input class="form-control" type="text" name="dni" required maxlength="8" placeholder="Ingrese el DNI">
				</div>
				 <div class="form-group">
					<label for="desde">Desde :</label>
					<input class="form-control" type="date" name="desde" required>
				 </div>
				 <div class="form-group">
					<label for="hasta">Hasta :</label>
					<input class="form-control" type="date" name="hasta" required>
				</div>
				<input type="submit" value="Buscar" class="btn btn-primary"/>
				<input type="reset" value="Limpiar" class="btn btn-success"/>
			</form>
		</div>	
		<style>
			h1{
				text-align: center;	
			}
			.formulario{
				width : 50%;
				margin:  auto;
			}
		</style>
	</section>
</body>
</html>