<?php
	include('scripts/conexion.php');
	//Verificar si existe un parametro php
	$vacio = 'No tiene';
	if ( !empty($_GET['dni']) ) 
	{
		$desde = $_GET['desde'];
		$hasta = $_GET['hasta'];
		$dni = $_GET['dni'];
		//$query = "call SP_Ver_Registro('{$dni}',STR_TO_DATE('{$desde}','%d-%m-%Y'),STR_TO_DATE('{$hasta}','%d-%m-%Y'))";
		$query = "call SP_Ver_Registro('{$dni}','{$desde}','{$hasta}')";
		$resultado = mysql_query($query);
		$opciones = "";
		while ($fila = mysql_fetch_array($resultado)) 
		{
			$date = strtotime($fila['fecha']); 
			$new_date = date('d-m-Y', $date);
			$opciones .= "<tr><td>".$new_date."</td>";
			$opciones .= "<td>".$fila['hora_llegada']."</td>";
			$opciones .= "<td>".$fila['suspende']."</td>";
			$opciones .= "<td>".$fila['regresar']."</td>";
			$opciones .= "<td>".$fila['hora_salida']."</td>";
			$opciones .= "<td>".$fila['motivo']."</td>";
			$opciones .= "<td><a href='resultado_editar.php?editar=1&fecha={$fila['fecha']}&dni={$dni}&desde={$desde}&hasta={$hasta}'>Editar</a></td>";
			$opciones .= "<td><a href='scripts/eliminar_registro.php?codigo1=".$fila['codigo1']."&codigo2=".$fila['codigo2']."&cod_permiso={$fila['cod_permiso']}'>Eliminar</a></td></tr>";
		}
	}
	else
	{
		$opciones = '';
	}
	mysql_close();
	$form_editar = "";
	//Verificar si hay algun formulario de edicion
	if (!empty($_GET['editar']))
	{
		$form_editar = '
		<h1 id="subtitulo">Formulario de Edición</h1>
		<div class="formulario">
			Se esta editando el registro de fecha '.$_GET['fecha'].'
			<form  id="fomulario" method="POST" action="scripts/editar_registro.php">
				<input id="desde" type="hidden" name="desde">
				<input id="hasta" type="hidden" name="hasta">
				<input id="codigo1" type="hidden" name="codigo1">
				<input id="codigo2" type="hidden" name="codigo2">
				<input id="dni" type="hidden" name = "dni">
				<input id="fecha" type="hidden" name = "fecha">
				<label  for="hora_llegada">Hora de llegada : </label>
				<input  id="hora_llegada" type="text" name="hora_llegada">
				<label  for="suspende">Hora de almuerzo : </label>
				<input  id="suspende" type="text" name="suspende">
				<label  for="regresar">Regreso de almuerzo : </label>
				<input  id="regresar" type="text" name="regresar">
				<label  for="hora_salida">Hora de salida : </label>
				<input  id="hora_salida" type="text" name="hora_salida">
				<br><label  for="motivo">Permisos : </label>
				<input  id="motivo" type="text" name="motivo" >
	  	        <br><button type="submit" class="btn btn-default">Guardar</button>
			</form>
		</div>';
		include('scripts/conexion2.php');
		//Se define la consulta
		$query = "CALL SP_Ver_Registro('{$_GET['dni']}','{$_GET['fecha']}','{$_GET['fecha']}') ";
		$resultado = mysqli_query($link,$query) or die("Error en: " . mysqli_error());
		while($fila = mysqli_fetch_assoc($resultado))
		{
			if ( $fila['suspende'] === $vacio ) 
			{
				$fila['suspende'] = "";
			}
			if ( $fila['regresar'] === $vacio)
			{
				$fila['regresar'] = "";
			}
			if ( $fila['codigo2'] === $vacio)
			{
				$fila['codigo2'] = "";
			}
			echo "<script type='text/javascript'>var desde = '".$desde."';</script>";
			echo "<script type='text/javascript'>var hasta = '".$hasta."';</script>";
			echo "<script type='text/javascript'>var dni = '".$_GET['dni']."';</script>";
			echo "<script type='text/javascript'>var fecha = '".$_GET['fecha']."';</script>";
			echo "<script type='text/javascript'>var codigo1 =  ".$fila['codigo1'].";</script>";
			echo "<script type='text/javascript'>var codigo2 = '".$fila['codigo2']."';</script>";
			echo "<script type='text/javascript'>var hora_llegada = '".$fila['hora_llegada']."';</script>";
			echo "<script type='text/javascript'>var suspende = '".$fila['suspende']."';</script>";
			echo "<script type='text/javascript'>var regresar = '".$fila['regresar']."';</script>";
			echo "<script type='text/javascript'>var hora_salida =  '".$fila['hora_salida']."';</script>";
			echo "<script type='text/javascript'>var motivo = '".$fila['motivo']."';</script>";
		}
		mysqli_close($link);
	}
?>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Resultados</title>
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
		<style>
			h1{
				text-align: center;	
			}
			.formulario{
				width : 100%;
				margin:  auto;
			}
		</style>
	<script type="text/javascript">
			$(document).ready(function()
			{
				$('#desde').val(desde);
				$('#hasta').val(hasta);
				$('#dni').val(dni);
				$('#fecha').val(fecha);
				$('#codigo1').val(codigo1);
				$('#codigo2').val(codigo2);
				$('#hora_llegada').val(hora_llegada);
				$('#suspende').val(suspende);
				$('#regresar').val(regresar);
				$('#hora_salida').val(hora_salida);
				$('#motivo').val(motivo);
			});
	</script>
	<!--EJEMPLO DE FORMULARIO
		<h1 id="subtitulo">Formulario de Edición</h1>
		<div class="formulario">
		Se esta editando el registro de fecha '.$_GET['fecha'].'
		<form id="fomulario" method="POST" action="scripts/editar_registro.php">
			<input id="desde" type="hidden" name="desde">
			<input id="hasta" type="hidden" name="hasta">
			<input id="codigo1" type="hidden" name="codigo1">
			<input id="codigo2" type="hidden" name="codigo2">
			<input id="dni" type="hidden" name = "dni">
			<input id="fecha" type="hidden" name = "fecha">
			<div class="form-group">
				<label class="col-lg-2 control-label" for="hora_llegada">Hora de llegada : </label>
				<div class="col-lg-10">
				<input class="form-control" id="hora_llegada" type="time" name="hora_llegada">
				</div>
			</div>
			<div class="form-group">
				<label class="col-lg-2 control-label" for="suspende">Hora de almuerzo : </label>
				<div class="col-lg-10">
				<input class="form-control" id="suspende" type="time" name="suspende">
				</div>
			</div>
			<div class="form-group">
				<label class="col-lg-2 control-label" for="regresar">Regreso de almuerzo : </label>
				<div class="col-lg-10">
				<input class="form-control" id="regresar" type="time" name="regresar">
				</div>
			</div>
			<div class="form-group">
				<label class="col-lg-2 control-label" for="hora_salida">Hora de salida : </label>
				<div class="col-lg-10">
				<input class="form-control" id="hora_salida" type="time" name="hora_salida">
				</div>
			</div>
			<div class="form-group">
				<label class="col-lg-2 control-label" for="motivo">Permisos : </label>
				<div class="col-lg-10">
				<input class="form-control" id="motivo" type="text" name="motivo" >
				</div>
			</div>
			  <div class="form-group">
			    <div class="col-lg-offset-2 col-lg-10">
			      <button type="submit" class="btn btn-default">Guardar</button>
			    </div>
			  </div>
		</form>
		</div>
		-->

	<?php echo $form_editar;?>
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
	
	<b>Visualizar registros de asistencia en un documento PDF : </b>
	<!--<input type="button" onclick="location.href='reporte.php?<?php echo"dni={$dni}&desde={$desde}&hasta={$hasta}" ?>' " value="Generar Reporte" /> -->
	<a target="_blank" href='reporte.php?<?php echo"dni={$dni}&desde={$desde}&hasta={$hasta}" ?>'>Generar Reporte</a>
	<br/>
	<br/>
	<b>Volver atras: </b>
	<input class="btn btn-warning" type="button" onclick=" location.href='editar.php' " value="Nueva Busqueda" /> 
	</section>
</body>
</html>
	

