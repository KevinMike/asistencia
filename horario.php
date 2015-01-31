<?php
	include('scripts/conexion.php');
	//LLenar la tabla de horarios
	$respuesta =  mysql_query("select * from horario");
	$tabla = "";
	while ($fila = mysql_fetch_array($respuesta)) {
		$tabla .= "<tr><td>".$fila['cod_horario']."</td>";
		$tabla .= "<td>".$fila['hora_llegada']."</td>";
		$tabla .= "<td>".$fila['suspende']."</td>";
		$tabla .= "<td>".$fila['regresar']."</td>";
		$tabla .= "<td>".$fila['hora_salida']."</td>";
		$tabla .= "<td></td>";
		$tabla .= "<td><a href='scripts/eliminar_horario.php?cod_horario={$fila["cod_horario"]}' >Eliminar</a></td></tr>";
	}

?>
<!DOCTYPE html>
<html lang="es">
<head>
	<meta charset="UTF-8">
	<script type="text/javascript" src="js/jquery-2.1.3.js"></script>
	<link rel="stylesheet" type="text/css" href="dist/jquery-clockpicker.min.css">
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<title>Horarios</title>
</head>
<body>
	<h1>Registrar horarios: </h1>
	<form class="form" role="form" action="scripts/registrar_horario.php" method="POST" enctype="multipart/form-data">
		<div class="form-group">
			<label for="hora_ingreso">Hora de Ingreso</label>
			<input type="TIME" name="hora_ingreso" required >
		</div>
		<div class="form-group">
			<label for="suspende">Hora de Suspención</label>
			<input type="TIME" name="suspende"  >
		</div>
		<div class="form-group">
			<label for="regresar">Hora de Retorno</label>
			<input type="TIME" name="regresar"  >
		</div>
		<div class="form-group">
			<label for="hora_salida">Hora de Salida</label>
			<input type="time" name="hora_salida" id="hora_salida"required>
		</div>
		<input type="submit" class="btn btn-success" value="Registrar">
		<input class="btn btn-primary" type="reset">

	</form>
	
	<h1>Horarios Registrados: </h1>
	<table class="table">
		<tr>	
			<th>Código</th>
			<th>Hora de llegada</th>
			<th>Almuerzo</th>
			<th>Regreso</th>
			<th>Hora de salida</th>
			<th>Editar</th>
			<th>Eliminar</th>
		</tr>
		<?php echo $tabla;?>	
		</table>

</body>
</html>

