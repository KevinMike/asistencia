<?php
	session_start();
	if ($_SESSION['login'] != true) {
	 	header("Location:index.php");
	 } 
	include('scripts/conexion.php');
	//Verificar si existe un parametro php
	$vacio = 'No tiene';
	if ( !empty($_GET['dni']) ) 
	{
		$desde = $_GET['desde'];
		$hasta = $_GET['hasta'];
		$dni = $_GET['dni'];
		//$query = "call SP_Ver_Registro('{$dni}',STR_TO_DATE('{$desde}','%d-%m-%Y'),STR_TO_DATE('{$hasta}','%d-%m-%Y'))";
		$query = "call SP_Ver_Registro2('{$dni}','{$desde}','{$hasta}')";
		$resultado = mysql_query($query) or die("Error en SP_Ver_Registro2".mysql_error());
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
			if (empty($fila['codigo1'])) {
				$opciones .= "<td><a href='scripts/aumentar_registro.php?editar=1&fecha={$fila['fecha']}&dni={$dni}'>Añadir Registro</a></td>";
				$opciones .= "<td><b>No existe asistencia</b></td></tr>";

			}
			else
			{
				$opciones .= "<td><a href='resultado_editar.php?editar=1&fecha={$fila['fecha']}&dni={$dni}&desde={$desde}&hasta={$hasta}'>Editar</a></td>";
				$opciones .= "<td><a href='scripts/eliminar_registro.php?codigo1=".$fila['codigo1']."&codigo2=".$fila['codigo2']."&cod_permiso={$fila['cod_permiso']}'>Eliminar</a></td></tr>";
			}
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
		$date = strtotime($_GET['fecha']); 
		$new_date = date('d-m-Y', $date);
		$form_editar = '
		<div class="formulario">
			<h4>Formulario de Edición</h4>
			Se esta editando el registro de fecha '.$new_date.'
			<form  id="formulario" method="POST" action="scripts/editar_registro.php">
				<input id="desde" type="hidden" name="desde">
				<input id="hasta" type="hidden" name="hasta">
				<input id="codigo1" type="hidden" name="codigo1">
				<input id="codigo2" type="hidden" name="codigo2">
				<input id="dni" type="hidden" name = "dni">
				<input id="fecha" type="hidden" name = "fecha">
				<table>
					<tr>
						<td><label  for="hora_llegada">Hora de llegada : </label></td>
						<td><input  id="hora_llegada" type="text" name="hora_llegada"></td>
						<td><label  for="suspende">Hora de almuerzo : </label></td>
						<td><input  id="suspende" type="text" name="suspende"></td>
						<td><label  for="regresar">Regreso de almuerzo : </label></td>
						<td><input  id="regresar" type="text" name="regresar"></td>
					</tr>
					<tr>
						<td><label  for="hora_salida">Hora de salida : </label></td>
						<td><input  id="hora_salida" type="text" name="hora_salida"></td>
						<td><label  for="motivo">Permisos : </label></td>
						<td><input  id="motivo" type="text" name="motivo" ></td>
					</tr>
				</table>
	  	        <button id="submit"type="submit" class="btn btn-info">Guardar</button>
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
				<li><a href="scripts/cerrar_sesion.php">Cerrar Sesion</a></li>
			</nav>
		</div>
	</header>
	<section>
		<style>
			section{
				margin: 1em;
			}
			.formulario > h4{
				text-align: center;
			}
			.formulario{
				background-color: #C1E946;
				border: 2px dashed black;
				width : 95%;
				margin:  0.5em auto;
				padding: 1em;
			}
			#formulario > table{
				width: 100%
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
		<div class="adicionar">
			<h4>Añadir Entrada</h4>
			<b>Importante : </b>
			<br>
			<p>Por medio de este formulario se puede añadir una entrada que por defecto marcara las 00:00 horas, es importante saber que si se desea añadir una entrada, primero debe cerrar alguna otra anterior que haya quedado sin alguna salida marcada.</p>
			<br>
				<form action="scripts/registrar_2do_registro.php" method="POST">
					<input type="hidden" name="reg_dni" value="<?php echo $dni;?>">
					<label for="reg_fecha">Fecha del Registro : </label>
					<input type="date" name="reg_fecha" ><br><br>
					<input class="btn btn-primary"type="submit" value="Añadir Registro">
				</form>
		</div>		
		<style>
			.adicionar{
				background-color: #C1E946;
				border: 2px dashed black;
				padding: 1em;
				margin: auto;
				width: 50%;
			}
			.adicionar > form{
				text-align: center;
			}
		</style>
		<br>
		<br>
		<b>Visualizar registros de asistencia en un documento PDF : </b>
		<a target="_blank" href='reporte.php?<?php echo"dni={$dni}&desde={$desde}&hasta={$hasta}" ?>'>Generar Reporte</a>
		<br>
		<br>
		<b>Volver atras: </b>
		<input class="btn btn-warning" type="button" onclick=" location.href='editar.php' " value="Nueva Busqueda" /> 
		<br>
		<br>
	</section>
</body>
</html>
	

