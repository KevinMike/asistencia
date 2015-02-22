<?php
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
		
		//echo "variables intermedias con datos";
		if ( $salida > $regreso && $regreso > $suspender && $suspender > $llegada)
		{
			if ($cod_horario > 0) {
				include('conexion.php');
				$query = "call SP_Ingresar_Horario({$cod_horario},'{$llegada}','{$suspender}','{$regreso}','{$salida}')";
				echo $query;
				mysql_query($query)  or die("Error : ".mysql_error());
				mysql_close();
				header('Location:../horario.php');
			}
			else
			{
				include('conexion.php');
				$query = "call SP_Ingresar_Horario(0,'{$llegada}','{$suspender}','{$regreso}','{$salida}')";
				echo $query;
				mysql_query($query)  or die("Error : ".mysql_error());
				mysql_close();
				header('Location:../horario.php');
			}
		}
		else{
			echo '<script language="javascript">alert("ERROR AL LLENAR LOS DATOS"); javascript:window.history.back();</script>';
		}
	}
	else
	{
		//echo "variables intermedias sin datos";
		if ((empty($suspender) && empty($regreso)) && $salida > $llegada) {
			if ($cod_horario > 0) {
				include('conexion.php');
				$query = "call SP_Ingresar_Horario({$cod_horario},'{$llegada}',null,null,'{$salida}')";	
				echo $query;
				mysql_query($query) or die("Error : ".mysql_error());
				mysql_close();
				header('Location:../horario.php');
			}
			else
			{
				include('conexion.php');
				$query = "call SP_Ingresar_Horario(0,'{$llegada}',null,null,'{$salida}')";	
				echo $query;
				mysql_query($query) or die("Error : ".mysql_error());
				mysql_close();
				header('Location:../horario.php');
			}
		}
		else
		{
			echo '<script language="javascript">alert("ERROR AL LLENAR LOS DATOS"); javascript:window.history.back();;</script>';
		}
	}
?>