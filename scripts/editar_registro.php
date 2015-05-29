<?php
	//Recibiendo Parametros
	$dni =  $_POST['dni'];
	$fecha = $_POST['fecha'];
	$codigo1 =  $_POST['codigo1'];
	$codigo2 = $_POST['codigo2'];
	$hora_llegada = $_POST['hora_llegada'];
	$suspende = $_POST['suspende'];
	$regresar = $_POST['regresar'];
	$hora_salida = $_POST['hora_salida'];
	$motivo = $_POST['motivo'];
	$desde = $_POST['desde'];
	$hasta = $_POST['hasta'];
	echo $codigo1." - ".$hora_llegada." - ".$suspende;
	echo "<br>";
	echo $codigo2." - ".$regresar." - ".$hora_salida;
	echo "<br>";
	//Verificar si es un horario con intermedio o sin intermedio
	if(empty($codigo2))
	{
		include('conexion.php');
		if(empty($hora_salida))
		{
			$estado = 1;
		}
		else
		{
			$estado = 0;
		}
		$query = "select if((select h.suspende from horario h inner join asignacion a on a.horario_cod_horario = h.cod_horario where a.personal_dni = '{$dni}') is not null,1,0) as bit";
		$result = mysql_query($query);
		$fila = mysql_fetch_array($result);
		/*if($fila['bit'] == '1')
		{
			echo "Tiene doble turno";
			$hora_salida = $suspende;
			if (!empty($suspende)) {
				$estado = 0;
			}
		}*/
		$query = "update registro set hora_llegada = '{$fecha} ".$hora_llegada."',hora_salida = '{$fecha} ".$hora_salida."',estado = {$estado} where cod_registro = ".$codigo1." ;";
		echo $query;
		mysql_query($query,$enlace) or die("Error en: " . mysql_error());
		$query = "call SP_registrar_permiso('{$motivo}','{$fecha}','{$dni}')";
		mysql_query($query,$enlace) or die("Error en: " . mysql_error());
		mysql_close();
	}
	else
	{
		include('conexion2.php');
		if (empty($suspende)) {
			$estado1 = 1;
		}
		else
		{
			$estado1 = 0;
		}
		if (empty($hora_salida)) {
			$estado2 = 1;
		}
		else
		{
			$estado2 = 0;
		}
		$query = "update registro set hora_llegada = '{$fecha} {$hora_llegada}',hora_salida = '{$fecha} {$suspende}',estado= {$estado1} where cod_registro = {$codigo1}; ";
		$query .= "update registro set hora_llegada = '{$fecha} {$regresar}',hora_salida = '{$fecha} {$hora_salida}', estado = {$estado2} where cod_registro = {$codigo2}; ";
		$query .= "call SP_registrar_permiso('{$motivo}','{$fecha}','{$dni}')";
		echo $query;
		if ($mysqli->multi_query($query)) {
		}
		else
		{
			echo "Se ha producido un error el procesar la edicion";
		}
		$mysqli->close();
	}
	header("Location:../resultado_editar.php?dni={$dni}&desde={$desde}&hasta={$hasta}");
?>
