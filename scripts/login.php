<?php
	include('conexion.php');
	//recibir parametros
	$usuario = $_POST['user'];
	$password = $_POST['password'];
	$query = "select usuario,password from usuario where usuario = '{$usuario}'";
	$resultado = mysql_query($query);
	$fila = mysql_fetch_array($resultado);
	if ($usuario === $fila['usuario'] && $password === $fila['password']) 
	{
		session_start();
		$_SESSION['login'] = true;
		header("Location:../panel.php");
	}
	else
	{
		header("Location:../index.php");
	}
?>	