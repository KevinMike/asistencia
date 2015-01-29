<?php
	include('conexion.php');
	$dni = $_POST['dni'];
	$password = $_POST['password'];
	$resultado1 = mysql_query("select dni,password from personal where dni = '{$dni}'");
	while ($fila = mysql_fetch_array($resultado1)) {
		$pass = $fila['password'];
		$doc = $fila['dni'];
	}
	//echo "db: ".$pass." - ".$doc;
	if ($password === $pass and $dni===$doc) {
		$query = "CALL SP_IngresarDNI('{$dni}')";
		//echo $query;
		$resultado = mysql_query($query,$enlace);
		if (!$resultado) {
			die("No se pudo registrar : ".mysql_error());
		}
		mysql_close();
		//header('Location:../asistencia.php');
		echo '<script language="javascript">alert("REGISTRO EXITOSO");location.href="../index.php";</script>';
	}
	else
	{
		echo '<script language="javascript">alert("ERROR, Vulelva a intentarlo");javascript:window.history.back();</script>';
		//sleep(5);
		//header('Location:../asistencia.php');
	}
?>