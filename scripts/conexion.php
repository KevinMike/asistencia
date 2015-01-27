<?php
	$enlace = mysql_connect('127.0.0.1:3306','root');
	if(!$enlace)
	{
		die('Error en la conexion : '.mysql_error());
	}
	mysql_select_db('control_asistencia',$enlace);
?>