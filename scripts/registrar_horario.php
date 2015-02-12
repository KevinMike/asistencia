<?php
	include('conexion.php');
	//Declarar variables como string
	$llegada = "";
	$suspender = "";
	$regreso = "";
	$salida = "";
	//Recibiendo parametros del formulario
	$cod_horario = $_POST['variable'];
	$llegada = $_REQUEST['hora_ingreso'];
	$suspender = $_REQUEST['suspende'];
	$regreso = $_REQUEST['regresar'];
	$salida = $_REQUEST['hora_salida'];
	$query ="";
	if (!empty($suspender) && !empty($regreso) )
	{
		echo "variables intermedias con datos";
		if ( $salida > $regreso && $regreso > $suspender && $suspender > $llegada)
		{
			$query = "call SP_Ingresar_Horario({$cod_horario},'{$llegada}','{$suspender}','{$regreso}','{$salida}')";
				mysql_query($query);
				mysql_close();
				header('Location:../horario.php');
		}
		else{
			echo '<script language="javascript">alert("ERROR AL LLENAR LOS DATOS"); javascript:window.history.back();</script>';
		}
	}
	else
	{
		echo "variables intermedias sin datos";
		if ((empty($suspender) && empty($regreso)) && $salida > $llegada) {
				$query = "call SP_Ingresar_Horario(0,'{$llegada}',null,null,'{$salida}')";	
				mysql_query($query);
				mysql_close();
				header('Location:../horario.php');
		}
		else
		{
			echo '<script language="javascript">alert("ERROR AL LLENAR LOS DATOS"); javascript:window.history.back();;</script>';
		}
	}
?>