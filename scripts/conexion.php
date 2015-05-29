<?php

	$enlace = mysql_connect('localhost','root','');

	if(!$enlace)

	{

		die('Error en la conexion : '.mysql_error());

	}

	mysql_select_db('asistencia',$enlace);
	//mysql_set_charset('utf8');
	//mysql_query("SET NAMES 'utf8'");

?>