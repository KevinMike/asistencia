<?php
	include("scripts/conexion.php");
	//Imprimir los valores de la tabla empleados
	$resultado = mysql_query('CALL SP_Empleados_Presentes()',$enlace);
	if(!$resultado)
	{
		die('No se pudo realizar la consulta : '.mysql_error());
	}
	$opciones2 = "";
	while ($fila = mysql_fetch_array($resultado)) 
	{
		$opciones2 .= '<tr><td>'.$fila['personal_dni'].'</td><td>';
		$opciones2 .= $fila['hora_llegada'].'</td><td>';
		$opciones2 .= $fila['hora_salida'].'</td></tr>';
	}
	mysql_close();
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Empleados Presentes</title>
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<link href="css/starter-template.css" rel="stylesheet">

</head>
<body>
	<h2>Empleados Presentes</h2>
	<table class="table table-striped">
		<tr >
			<th>DNI</th>
			<th>Hora de llegada</th>
			<th>Hora de salida</th>
		</tr>
			<?php echo $opciones2; ?>
	</table>
</body>
</html>