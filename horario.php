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
		$tabla .= "<td><a href='horario.php?cod_horario={$fila["cod_horario"]}' >Editar</a></td>";
		$tabla .= "<td><a href='scripts/eliminar_horario.php?cod_horario={$fila["cod_horario"]}' >Eliminar</a></td></tr>";
	}
	//Edicion de los Horarios
	if ( !empty($_GET['cod_horario']) ) {
	// traemos la noticia
		Echo "<B>EDITANTO EL HORARIO NRO. <b>".$_GET['cod_horario'];
		$action = "scripts/registrar_horario.php?cod_horario=".$_GET['cod_horario'];
		$query = "select * from horario where cod_horario = {$_GET['cod_horario']} Limit 1";
		$respuesta = mysql_query($query);
		while ($fila = mysql_fetch_array($respuesta)) 
		{
			echo "<script type='text/javascript'>var cod_horario =  ".$fila['cod_horario'].";</script>";
			echo "<script type='text/javascript'>var llegada = '".$fila['hora_llegada']."';</script>";
			echo "<script type='text/javascript'>var receso = '".$fila['suspende']."';</script>";
			echo "<script type='text/javascript'>var regreso = '".$fila['regresar']."';</script>";
			echo "<script type='text/javascript'>var salida = '".$fila['hora_salida']."';</script>";
		}
	}
	else
	{
		echo "<script type='text/javascript'>var cod_horario = 0;</script>";
	}
?>
<!DOCTYPE html>
<html lang="es">
<head>
	<meta charset="UTF-8">
	<script src="js/jquery-1.11.2.min.js"type="text/javascript"></script>
	<link rel='stylesheet' type='text/css'href='TimePicki-master/css/timepicki.css'/>
	<script type='text/javascript'src='TimePicki-master/js/timepicki.js'></script>
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<title>Horarios</title>
</head>
<body>
	<h1>Registrar horarios: </h1>
		<script type='text/javascript'>
			$(document).ready(function()
			{
				$('#hora_llegada').val(llegada);
				$('#suspende').val(receso);
				$('#regresar').val(regreso);
				$('#hora_salida').val(salida);
			});
		    function onEnviar(){
			   document.getElementById("variable").value = cod_horario;
			}
		</script>
	<form class="form" role="form" action="scripts/registrar_horario.php" method="POST" enctype="multipart/form-data" name="formu" onsubmit="onEnviar()">
		<input id="variable" name="variable" type="hidden" />
		<div class="form-group">
			<label for="hora_ingreso">Hora de Ingreso</label>
			<input id='hora_llegada' type='TIME'name='hora_ingreso'required class="timepicker" />
			
		</div>
		<div class="form-group">
			<label for="suspende">Hora de Suspención</label>
			<input id="suspende" type="TIME" name="suspende"  class="timepicker">
		</div>
		<div class="form-group">
			<label for="regresar">Hora de Retorno</label>
			<input id="regresar" type="TIME" name="regresar"  class="timepicker">
		</div>
		<div class="form-group">
			<label for="hora_salida">Hora de Salida</label>
			<input type="TIME" name="hora_salida" id="hora_salida" required class="timepicker">
		</div>
		<input type="submit" class="btn btn-success" value="Registrar">
		<input class="btn btn-primary" type="reset">
	</form>
	<script text='text/javascript'> //$('.timepicker').timepicki(); </script>
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
	<form action="empleados.php" method="get">
		<input  type="submit" class="btn btn-default" value="Regresar al Registro de Empleados">
		</br>
	</form>
</body>
</html>

