<?php
	include('conexion.php');
	$dni = $_POST['dni'];
	$password = $_POST['password'];
	$resultado1 = mysql_query("select dni,password from personal where dni = '{$dni}'");
	while ($fila = mysql_fetch_array($resultado1)) {
		$pass = $fila['password'];
		$doc = $fila['dni'];
	}
	$resultado2 = mysql_query("select * from asignacion where dni = '{$dni}'");
	while ($reglon = mysql_fetch_array($resultado2) ) {
		$Sunday = $reglon['Sunday'];
		$Monday = $reglon['Monday'];
		$Tuesday = $reglon['Tuesday'];
		$Wednesday = $reglon['Wednesday'];
		$Thursday = $reglon['Thursday'];
		$Friday = $reglon['Friday'];
		$Saturday = $reglon['Saturday'];
	}
	if ($password === $pass and $dni===$doc ) {
		$dia = date('l');
		$resultado3 = mysql_query("select ".$dia." from asignacion  where personal_dni = '{$dni}'");
		$variable = mysql_fetch_array($resultado3);
		if ($variable[$dia]) {
			$query = "CALL SP_IngresarDNI('{$dni}')";
			$resultado = mysql_query($query,$enlace);
			if (!$resultado) {
				die("No se pudo registrar : ".mysql_error());
			}
			mysql_close();
			echo '<script language="javascript">alert("REGISTRO EXITOSO");location.href="../index.php";</script>';		
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