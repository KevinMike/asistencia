<?php
	include('scripts/conexion.php');
	//Verificar si existe un parametro php
	if ( !empty($_POST['dni']) ) {
		$desde = $_REQUEST['desde'];
		$hasta = $_REQUEST['hasta'];
		$dni = $_REQUEST['dni'];
		//$query = "call SP_Ver_Registro('{$dni}',STR_TO_DATE('{$desde}','%d-%m-%Y'),STR_TO_DATE('{$hasta}','%d-%m-%Y'))";
		$query = "call SP_Ver_Registro('{$dni}','{$desde}','{$hasta}')";
		$resultado = mysql_query($query);
		$opciones = "";
		while ($fila = mysql_fetch_array($resultado)) {
			$date = strtotime($fila['fecha']); 
			$new_date = date('d-m-Y', $date);
			$opciones .= "<tr><td>".$new_date."</td>";
			$opciones .= "<td>".$fila['hora_llegada']."</td>";
			$opciones .= "<td>".$fila['suspende']."</td>";
			$opciones .= "<td>".$fila['regresar']."</td>";
			$opciones .= "<td>".$fila['hora_salida']."</td>";
			$opciones .= "<td>".$fila['motivo']."</td>";
			$opciones .= "<td><a href='scripts/eliminar_registro.php?codigo1=".$fila['codigo1']."&codigo2=".$fila['codigo2']."'>Editar</a></td>";
			$opciones .= "<td><a href='scripts/eliminar_registro.php?codigo1=".$fila['codigo1']."&codigo2=".$fila['codigo2']."'>Eliminar</a></td></tr>";
		}
	}
	else
	{
		$opciones = '';
	}
	mysql_close();
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Editar Asistencias</title>
	<script src="js/jquery-1.11.2.min.js"type="text/javascript"></script>
	<link rel='stylesheet' type='text/css'href='TimePicki-master/css/timepicki.css'/>
	<script type='text/javascript'src='TimePicki-master/js/timepicki.js'></script>
	<link href="css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
	<h1>Busqueda</h1>
	<form method="POST" action="">
		<label for="dni">Ingrese el DNI :</label>
		<input type="text" name="dni" required>
		<label for="desde">Desde :</label>
		<input type="date" name="desde" required>
		<label for="hasta">Hasta :</label>
		<input type="date" name="hasta" required>
		<input type="submit" value="Buscar"  onclick=this.form.action="editar.php" />
		<!--<input type="submit" value="Reporte" dir = "reporte.php"/>-->
	</form>
	<h1>Listas de Asistencia</h1>
	<table class="table">
		<tr>
			<th>Fecha</th>
			<th>Hora de llegada</th>
			<th>Salida para Almorzar</th>
			<th>Regreso de Almuerzo</th>
			<th>Hora de Salida</th>
			<th>Permiso</th>
			<th>Editar</th>
			<th>Eliminar</th>
		</tr>
		<?php  echo $opciones;?>
	</table>
</body>
</html>