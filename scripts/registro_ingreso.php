<?php
	include('conexion.php');
	//Recibinedo parametros
	$dni = $_POST['dni'];
	$password = $_POST['password'];
	//Solicitando datos dni y contraseña
	$resultado1 = mysql_query("select dni,password from personal where dni = '{$dni}'");
	while ($fila = mysql_fetch_array($resultado1)) {
		$pass = $fila['password'];
		$doc = $fila['dni'];
	}
	mysql_free_result($resultado1);
	//Recogiendo frecuencia horaria
	$resultado2 = mysql_query("select * from asignacion where personal_dni = '{$dni}'",$enlace) or die("Error en: " . mysql_error());
	while ($reglon = mysql_fetch_array($resultado2)) {
		$Sunday = $reglon['Sunday'];
		$Monday = $reglon['Monday'];
		$Tuesday = $reglon['Tuesday'];
		$Wednesday = $reglon['Wednesday'];
		$Thursday = $reglon['Thursday'];
		$Friday = $reglon['Friday'];
		$Saturday = $reglon['Saturday'];
	}
	mysql_free_result($resultado2);
	//Verificando la consistencia de los datos
	if ($password === $pass and $dni===$doc ) 
	{
			$dia = date('l');
			$resultado3 = mysql_query("select ".$dia." from asignacion  where personal_dni = '{$dni}'");
			$variable = mysql_fetch_array($resultado3);
			mysql_free_result($resultado3);
			if ($variable[$dia]) 
			{
				$resultado4 = mysql_query("CALL SP_cantidad_registros('{$dni}')",$enlace) or die("Error en: $busqueda: " . mysql_error());
				$var = mysql_fetch_array($resultado4);
				mysql_close();
				if($var['num'] == 1) 
				{
					include('conexion2.php');
					$query = "call SP_puntualidad('{$dni}')";
					$resultado5 = mysqli_query($link,$query);
					if (!$resultado5) {
						die("No se pudo registrar : ".mysqli_error($link));
					}
					$fila = mysqli_fetch_array($resultado5);
					switch ($fila['num'])
					{
						case '1':
							$query = "CALL SP_IngresarDNI('{$dni}')";
							//$resultado = mysqli_query($link,$query);
							if (!$mysqli->multi_query($query)) {
							    echo "Multi query failed: (" . $mysqli->errno . ") " . $mysqli->error;
							}
							/*if (!$resultado) {
								die("No se pudo registrar : ".mysqli_error($link));
							}*/
							mysqli_close($link);
							echo '<script language="javascript">alert("REGISTRO EXITOSO");location.href="../index.php";</script>';
							break;
						case '2':
							mysqli_close($link);
							echo '<script language="javascript">alert("NO SE PUDO REGISTRAR SU ASISTENCIA, SU HORA DE ENTRADA ES '.$fila['llegada'].'");location.href="../index.php";</script>';
							break;
						case '3':
							mysqli_close($link);
							echo '<script language="javascript">alert("NO PUEDE SALIR ANTES DE LAS '.$fila['salida'].'");location.href="../index.php";</script>';
							break;
					}
				}
				else
				{
						echo '<script language="javascript">alert("USTED YA COMPLETO SU HORARIO DE TRABAJO POR HOY");location.href="../index.php";</script>';		
				}
			}
			else
			{
				echo '<script language="javascript">alert("SE ENCUENTRA FUERA DE SU HORARIO DE TRABAJO");location.href="../index.php";</script>';		
			}
	}
	else
	{
		echo '<script language="javascript">alert("ERROR, Vulelva a intentarlo");javascript:window.history.back();</script>';
	}
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<script src="..\js\smoke.js-master\smoke.js"></script>
	<script src="..\js\smoke.js-master\smoke.min.js"></script>
</head>
<body>
	
</body>
</html>